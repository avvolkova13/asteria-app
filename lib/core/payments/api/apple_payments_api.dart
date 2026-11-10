import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/payments/apple/apple_models.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:dio/dio.dart';

class AppleApiException implements Exception {
  final String code;
  const AppleApiException(this.code);
  @override
  String toString() => 'AppleApiException($code)';
}

abstract interface class AppleLifecycleApi {
  Future<AppleCheckout> checkout({
    required String userId,
    required String attemptId,
    required String productId,
    Map<String, Object?>? analyticsContext,
  });
  Future<AppleReconciliation> reconcile({
    required String userId,
    required String signedTransactionJws,
    required String productId,
    String? attemptId,
    Map<String, Object?>? analyticsContext,
  });
  Future<AppleAttemptStatus> attempt({
    required String userId,
    required String attemptId,
  });
  Future<void> finishAck({
    required String userId,
    required String transactionId,
    required String environment,
  });
}

/// Apple lifecycle API only. No generic verify/account-binding compatibility.
/// Never install body logging: checkout responses contain account tokens.
class ApplePaymentsApi implements AppleLifecycleApi {
  final Dio _dio;
  final AuthSessionService _authSession;
  ApplePaymentsApi(Environment environment, this._authSession, {Dio? dio})
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
            ),
          );
  ApplePaymentsApi.forDio(this._dio, this._authSession);

  Future<Map<String, dynamic>> _request(
    String uid,
    String path, {
    Map<String, Object?>? data,
    bool get = false,
  }) async {
    if (_authSession.currentUid != uid) {
      throw const AppleApiException('identity_changed');
    }
    final token = await _authSession.getAccessTokenForUid(uid);
    if (token == null || token.isEmpty || _authSession.currentUid != uid) {
      throw const AppleApiException('identity_changed');
    }
    try {
      final response = await _dio.request<Object?>(
        'api/v1/payments/apple/$path',
        data: data,
        options: Options(
          method: get ? 'GET' : 'POST',
          headers: {'X-Asteria-User-Token': token},
          validateStatus: (_) => true,
        ),
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw AppleApiException(switch (response.statusCode) {
        401 => 'invalid_or_unauthenticated',
        400 || 422 => 'invalid_purchase',
        409 => 'account_conflict',
        404 => 'not_found',
        _ => 'unavailable',
      });
    } on DioException {
      throw const AppleApiException('offline');
    }
  }

  @override
  Future<AppleCheckout> checkout({
    required String userId,
    required String attemptId,
    required String productId,
    Map<String, Object?>? analyticsContext,
  }) async => AppleCheckout.fromJson(
    await _request(
      userId,
      'checkout',
      data: {
        'attempt_id': attemptId,
        'product_id': productId,
        if (analyticsContext != null) 'analytics_context': analyticsContext,
      },
    ),
  );
  @override
  Future<AppleReconciliation> reconcile({
    required String userId,
    required String signedTransactionJws,
    required String productId,
    String? attemptId,
    Map<String, Object?>? analyticsContext,
  }) async => AppleReconciliation.fromJson(
    await _request(
      userId,
      'reconcile',
      data: {
        'signed_transaction_jws': signedTransactionJws,
        'product_id': productId,
        if (attemptId != null) 'attempt_id': attemptId,
        if (analyticsContext != null) 'analytics_context': analyticsContext,
      },
    ),
  );
  @override
  Future<AppleAttemptStatus> attempt({
    required String userId,
    required String attemptId,
  }) async => AppleAttemptStatus.fromJson(
    await _request(userId, 'attempts/$attemptId', get: true),
  );
  @override
  Future<void> finishAck({
    required String userId,
    required String transactionId,
    required String environment,
  }) async {
    final result = await _request(
      userId,
      'finish-ack',
      data: {'transaction_id': transactionId, 'environment': environment},
    );
    if (result['finish_state'] != 'finished') {
      throw const AppleApiException('finish_unconfirmed');
    }
  }
}
