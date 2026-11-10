import 'dart:async';
import 'dart:io';

import 'package:asteria_app/core/payments/api/store_payments_api.dart';
import 'package:asteria_app/core/payments/gateway/store_kit_gateway.dart';
import 'package:asteria_app/core/payments/models/purchase_result.dart';
import 'package:asteria_app/core/payments/models/purchase_update.dart';
import 'package:asteria_app/core/payments/recovery/google_purchase_recovery.dart';
import 'package:asteria_app/core/payments/storage/pending_purchases_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:in_app_purchase_android/billing_client_wrappers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late PendingPurchasesStore pending;
  late _Identity identity;
  late _Api api;
  late StreamController<PurchaseUpdate> updates;
  late GooglePurchaseRecovery recovery;
  var queries = 0;
  var refreshed = 0;
  final refreshedUsers = <String?>[];
  late List<GooglePlayPurchaseDetails> owned;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('google-recovery');
    Hive.init(directory.path);
    pending = PendingPurchasesStore();
    await pending.init();
    identity = _Identity('user-a');
    api = _Api();
    queries = 0;
    refreshed = 0;
    refreshedUsers.clear();
    owned = [_purchase('user-a')];
    updates = StreamController<PurchaseUpdate>.broadcast();
    recovery = GooglePurchaseRecovery(
      identityChanges: identity,
      currentUserId: () => identity.uid,
      purchaseUpdates: updates.stream,
      queryPurchases: () async {
        queries++;
        return owned;
      },
      paymentsApi: api,
      pendingStore: pending,
      refreshEntitlements: () async {
        refreshed++;
        refreshedUsers.add(identity.uid);
      },
    );
  });
  tearDown(() async {
    recovery.dispose();
    await updates.close();
    identity.dispose();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('cold start recovers paid purchase absent from local storage', () async {
    await recovery.start();
    expect(api.verified, ['user-a:paid-token']);
    expect(pending.getAll(), isEmpty);
    expect(refreshed, 1);
  });

  test('signed-out launch waits for login then queries purchases', () async {
    identity.uid = null;
    await recovery.start();
    expect(queries, 0);
    identity.change('user-a');
    await recovery.recover();
    expect(api.verified, ['user-a:paid-token']);
  });

  test(
    'resume discovers a payment completed while app was backgrounded',
    () async {
      owned = [];
      await recovery.start();
      owned = [_purchase('user-a')];
      recovery.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await recovery.recover();
      expect(api.verified, ['user-a:paid-token']);
    },
  );

  test('other account and pending payments cannot be credited', () async {
    owned = [_purchase('user-b'), _purchase('user-a', pending: true)];
    await recovery.start();
    expect(api.verified, isEmpty);
    expect(pending.getAll(), isEmpty);
  });

  test(
    'restored wrapper cannot turn pending payment into failed paid token',
    () async {
      final raw = _purchase('user-a', pending: true)
        ..status = iap.PurchaseStatus.restored;
      owned = [raw];
      api.reject = true;
      await recovery.start();
      expect(api.verified, isEmpty);
      expect(pending.getAll(), isEmpty);
      expect(refreshed, 1);
      // Later, the very same token completes payment and must remain recoverable.
      owned = [_purchase('user-a')];
      api.reject = false;
      await recovery.recover();
      expect(api.verified, ['user-a:paid-token']);
      expect(refreshed, 2);
      expect(pending.getAll(), isEmpty);
    },
  );

  test(
    'subscription without account hash is bound by server before refresh',
    () async {
      owned = [_purchase(null, productId: 'asteria_pro_month')];
      api.expectedProductId = 'asteria_pro_month';
      await recovery.start();
      expect(api.verified, ['user-a:paid-token']);
      expect(refreshed, 1);
      expect(pending.getAll(), isEmpty);
    },
  );

  test(
    'consumable without account hash is never submitted for credit',
    () async {
      owned = [_purchase(null)];
      await recovery.start();
      expect(api.verified, isEmpty);
      expect(refreshed, 1);
      expect(pending.getAll(), isEmpty);
    },
  );

  test(
    'server rejection never grants while current account snapshot refreshes',
    () async {
      owned = [_purchase(null, productId: 'asteria_pro_month')];
      api.expectedProductId = 'asteria_pro_month';
      api.reject = true;
      await recovery.start();
      expect(api.verified, ['user-a:paid-token']);
      expect(refreshed, 1);
      expect(pending.getPending(), isEmpty);
      expect(pending.getAll().single.failed, isTrue);
    },
  );

  test(
    'subscription explicitly bound to another account remains skipped',
    () async {
      owned = [_purchase('user-b', productId: 'asteria_pro_month')];
      await recovery.start();
      expect(api.verified, isEmpty);
      expect(refreshed, 1);
    },
  );

  test(
    'one recovery pass verifies each token once across disk and Play',
    () async {
      await pending.save(
        PendingPurchase(
          originalTransactionId: 'existing-order',
          productId: 'asteria_stars_10',
          signedTransactionJws: 'paid-token',
          userId: 'user-a',
          createdAt: DateTime.now(),
          storeProvider: StoreProvider.google,
          analyticsContext: const {'attempt_id': 'checkout-attempt'},
        ),
      );
      owned = [_purchase('user-a'), _purchase('user-a')];
      await recovery.start();
      expect(api.verified, ['user-a:paid-token']);
      expect(api.contexts.single, {'attempt_id': 'checkout-attempt'});
      expect(pending.getAll(), isEmpty);
    },
  );

  test(
    'duplicate query and stream update share verification in flight',
    () async {
      final gate = Completer<void>();
      api.gate = gate.future;
      final recovering = recovery.start();
      await api.entered.future;
      updates.add(PurchaseUpdate(_result(owned.single)));
      final again = recovery.recover();
      await Future<void>.delayed(Duration.zero);
      expect(api.verified, ['user-a:paid-token']);
      gate.complete();
      await Future.wait([recovering, again]);
      expect(refreshed, 1);
    },
  );

  test(
    'account switch during verify cannot refresh new account with old result',
    () async {
      final gate = Completer<void>();
      api.gate = gate.future;
      final recovering = recovery.start();
      await api.entered.future;
      identity.change('user-b');
      gate.complete();
      await recovering;
      expect(refreshedUsers, ['user-b']);
      expect(api.verified, ['user-a:paid-token']);
    },
  );

  test(
    'failed verify survives restart and replays even after store consumption',
    () async {
      api.fail = true;
      await recovery.start();
      expect(pending.getPending(), hasLength(1));
      recovery.dispose();
      owned = [];
      api.fail = false;
      recovery = GooglePurchaseRecovery(
        identityChanges: identity,
        currentUserId: () => identity.uid,
        purchaseUpdates: updates.stream,
        queryPurchases: () async => owned,
        paymentsApi: api,
        pendingStore: pending,
        refreshEntitlements: () async {
          refreshed++;
        },
      );
      await recovery.start();
      expect(api.verified, ['user-a:paid-token', 'user-a:paid-token']);
      expect(pending.getAll(), isEmpty);
      expect(refreshed, 2);
    },
  );
  for (final throwsOnFailure in [false, true]) {
    test(
      'resume repairs stale balance after consumed token and refresh failure ($throwsOnFailure)',
      () async {
        recovery.dispose();
        var visibleBalance = 0;
        var online = false;
        recovery = GooglePurchaseRecovery(
          identityChanges: identity,
          currentUserId: () => identity.uid,
          purchaseUpdates: updates.stream,
          queryPurchases: () async => owned,
          paymentsApi: api,
          pendingStore: pending,
          refreshEntitlements: () async {
            if (!online) {
              if (throwsOnFailure) throw StateError('offline');
              return; // MonetizationProvider.refresh currently absorbs errors.
            }
            visibleBalance = 10;
          },
        );
        await recovery.start();
        expect(api.verified, ['user-a:paid-token']);
        expect(pending.getAll(), isEmpty);
        expect(visibleBalance, 0);
        owned = []; // The successful server verification consumed the token.
        online = true;
        recovery.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await recovery.recover();
        expect(visibleBalance, 10);
        expect(api.verified, ['user-a:paid-token']);
      },
    );
  }

  test(
    'Play query failure does not prevent authoritative balance refresh',
    () async {
      recovery.dispose();
      var visibleBalance = 0;
      recovery = GooglePurchaseRecovery(
        identityChanges: identity,
        currentUserId: () => identity.uid,
        purchaseUpdates: updates.stream,
        queryPurchases: () async => throw StateError('Play unavailable'),
        paymentsApi: api,
        pendingStore: pending,
        refreshEntitlements: () async => visibleBalance = 25,
      );
      await recovery.start();
      expect(visibleBalance, 25);
      expect(api.verified, isEmpty);
    },
  );

  test(
    'account switch during empty query refreshes only current account',
    () async {
      recovery.dispose();
      final query = Completer<List<GooglePlayPurchaseDetails>>();
      final queried = Completer<void>();
      final refreshedUsers = <String?>[];
      recovery = GooglePurchaseRecovery(
        identityChanges: identity,
        currentUserId: () => identity.uid,
        purchaseUpdates: updates.stream,
        queryPurchases: () {
          if (!queried.isCompleted) queried.complete();
          return query.future;
        },
        paymentsApi: api,
        pendingStore: pending,
        refreshEntitlements: () async => refreshedUsers.add(identity.uid),
      );
      final started = recovery.start();
      await queried.future;
      identity.change('user-b');
      query.complete([]);
      await started;
      expect(refreshedUsers, ['user-b']);
      expect(api.verified, isEmpty);
    },
  );

  test('disposed recovery cannot refresh after outstanding query', () async {
    recovery.dispose();
    final query = Completer<List<GooglePlayPurchaseDetails>>();
    final queried = Completer<void>();
    recovery = GooglePurchaseRecovery(
      identityChanges: identity,
      currentUserId: () => identity.uid,
      purchaseUpdates: updates.stream,
      queryPurchases: () {
        queried.complete();
        return query.future;
      },
      paymentsApi: api,
      pendingStore: pending,
      refreshEntitlements: () async => refreshed++,
    );
    final started = recovery.start();
    await queried.future;
    recovery.dispose();
    query.complete([]);
    await started;
    expect(refreshed, 0);
  });
}

class _Identity extends ChangeNotifier {
  _Identity(this.uid);
  String? uid;
  void change(String? value) {
    uid = value;
    notifyListeners();
  }
}

class _Api implements StorePaymentsApi {
  final verified = <String>[];
  final contexts = <Map<String, Object?>?>[];
  final entered = Completer<void>();
  Future<void>? gate;
  bool fail = false;
  bool reject = false;
  String expectedProductId = 'asteria_stars_10';
  @override
  Future<StoreVerifyResponse> verify({
    required String userId,
    required String verificationData,
    required String productId,
    Map<String, Object?>? analyticsContext,
  }) async {
    verified.add('$userId:$verificationData');
    contexts.add(analyticsContext);
    if (!entered.isCompleted) entered.complete();
    expect(productId, expectedProductId);
    await gate;
    if (fail) throw const StoreVerifyServerException('offline');
    if (reject) throw const StoreVerifyBadRequestException('Owner mismatch');
    return const StoreVerifyResponse(
      transactionId: 'transaction',
      status: 'fulfilled',
      balance: 10,
    );
  }

  @override
  Future<String> preparePurchaseUserToken(String userId) async => userId;
  @override
  Future<void> recordClientDiagnostic({
    required String userId,
    required String stage,
    String? productId,
    Map<String, Object?> details = const {},
  }) async {}
}

GooglePlayPurchaseDetails _purchase(
  String? uid, {
  bool pending = false,
  String productId = 'asteria_stars_10',
}) => GooglePlayPurchaseDetails.fromPurchase(
  PurchaseWrapper(
    orderId: 'order',
    packageName: 'com.asteria',
    purchaseTime: 1000,
    purchaseToken: 'paid-token',
    signature: 'signature',
    products: [productId],
    isAutoRenewing: false,
    originalJson: '{}',
    isAcknowledged: false,
    purchaseState: pending
        ? PurchaseStateWrapper.pending
        : PurchaseStateWrapper.purchased,
    obfuscatedAccountId: googlePlayObfuscatedAccountId(uid),
  ),
).single;
PurchaseResult _result(GooglePlayPurchaseDetails raw) => PurchaseResult(
  productId: raw.productID,
  status: PurchaseStatus.success,
  storeProvider: StoreProvider.google,
  originalTransactionId: raw.purchaseID,
  serverVerificationData: raw.verificationData.serverVerificationData,
  rawPurchase: raw,
);
