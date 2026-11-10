import 'dart:typed_data';

import 'package:asteria_app/core/payments/api/arc_pay_subscriptions_api.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses v2 endpoints and User session for owned operations', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = ArcPaySubscriptionsApi.forDio(dio, _FakeSession());

    await api.getProducts();
    final checkout = await api.createCheckout(
      productId: 'asteria_pro_month',
      requestId: 'request-1',
    );
    await api.getCurrent();
    await api.cancel(checkout.subscriptionId);

    expect(adapter.requests.map((request) => request.uri.path), [
      '/api/v2/payments/arc-pay/subscriptions/products',
      '/api/v2/payments/arc-pay/subscriptions/checkout',
      '/api/v2/payments/arc-pay/subscriptions/current',
      '/api/v2/payments/arc-pay/subscriptions/subscription-1/cancel',
    ]);
    for (final request in adapter.requests.skip(1)) {
      expect(request.headers['X-Asteria-User-Token'], 'access-token');
    }
    expect(adapter.requests[1].data, isNot(contains('user_id')));
  });
}

class _FakeSession implements AuthSessionService {
  @override
  String? get currentEmail => null;
  @override
  String? get currentUid => 'mongo-user';
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

class _RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

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
    const body =
        '{"subscription_id":"subscription-1","status":"setup_pending","checkout_url":"https://checkout.example/setup","product_id":"asteria_pro_month","cancel_at_period_end":false}';
    return ResponseBody.fromString(body, 200, headers: headers);
  }

  @override
  void close({bool force = false}) {}
}
