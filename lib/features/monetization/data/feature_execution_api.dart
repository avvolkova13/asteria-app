import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/monetization/domain/feature_execution_models.dart';
import 'package:dio/dio.dart';

class FeatureExecutionException implements Exception {
  final String code;
  final String message;

  const FeatureExecutionException(this.code, this.message);

  @override
  String toString() => 'FeatureExecutionException($code): $message';
}

class FeatureExecutionInsufficientStarsException
    extends FeatureExecutionException {
  const FeatureExecutionInsufficientStarsException(String message)
    : super('insufficient_stars', message);

  @override
  String toString() =>
      'FeatureExecutionInsufficientStarsException($code): $message';
}

class FeatureExecutionIncompleteException extends FeatureExecutionException {
  final String status;

  FeatureExecutionIncompleteException(this.status)
    : super('execution_$status', 'Feature execution did not finish: $status');
}

class FeatureExecutionApi {
  final Dio _dio;
  final AuthSessionService _authSession;

  FeatureExecutionApi(Environment environment, this._authSession)
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

  FeatureExecutionApi.forDio(this._dio, this._authSession) {
    _dio.options.validateStatus = (_) => true;
  }

  Future<TarotSpreadResultModel> createTarotSpread({
    required String spreadType,
    required int expectedCatalogRevision,
    required String idempotencyKey,
    bool requirePro = false,
  }) async {
    final response = await _dio.post<dynamic>(
      'api/v2/features/tarot_spread/executions',
      data: {
        'payload': {'spread_type': spreadType},
        'expected_catalog_revision': expectedCatalogRevision,
        if (requirePro) 'require_pro': true,
      },
      options: await _currentUserOptions(
        headers: {'Idempotency-Key': idempotencyKey},
      ),
    );
    final status = response.statusCode ?? 0;
    if (status < 200 ||
        status >= 300 ||
        response.data is! Map<String, dynamic>) {
      throw _exception(response, status);
    }
    final decision = FeatureExecutionDecisionModel.fromJson(
      response.data as Map<String, dynamic>,
    );
    if (!decision.succeeded || decision.executionId.isEmpty) {
      throw FeatureExecutionIncompleteException(decision.status);
    }
    return getTarotSpreadResult(decision.executionId);
  }

  Future<TarotSpreadResultModel> getTarotSpreadResult(
    String executionId,
  ) async {
    final response = await _dio.get<dynamic>(
      'api/v2/features/tarot_spread/executions/$executionId/result',
      options: await _currentUserOptions(),
    );
    final status = response.statusCode ?? 0;
    if (status >= 200 &&
        status < 300 &&
        response.data is Map<String, dynamic>) {
      return TarotSpreadResultModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception(_message(response) ?? 'HTTP $status');
  }

  Future<TarotSpreadResultModel?> getLatestTarotSpread({
    required String spreadType,
  }) async {
    final response = await _dio.get<dynamic>(
      'api/v2/features/tarot_spread/results/latest',
      queryParameters: {'spread_type': spreadType},
      options: await _currentUserOptions(),
    );
    final status = response.statusCode ?? 0;
    if (status == 404) return null;
    if (status >= 200 &&
        status < 300 &&
        response.data is Map<String, dynamic>) {
      return TarotSpreadResultModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception(_message(response) ?? 'HTTP $status');
  }

  Future<ClientFeatureResultModel> createClientResultFeature({
    required String featureKey,
    required Map<String, dynamic> result,
    required int expectedCatalogRevision,
    required String idempotencyKey,
    bool requirePro = false,
  }) async {
    final response = await _dio.post<dynamic>(
      'api/v2/features/$featureKey/executions',
      data: {
        'payload': {'result': result},
        'expected_catalog_revision': expectedCatalogRevision,
        if (requirePro) 'require_pro': true,
      },
      options: await _currentUserOptions(
        headers: {'Idempotency-Key': idempotencyKey},
      ),
    );
    final status = response.statusCode ?? 0;
    if (status < 200 ||
        status >= 300 ||
        response.data is! Map<String, dynamic>) {
      throw _exception(response, status);
    }
    final decision = FeatureExecutionDecisionModel.fromJson(
      response.data as Map<String, dynamic>,
    );
    if (!decision.succeeded || decision.executionId.isEmpty) {
      throw FeatureExecutionIncompleteException(decision.status);
    }
    return getClientFeatureResult(decision.executionId);
  }

  Future<ClientFeatureResultModel> createGeneratedFeature({
    required String featureKey,
    required Map<String, dynamic> payload,
    required int expectedCatalogRevision,
    required String idempotencyKey,
    bool requirePro = false,
  }) async {
    final response = await _dio.post<dynamic>(
      'api/v2/features/$featureKey/executions',
      data: {
        'payload': payload,
        'expected_catalog_revision': expectedCatalogRevision,
        if (requirePro) 'require_pro': true,
      },
      options: await _currentUserOptions(
        headers: {'Idempotency-Key': idempotencyKey},
      ),
    );
    final status = response.statusCode ?? 0;
    if (status < 200 ||
        status >= 300 ||
        response.data is! Map<String, dynamic>) {
      throw _exception(response, status);
    }
    final decision = FeatureExecutionDecisionModel.fromJson(
      response.data as Map<String, dynamic>,
    );
    if (!decision.succeeded || decision.executionId.isEmpty) {
      throw FeatureExecutionIncompleteException(decision.status);
    }
    return getClientFeatureResult(decision.executionId);
  }

  Future<ClientFeatureResultModel> getClientFeatureResult(
    String executionId,
  ) async {
    final response = await _dio.get<dynamic>(
      'api/v2/features/client-results/$executionId',
      options: await _currentUserOptions(),
    );
    final status = response.statusCode ?? 0;
    if (status >= 200 &&
        status < 300 &&
        response.data is Map<String, dynamic>) {
      return ClientFeatureResultModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception(_message(response) ?? 'HTTP $status');
  }

  Future<UserModel> translateNatalCard({required String language}) async {
    final response = await _dio.post<dynamic>(
      'api/v2/features/natal_chart/translations/$language',
      options: await _currentUserOptions(),
    );
    final status = response.statusCode ?? 0;
    if (status >= 200 &&
        status < 300 &&
        response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(
        Map<String, dynamic>.from(data['user'] as Map? ?? const {}),
      );
    }
    throw _exception(response, status);
  }

  Future<Options> _currentUserOptions({Map<String, dynamic>? headers}) async {
    final expectedUid = _authSession.currentUid;
    if (expectedUid == null) {
      throw Exception('User session is required');
    }
    final token = await _authSession.getAccessTokenForUid(expectedUid);
    if (token == null || token.isEmpty) {
      throw Exception('User session is required');
    }
    return Options(
      headers: {if (headers != null) ...headers, 'X-Asteria-User-Token': token},
    );
  }

  String? _message(Response<dynamic> response) {
    final data = response.data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is Map) {
        return (detail['message'] ?? detail['code'])?.toString();
      }
      return (detail ?? data['message'] ?? data['error'])?.toString();
    }
    return data?.toString();
  }

  Exception _exception(Response<dynamic> response, int status) {
    final code = _code(response);
    final message = _message(response) ?? 'HTTP $status';
    if (code == 'insufficient_stars') {
      return FeatureExecutionInsufficientStarsException(message);
    }
    if (code != null && code.isNotEmpty) {
      return FeatureExecutionException(code, message);
    }
    return Exception(message);
  }

  String? _code(Response<dynamic> response) {
    final data = response.data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is Map) {
        return detail['code']?.toString();
      }
      return data['code']?.toString();
    }
    return null;
  }
}
