import 'dart:typed_data';

import 'package:asteria_app/core/payments/api/arc_pay_payments_api.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses only v2 Hosted Checkout endpoints', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = ArcPayPaymentsApi.forDio(dio, _FakeSession());

    await api.getProducts();
    await api.createCheckout(
      userId: 'user-1',
      productId: 'asteria_stars_10',
      requestId: 'request-1',
      platform: 'ios',
      analyticsContext: const {'attempt_id': 'attempt'},
    );
    await api.getOrder(orderId: 'order-1', userId: 'user-1');
    final abandoned = await api.abandonOrder(
      orderId: 'order-1',
      userId: 'user-1',
    );

    expect(adapter.requests.map((request) => request.uri.path), [
      '/api/v2/payments/arc-pay/products',
      '/api/v2/payments/arc-pay/checkout',
      '/api/v2/payments/arc-pay/orders/order-1',
      '/api/v2/payments/arc-pay/orders/order-1/abandon',
    ]);
    expect(
      adapter.requests.any((request) => request.uri.path.contains('/api/v1/')),
      isFalse,
    );
    expect(adapter.requests[1].data, containsPair('platform', 'ios'));
    expect(adapter.requests[1].data['attempt_id'], 'attempt');
    for (final request in adapter.requests.skip(1)) {
      expect(request.headers['X-Asteria-User-Token'], 'access-token');
    }
    expect(adapter.requests[3].data, {'user_id': 'user-1'});
    expect(abandoned.clientState, 'abandoned');
  });

  test('does not create checkout after account switch', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = ArcPayPaymentsApi.forDio(
      dio,
      _SwitchingSession(initialUid: 'user-1', switchedUid: 'user-2'),
    );

    await expectLater(
      api.createCheckout(
        userId: 'user-1',
        productId: 'asteria_stars_10',
        requestId: 'request-race',
      ),
      throwsStateError,
    );

    expect(adapter.requests, isEmpty);
  });

  test('parses Arc Pay one-time PRO products and orders', () async {
    final product = ArcPayProduct.fromJson({
      'product_id': 'asteria_pro_month',
      'name': 'Asteria PRO — month',
      'product_type': 'pro_access',
      'coins': null,
      'duration_days': 30,
      'amount_minor': 49900,
      'currency': 'RUB',
    });
    final order = ArcPayOrder.fromJson({
      'order_id': 'order-pro',
      'product_id': 'asteria_pro_month',
      'product_type': 'pro_access',
      'coins': null,
      'duration_days': 30,
      'amount_minor': 49900,
      'currency': 'RUB',
      'status': 'fulfilled',
      'provider_status': 'captured',
      'client_state': 'active',
      'payment_method': 'bank_card',
      'balance': null,
      'unrecovered_coins': 0,
    });

    expect(product.productType, 'pro_access');
    expect(product.coins, isNull);
    expect(product.durationDays, 30);
    expect(order.productType, 'pro_access');
    expect(order.coins, isNull);
    expect(order.durationDays, 30);
  });
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

class _SwitchingSession implements AuthSessionService {
  _SwitchingSession({required this.initialUid, required this.switchedUid});

  final String initialUid;
  final String switchedUid;
  bool _switched = false;

  @override
  String? get currentEmail => null;

  @override
  String? get currentUid => _switched ? switchedUid : initialUid;

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => true;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async {
    _switched = true;
    return 'user-2-token';
  }

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

class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    const headers = {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    };
    if (options.path.endsWith('/products')) {
      return ResponseBody.fromString('[]', 200, headers: headers);
    }
    if (options.path.endsWith('/checkout')) {
      return ResponseBody.fromString(
        '{"order_id":"order-1","checkout_url":"https://checkout.example/order-1","status":"pending"}',
        200,
        headers: headers,
      );
    }
    final abandoned = options.path.endsWith('/abandon');
    return ResponseBody.fromString(
      '{"order_id":"order-1","product_id":"asteria_stars_10","coins":10,"amount_minor":4900,"currency":"RUB","status":"pending","provider_status":"created","client_state":"${abandoned ? 'abandoned' : 'active'}","unrecovered_coins":0}',
      200,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}
}
