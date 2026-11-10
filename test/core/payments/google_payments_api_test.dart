import 'dart:typed_data';

import 'package:asteria_app/core/payments/api/google_payments_api.dart';
import 'package:asteria_app/core/payments/api/store_payments_api.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'verify authenticates with backend session and does not send user_id',
    () async {
      final adapter = _RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final api = GooglePaymentsApi.forDio(dio, _FakeSession('access-token'));

      final result = await api.verify(
        userId: 'mongo-user',
        verificationData: 'purchase-token',
        productId: 'asteria_stars_10',
        analyticsContext: const {'attempt_id': 'attempt'},
      );

      final request = adapter.requests.single;
      expect(request.uri.path, '/api/v1/payments/google/verify');
      expect(request.headers['X-Asteria-User-Token'], 'access-token');
      expect(request.data, isNot(contains('user_id')));
      expect(request.data, containsPair('purchase_token', 'purchase-token'));
      expect(request.data['attempt_id'], 'attempt');
      expect(request.data.containsKey('analytics_context'), isFalse);
      expect(result.status, 'fulfilled');
    },
  );

  test('expired session HTTP 401 keeps a paid token retryable', () async {
    final adapter = _RecordingAdapter()..status = 401;
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com/',
        validateStatus: (_) => true,
      ),
    )..httpClientAdapter = adapter;
    final api = GooglePaymentsApi.forDio(dio, _FakeSession('expired'));
    await expectLater(
      api.verify(
        userId: 'mongo-user',
        verificationData: 'token',
        productId: 'asteria_stars_10',
      ),
      throwsA(isA<StoreVerifyServerException>()),
    );
  });

  test(
    'account switch during verification cannot return old account balance',
    () async {
      final session = _FakeSession('token');
      final adapter = _RecordingAdapter()
        ..onRequest = () {
          session.uid = 'new-user';
        };
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final api = GooglePaymentsApi.forDio(dio, session);
      await expectLater(
        api.verify(
          userId: 'mongo-user',
          verificationData: 'token',
          productId: 'asteria_stars_10',
        ),
        throwsA(isA<StoreVerifyServerException>()),
      );
    },
  );

  test('missing session keeps a paid token retryable', () async {
    final api = GooglePaymentsApi.forDio(Dio(), _FakeSession(null));
    await expectLater(
      api.verify(
        userId: 'mongo-user',
        verificationData: 'token',
        productId: 'asteria_stars_10',
      ),
      throwsA(isA<StoreVerifyServerException>()),
    );
  });

  test('verify does not send purchase after account switch', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = GooglePaymentsApi.forDio(dio, _FakeSession('access-token'));

    expect(
      () => api.verify(
        userId: 'other-user',
        verificationData: 'purchase-token',
        productId: 'asteria_stars_10',
      ),
      throwsA(isA<StoreVerifyServerException>()),
    );
    expect(adapter.requests, isEmpty);
  });
}

class _FakeSession implements AuthSessionService {
  _FakeSession(this.token);

  final String? token;
  String uid = 'mongo-user';

  @override
  String? get currentEmail => null;
  @override
  String? get currentUid => uid;
  @override
  bool get hasRecentSignIn => true;
  @override
  bool get hasSession => token != null;
  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async => token;
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
  int status = 200;
  void Function()? onRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    onRequest?.call();
    const headers = {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    };
    const body =
        '{"transaction_id":"google-transaction","status":"fulfilled","balance":20,"product_id":"asteria_stars_10","product_type":"consumable"}';
    return ResponseBody.fromString(body, status, headers: headers);
  }

  @override
  void close({bool force = false}) {}
}
