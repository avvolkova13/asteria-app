import 'dart:async';

import 'package:asteria_app/core/payments/api/arc_pay_payments_api.dart';
import 'package:asteria_app/core/payments/storage/arc_pay_pending_order_store.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_cubit.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const product = ArcPayProduct(
    productId: 'asteria_stars_10',
    name: '10 монет Asteria',
    productType: 'stars',
    coins: 10,
    durationDays: null,
    amountMinor: 4900,
    currency: 'RUB',
  );

  for (final fails in [false, true]) {
    test(
      'leaving while the catalog loads ignores late response (error: $fails)',
      () async {
        final request = Completer<List<ArcPayProduct>>();
        final cubit = _cubit(api: _FakeApi()..catalogRequest = request);
        final loading = cubit.loadProducts();
        await cubit.close();
        if (fails) {
          request.completeError(StateError('offline'));
        } else {
          request.complete(const [product]);
        }
        await expectLater(loading, completes);
      },
    );
  }

  test('loads server catalog', () async {
    final api = _FakeApi()..products = const [product];
    final cubit = _cubit(api: api);

    await cubit.loadProducts();

    expect(cubit.state, isA<ArcPayProductsLoaded>());
    expect(
      (cubit.state as ArcPayProductsLoaded).products.single.productId,
      product.productId,
    );
    await cubit.close();
  });

  test('blocks a double checkout tap', () async {
    final api = _FakeApi();
    final completer = Completer<ArcPayCheckout>();
    api.checkoutCompleter = completer;
    final cubit = _cubit(api: api);

    final first = cubit.start(
      productId: product.productId,
      amountMinor: product.amountMinor,
      currency: product.currency,
    );
    final second = cubit.start(
      productId: product.productId,
      amountMinor: product.amountMinor,
      currency: product.currency,
    );
    completer.complete(
      ArcPayCheckout(
        orderId: 'order-1',
        checkoutUrl: Uri.parse('https://checkout.example/order-1'),
        status: 'pending',
      ),
    );
    await Future.wait([first, second]);

    expect(api.createCalls, 1);
    expect(cubit.state, isA<ArcPayCheckoutReady>());
    await cubit.close();
  });

  test('restores pending order and only succeeds on fulfilled', () async {
    final api = _FakeApi()
      ..nextOrder = _order(status: 'fulfilled', providerStatus: 'captured');
    final store = _FakeStore()
      ..value = ArcPayPendingOrder(
        orderId: 'order-1',
        productId: product.productId,
        amountMinor: product.amountMinor,
        currency: product.currency,
        userId: 'user-1',
        checkoutUrl: Uri.parse('https://checkout.example/order-1'),
      );
    var refreshCalls = 0;
    final cubit = _cubit(
      api: api,
      store: store,
      refreshUser: () async => refreshCalls++,
    );

    await cubit.start(
      productId: product.productId,
      amountMinor: product.amountMinor,
      currency: product.currency,
    );

    expect(cubit.state, isA<ArcPayCheckoutFulfilled>());
    expect(refreshCalls, 1);
    expect(store.value, isNull);
    await cubit.close();
  });

  test('does not restore pending order without a requested product', () async {
    final api = _FakeApi();
    final store = _FakeStore()
      ..value = ArcPayPendingOrder(
        orderId: 'order-1',
        productId: product.productId,
        amountMinor: product.amountMinor,
        currency: product.currency,
        userId: 'user-1',
        checkoutUrl: Uri.parse('https://checkout.example/order-1'),
      );
    final cubit = _cubit(api: api, store: store);

    await cubit.start();

    expect(cubit.state, isA<ArcPayCheckoutFailure>());
    expect(
      (cubit.state as ArcPayCheckoutFailure).code,
      ArcPayCheckoutErrorCode.noPendingPayment,
    );
    expect(api.createCalls, 0);
    expect(store.value?.orderId, 'order-1');
    await cubit.close();
  });

  test('does not restore pending order for a different product', () async {
    final api = _FakeApi();
    final store = _FakeStore()
      ..value = ArcPayPendingOrder(
        orderId: 'order-stars',
        productId: 'asteria_stars_10',
        amountMinor: 4900,
        currency: 'RUB',
        userId: 'user-1',
        checkoutUrl: Uri.parse('https://checkout.example/order-stars'),
      );
    final cubit = _cubit(api: api, store: store);

    await cubit.start(
      productId: 'asteria_pro_month',
      amountMinor: 19900,
      currency: 'RUB',
    );

    expect(api.createCalls, 1);
    expect(api.createdProductIds, ['asteria_pro_month']);
    final state = cubit.state as ArcPayCheckoutReady;
    expect(state.restored, isFalse);
    expect(store.value?.productId, 'asteria_pro_month');
    expect(store.value?.amountMinor, 19900);
    expect(store.value?.currency, 'RUB');
    await cubit.close();
  });

  test('does not restore pending order with a different amount', () async {
    final api = _FakeApi();
    final store = _FakeStore()
      ..value = ArcPayPendingOrder(
        orderId: 'order-old-price',
        productId: product.productId,
        amountMinor: 3900,
        currency: product.currency,
        userId: 'user-1',
        checkoutUrl: Uri.parse('https://checkout.example/order-old-price'),
      );
    final cubit = _cubit(api: api, store: store);

    await cubit.start(
      productId: product.productId,
      amountMinor: product.amountMinor,
      currency: product.currency,
    );

    expect(api.createCalls, 1);
    expect(cubit.state, isA<ArcPayCheckoutReady>());
    expect((cubit.state as ArcPayCheckoutReady).restored, isFalse);
    expect(store.value?.amountMinor, product.amountMinor);
    await cubit.close();
  });

  test(
    'captured without fulfillment stays confirming and remains recoverable',
    () async {
      final api = _FakeApi()
        ..nextOrder = _order(status: 'confirming', providerStatus: 'captured');
      final store = _FakeStore()
        ..value = ArcPayPendingOrder(
          orderId: 'order-1',
          productId: product.productId,
          amountMinor: product.amountMinor,
          currency: product.currency,
          userId: 'user-1',
          checkoutUrl: Uri.parse('https://checkout.example/order-1'),
        );
      final cubit = _cubit(api: api, store: store);

      await cubit.start(
        productId: product.productId,
        amountMinor: product.amountMinor,
        currency: product.currency,
      );

      expect(cubit.state, isA<ArcPayCheckoutConfirming>());
      expect(store.value?.orderId, 'order-1');
      await cubit.close();
    },
  );

  test('abandon clears pending order and allows a new checkout', () async {
    final api = _FakeApi();
    final store = _FakeStore()
      ..value = ArcPayPendingOrder(
        orderId: 'order-1',
        productId: product.productId,
        amountMinor: product.amountMinor,
        currency: product.currency,
        userId: 'user-1',
        checkoutUrl: Uri.parse('https://checkout.example/order-1'),
      );
    final cubit = _cubit(api: api, store: store);

    await cubit.abandon();

    expect(api.abandonCalls, 1);
    expect(store.value, isNull);
    expect(cubit.state, isA<ArcPayCheckoutAbandoned>());
    await cubit.start(
      productId: product.productId,
      amountMinor: product.amountMinor,
      currency: product.currency,
    );
    expect(api.createCalls, 1);
    expect(cubit.state, isA<ArcPayCheckoutReady>());
    await cubit.close();
  });

  test('cancel deep link abandons only the matching pending order', () async {
    final api = _FakeApi();
    final store = _FakeStore()
      ..value = ArcPayPendingOrder(
        orderId: 'order-1',
        productId: product.productId,
        amountMinor: product.amountMinor,
        currency: product.currency,
        userId: 'user-1',
        checkoutUrl: Uri.parse('https://checkout.example/order-1'),
      );
    final cubit = _cubit(api: api, store: store);

    await cubit.handlePaymentReturn(
      Uri.parse('asteria://payment-return?order_id=other&result=cancel'),
    );
    expect(api.abandonCalls, 0);
    await cubit.handlePaymentReturn(
      Uri.parse('asteria://payment-return?order_id=order-1&result=cancel'),
    );

    expect(api.abandonCalls, 1);
    expect(store.value, isNull);
    await cubit.close();
  });

  test('network failure during abandon still releases local attempt', () async {
    final api = _FakeApi()..abandonError = true;
    final store = _FakeStore()
      ..value = ArcPayPendingOrder(
        orderId: 'order-1',
        productId: product.productId,
        amountMinor: product.amountMinor,
        currency: product.currency,
        userId: 'user-1',
        checkoutUrl: Uri.parse('https://checkout.example/order-1'),
      );
    final cubit = _cubit(api: api, store: store);

    await cubit.abandon();

    final state = cubit.state as ArcPayCheckoutAbandoned;
    expect(state.serverConfirmed, isFalse);
    expect(store.value, isNull);
    await cubit.close();
  });

  test(
    'restored server-abandoned order releases stale local attempt',
    () async {
      final api = _FakeApi()
        ..nextOrder = _order(
          status: 'pending',
          providerStatus: 'created',
          clientState: 'abandoned',
        );
      final store = _FakeStore()
        ..value = ArcPayPendingOrder(
          orderId: 'order-1',
          productId: product.productId,
          amountMinor: product.amountMinor,
          currency: product.currency,
          userId: 'user-1',
          checkoutUrl: Uri.parse('https://checkout.example/order-1'),
        );
      final cubit = _cubit(api: api, store: store);

      await cubit.start(
        productId: product.productId,
        amountMinor: product.amountMinor,
        currency: product.currency,
      );

      expect(cubit.state, isA<ArcPayCheckoutAbandoned>());
      expect(store.value, isNull);
      await cubit.close();
    },
  );
}

ArcPayCheckoutCubit _cubit({
  required _FakeApi api,
  _FakeStore? store,
  Future<void> Function()? refreshUser,
}) => ArcPayCheckoutCubit(
  api: api,
  store: store ?? _FakeStore(),
  currentUserId: () => 'user-1',
  refreshUser: refreshUser ?? () async {},
  pollingInterval: const Duration(days: 1),
);

ArcPayOrder _order({
  required String status,
  required String providerStatus,
  String clientState = 'active',
}) => ArcPayOrder(
  orderId: 'order-1',
  productId: 'asteria_stars_10',
  productType: 'stars',
  coins: 10,
  durationDays: null,
  amountMinor: 4900,
  currency: 'RUB',
  status: status,
  providerStatus: providerStatus,
  clientState: clientState,
  paymentMethod: 'sbp',
  balance: status == 'fulfilled' ? 10 : null,
  failureCode: null,
  unrecoveredCoins: 0,
);

class _FakeApi extends ArcPayPaymentsApi {
  _FakeApi() : super.forDio(Dio(), _FakeSession());

  List<ArcPayProduct> products = const [];
  Completer<List<ArcPayProduct>>? catalogRequest;
  int createCalls = 0;
  final List<String> createdProductIds = [];
  Completer<ArcPayCheckout>? checkoutCompleter;
  ArcPayOrder nextOrder = _order(status: 'pending', providerStatus: 'pending');
  int abandonCalls = 0;
  bool abandonError = false;

  @override
  Future<List<ArcPayProduct>> getProducts() async =>
      catalogRequest?.future ?? products;

  @override
  Future<ArcPayCheckout> createCheckout({
    required String userId,
    required String productId,
    required String requestId,
    String platform = 'android',
    Map<String, Object?>? analyticsContext,
  }) async {
    createCalls++;
    createdProductIds.add(productId);
    return checkoutCompleter?.future ??
        ArcPayCheckout(
          orderId: 'order-1',
          checkoutUrl: Uri.parse('https://checkout.example/order-1'),
          status: 'pending',
        );
  }

  @override
  Future<ArcPayOrder> getOrder({
    required String orderId,
    required String userId,
  }) async => nextOrder;

  @override
  Future<ArcPayOrder> abandonOrder({
    required String orderId,
    required String userId,
  }) async {
    abandonCalls++;
    if (abandonError) throw DioException(requestOptions: RequestOptions());
    return ArcPayOrder(
      orderId: orderId,
      productId: 'asteria_stars_10',
      productType: 'stars',
      coins: 10,
      durationDays: null,
      amountMinor: 4900,
      currency: 'RUB',
      status: 'pending',
      providerStatus: 'timeout',
      clientState: 'abandoned',
      paymentMethod: 'sbp',
      balance: null,
      failureCode: null,
      unrecoveredCoins: 0,
    );
  }
}

class _FakeSession implements AuthSessionService {
  @override
  String? get currentEmail => null;

  @override
  String? get currentUid => 'user-1';

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => true;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async =>
      'access-token';

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
  Future<void> signOut() async {}
}

class _FakeStore extends ArcPayPendingOrderStore {
  ArcPayPendingOrder? value;

  @override
  ArcPayPendingOrder? read() => value;

  @override
  Future<void> save(ArcPayPendingOrder order) async {
    value = order;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}
