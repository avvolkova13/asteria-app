import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/payments/api/store_payments_api.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:dio/dio.dart';

class GooglePaymentsApi implements StorePaymentsApi {
  GooglePaymentsApi(Environment environment, this._authSession)
    : _dio = Dio(
        BaseOptions(
          baseUrl: environment.asteriaBackendUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          validateStatus: (_) => true,
          headers: {
            'Authorization': 'Bearer ${environment.asteriaApiKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

  final Dio _dio;
  final AuthSessionService _authSession;

  GooglePaymentsApi.forDio(this._dio, this._authSession);

  @override
  Future<String> preparePurchaseUserToken(String userId) async {
    return userId;
  }

  @override
  Future<void> recordClientDiagnostic({
    required String userId,
    required String stage,
    String? productId,
    Map<String, Object?> details = const {},
  }) async {}

  @override
  Future<StoreVerifyResponse> verify({
    required String userId,
    required String verificationData,
    required String productId,
    Map<String, Object?>? analyticsContext,
  }) async {
    if (_authSession.currentUid != userId) {
      throw const StoreVerifyServerException('User session changed');
    }
    final accessToken = await _authSession.getAccessTokenForUid(userId);
    if (accessToken == null || accessToken.isEmpty) {
      throw const StoreVerifyServerException('User session is required');
    }
    final response = await _dio.post<dynamic>(
      'api/v1/payments/google/verify',
      data: {
        'purchase_token': verificationData,
        'product_id': productId,
        if (analyticsContext?['attempt_id'] != null)
          'attempt_id': analyticsContext!['attempt_id'],
      },
      options: Options(headers: {'X-Asteria-User-Token': accessToken}),
    );
    if (_authSession.currentUid != userId) {
      throw const StoreVerifyServerException('User session changed');
    }
    final status = response.statusCode ?? 0;
    if (status == 200 && response.data is Map<String, dynamic>) {
      return StoreVerifyResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    final message = _extractMessage(response.data) ?? 'HTTP $status';
    if (status == 401) throw StoreVerifyServerException(message);
    if (status == 400 || status == 409 || status == 422) {
      throw StoreVerifyBadRequestException(message);
    }
    throw StoreVerifyServerException(message);
  }

  String? _extractMessage(Object? data) {
    if (data is Map) {
      return (data['detail'] ?? data['message'] ?? data['error'])?.toString();
    }
    return data?.toString();
  }
}
