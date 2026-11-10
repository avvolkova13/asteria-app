import 'dart:async';
import 'dart:convert';

import 'package:asteria_app/core/payments/api/store_payments_api.dart';
import 'package:asteria_app/core/payments/catalog/product_catalog.dart';
import 'package:asteria_app/core/payments/gateway/store_kit_gateway.dart';
import 'package:asteria_app/core/payments/models/purchase_result.dart';
import 'package:asteria_app/core/payments/models/purchase_update.dart';
import 'package:asteria_app/core/payments/storage/pending_purchases_store.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';

/// Recovers Google purchases across process death, login and foregrounding.
/// The backend owns verification, delivery, acknowledgement and consumption.
class GooglePurchaseRecovery with WidgetsBindingObserver {
  GooglePurchaseRecovery({
    required Listenable identityChanges,
    required String? Function() currentUserId,
    required Stream<PurchaseUpdate> purchaseUpdates,
    required StorePaymentsApi paymentsApi,
    required PendingPurchasesStore pendingStore,
    required Future<void> Function() refreshEntitlements,
    Future<List<GooglePlayPurchaseDetails>> Function()? queryPurchases,
  }) : _identityChanges = identityChanges,
       _currentUserId = currentUserId,
       _purchaseUpdates = purchaseUpdates,
       _paymentsApi = paymentsApi,
       _pendingStore = pendingStore,
       _refreshEntitlements = refreshEntitlements,
       _queryPurchases = queryPurchases ?? _queryOwnedPurchases;

  final Listenable _identityChanges;
  final String? Function() _currentUserId;
  final Stream<PurchaseUpdate> _purchaseUpdates;
  final StorePaymentsApi _paymentsApi;
  final PendingPurchasesStore _pendingStore;
  final Future<void> Function() _refreshEntitlements;
  final Future<List<GooglePlayPurchaseDetails>> Function() _queryPurchases;
  final Map<String, Future<void>> _verifying = {};
  StreamSubscription<PurchaseUpdate>? _subscription;
  Future<void>? _recovering;
  String? _activeUserId;
  bool _started = false;
  bool _disposed = false;
  bool _recoverAgain = false;
  int _entitlementRefreshAttempts = 0;

  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    _activeUserId = _currentUserId();
    _identityChanges.addListener(_identityChanged);
    WidgetsBinding.instance.addObserver(this);
    _subscription = _purchaseUpdates.listen(
      (update) {
        if (update.result.storeProvider == StoreProvider.google) {
          unawaited(_handlePurchase(update.result));
        }
      },
      onError: (Object _) {
        debugPrint('[GooglePurchaseRecovery] purchase stream failed');
      },
    );
    await recover();
  }

  void _identityChanged() {
    final userId = _currentUserId();
    if (userId == _activeUserId) return;
    _activeUserId = userId;
    _recoverAgain = true;
    unawaited(recover());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(recover());
  }

  Future<void> recover() {
    if (_disposed) return Future.value();
    return _recovering ??= _recover().whenComplete(() => _recovering = null);
  }

  Future<void> _recover() async {
    do {
      _recoverAgain = false;
      final userId = _currentUserId();
      final seenTokens = <String>{};
      final refreshAttemptsAtStart = _entitlementRefreshAttempts;
      if (userId == null || userId.isEmpty || _disposed) return;
      // Replay first: the server may have consumed the token just before the
      // previous process died, so Play might no longer return that purchase.
      for (final entry in _pendingStore.getPending()) {
        if (entry.storeProvider == StoreProvider.google &&
            entry.userId == userId &&
            seenTokens.add(entry.signedTransactionJws)) {
          await _verify(entry);
        }
      }
      if (_currentUserId() != userId || _disposed) continue;
      try {
        final purchases = await _queryPurchases();
        if (_currentUserId() != userId || _disposed) continue;
        for (final raw in purchases) {
          if (!seenTokens.add(raw.verificationData.serverVerificationData)) {
            continue;
          }
          await _handlePurchase(
            PurchaseResult(
              productId: raw.productID,
              status:
                  raw.status == iap.PurchaseStatus.purchased ||
                      raw.status == iap.PurchaseStatus.restored
                  ? PurchaseStatus.success
                  : PurchaseStatus.pending,
              storeProvider: StoreProvider.google,
              originalTransactionId: raw.purchaseID,
              serverVerificationData:
                  raw.verificationData.serverVerificationData,
              rawPurchase: raw,
            ),
          );
        }
      } catch (_) {
        debugPrint('[GooglePurchaseRecovery] store query failed; will retry');
      }
      // A consumed purchase may already be absent from both Play and Hive.
      // Retry the account snapshot even when this pass has no token to verify.
      if (_entitlementRefreshAttempts == refreshAttemptsAtStart) {
        await _refreshCurrentUser(userId);
      }
    } while (_recoverAgain && !_disposed);
  }

  Future<void> _handlePurchase(PurchaseResult result) async {
    final userId = _currentUserId();
    final raw = result.rawPurchase;
    final token = result.verificationData;
    if (_disposed ||
        userId == null ||
        userId.isEmpty ||
        result.status != PurchaseStatus.success ||
        raw is! GooglePlayPurchaseDetails ||
        raw.billingClientPurchase.purchaseState !=
            PurchaseStateWrapper.purchased ||
        token == null ||
        token.isEmpty ||
        !ProductCatalog.allIds.contains(result.productId)) {
      return;
    }
    final accountId = raw.billingClientPurchase.obfuscatedAccountId;
    if (accountId == null) {
      // Play-center re-subscription can omit the current account identifier.
      // Only the server can recover ownership through the expired token; this
      // request never grants access locally without successful verification.
      if (!ProductCatalog.subscriptionIds.contains(result.productId)) return;
    } else if (accountId != googlePlayObfuscatedAccountId(userId)) {
      return;
    }
    PendingPurchase? existing;
    for (final entry in _pendingStore.getAll()) {
      if (entry.storeProvider == StoreProvider.google &&
          entry.userId == userId &&
          entry.signedTransactionJws == token &&
          entry.productId == result.productId) {
        existing = entry;
        break;
      }
    }
    if (existing?.failed ?? false) return;
    await _verify(
      existing ??
          PendingPurchase(
            originalTransactionId:
                'google:${sha256.convert(utf8.encode(token))}',
            productId: result.productId,
            signedTransactionJws: token,
            userId: userId,
            createdAt: DateTime.now(),
            storeProvider: StoreProvider.google,
          ),
    );
  }

  Future<void> _verify(PendingPurchase entry) {
    final key = '${entry.userId}:${entry.signedTransactionJws}';
    return _verifying[key] ??= _performVerify(entry).whenComplete(() {
      _verifying.remove(key);
    });
  }

  Future<void> _performVerify(PendingPurchase entry) async {
    try {
      if (_disposed || _currentUserId() != entry.userId) return;
      await _pendingStore.save(entry);
      if (_disposed || _currentUserId() != entry.userId) return;
      await _paymentsApi.verify(
        userId: entry.userId,
        verificationData: entry.signedTransactionJws,
        productId: entry.productId,
        analyticsContext: entry.analyticsContext,
      );
      await _pendingStore.delete(entry.originalTransactionId);
      await _refreshCurrentUser(entry.userId);
    } on StoreVerifyInvalidPurchaseException {
      await _pendingStore.markFailed(entry.originalTransactionId);
    } on StoreVerifyBadRequestException {
      await _pendingStore.markFailed(entry.originalTransactionId);
    } catch (_) {
      debugPrint('[GooglePurchaseRecovery] verification deferred');
    }
  }

  Future<void> _refreshCurrentUser(String userId) async {
    if (_disposed || _currentUserId() != userId) return;
    _entitlementRefreshAttempts++;
    try {
      // Fetch current server state without applying an old UID's verify result.
      await _refreshEntitlements();
    } catch (_) {
      debugPrint('[GooglePurchaseRecovery] entitlement refresh deferred');
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _identityChanges.removeListener(_identityChanged);
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
  }

  static Future<List<GooglePlayPurchaseDetails>> _queryOwnedPurchases() async {
    final addition = iap.InAppPurchase.instance
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final response = await addition.queryPastPurchases();
    if (response.error != null) {
      throw const StoreVerifyServerException('Google purchase query failed');
    }
    return response.pastPurchases;
  }
}
