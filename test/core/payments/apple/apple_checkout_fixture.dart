import 'dart:async';
import 'dart:convert';
import 'package:asteria_app/core/payments/api/apple_payments_api.dart';
import 'package:asteria_app/core/payments/apple/apple_models.dart';
import 'package:asteria_app/core/payments/apple/apple_purchase_coordinator.dart';
import 'package:asteria_app/core/payments/apple/apple_transactions.dart';
import 'package:asteria_app/core/payments/apple/apple_attempt_store.dart';
import 'package:asteria_app/core/payments/storage/pending_purchases_store.dart';

class AppleCheckoutFixture implements AppleTransactions, AppleLifecycleApi {
  final events = StreamController<AppleReceipt>.broadcast();
  final nativeResult = Completer<AppleNativePurchaseOutcome>();
  final journal = MemoryAppleJournal();
  final markers = MemoryAppleAttempts();
  final contexts = <Map<String, Object?>?>[];
  final finished = <String>[];
  String? purchasedToken, attemptId, productId;
  AppleReconciliation? reconciled;
  late final ApplePurchaseCoordinator coordinator;
  AppleCheckoutFixture({
    String uid = 'checkout-user',
    Map<String, Object?>? context,
  }) {
    coordinator = ApplePurchaseCoordinator(
      native: this,
      api: this,
      journal: journal,
      attempts: markers,
      currentIdentity: () => AppleIdentity(uid, 1),
      updates: events.stream,
      refreshEntitlements: (_, _) async {},
      analyticsContext: (_, _) async => context,
    );
    coordinator.listenForUpdates();
  }
  void deliver() {
    final payload = {
      'transactionId': 'exact',
      'originalTransactionId': 'chain',
      'productId': productId,
      'environment': 'Sandbox',
      'appAccountToken': purchasedToken,
    };
    events.add(
      AppleReceipt.fromJws(
        'h.${base64Url.encode(utf8.encode(jsonEncode(payload)))}.s',
      ),
    );
    nativeResult.complete(AppleNativePurchaseOutcome.success);
  }

  Future<void> dispose() async {
    coordinator.dispose();
    await events.close();
  }

  @override
  Future<List<AppleReceipt>> currentEntitlements() async => [];
  @override
  Future<List<AppleReceipt>> unfinished() async => [];
  @override
  Future<AppleNativePurchaseOutcome> purchase(String productId, String token) {
    this.productId = productId;
    purchasedToken = token;
    return nativeResult.future;
  }

  @override
  Future<AppleFinishOutcome> finish(String transactionId) async {
    finished.add(transactionId);
    return AppleFinishOutcome.finished;
  }

  @override
  Future<AppleCheckout> checkout({
    required String userId,
    required String attemptId,
    required String productId,
    Map<String, Object?>? analyticsContext,
  }) async {
    this.attemptId = attemptId;
    return AppleCheckout(
      attemptId: attemptId,
      appAccountToken: 'unique-server-token',
      action: AppleCheckoutAction.proceed,
    );
  }

  @override
  Future<AppleReconciliation> reconcile({
    required String userId,
    required String signedTransactionJws,
    required String productId,
    String? attemptId,
    Map<String, Object?>? analyticsContext,
  }) async {
    contexts.add(analyticsContext);
    return reconciled = AppleReconciliation(
      transactionId: 'exact',
      originalTransactionId: 'chain',
      environment: 'test',
      productId: productId,
      disposition: 'delivered',
      finishAllowed: true,
      finishState: 'pending',
      action: AppleCheckoutAction.proceed,
      entitlement: const AppleEntitlement(
        balance: 10,
        subscriptionType: 'free',
      ),
    );
  }

  @override
  Future<AppleAttemptStatus> attempt({
    required String userId,
    required String attemptId,
  }) async => AppleAttemptStatus(
    attemptId: attemptId,
    productId: productId!,
    result: reconciled,
  );
  @override
  Future<void> finishAck({
    required String userId,
    required String transactionId,
    required String environment,
  }) async {}
}

class MemoryAppleAttempts implements AppleAttemptStore {
  final values = <String, ApplePendingAttempt>{};
  @override
  List<ApplePendingAttempt> readAll() => values.values.toList();
  @override
  Future<void> save(ApplePendingAttempt a) async {
    values[a.id] = a;
  }

  @override
  Future<void> clear(ApplePendingAttempt a) async {
    values.remove(a.id);
  }
}

class MemoryAppleJournal extends PendingPurchasesStore {
  final values = <Object, PendingPurchaseEntry>{};
  PendingPurchase? saved;
  @override
  Future<void> init() async {}
  @override
  List<PendingPurchaseEntry> get entries => values.values.toList();
  @override
  Future<PendingPurchaseEntry> saveApple(
    PendingPurchase p, {
    required String environment,
    required String transactionId,
  }) async {
    saved = p;
    final e = PendingPurchaseEntry(
      '$environment:$transactionId',
      p,
      jsonEncode(p.toMap()),
    );
    values[e.key] = e;
    return e;
  }

  @override
  Future<bool> deleteObserved(PendingPurchaseEntry e) async {
    if (values[e.key]?.observedPayload != e.observedPayload) return false;
    values.remove(e.key);
    return true;
  }
}
