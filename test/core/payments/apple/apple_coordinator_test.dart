import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:asteria_app/core/payments/apple/apple_purchase_coordinator.dart';
import 'package:asteria_app/core/payments/apple/apple_models.dart';
import 'package:asteria_app/core/payments/apple/apple_transactions.dart';
import 'package:asteria_app/core/payments/apple/apple_attempt_store.dart';
import 'package:asteria_app/core/payments/api/apple_payments_api.dart';
import 'package:asteria_app/core/payments/models/payment_product.dart';
import 'package:asteria_app/core/payments/storage/pending_purchases_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

const sku = 'asteria_stars_10';
const subscription = 'asteria_pro_month';
PaymentProduct product([String id = sku]) => PaymentProduct(
  id: id,
  type: id == sku ? ProductType.consumable : ProductType.subscription,
  title: 'Test',
  description: '',
  localizedPrice: '1',
  rawPrice: 1,
  currencyCode: 'USD',
);
AppleReceipt receipt({
  String id = 'exact',
  String productId = sku,
  String token = 'unique-attempt-token',
}) {
  final payload = {
    'transactionId': id,
    'originalTransactionId': 'chain',
    'productId': productId,
    'environment': 'Sandbox',
    'appAccountToken': token,
  };
  return AppleReceipt.fromJws(
    'header.${base64Url.encode(utf8.encode(jsonEncode(payload)))}.signature',
  );
}

AppleReconciliation result(
  AppleReceipt receipt, {
  AppleCheckoutAction action = AppleCheckoutAction.proceed,
  String finish = 'pending',
}) => AppleReconciliation(
  transactionId: receipt.transactionId,
  originalTransactionId: receipt.originalTransactionId,
  environment: receipt.environment,
  productId: receipt.productId,
  disposition: 'delivered',
  finishAllowed: true,
  finishState: finish,
  action: action,
  entitlement: const AppleEntitlement(balance: 10, subscriptionType: 'free'),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late PendingPurchasesStore journal;
  late AppleAttemptStore attempts;
  late FakeNative native;
  late FakeApi api;
  late AppleIdentity identity;
  late ApplePurchaseCoordinator coordinator;
  late StreamController<AppleReceipt> updates;
  late int refreshes;
  setUp(() async {
    refreshes = 0;
    temp = await Directory.systemTemp.createTemp('apple-coordinator');
    Hive.init(temp.path);
    journal = PendingPurchasesStore();
    await journal.init();
    attempts = AppleAttemptStore(await Hive.openBox<Map>('settings'));
    native = FakeNative();
    api = FakeApi();
    identity = const AppleIdentity('A', 1);
    updates = StreamController.broadcast();
    coordinator = ApplePurchaseCoordinator(
      native: native,
      api: api,
      journal: journal,
      attempts: attempts,
      currentIdentity: () => identity,
      updates: updates.stream,
      refreshEntitlements: (expected, isCurrent) async {
        refreshes++;
      },
      deadline: const Duration(milliseconds: 400),
    );
    coordinator.listenForUpdates();
  });
  tearDown(() async {
    coordinator.dispose();
    await updates.close();
    await Hive.close();
    await temp.delete(recursive: true);
  });
  test(
    'paid stream completed during snapshot cannot buy same consumable again',
    () async {
      final entered = Completer<void>();
      final snapshot = Completer<List<AppleReceipt>>();
      native.snapshotCall = () {
        if (!entered.isCompleted) entered.complete();
        return snapshot.future;
      };
      final buying = coordinator.purchase(product());
      await entered.future;
      await coordinator.accept(receipt(token: 'historical-token'));
      expect(journal.entries, isEmpty);
      snapshot.complete([]);
      await buying;
      expect(native.purchases, 0);
      expect(coordinator.state.phase, ApplePurchasePhase.restored);
    },
  );
  test(
    'expired subscription stream during snapshot permits fresh subscription checkout',
    () async {
      final entered = Completer<void>();
      final snapshot = Completer<List<AppleReceipt>>();
      native.snapshotCall = () {
        if (!entered.isCompleted) entered.complete();
        return snapshot.future;
      };
      api.receiptResults['expired'] = const AppleReconciliation(
        transactionId: 'expired',
        originalTransactionId: 'chain',
        environment: 'test',
        productId: subscription,
        disposition: 'terminal_reconciled',
        finishAllowed: true,
        finishState: 'finished',
        action: AppleCheckoutAction.proceed,
        entitlement: AppleEntitlement(balance: 0, subscriptionType: 'free'),
      );
      final buying = coordinator.purchase(product(subscription));
      await entered.future;
      await coordinator.accept(
        receipt(
          id: 'expired',
          productId: subscription,
          token: 'historical-token',
        ),
      );
      snapshot.complete([]);
      await buying;
      expect(native.purchases, 1);
    },
  );
  test(
    'matching terminal result clears durable gate without purchase success',
    () async {
      await attempts.save(
        const ApplePendingAttempt(
          id: 'terminal',
          uid: 'A',
          productId: sku,
          token: 'token',
          approval: true,
        ),
      );
      api.results['terminal'] = terminalResult();
      final phases = <ApplePurchasePhase>[];
      final listener = coordinator.states.listen((s) => phases.add(s.phase));
      await coordinator.recover(restore: true);
      expect(attempts.readAll(), isEmpty);
      expect(phases, isNot(contains(ApplePurchasePhase.success)));
      await listener.cancel();
      await coordinator.purchase(product());
      expect(native.purchases, 1);
    },
  );
  test(
    'terminal result clears marker but cannot release outstanding invocation',
    () async {
      native.buy = Completer<AppleNativePurchaseOutcome>();
      final buying = coordinator.purchase(product());
      while (!coordinator.nativeBusy) {
        await Future<void>.delayed(Duration.zero);
      }
      final marker = attempts.readAll().single;
      api.results[marker.id] = terminalResult();
      await coordinator.recover(restore: true);
      expect(attempts.readAll(), isEmpty);
      expect(coordinator.nativeBusy, isTrue);
      expect(coordinator.state.phase, ApplePurchasePhase.waiting);
      native.buy!.complete(AppleNativePurchaseOutcome.canceled);
      await buying;
    },
  );
  test(
    'old approval delivers without replacing another native purchase UI',
    () async {
      await attempts.save(
        const ApplePendingAttempt(
          id: 'old-subscription',
          uid: 'A',
          productId: subscription,
          token: 'old-token',
          approval: true,
        ),
      );
      native.buy = Completer<AppleNativePurchaseOutcome>();
      final buying = coordinator.purchase(product());
      while (!coordinator.nativeBusy) {
        await Future<void>.delayed(Duration.zero);
      }
      final before = coordinator.state;
      final phases = <ApplePurchasePhase>[];
      final listener = coordinator.states.listen((s) => phases.add(s.phase));
      await coordinator.accept(
        receipt(
          id: 'old-approval',
          productId: subscription,
          token: 'old-token',
        ),
      );
      expect(native.finishes, ['old-approval']);
      expect(api.acks, 1);
      expect(refreshes, greaterThan(0));
      expect(
        attempts.readAll().any((m) => m.id == 'old-subscription'),
        isFalse,
      );
      expect(journal.entries, isEmpty);
      expect(coordinator.nativeBusy, isTrue);
      expect(attempts.readAll().single.productId, sku);
      expect(phases, isNot(contains(ApplePurchasePhase.success)));
      expect(coordinator.state, same(before));
      native.buy!.complete(AppleNativePurchaseOutcome.pending);
      await buying;
      expect(attempts.readAll().single.approval, isTrue);
      expect(native.purchases, 1);
      await listener.cancel();
    },
  );
  test(
    'old approval cannot complete unrelated checkout before native launch',
    () async {
      await attempts.save(
        const ApplePendingAttempt(
          id: 'old-subscription',
          uid: 'A',
          productId: subscription,
          token: 'old-token',
          approval: true,
        ),
      );
      api.checkoutWait = Completer<void>();
      final buying = coordinator.purchase(product());
      await api.checkoutEntered.future;
      final before = coordinator.state;
      await coordinator.accept(
        receipt(
          id: 'old-approval',
          productId: subscription,
          token: 'old-token',
        ),
      );
      expect(coordinator.state, same(before));
      expect(api.acks, 1);
      expect(refreshes, greaterThan(0));
      expect(attempts.readAll(), isEmpty);
      api.checkoutWait!.complete();
      await buying;
      expect(native.purchases, 1);
    },
  );
  test(
    'surviving delivered marker replays terminal receipt without success',
    () async {
      await attempts.save(
        const ApplePendingAttempt(
          id: 'delivered-before-exit',
          uid: 'A',
          productId: sku,
          token: 'token',
          approval: false,
        ),
      );
      native.unfinishedReceipts = [receipt(token: 'token')];
      api.receiptResults['exact'] = terminalResult();
      final phases = <ApplePurchasePhase>[];
      final listener = coordinator.states.listen((s) => phases.add(s.phase));
      await coordinator.recover(restore: true);
      expect(attempts.readAll(), isEmpty);
      expect(journal.entries, isEmpty);
      expect(api.reconciled, 1);
      expect(phases, isNot(contains(ApplePurchasePhase.success)));
      expect(native.purchases, 0);
      await listener.cancel();
    },
  );
  test('unrelated subscription attempt outage does not block Stars', () async {
    await attempts.save(
      const ApplePendingAttempt(
        id: 'unrelated',
        uid: 'A',
        productId: subscription,
        token: 'token',
        approval: true,
      ),
    );
    api.failedAttempts.add('unrelated');
    await coordinator.purchase(product());
    expect(native.purchases, 1);
    expect(attempts.readAll().any((a) => a.id == 'unrelated'), isTrue);
  });
  test('related attempt outage still blocks selected product', () async {
    await attempts.save(
      const ApplePendingAttempt(
        id: 'related',
        uid: 'A',
        productId: sku,
        token: 'token',
        approval: true,
      ),
    );
    api.failedAttempts.add('related');
    await coordinator.purchase(product());
    expect(native.purchases, 0);
    expect(coordinator.state.phase, ApplePurchasePhase.error);
  });
  test(
    'native future hangs: deadline stops spinner, receipt is processed, duplicate buy remains blocked',
    () async {
      native.buy = Completer<AppleNativePurchaseOutcome>();
      await coordinator.purchase(product());
      expect(coordinator.state.phase, ApplePurchasePhase.waiting);
      expect(native.purchases, 1);
      updates.add(receipt());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(api.reconciled, 1);
      expect(native.finishes, ['exact']);
      expect(coordinator.nativeBusy, isTrue);
      await coordinator.purchase(product());
      expect(native.purchases, 1);
      native.buy!.complete(AppleNativePurchaseOutcome.success);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(coordinator.nativeBusy, isFalse);
    },
  );
  test(
    'late recovery failure from old invocation cannot unlock a newer native invocation',
    () async {
      native.buy = Completer<AppleNativePurchaseOutcome>();
      await coordinator.purchase(product());
      await coordinator.accept(receipt());
      final oldRecovery = Completer<List<AppleReceipt>>();
      var snapshots = 0;
      native.snapshotCall = () =>
          snapshots++ == 0 ? oldRecovery.future : Future.value([]);
      native.buy!.complete(AppleNativePurchaseOutcome.success);
      while (snapshots == 0) {
        await Future<void>.delayed(Duration.zero);
      }
      await coordinator.recover();
      native.buy = Completer<AppleNativePurchaseOutcome>();
      final newer = coordinator.purchase(product());
      while (native.purchases < 2) {
        await Future<void>.delayed(Duration.zero);
      }
      oldRecovery.completeError(StateError('old lookup failed'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(coordinator.nativeBusy, isTrue);
      native.buy!.complete(AppleNativePurchaseOutcome.pending);
      await newer;
    },
  );
  test(
    'preflight waits for complete snapshot before native invocation',
    () async {
      native.snapshot = Completer<List<AppleReceipt>>();
      final buying = coordinator.purchase(product());
      await Future<void>.delayed(Duration.zero);
      expect(native.purchases, 0);
      native.snapshot!.complete([]);
      await buying;
      expect(native.purchases, 1);
    },
  );
  test(
    'deadline before checkout or snapshot completion never launches a late buy',
    () async {
      native.snapshot = Completer<List<AppleReceipt>>();
      await coordinator.purchase(product());
      expect(coordinator.state.isBusy, isFalse);
      native.snapshot!.complete([]);
      await Future<void>.delayed(Duration.zero);
      expect(native.purchases, 0);
    },
  );
  test(
    'foreign active subscription blocks subscription but independent Stars can buy',
    () async {
      native.current = [receipt(productId: subscription, token: 'foreign')];
      api.action = AppleCheckoutAction.accountActionRequired;
      await coordinator.purchase(product(subscription));
      expect(native.purchases, 0);
      expect(
        coordinator.state.phase,
        ApplePurchasePhase.accountAction,
        reason:
            '${coordinator.state.errorCode} calls=${api.reconciled} finish=${native.finishes} entries=${journal.entries.length}',
      );
      await coordinator.purchase(product());
      expect(native.purchases, 1);
    },
  );
  test('same SKU unfinished failure blocks a duplicate consumable', () async {
    native.unfinishedReceipts = [receipt()];
    api.fail = true;
    await coordinator.purchase(product());
    expect(native.purchases, 0);
    expect(coordinator.state.isBusy, isFalse);
  });
  test(
    'recovered paid consumable is not charged again by the recovery click',
    () async {
      native.unfinishedReceipts = [receipt()];
      await coordinator.purchase(product());
      expect(native.purchases, 0);
      expect(coordinator.state.phase, ApplePurchasePhase.restored);
    },
  );
  test(
    'resolving a durable approval marker checks status without another checkout',
    () async {
      native.outcome = AppleNativePurchaseOutcome.pending;
      await coordinator.purchase(product());
      final marker = attempts.readAll().single;
      api.results[marker.id] = result(receipt());
      await coordinator.purchase(product());
      expect(native.purchases, 1);
      expect(coordinator.state.phase, ApplePurchasePhase.success);
    },
  );
  test(
    'account switch with sole saved receipt verifies under current caller and exact finish',
    () async {
      await journal.save(
        PendingPurchase(
          originalTransactionId: 'old-chain',
          productId: sku,
          signedTransactionJws: receipt().jws,
          userId: 'A',
          createdAt: DateTime.utc(2026),
          failed: true,
        ),
      );
      identity = const AppleIdentity('B', 2);
      await coordinator.recover();
      expect(api.users, ['B']);
      expect(native.finishes, ['exact']);
      expect(journal.entries, isEmpty);
    },
  );
  test(
    'native finish error keeps receipt and recovery retries without buying',
    () async {
      native.failFinish = true;
      await expectLater(coordinator.accept(receipt()), throwsStateError);
      expect(journal.entries.length, 1);
      expect(api.acks, 0);
      native.failFinish = false;
      await coordinator.recover();
      expect(api.acks, 1);
      expect(journal.entries, isEmpty);
      expect(native.purchases, 0);
    },
  );
  test(
    'finish ack failure keeps journal until confirmed on a later retry',
    () async {
      api.failAck = true;
      await expectLater(
        coordinator.accept(receipt()),
        throwsA(isA<AppleApiException>()),
      );
      expect(journal.entries.length, 1);
      api.failAck = false;
      await coordinator.recover();
      expect(journal.entries, isEmpty);
    },
  );
  for (final stage in ['snapshot', 'unfinished', 'checkout', 'native']) {
    test(
      '$stage failure ends the spinner and cannot start an unguarded second buy',
      () async {
        native.failStage = stage;
        api.failCheckout = stage == 'checkout';
        await coordinator.purchase(product());
        expect(coordinator.state.isBusy, isFalse);
        expect(native.purchases, stage == 'native' ? 1 : 0);
        if (stage == 'native') {
          await coordinator.purchase(product());
          expect(native.purchases, 1);
        }
      },
    );
  }
  test(
    'a failed incoming same SKU update during preflight blocks native buy',
    () async {
      native.snapshot = Completer<List<AppleReceipt>>();
      api.fail = true;
      final buying = coordinator.purchase(product());
      updates.add(receipt());
      await api.entered.future;
      native.snapshot!.complete([]);
      await buying;
      expect(native.purchases, 0);
    },
  );
  test(
    'paid same SKU event during checkout prevents a duplicate invocation',
    () async {
      api.checkoutWait = Completer<void>();
      final buying = coordinator.purchase(product());
      await api.checkoutEntered.future;
      await coordinator.accept(receipt(token: 'old-token'));
      api.checkoutWait!.complete();
      await buying;
      expect(native.purchases, 0);
      expect(coordinator.state.isBusy, isFalse);
    },
  );
  test(
    'identity generation change during checkout prevents native invocation',
    () async {
      api.checkoutWait = Completer<void>();
      final buying = coordinator.purchase(product());
      await api.checkoutEntered.future;
      identity = const AppleIdentity('A', 2);
      api.checkoutWait!.complete();
      await buying;
      expect(native.purchases, 0);
      expect(attempts.readAll(), isEmpty);
      expect(coordinator.state.isBusy, isFalse);
    },
  );
  test(
    'explicit restore reports reconciled products rather than empty history',
    () async {
      native.current = [receipt(productId: subscription)];
      await coordinator.recover(restore: true);
      expect(coordinator.state.phase, ApplePurchasePhase.restored);
      expect(coordinator.state.restoredProducts, [subscription]);
    },
  );
  test(
    'explicit restore surfaces verification failure instead of empty success',
    () async {
      native.current = [receipt()];
      api.fail = true;
      await coordinator.recover(restore: true);
      expect(coordinator.state.phase, ApplePurchasePhase.error);
    },
  );
  test(
    'explicit restore surfaces foreign active ownership as account action',
    () async {
      native.current = [receipt(productId: subscription)];
      api.action = AppleCheckoutAction.accountActionRequired;
      await coordinator.recover(restore: true);
      expect(coordinator.state.phase, ApplePurchasePhase.accountAction);
    },
  );
  test(
    'logged out updates persist and old failed receipts replay for current identity',
    () async {
      identity = const AppleIdentity(null, 2);
      updates.add(receipt());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(journal.entries.length, 1);
      expect(api.reconciled, 0);
      await journal.markFailed('test:exact');
      identity = const AppleIdentity('B', 3);
      await coordinator.recover();
      expect(api.users, ['B']);
      expect(journal.entries, isEmpty);
    },
  );
  test(
    'not_present does not acknowledge or delete journal; server finished can clean up later',
    () async {
      native.finishOutcome = AppleFinishOutcome.notPresent;
      updates.add(receipt());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(api.acks, 0);
      expect(journal.entries.length, 1);
      api.serverFinished = true;
      await coordinator.recover();
      expect(journal.entries, isEmpty);
    },
  );
  test('historical same product stream never completes new attempt', () async {
    native.buy = Completer<AppleNativePurchaseOutcome>();
    final purchase = coordinator.purchase(product());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    updates.add(receipt(id: 'old', token: 'old-token'));
    await purchase;
    expect(coordinator.state.phase, ApplePurchasePhase.waiting);
    expect(attempts.readAll().length, 1);
  });
  test(
    'pending approval survives restart and empty StoreKit does not authorize rebuy',
    () async {
      native.outcome = AppleNativePurchaseOutcome.pending;
      await coordinator.purchase(product());
      expect(coordinator.state.phase, ApplePurchasePhase.approval);
      coordinator.dispose();
      coordinator = ApplePurchaseCoordinator(
        native: native,
        api: api,
        journal: journal,
        attempts: attempts,
        currentIdentity: () => identity,
        updates: updates.stream,
        refreshEntitlements: (_, _) async {},
      );
      await coordinator.purchase(product());
      expect(native.purchases, 1);
      expect(coordinator.state.phase, ApplePurchasePhase.approval);
    },
  );
  test(
    'marker write failure prevents native invocation and ends spinner',
    () async {
      coordinator.dispose();
      coordinator = ApplePurchaseCoordinator(
        native: native,
        api: api,
        journal: journal,
        attempts: FailingMarkerStore(Hive.box<Map>('settings')),
        currentIdentity: () => identity,
        updates: updates.stream,
        refreshEntitlements: (_, _) async {},
      );
      await coordinator.purchase(product());
      expect(native.purchases, 0);
      expect(coordinator.state.isBusy, isFalse);
    },
  );
  test(
    'journal write error during native checkout ends spinner but keeps native lock',
    () async {
      coordinator.dispose();
      native.buy = Completer<AppleNativePurchaseOutcome>();
      coordinator = ApplePurchaseCoordinator(
        native: native,
        api: api,
        journal: FailingJournalStore(),
        attempts: attempts,
        currentIdentity: () => identity,
        updates: updates.stream,
        refreshEntitlements: (_, _) async {},
        deadline: const Duration(milliseconds: 400),
      );
      final buying = coordinator.purchase(product());
      await api.checkoutEntered.future;
      while (!coordinator.nativeBusy) {
        await Future<void>.delayed(Duration.zero);
      }
      await expectLater(coordinator.accept(receipt()), throwsStateError);
      expect(coordinator.state.isBusy, isFalse);
      expect(coordinator.nativeBusy, isTrue);
      expect(api.reconciled, 0);
      native.buy!.complete(AppleNativePurchaseOutcome.pending);
      await buying;
    },
  );
  test(
    'storage failure before invocation stops spinner and prevents native buy',
    () async {
      await Hive.box<Map>('settings').close();
      await coordinator.purchase(product());
      expect(native.purchases, 0);
      expect(coordinator.state.isBusy, isFalse);
    },
  );
  test(
    'receipt verification cannot show success for another identity or generation',
    () async {
      api.wait = Completer<void>();
      final processing = coordinator.accept(receipt());
      await api.entered.future;
      identity = const AppleIdentity('B', 2);
      api.wait!.complete();
      await processing;
      expect(coordinator.state.phase, isNot(ApplePurchasePhase.success));
      expect(journal.entries.length, 1);
    },
  );
}

class FakeNative implements AppleTransactions {
  List<AppleReceipt> current = [], unfinishedReceipts = [];
  Completer<List<AppleReceipt>>? snapshot;
  Future<List<AppleReceipt>> Function()? snapshotCall;
  Completer<AppleNativePurchaseOutcome>? buy;
  AppleNativePurchaseOutcome outcome = AppleNativePurchaseOutcome.canceled;
  AppleFinishOutcome finishOutcome = AppleFinishOutcome.finished;
  bool failFinish = false;
  String? failStage;
  int purchases = 0;
  final finishes = <String>[];
  @override
  Future<List<AppleReceipt>> currentEntitlements() async {
    if (failStage == 'snapshot') throw StateError('snapshot');
    if (snapshotCall != null) return snapshotCall!();
    return snapshot == null ? current : await snapshot!.future;
  }

  @override
  Future<List<AppleReceipt>> unfinished() async {
    if (failStage == 'unfinished') throw StateError('unfinished');
    return unfinishedReceipts;
  }

  @override
  Future<AppleNativePurchaseOutcome> purchase(
    String productId,
    String token,
  ) async {
    purchases++;
    if (failStage == 'native') throw StateError('native');
    expect(token, 'unique-attempt-token');
    return buy == null ? outcome : await buy!.future;
  }

  @override
  Future<AppleFinishOutcome> finish(String id) async {
    finishes.add(id);
    if (failFinish) throw StateError('finish');
    return finishOutcome;
  }
}

class FakeApi implements AppleLifecycleApi {
  final entered = Completer<void>();
  int reconciled = 0, acks = 0;
  final users = <String>[];
  bool fail = false,
      serverFinished = false,
      failAck = false,
      failCheckout = false;
  Completer<void>? checkoutWait;
  final checkoutEntered = Completer<void>();
  Completer<void>? wait;
  AppleCheckoutAction action = AppleCheckoutAction.proceed;
  final results = <String, AppleReconciliation>{};
  final receiptResults = <String, AppleReconciliation>{};
  final failedAttempts = <String>{};
  @override
  Future<AppleCheckout> checkout({
    required String userId,
    required String attemptId,
    required String productId,
    Map<String, Object?>? analyticsContext,
  }) async {
    if (!checkoutEntered.isCompleted) checkoutEntered.complete();
    await checkoutWait?.future;
    if (failCheckout) throw const AppleApiException('offline');
    return AppleCheckout(
      attemptId: attemptId,
      appAccountToken: 'unique-attempt-token',
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
    reconciled++;
    users.add(userId);
    if (!entered.isCompleted) entered.complete();
    await wait?.future;
    if (fail) throw const AppleApiException('offline');
    final r =
        receiptResults[AppleReceipt.fromJws(
          signedTransactionJws,
        ).transactionId] ??
        result(
          AppleReceipt.fromJws(signedTransactionJws),
          action: action,
          finish: serverFinished ? 'finished' : 'pending',
        );
    if (attemptId != null) results[attemptId] = r;
    return r;
  }

  @override
  Future<AppleAttemptStatus> attempt({
    required String userId,
    required String attemptId,
  }) async {
    if (failedAttempts.contains(attemptId)) {
      throw const AppleApiException('offline');
    }
    return AppleAttemptStatus(
      attemptId: attemptId,
      productId: results[attemptId]?.productId ?? sku,
      result: results[attemptId],
    );
  }

  @override
  Future<void> finishAck({
    required String userId,
    required String transactionId,
    required String environment,
  }) async {
    acks++;
    if (failAck) throw const AppleApiException('offline');
  }
}

class FailingMarkerStore extends AppleAttemptStore {
  FailingMarkerStore(super.settings);
  @override
  Future<void> save(ApplePendingAttempt attempt) async =>
      throw StateError('disk write failed');
}

class FailingJournalStore extends PendingPurchasesStore {
  @override
  Future<PendingPurchaseEntry> saveApple(
    PendingPurchase purchase, {
    required String environment,
    required String transactionId,
  }) async => throw StateError('disk write failed');
}

AppleReconciliation terminalResult() => const AppleReconciliation(
  transactionId: 'exact',
  originalTransactionId: 'chain',
  environment: 'test',
  productId: sku,
  disposition: 'terminal_reconciled',
  finishAllowed: true,
  finishState: 'finished',
  action: AppleCheckoutAction.proceed,
  entitlement: AppleEntitlement(balance: 0, subscriptionType: 'free'),
);
