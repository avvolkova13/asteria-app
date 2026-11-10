import 'dart:convert';
import 'dart:typed_data';

import 'package:asteria_app/features/auth/data/email_auth_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses email auth contracts without sending an expected OTP', () async {
    final adapter = _EmailAuthAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = EmailAuthApi.forDio(dio);

    final challenge = await api.requestCode('user@example.com');
    final verification = await api.verifyCode(
      challengeId: challenge.challengeId,
      code: '123456',
    );

    expect(challenge.expiresIn, 600);
    expect(challenge.resendAfter, 60);
    expect(verification.uid, 'mongo-uid');
    expect(verification.accessToken, 'access-token');
    expect(verification.refreshToken, 'refresh-token');
    expect(verification.tokenType, 'bearer');
    expect(verification.expiresIn, 900);
    expect(adapter.requests.map((request) => request.uri.path), [
      '/api/v1/auth/email/request-code',
      '/api/v1/auth/email/verify-code',
    ]);
    expect(adapter.bodies.first, {'email': 'user@example.com'});
    expect(adapter.bodies.first.containsKey('code'), isFalse);
    expect(adapter.bodies.last, {
      'challenge_id': '11111111-1111-4111-8111-111111111111',
      'code': '123456',
    });
  });

  test('maps invalid or expired code to a typed error', () async {
    final adapter = _EmailAuthAdapter(verifyStatus: 401);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = EmailAuthApi.forDio(dio);

    await api.requestCode('user@example.com');

    expect(
      () => api.verifyCode(
        challengeId: '11111111-1111-4111-8111-111111111111',
        code: '000000',
      ),
      throwsA(
        isA<EmailAuthException>().having(
          (error) => error.type,
          'type',
          EmailAuthErrorType.invalidOrExpiredCode,
        ),
      ),
    );
  });
}

class _EmailAuthAdapter implements HttpClientAdapter {
  final int verifyStatus;
  final List<RequestOptions> requests = [];
  final List<Map<String, dynamic>> bodies = [];

  _EmailAuthAdapter({this.verifyStatus = 200});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    bodies.add(Map<String, dynamic>.from(options.data as Map));
    if (options.uri.path.endsWith('request-code')) {
      return _jsonResponse({
        'challenge_id': '11111111-1111-4111-8111-111111111111',
        'expires_in': 600,
        'resend_after': 60,
      });
    }
    if (verifyStatus == 401) {
      return _jsonResponse({
        'detail': {'code': 'invalid_or_expired_code'},
      }, status: 401);
    }
    return _jsonResponse({
      'uid': 'mongo-uid',
      'access_token': 'access-token',
      'refresh_token': 'refresh-token',
      'token_type': 'bearer',
      'expires_in': 900,
      'profile_exists': true,
    });
  }

  ResponseBody _jsonResponse(Map<String, dynamic> data, {int status = 200}) {
    return ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: const {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
