import 'dart:typed_data';

import 'package:asteria_app/core/payments/api/apple_payments_api.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'checkout uses attempt-unique server token and authenticated new wire',
    () async {
      final adapter = _RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final api = ApplePaymentsApi.forDio(dio, _FakeSession());
      final response = await api.checkout(
        userId: 'mongo-user',
        attemptId: 'attempt',
        productId: 'asteria_pro_month',
      );
      expect(response.appAccountToken, '00000000-0000-4000-8000-000000000001');
      final request = adapter.requests.single;
      expect(request.uri.path, '/api/v1/payments/apple/checkout');
      expect(request.data['attempt_id'], 'attempt');
      expect(request.headers['X-Asteria-User-Token'], 'access-token');
    },
  );
  test(
    'reconcile keeps exact and original identities and finish authority',
    () async {
      final adapter = _RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final api = ApplePaymentsApi.forDio(dio, _FakeSession());
      final response = await api.reconcile(
        userId: 'mongo-user',
        signedTransactionJws: 'synthetic-jws',
        productId: 'asteria_pro_month',
      );
      expect(response.transactionId, 'exact');
      expect(response.originalTransactionId, 'chain');
      expect(response.finishAllowed, isTrue);
      expect(
        adapter.requests.single.uri.path,
        '/api/v1/payments/apple/reconcile',
      );
      expect(adapter.requests.single.data, isNot(contains('user_id')));
    },
  );
  test('changed identity prevents transmission', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = ApplePaymentsApi.forDio(dio, _FakeSession());
    await expectLater(
      api.checkout(userId: 'other', attemptId: 'a', productId: 'p'),
      throwsA(isA<AppleApiException>()),
    );
    expect(adapter.requests, isEmpty);
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
    final checkout = options.uri.path.endsWith('/checkout');
    return ResponseBody.fromString(
      checkout
          ? '{"attempt_id":"attempt","app_account_token":"00000000-0000-4000-8000-000000000001","checkout_action":"continue","entitlement":{"balance":10,"subscription_type":"free"}}'
          : '{"transaction_id":"exact","original_transaction_id":"chain","product_id":"asteria_pro_month","environment":"test","disposition":"delivered","finish_allowed":true,"finish_state":"pending","checkout_action":"continue","entitlement":{"balance":10,"subscription_type":"pro"}}',
      200,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}
}
