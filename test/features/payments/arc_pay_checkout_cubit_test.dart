import 'dart:async';

import 'package:asteria_app/core/payments/api/arc_pay_payments_api.dart';
import 'package:asteria_app/core/payments/storage/arc_pay_pending_order_store.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_cubit.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';

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

  for (final fails in [false, true]) {
    test('checkout completes safely after leaving (error: $fails)', () async {
      final request = Completer<ArcPayCheckout>();
      final store = _FakeStore();
      final cubit = _cubit(
        api: _FakeApi()..checkoutCompleter = request,
        store: store,
      );
      final checkout = cubit.start(
        productId: product.productId,
        amountMinor: product.amountMinor,
        currency: product.currency,
      );
      final completion = expectLater(checkout, completes);
      await Future<void>.delayed(Duration.zero);
      await cubit.close();
      if (fails) {
        request.completeError(StateError('offline'));
      } else {
        request.complete(
          ArcPayCheckout(
            orderId: 'order-1',
            checkoutUrl: Uri.parse('https://checkout.example/order-1'),
            status: 'pending',
          ),
        );
      }
      await completion;
      expect(store.value?.orderId, fails ? null : 'order-1');
    });
  }

  test('late checkout saves recovery without restarting polling', () {
    fakeAsync((clock) {
      final request = Completer<ArcPayCheckout>();
      final store = _FakeStore();
      final cubit = _cubit(
        api: _FakeApi()..checkoutCompleter = request,
        store: store,
      );
      unawaited(
        cubit.start(
          productId: product.productId,
          amountMinor: product.amountMinor,
          currency: product.currency,
        ),
      );
      clock.flushMicrotasks();
      unawaited(cubit.close());
      clock.flushMicrotasks();
      request.complete(
        ArcPayCheckout(
          orderId: 'order-1',
          checkoutUrl: Uri.parse('https://checkout.example/order-1'),
          status: 'pending',
        ),
      );
      clock.flushMicrotasks();
      expect(store.value?.orderId, 'order-1');
      expect(clock.periodicTimerCount, 0);
    });
  });

  for (final fails in [false, true]) {
    test('late abandon completes safely (error: $fails)', () async {
      final request = Completer<ArcPayOrder>();
      final store = _FakeStore()
        ..value = ArcPayPendingOrder(
          orderId: 'order-1',
          productId: product.productId,
          amountMinor: product.amountMinor,
          currency: product.currency,
          userId: 'user-1',
          checkoutUrl: Uri.parse('https://checkout.example/order-1'),
        );
      final cubit = _cubit(
        api: _FakeApi()..abandonRequest = request,
        store: store,
      );
      final abandon = cubit.abandon();
      final completion = expectLater(abandon, completes);
      await cubit.close();
      if (fails) {
        request.completeError(StateError('offline'));
      } else {
        request.complete(_order(status: 'pending', providerStatus: 'created'));
      }
      await completion;
      expect(store.value, isNull);
    });
  }

  test(
    'lost checkout response reuses request identity after screen restart',
    () async {
      final request = Completer<ArcPayCheckout>();
      final api = _FakeApi()..checkoutCompleter = request;
      final store = _FakeStore();
      var contextCalls = 0;
      Future<Map<String, Object?>?> context(String product, String uid) async {
        contextCalls++;
        return {'attempt_id': 'analytics-$contextCalls'};
      }

      final firstCubit = _cubit(
        api: api,
        store: store,
        analyticsContext: context,
      );
      final first = firstCubit.start(
        productId: product.productId,
        amountMinor: product.amountMinor,
        currency: product.currency,
      );
      await Future<void>.delayed(Duration.zero);
      request.completeError(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.receiveTimeout,
        ),
      );
      await first;
      await firstCubit.close();
      api.checkoutCompleter = null;
      final retryCubit = _cubit(
        api: api,
        store: store,
        analyticsContext: context,
      );
      await retryCubit.start(
        productId: product.productId,
        amountMinor: product.amountMinor,
        currency: product.currency,
      );
      expect(api.createdRequestIds, hasLength(2));
      expect(api.createdRequestIds.last, api.createdRequestIds.first);
      expect(contextCalls, 1);
      expect(api.createdContexts, [
        {'attempt_id': 'analytics-1'},
        {'attempt_id': 'analytics-1'},
      ]);
      await retryCubit.close();
    },
  );

  for (final mismatch in ['account', 'product', 'amount']) {
    test('uncertain request is isolated from changed $mismatch', () async {
      final request = Completer<ArcPayCheckout>();
      final api = _FakeApi()..checkoutCompleter = request;
      final store = _FakeStore();
      final firstCubit = _cubit(api: api, store: store);
      final first = firstCubit.start(
        productId: product.productId,
        amountMinor: product.amountMinor,
        currency: product.currency,
      );
      await Future<void>.delayed(Duration.zero);
      request.completeError(StateError('response lost'));
      await first;
      expect(store.requests, hasLength(1));
      await firstCubit.close();
      api.checkoutCompleter = null;
      final retryCubit = _cubit(
        api: api,
        store: store,
        currentUserId: () => mismatch == 'account' ? 'user-2' : 'user-1',
      );
      await retryCubit.start(
        productId: mismatch == 'product'
            ? 'asteria_pro_month'
            : product.productId,
        amountMinor: mismatch == 'amount' ? 9900 : product.amountMinor,
        currency: product.currency,
      );
      expect(api.createdRequestIds, hasLength(2));
      expect(api.createdRequestIds.last, isNot(api.createdRequestIds.first));
      expect(store.requests, hasLength(1));
      await retryCubit.close();
    });
  }

  test('pending checkout retry does not create a second order', () async {
    final api = _FakeApi();
    final cubit = _cubit(api: api);
    await cubit.start(
      productId: product.productId,
      amountMinor: product.amountMinor,
      currency: product.currency,
    );
    await cubit.start(
      productId: product.productId,
      amountMinor: product.amountMinor,
      currency: product.currency,
    );
    expect(api.createCalls, 1);
    expect(cubit.state, isA<ArcPayCheckoutPending>());
    await cubit.close();
  });

  test(
    'fulfilled checkout allows a new intentional purchase with a new ID',
    () async {
      final api = _FakeApi();
      final cubit = _cubit(api: api);
      await cubit.start(
        productId: product.productId,
        amountMinor: product.amountMinor,
        currency: product.currency,
      );
      api.nextOrder = _order(status: 'fulfilled', providerStatus: 'captured');
      await cubit.checkNow();
      await cubit.start(
        productId: product.productId,
        amountMinor: product.amountMinor,
        currency: product.currency,
      );
      expect(api.createdRequestIds, hasLength(2));
      expect(api.createdRequestIds.last, isNot(api.createdRequestIds.first));
      await cubit.close();
    },
  );

  test('cannot POST when durable request persistence fails', () async {
    final api = _FakeApi();
    final cubit = _cubit(api: api, store: _FakeStore()..failRequestSave = true);
    await cubit.start(
      productId: product.productId,
      amountMinor: product.amountMinor,
      currency: product.currency,
    );
    expect(api.createCalls, 0);
    expect(cubit.state, isA<ArcPayCheckoutFailure>());
    await cubit.close();
  });

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
  String? Function()? currentUserId,
  Future<Map<String, Object?>?> Function(String product, String uid)?
  analyticsContext,
}) => ArcPayCheckoutCubit(
  api: api,
  store: store ?? _FakeStore(),
  currentUserId: currentUserId ?? () => 'user-1',
  refreshUser: refreshUser ?? () async {},
  analyticsContext: analyticsContext,
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
  final List<String> createdRequestIds = [];
  final createdContexts = <Map<String, Object?>?>[];
  Completer<ArcPayCheckout>? checkoutCompleter;
  ArcPayOrder nextOrder = _order(status: 'pending', providerStatus: 'pending');
  int abandonCalls = 0;
  bool abandonError = false;
  Completer<ArcPayOrder>? abandonRequest;

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
    createdRequestIds.add(requestId);
    createdContexts.add(analyticsContext);
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
    if (abandonRequest != null) return abandonRequest!.future;
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
  bool failRequestSave = false;
  final requests = <String, ArcPayCheckoutRequest>{};

  @override
  ArcPayCheckoutRequest? readCheckoutRequest(String key) => requests[key];

  @override
  Future<ArcPayCheckoutRequest> saveCheckoutRequestIfAbsent(
    ArcPayCheckoutRequest request,
  ) async {
    if (failRequestSave) throw StateError('storage unavailable');
    return requests.putIfAbsent(request.key, () => request);
  }

  ArcPayPendingOrder? value;

  @override
  ArcPayPendingOrder? read() => value;

  @override
  Future<void> save(ArcPayPendingOrder order) async {
    value = order;
    if (requests[order.requestKey]?.requestId == order.requestId) {
      requests.remove(order.requestKey);
    }
  }

  @override
  Future<void> clear() async {
    final order = value;
    if (order != null &&
        requests[order.requestKey]?.requestId == order.requestId) {
      requests.remove(order.requestKey);
    }
    value = null;
  }
}
