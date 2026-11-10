import 'dart:async';

import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/payments/api/store_payments_api.dart';
import 'package:asteria_app/core/payments/gateway/payment_gateway.dart';
import 'package:asteria_app/core/payments/models/payment_product.dart';
import 'package:asteria_app/core/payments/models/purchase_result.dart';
import 'package:asteria_app/core/payments/models/purchase_update.dart';
import 'package:asteria_app/core/payments/storage/pending_purchases_store.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_cubit.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('completed Google checkout retains its successful result', () async {
    final cubit = PaywallCubit(
      storeGateway: _CompletedGoogleGateway(),
      storePaymentsApi: _RecordingStorePaymentsApi(),
      pendingPurchasesStore: _MemoryPendingPurchasesStore(),
      monetizationProvider: _RecordingMonetizationProvider(),
      authSession: _MutableSession('user-a'),
    );
    addTearDown(cubit.close);

    await cubit.purchase(_product);

    expect(cubit.state, isA<PaywallSuccess>());
  });

  test(
    'records structured diagnostics when store products fail to load',
    () async {
      final session = _MutableSession('user-a');
      final payments = _RecordingStorePaymentsApi();
      final cubit = PaywallCubit(
        storeGateway: _FailingLoadGateway(),
        storePaymentsApi: payments,
        pendingPurchasesStore: _MemoryPendingPurchasesStore(),
        monetizationProvider: _fakeMonetizationProvider(),
        authSession: session,
      );
      addTearDown(cubit.close);

      await cubit.loadProducts(const ['asteria_stars_10', 'asteria_stars_30']);

      expect(cubit.state, const PaywallFailed(PaywallFailureCode.productsLoad));
      expect(payments.diagnosticStages, [
        'load_products_start',
        'load_products_error',
      ]);
      expect(payments.diagnosticDetails.last, {
        'code': 'store_products_not_found',
        'message': 'Store did not return requested products',
        'requested_ids': ['asteria_stars_10', 'asteria_stars_30'],
        'not_found_ids': ['asteria_stars_10', 'asteria_stars_30'],
        'loaded_ids': <String>[],
        'store_error_code': null,
        'store_error_message': null,
      });
    },
  );

  test(
    'shows loaded store products when only part of the requested products load',
    () async {
      final session = _MutableSession('user-a');
      final payments = _RecordingStorePaymentsApi();
      final cubit = PaywallCubit(
        storeGateway: _PartialLoadGateway(),
        storePaymentsApi: payments,
        pendingPurchasesStore: _MemoryPendingPurchasesStore(),
        monetizationProvider: _fakeMonetizationProvider(),
        authSession: session,
      );
      addTearDown(cubit.close);

      await cubit.loadProducts(const ['asteria_stars_10', 'asteria_stars_30']);

      expect(
        cubit.state,
        isA<PaywallProductsLoaded>().having(
          (state) => state.products.map((product) => product.id).toList(),
          'product ids',
          ['asteria_stars_10'],
        ),
      );
      expect(payments.diagnosticStages, [
        'load_products_start',
        'load_products_partial',
      ]);
      expect(payments.diagnosticDetails.last, {
        'code': 'store_products_partial',
        'message': 'Store did not return every requested product',
        'requested_ids': ['asteria_stars_10', 'asteria_stars_30'],
        'not_found_ids': ['asteria_stars_30'],
        'loaded_ids': ['asteria_stars_10'],
        'store_error_code': null,
        'store_error_message': null,
      });
    },
  );

  test(
    'Google pending payment shows pending without verification or fulfillment',
    () async {
      final payments = _RecordingStorePaymentsApi();
      final cubit = PaywallCubit(
        storeGateway: _PendingGoogleGateway(),
        storePaymentsApi: payments,
        pendingPurchasesStore: _MemoryPendingPurchasesStore(),
        monetizationProvider: _fakeMonetizationProvider(),
        authSession: _MutableSession('user-a'),
      );
      addTearDown(cubit.close);
      await cubit.purchase(_product);
      expect(cubit.state, isA<PaywallPending>());
      expect(payments.verifyCalls, 0);
    },
  );

  test(
    'Google checkout cannot apply old balance after account switch during disk deletion',
    () async {
      final session = _MutableSession('user-a');
      final monetization = _RecordingMonetizationProvider();
      final cubit = PaywallCubit(
        storeGateway: _CompletedGoogleGateway(),
        storePaymentsApi: _RecordingStorePaymentsApi(),
        pendingPurchasesStore: _SwitchOnDeleteStore(
          () => session.uid = 'user-b',
        ),
        monetizationProvider: monetization,
        authSession: session,
      );
      addTearDown(cubit.close);
      await cubit.purchase(_product);
      expect(monetization.applied, isEmpty);
      expect(cubit.state, isNot(isA<PaywallSuccess>()));
    },
  );

  test(
    'Google restore cannot apply old balance after account switch during finalize',
    () async {
      final session = _MutableSession('user-a');
      final monetization = _RecordingMonetizationProvider();
      final cubit = PaywallCubit(
        storeGateway: _CompletedGoogleGateway(
          onFinalize: () => session.uid = 'user-b',
        ),
        storePaymentsApi: _RecordingStorePaymentsApi(),
        pendingPurchasesStore: _MemoryPendingPurchasesStore(),
        monetizationProvider: monetization,
        authSession: session,
      );
      addTearDown(cubit.close);
      await cubit.restorePurchases();
      expect(monetization.applied, isEmpty);
      expect(cubit.state, isNot(isA<PaywallRestored>()));
    },
  );

  test('does not verify a store purchase after account switch', () async {
    final session = _MutableSession('user-a');
    final gateway = _SwitchingGateway(() => session.uid = 'user-b');
    final payments = _RecordingStorePaymentsApi();
    final cubit = PaywallCubit(
      storeGateway: gateway,
      storePaymentsApi: payments,
      pendingPurchasesStore: _MemoryPendingPurchasesStore(),
      monetizationProvider: _fakeMonetizationProvider(),
      authSession: session,
      analyticsContext: (product, uid) async => {
        'attempt_id': 'original-attempt',
      },
    );
    addTearDown(cubit.close);

    await cubit.purchase(_product);

    expect(gateway.purchaseUserToken, 'user-a');
    expect(payments.verifyCalls, 0);
    expect(cubit.state, isA<PaywallPending>());
    final saved = _MemoryPendingPurchasesStore.lastSaved!;
    expect(
      PendingPurchase.fromMap(
        saved.toMap(),
      ).copyWith(failed: true).analyticsContext,
      {'attempt_id': 'original-attempt'},
    );
    expect(
      gateway.purchaseUserToken,
      _MemoryPendingPurchasesStore.lastSaved?.userId,
    );
  });
}

const _product = PaymentProduct(
  id: 'asteria_pro_month',
  type: ProductType.subscription,
  title: 'Pro',
  description: 'Pro',
  localizedPrice: '499 RUB',
  rawPrice: 499,
  currencyCode: 'RUB',
);

class _SwitchingGateway implements PaymentGateway {
  _SwitchingGateway(this.onPurchase);

  final VoidCallback onPurchase;
  String? purchaseUserToken;

  @override
  Future<List<PaymentProduct>> loadProducts(List<String> ids) async => [
    _product,
  ];

  @override
  Future<PurchaseResult> purchase(
    PaymentProduct product, {
    String? userToken,
  }) async {
    purchaseUserToken = userToken;
    onPurchase();
    return const PurchaseResult(
      productId: 'asteria_pro_month',
      status: PurchaseStatus.success,
      originalTransactionId: 'tx-1',
      signedTransactionJws: 'signed-jws',
      storeProvider: StoreProvider.apple,
    );
  }

  @override
  Future<void> finalize(PurchaseResult result) async {}

  @override
  Stream<PurchaseUpdate> get purchaseUpdates => const Stream.empty();

  @override
  Future<List<PurchaseResult>> restorePurchases() async => const [];

  @override
  Future<String?> currentStorefrontCountry() async => 'RUS';
}

class _RecordingStorePaymentsApi implements StorePaymentsApi {
  int verifyCalls = 0;
  final List<String> diagnosticStages = [];
  final List<Map<String, Object?>> diagnosticDetails = [];

  @override
  Future<String> preparePurchaseUserToken(String userId) async => userId;

  @override
  Future<void> recordClientDiagnostic({
    required String userId,
    required String stage,
    String? productId,
    Map<String, Object?> details = const {},
  }) async {
    diagnosticStages.add(stage);
    diagnosticDetails.add(details);
  }

  @override
  Future<StoreVerifyResponse> verify({
    required String userId,
    required String verificationData,
    required String productId,
    Map<String, Object?>? analyticsContext,
  }) async {
    verifyCalls += 1;
    return const StoreVerifyResponse(
      transactionId: 'tx-1',
      status: 'fulfilled',
      balance: 0,
    );
  }
}

class _PartialLoadGateway implements PaymentGateway {
  @override
  Future<List<PaymentProduct>> loadProducts(List<String> ids) async {
    throw StoreProductLoadException(
      code: 'store_products_partial',
      message: 'Store did not return every requested product',
      requestedIds: ids,
      notFoundIds: const ['asteria_stars_30'],
      loadedIds: const ['asteria_stars_10'],
      loadedProducts: const [
        PaymentProduct(
          id: 'asteria_stars_10',
          type: ProductType.consumable,
          title: 'Stars',
          description: 'Stars',
          localizedPrice: r'$0.99',
          rawPrice: 0.99,
          currencyCode: 'USD',
        ),
      ],
    );
  }

  @override
  Future<PurchaseResult> purchase(
    PaymentProduct product, {
    String? userToken,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> finalize(PurchaseResult result) async {}

  @override
  Stream<PurchaseUpdate> get purchaseUpdates => const Stream.empty();

  @override
  Future<List<PurchaseResult>> restorePurchases() async => const [];

  @override
  Future<String?> currentStorefrontCountry() async => null;
}

class _FailingLoadGateway implements PaymentGateway {
  @override
  Future<List<PaymentProduct>> loadProducts(List<String> ids) async {
    throw StoreProductLoadException(
      code: 'store_products_not_found',
      message: 'Store did not return requested products',
      requestedIds: ids,
      notFoundIds: ids,
      loadedIds: const [],
    );
  }

  @override
  Future<PurchaseResult> purchase(
    PaymentProduct product, {
    String? userToken,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> finalize(PurchaseResult result) async {}

  @override
  Stream<PurchaseUpdate> get purchaseUpdates => const Stream.empty();

  @override
  Future<List<PurchaseResult>> restorePurchases() async => const [];

  @override
  Future<String?> currentStorefrontCountry() async => null;
}

class _MemoryPendingPurchasesStore extends PendingPurchasesStore {
  static PendingPurchase? lastSaved;
  final Map<String, PendingPurchase> purchases = {};

  @override
  Future<void> save(PendingPurchase purchase) async {
    lastSaved = purchase;
    purchases[purchase.originalTransactionId] = purchase;
  }

  @override
  Future<void> markFailed(String originalTransactionId) async {
    final purchase = purchases[originalTransactionId];
    if (purchase != null) {
      purchases[originalTransactionId] = purchase.copyWith(failed: true);
    }
  }

  @override
  Future<void> delete(String originalTransactionId) async {
    purchases.remove(originalTransactionId);
  }
}

class _MutableSession implements AuthSessionService {
  _MutableSession(this.uid);

  String? uid;

  @override
  String? get currentEmail => '$uid@example.test';

  @override
  String? get currentUid => uid;

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => uid != null;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async => uid;

  @override
  Future<void> deleteCurrentIdentity() async {}

  @override
  Future<void> saveSession({
    required String uid,
    required String? email,
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {}

  @override
  Future<void> signOut() async {
    uid = null;
  }
}

class _FakeUserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PendingGoogleGateway extends _SwitchingGateway {
  _PendingGoogleGateway() : super(() {});
  @override
  Future<PurchaseResult> purchase(
    PaymentProduct product, {
    String? userToken,
  }) async => const PurchaseResult(
    productId: 'asteria_pro_month',
    status: PurchaseStatus.pending,
    storeProvider: StoreProvider.google,
  );
}

class _CompletedGoogleGateway extends _SwitchingGateway {
  _CompletedGoogleGateway({this.onFinalize}) : super(() {});
  final VoidCallback? onFinalize;
  static const result = PurchaseResult(
    productId: 'asteria_pro_month',
    status: PurchaseStatus.success,
    storeProvider: StoreProvider.google,
    originalTransactionId: 'google-order',
    serverVerificationData: 'paid-token',
  );
  @override
  Future<PurchaseResult> purchase(
    PaymentProduct product, {
    String? userToken,
  }) async => result;
  @override
  Future<List<PurchaseResult>> restorePurchases() async => [result];
  @override
  Future<void> finalize(PurchaseResult result) async {
    onFinalize?.call();
  }
}

class _SwitchOnDeleteStore extends _MemoryPendingPurchasesStore {
  _SwitchOnDeleteStore(this.onDelete);
  final VoidCallback onDelete;
  @override
  Future<void> delete(String id) async {
    await super.delete(id);
    onDelete();
  }
}

class _RecordingMonetizationProvider extends MonetizationProvider {
  _RecordingMonetizationProvider()
    : super(
        api: MonetizationApi.forDio(Dio(), _MutableSession('user-a')),
        userProvider: UserProvider(userRepository: _FakeUserRepository()),
      );
  final applied = <StoreVerifyResponse>[];
  @override
  Future<void> refreshAfterVerify(StoreVerifyResponse response) async {
    applied.add(response);
  }
}

MonetizationProvider _fakeMonetizationProvider() {
  return MonetizationProvider(
    api: MonetizationApi.forDio(Dio(), _MutableSession('user-a')),
    userProvider: UserProvider(userRepository: _FakeUserRepository()),
  );
}
