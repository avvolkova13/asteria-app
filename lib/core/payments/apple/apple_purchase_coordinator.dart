import 'dart:async';

import 'package:asteria_app/core/payments/api/apple_payments_api.dart';
import 'package:asteria_app/core/payments/apple/apple_attempt_store.dart';
import 'package:asteria_app/core/payments/apple/apple_models.dart';
import 'package:asteria_app/core/payments/apple/apple_transactions.dart';
import 'package:asteria_app/core/payments/catalog/product_catalog.dart';
import 'package:asteria_app/core/payments/models/payment_product.dart';
import 'package:asteria_app/core/payments/models/purchase_result.dart';
import 'package:asteria_app/core/payments/storage/pending_purchases_store.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

class AppleIdentity {
  final String? uid;
  final Object generation;
  const AppleIdentity(this.uid, this.generation);
  bool same(AppleIdentity other) =>
      uid == other.uid && generation == other.generation;
}

enum ApplePurchasePhase {
  idle,
  checking,
  purchasing,
  verifying,
  waiting,
  approval,
  canceled,
  accountAction,
  error,
  success,
  restored,
}

class ApplePurchaseState {
  final ApplePurchasePhase phase;
  final String? productId, errorCode;
  final AppleEntitlement? entitlement;
  final List<String> restoredProducts;
  const ApplePurchaseState(
    this.phase, {
    this.productId,
    this.errorCode,
    this.entitlement,
    this.restoredProducts = const [],
  });
  bool get isBusy =>
      phase == ApplePurchasePhase.checking ||
      phase == ApplePurchasePhase.purchasing ||
      phase == ApplePurchasePhase.verifying;
}

/// One application-scoped owner for every Apple lifecycle path.
/// Receipt processing is independent of native purchase invocation completion.
class ApplePurchaseCoordinator with WidgetsBindingObserver {
  final AppleTransactions native;
  final AppleLifecycleApi api;
  final PendingPurchasesStore journal;
  final AppleAttemptStore attempts;
  final AppleIdentity Function() currentIdentity;
  final Future<void> Function(AppleIdentity expected, bool Function() isCurrent)
  refreshEntitlements;
  final Stream<AppleReceipt> updates;
  final Listenable? identityChanges;
  final Future<Map<String, Object?>?> Function(String product, String uid)?
  analyticsContext;
  final Duration deadline;
  ApplePurchaseCoordinator({
    required this.native,
    required this.api,
    required this.journal,
    required this.attempts,
    required this.currentIdentity,
    required this.refreshEntitlements,
    required this.updates,
    this.identityChanges,
    this.analyticsContext,
    this.deadline = const Duration(seconds: 60),
  });

  final _states = StreamController<ApplePurchaseState>.broadcast(sync: true);
  ApplePurchaseState _state = const ApplePurchaseState(ApplePurchasePhase.idle);
  ApplePurchaseState get state => _state;
  Stream<ApplePurchaseState> get states => _states.stream;
  final Map<String, Future<AppleReconciliation?>> _processing = {};
  final Map<String, AppleReceipt> _unpersisted = {};
  final Set<String> _announcedAttempts = {};
  final Map<String, int> _receiptVersions = {};
  // Retain concurrent results only while a recovery barrier is observing them.
  // A paid stream event may finish and leave Hive before the snapshot returns.
  final Set<Map<String, _Observation>> _recoveryObservations = {};
  StreamSubscription<AppleReceipt>? _subscription;
  _CheckoutOperation? _operation;
  ApplePendingAttempt? _nativeInvocation;
  bool get nativeBusy => _nativeInvocation != null;
  bool _disposed = false;
  AppleIdentity? _lastIdentity;

  void listenForUpdates() {
    if (_subscription != null || _disposed) return;
    _lastIdentity = currentIdentity();
    _subscription = updates.listen(
      (receipt) {
        unawaited(accept(receipt).catchError((Object _) => null));
      },
      onError: (Object _) => _emit(
        const ApplePurchaseState(
          ApplePurchasePhase.error,
          errorCode: 'store_unavailable',
        ),
      ),
    );
    identityChanges?.addListener(_identityChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> start() async {
    listenForUpdates();
    await recover();
  }

  void _identityChanged() {
    final next = currentIdentity();
    if (_lastIdentity?.same(next) == true) return;
    _lastIdentity = next;
    _operation?.expired = true;
    _emit(const ApplePurchaseState(ApplePurchasePhase.idle));
    unawaited(recover());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(recover());
  }

  bool _current(AppleIdentity identity) =>
      !_disposed && identity.same(currentIdentity());
  void _emit(ApplePurchaseState state, [AppleIdentity? identity]) {
    if (_disposed || identity != null && !_current(identity)) return;
    _state = state;
    _states.add(state);
  }

  bool _related(String a, String b) =>
      a == b ||
      ProductCatalog.subscriptionIds.contains(a) &&
          ProductCatalog.subscriptionIds.contains(b);

  int _relatedReceiptVersion(String product) => _receiptVersions.entries
      .where((entry) => _related(entry.key, product))
      .fold(0, (total, entry) => total + entry.value);

  Future<void> purchase(PaymentProduct product) async {
    if (_operation != null && !_operation!.expired) return;
    final identity = currentIdentity();
    if (identity.uid == null) {
      _emit(
        ApplePurchaseState(
          ApplePurchasePhase.accountAction,
          productId: product.id,
          errorCode: 'sign_in',
        ),
      );
      return;
    }
    final op = _CheckoutOperation(identity, product.id);
    _operation = op;
    _emit(
      ApplePurchaseState(ApplePurchasePhase.checking, productId: product.id),
      identity,
    );
    // Starts before the first await, including analytics, storage and preflight.
    try {
      await _buy(op, product).timeout(deadline);
    } on TimeoutException {
      op.expired = true;
      _emit(
        ApplePurchaseState(
          nativeBusy ? ApplePurchasePhase.waiting : ApplePurchasePhase.error,
          productId: product.id,
          errorCode: 'timeout',
        ),
        identity,
      );
    } catch (error) {
      _emit(
        ApplePurchaseState(
          ApplePurchasePhase.error,
          productId: product.id,
          errorCode: _code(error),
        ),
        identity,
      );
    } finally {
      op.expired = true;
      if (identical(_operation, op)) {
        _operation = null;
        if (_state.isBusy) {
          _emit(
            _current(identity)
                ? ApplePurchaseState(
                    ApplePurchasePhase.waiting,
                    productId: product.id,
                  )
                : const ApplePurchaseState(ApplePurchasePhase.idle),
          );
        }
      }
    }
  }

  bool _canLaunch(_CheckoutOperation op) =>
      !op.expired && _current(op.identity);
  Future<void> _buy(_CheckoutOperation op, PaymentProduct product) async {
    final pendingAtStart = attempts
        .readAll()
        .where((m) => _related(m.productId, product.id))
        .toList();
    final nativeAtStart = nativeBusy;
    // Snapshot and journal barrier are required on every buy, including retries.
    final observations = await _recoverReceipts();
    final receiptVersion = _relatedReceiptVersion(product.id);
    if (!_canLaunch(op)) return;
    await _resolveAttempts(productId: product.id);
    if (!_canLaunch(op)) return;
    if (nativeBusy) {
      _emit(
        ApplePurchaseState(ApplePurchasePhase.waiting, productId: product.id),
        op.identity,
      );
      return;
    }
    for (final pending in attempts.readAll()) {
      if (_related(pending.productId, product.id)) {
        _emit(
          ApplePurchaseState(
            pending.approval
                ? ApplePurchasePhase.approval
                : ApplePurchasePhase.waiting,
            productId: product.id,
          ),
          op.identity,
        );
        return;
      }
    }
    if (pendingAtStart.isNotEmpty || nativeAtStart) {
      if (_state.isBusy) {
        _emit(
          ApplePurchaseState(ApplePurchasePhase.waiting, productId: product.id),
          op.identity,
        );
      }
      return;
    } // This click only recovers the existing operation.
    for (final observation in observations) {
      if (!_related(observation.productId, product.id)) continue;
      final response = observation.result;
      if (response == null || response.disposition == 'unresolved') {
        throw const AppleApiException('recovery_required');
      }
      if (observation.current &&
          response.action == AppleCheckoutAction.accountActionRequired) {
        _emit(
          ApplePurchaseState(
            ApplePurchasePhase.accountAction,
            productId: product.id,
          ),
          op.identity,
        );
        return;
      }
      if (!observation.current && !observation.finished) {
        throw const AppleApiException('finish_pending');
      }
    }
    if (product.type == ProductType.consumable &&
        observations.any(
          (o) =>
              o.productId == product.id &&
              !o.current &&
              o.result?.delivered == true,
        )) {
      _emit(
        ApplePurchaseState(ApplePurchasePhase.restored, productId: product.id),
        op.identity,
      );
      return;
    }
    // Analytics must never prevent or extend checkout.
    Map<String, Object?>? context;
    try {
      context = await analyticsContext
          ?.call(product.id, op.identity.uid!)
          .timeout(const Duration(seconds: 1));
    } catch (_) {}
    if (!_canLaunch(op)) return;
    final contextualAttempt = context?['attempt_id'];
    final attemptId =
        contextualAttempt is String &&
            RegExp(
              r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
            ).hasMatch(contextualAttempt)
        ? contextualAttempt
        : const Uuid().v4();
    context = {...?context, 'attempt_id': attemptId};
    final checkout = await api.checkout(
      userId: op.identity.uid!,
      attemptId: attemptId,
      productId: product.id,
      analyticsContext: context,
    );
    if (!_canLaunch(op)) return;
    if (checkout.attemptId != attemptId || checkout.appAccountToken.isEmpty) {
      throw const AppleApiException('invalid_checkout');
    }
    if (checkout.action != AppleCheckoutAction.proceed) {
      _emit(
        ApplePurchaseState(
          checkout.action == AppleCheckoutAction.retry
              ? ApplePurchasePhase.error
              : ApplePurchasePhase.accountAction,
          productId: product.id,
          errorCode: checkout.action.name,
        ),
        op.identity,
      );
      return;
    }
    if (_relatedReceiptVersion(product.id) != receiptVersion) {
      _emit(
        ApplePurchaseState(ApplePurchasePhase.waiting, productId: product.id),
        op.identity,
      );
      return;
    }
    final marker = ApplePendingAttempt(
      id: attemptId,
      uid: op.identity.uid!,
      productId: product.id,
      token: checkout.appAccountToken,
      analyticsContext: context,
    );
    await attempts.save(marker);
    if (!_canLaunch(op) ||
        _relatedReceiptVersion(product.id) != receiptVersion) {
      await attempts.clear(marker);
      return;
    } // Native definitely not invoked.
    _nativeInvocation = marker;
    _emit(
      ApplePurchaseState(ApplePurchasePhase.purchasing, productId: product.id),
      op.identity,
    );
    // This future alone releases the invocation lock. No stream event can do it.
    await _invoke(marker, op.identity);
  }

  Future<void> _invoke(
    ApplePendingAttempt marker,
    AppleIdentity identity,
  ) async {
    try {
      final outcome = await native.purchase(marker.productId, marker.token);
      if (_nativeInvocation?.id == marker.id) _nativeInvocation = null;
      if (outcome == AppleNativePurchaseOutcome.canceled) {
        await attempts.clear(marker);
        _emit(
          ApplePurchaseState(
            ApplePurchasePhase.canceled,
            productId: marker.productId,
          ),
          identity,
        );
      } else if (outcome == AppleNativePurchaseOutcome.pending) {
        // A receipt may have arrived first; never resurrect a cleared marker.
        if (attempts.readAll().any((a) => a.id == marker.id)) {
          await attempts.save(marker.withApproval());
        }
        _emit(
          ApplePurchaseState(
            ApplePurchasePhase.approval,
            productId: marker.productId,
          ),
          identity,
        );
      } else {
        await _recoverReceipts();
        await _resolveAttempts();
        if (attempts.readAll().any((a) => a.id == marker.id)) {
          _emit(
            ApplePurchaseState(
              ApplePurchasePhase.waiting,
              productId: marker.productId,
            ),
            identity,
          );
        }
      }
    } catch (error) {
      // Throw proves invocation ended, not that Apple cannot later deliver a charge.
      if (_nativeInvocation?.id == marker.id) _nativeInvocation = null;
      _emit(
        ApplePurchaseState(
          ApplePurchasePhase.waiting,
          productId: marker.productId,
          errorCode: _code(error),
        ),
        identity,
      );
    }
  }

  Future<AppleReconciliation?> accept(AppleReceipt receipt) {
    _receiptVersions.update(receipt.productId, (v) => v + 1, ifAbsent: () => 1);
    final key = receipt.jws;
    final identity = currentIdentity();
    final existing = _processing[key];
    if (existing != null) return existing;
    _unpersisted[key] = receipt;
    return _processing[key] ??= _accept(receipt)
        .then((response) {
          _observeRecovery(receipt, response);
          return response;
        })
        .catchError((Object error) {
          _observeRecovery(receipt, null);
          _emit(
            ApplePurchaseState(
              ApplePurchasePhase.error,
              productId: receipt.productId,
              errorCode: _code(error),
            ),
            identity,
          );
          throw error;
        })
        .whenComplete(() {
          _processing.remove(key);
        });
  }

  void _observeRecovery(AppleReceipt receipt, AppleReconciliation? result) {
    if (_recoveryObservations.isEmpty) return;
    final observation = _Observation(
      receipt.productId,
      result,
      false,
      !_unpersisted.containsKey(receipt.jws) &&
          !journal.entries.any(
            (e) => e.purchase.signedTransactionJws == receipt.jws,
          ),
    );
    for (final observations in _recoveryObservations) {
      observations[receipt.jws] = observation;
    }
  }

  Future<AppleReconciliation?> _accept(AppleReceipt receipt) async {
    ApplePendingAttempt? marker;
    try {
      marker = attempts
          .readAll()
          .where(
            (m) =>
                m.token.toLowerCase() ==
                    receipt.appAccountToken?.toLowerCase() &&
                m.productId == receipt.productId,
          )
          .firstOrNull;
    } catch (_) {}
    final entry = await journal.saveApple(
      PendingPurchase(
        originalTransactionId: receipt.originalTransactionId,
        productId: receipt.productId,
        signedTransactionJws: receipt.jws,
        userId: currentIdentity().uid ?? '',
        createdAt: DateTime.now(),
        analyticsContext: marker?.analyticsContext,
      ),
      environment: receipt.environment,
      transactionId: receipt.transactionId,
    );
    _unpersisted.remove(receipt.jws);
    return _process(entry, marker: marker);
  }

  Future<AppleReconciliation?> _process(
    PendingPurchaseEntry entry, {
    ApplePendingAttempt? marker,
  }) async {
    final identity = currentIdentity();
    if (identity.uid == null) return null;
    final purchase = entry.purchase;
    final response = await api.reconcile(
      userId: identity.uid!,
      signedTransactionJws: purchase.signedTransactionJws,
      productId: purchase.productId,
      attemptId: marker?.uid == identity.uid ? marker?.id : null,
      analyticsContext: purchase.analyticsContext,
    );
    if (!_current(identity)) return response;
    if (response.productId != purchase.productId) {
      throw const AppleApiException('product_mismatch');
    }
    if (response.finishAllowed) {
      var finished = response.finishState == 'finished';
      if (!finished) {
        final outcome = await native.finish(response.transactionId);
        if (!_current(identity)) return response;
        if (outcome != AppleFinishOutcome.notPresent) {
          await api.finishAck(
            userId: identity.uid!,
            transactionId: response.transactionId,
            environment: response.environment,
          );
          finished = true;
        }
      }
      if (finished && _current(identity)) await journal.deleteObserved(entry);
    }
    if (_current(identity)) {
      await refreshEntitlements(identity, () => _current(identity));
    }
    if (marker != null && _current(identity)) {
      await _resolveAttempt(marker, identity);
    }
    return response;
  }

  Future<void> _resolveAttempt(
    ApplePendingAttempt marker,
    AppleIdentity identity,
  ) async {
    if (marker.uid != identity.uid) return;
    final status = await api.attempt(
      userId: identity.uid!,
      attemptId: marker.id,
    );
    if (!_current(identity) ||
        status.attemptId != marker.id ||
        status.productId != marker.productId) {
      return;
    }
    final response = status.result;
    if (response == null ||
        (!response.delivered &&
            response.disposition != 'terminal_reconciled') ||
        response.action == AppleCheckoutAction.accountActionRequired) {
      return;
    }
    if (response.disposition == 'terminal_reconciled') {
      // Delivery is resolved, not a new purchase success. The independent native
      // invocation remains locked until its own future completes.
      await attempts.clear(marker);
      return;
    }
    if (_nativeInvocation?.id == marker.id) {
      _emit(
        ApplePurchaseState(
          ApplePurchasePhase.waiting,
          productId: marker.productId,
          entitlement: response.entitlement,
        ),
        identity,
      );
      return;
    }
    await attempts.clear(marker);
    if (_current(identity) && _announcedAttempts.add(marker.id)) {
      // Background delivery still finishes and refreshes entitlements, but an
      // unrelated approval cannot complete the purchase currently on screen.
      if (_nativeInvocation != null && _nativeInvocation!.id != marker.id ||
          _operation != null && _operation!.productId != marker.productId) {
        return;
      }
      _emit(
        ApplePurchaseState(
          ApplePurchasePhase.success,
          productId: marker.productId,
          entitlement: response.entitlement,
        ),
        identity,
      );
    }
  }

  Future<void> _resolveAttempts({String? productId}) async {
    final identity = currentIdentity();
    if (identity.uid == null) return;
    for (final marker in attempts.readAll()) {
      if (!_current(identity)) return;
      if (productId != null && !_related(marker.productId, productId)) continue;
      await _resolveAttempt(marker, identity);
    }
  }

  Future<List<_Observation>> _recoverReceipts() async {
    final concurrent = <String, _Observation>{};
    _recoveryObservations.add(concurrent);
    try {
      return await _collectReceipts(concurrent);
    } finally {
      _recoveryObservations.remove(concurrent);
    }
  }

  Future<List<_Observation>> _collectReceipts(
    Map<String, _Observation> concurrent,
  ) async {
    await journal.init();
    final observations = <_Observation>[];
    for (final receipt in _unpersisted.values.toList()) {
      try {
        await accept(receipt);
      } catch (_) {}
    }
    // Await the whole verified snapshot; an empty snapshot is distinct from error.
    final seen = <String>{};
    for (final entry in journal.entries) {
      if (entry.purchase.storeProvider != StoreProvider.apple) continue;
      seen.add(entry.purchase.signedTransactionJws);
      AppleReconciliation? response;
      try {
        response =
            await (_processing[entry.purchase.signedTransactionJws] ??
                _process(entry));
      } catch (_) {}
      observations.add(
        _Observation(
          entry.purchase.productId,
          response,
          false,
          !journal.entries.any((e) => e.key == entry.key),
        ),
      );
    }
    final current = await native.currentEntitlements();
    final unfinished = await native.unfinished();
    for (final receipt in [...current, ...unfinished]) {
      final isCurrent = current.any((r) => r.jws == receipt.jws);
      if (!seen.add(receipt.jws) && !isCurrent) continue;
      AppleReconciliation? response;
      try {
        response = await accept(receipt);
      } catch (_) {}
      observations.add(
        _Observation(
          receipt.productId,
          response,
          isCurrent,
          !journal.entries.any(
            (e) => e.purchase.signedTransactionJws == receipt.jws,
          ),
        ),
      );
    }
    // Drain updates accepted while recovery awaited network or storage.
    while (_processing.isNotEmpty) {
      final pending = _processing.values.toList();
      await Future.wait(pending.map((f) => f.catchError((Object _) => null)));
    }
    // Include receipts arriving during the barrier, including failed writes or
    // verification. Their SKU must not slip through into a duplicate purchase.
    for (final entry in journal.entries) {
      if (entry.purchase.storeProvider != StoreProvider.apple ||
          !seen.add(entry.purchase.signedTransactionJws)) {
        continue;
      }
      AppleReconciliation? response;
      try {
        response = await _process(entry);
      } catch (_) {}
      observations.add(
        _Observation(
          entry.purchase.productId,
          response,
          false,
          !journal.entries.any((e) => e.key == entry.key),
        ),
      );
    }
    for (final receipt in _unpersisted.values) {
      observations.add(_Observation(receipt.productId, null, false, false));
    }
    observations.addAll(
      concurrent.entries
          .where((e) => !seen.contains(e.key))
          .map((e) => e.value),
    );
    return observations;
  }

  Future<void> recover({bool restore = false}) async {
    final identity = currentIdentity();
    if (restore) {
      _emit(const ApplePurchaseState(ApplePurchasePhase.checking), identity);
    }
    try {
      await (() async {
        final observations = await _recoverReceipts();
        await _resolveAttempts();
        if (!restore || _state.phase == ApplePurchasePhase.success) return;
        if (observations.any(
          (o) => o.result == null || o.result?.disposition == 'unresolved',
        )) {
          throw AppleApiException(_state.errorCode ?? 'recovery_required');
        }
        if (observations.any(
          (o) =>
              o.current &&
              o.result?.action == AppleCheckoutAction.accountActionRequired,
        )) {
          _emit(
            const ApplePurchaseState(ApplePurchasePhase.accountAction),
            identity,
          );
          return;
        }
        final pending = attempts.readAll();
        if (pending.isNotEmpty || nativeBusy) {
          _emit(
            ApplePurchaseState(
              pending.any((a) => a.approval)
                  ? ApplePurchasePhase.approval
                  : ApplePurchasePhase.waiting,
            ),
            identity,
          );
          return;
        }
        _emit(
          ApplePurchaseState(
            ApplePurchasePhase.restored,
            restoredProducts: observations
                .where(
                  (o) =>
                      o.result?.delivered == true &&
                      o.result?.action !=
                          AppleCheckoutAction.accountActionRequired,
                )
                .map((o) => o.productId)
                .toSet()
                .toList(),
          ),
          identity,
        );
      })().timeout(deadline);
    } catch (error) {
      _emit(
        ApplePurchaseState(ApplePurchasePhase.error, errorCode: _code(error)),
        identity,
      );
    } finally {
      if (!_current(identity) && _state.isBusy) {
        _emit(const ApplePurchaseState(ApplePurchasePhase.idle));
      }
    }
  }

  String _code(Object error) =>
      error is AppleApiException ? error.code : 'recovery_required';
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _subscription?.cancel();
    identityChanges?.removeListener(_identityChanged);
    WidgetsBinding.instance.removeObserver(this);
    _states.close();
  }
}

class _CheckoutOperation {
  final AppleIdentity identity;
  final String productId;
  bool expired = false;
  _CheckoutOperation(this.identity, this.productId);
}

class _Observation {
  final String productId;
  final AppleReconciliation? result;
  final bool current, finished;
  _Observation(this.productId, this.result, this.current, this.finished);
}
