import 'package:asteria_app/core/environment/environment.dart';
import 'package:dio/dio.dart';

class EmailCodeChallenge {
  final String challengeId;
  final int expiresIn;
  final int resendAfter;

  const EmailCodeChallenge({
    required this.challengeId,
    required this.expiresIn,
    required this.resendAfter,
  });

  factory EmailCodeChallenge.fromJson(Map<String, dynamic> json) {
    return EmailCodeChallenge(
      challengeId: json['challenge_id'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      resendAfter: (json['resend_after'] as num).toInt(),
    );
  }
}

class EmailCodeVerification {
  final String uid;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final bool profileExists;

  const EmailCodeVerification({
    required this.uid,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.profileExists,
  });

  factory EmailCodeVerification.fromJson(Map<String, dynamic> json) {
    return EmailCodeVerification(
      uid: json['uid'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: (json['expires_in'] as num).toInt(),
      profileExists: json['profile_exists'] as bool,
    );
  }
}

enum EmailAuthErrorType {
  invalidInput,
  invalidOrExpiredCode,
  rateLimited,
  deliveryFailed,
  unavailable,
  network,
  unknown,
}

class EmailAuthException implements Exception {
  final EmailAuthErrorType type;
  final String? code;

  const EmailAuthException(this.type, {this.code});
}

class EmailAuthApi {
  final Dio _dio;

  EmailAuthApi(Environment environment, {Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: environment.asteriaBackendUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 30),
              headers: {
                'Authorization': 'Bearer ${environment.asteriaApiKey}',
                'Content-Type': 'application/json',
              },
              validateStatus: (_) => true,
            ),
          );

  EmailAuthApi.forDio(Dio dio) : _dio = dio {
    _dio.options.validateStatus = (_) => true;
  }

  Future<EmailCodeChallenge> requestCode(String email) async {
    try {
      final response = await _dio.post<Object?>(
        'api/v1/auth/email/request-code',
        data: {'email': email},
      );
      final data = _mapResponse(response);
      return EmailCodeChallenge.fromJson(data);
    } on DioException {
      throw const EmailAuthException(EmailAuthErrorType.network);
    }
  }

  Future<EmailCodeVerification> verifyCode({
    required String challengeId,
    required String code,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        'api/v1/auth/email/verify-code',
        data: {'challenge_id': challengeId, 'code': code},
      );
      final data = _mapResponse(response);
      return EmailCodeVerification.fromJson(data);
    } on DioException {
      throw const EmailAuthException(EmailAuthErrorType.network);
    }
  }

  Map<String, dynamic> _mapResponse(Response<Object?> response) {
    final status = response.statusCode ?? 0;
    final data = response.data;
    if (status >= 200 && status < 300 && data is Map<String, dynamic>) {
      return data;
    }

    final code = _extractErrorCode(data);
    if (status == 401) {
      throw EmailAuthException(
        EmailAuthErrorType.invalidOrExpiredCode,
        code: code,
      );
    }
    if (status == 422) {
      throw EmailAuthException(EmailAuthErrorType.invalidInput, code: code);
    }
    if (status == 429) {
      throw EmailAuthException(EmailAuthErrorType.rateLimited, code: code);
    }
    if (status == 502) {
      throw EmailAuthException(EmailAuthErrorType.deliveryFailed, code: code);
    }
    if (status == 503) {
      throw EmailAuthException(EmailAuthErrorType.unavailable, code: code);
    }
    throw EmailAuthException(EmailAuthErrorType.unknown, code: code);
  }

  String? _extractErrorCode(Object? data) {
    if (data is! Map) return null;
    final detail = data['detail'];
    if (detail is String) return detail;
    if (detail is Map) {
      final code = detail['code'] ?? detail['error'];
      return code?.toString();
    }
    return null;
  }
}
