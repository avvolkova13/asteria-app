import 'package:asteria_app/features/monetization/data/feature_execution_api.dart';
import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:dio/dio.dart';

class MonetizationApi {
  final Dio _dio;
  final AuthSessionService _authSession;

  MonetizationApi(Environment environment, this._authSession)
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

  MonetizationApi.forDio(this._dio, this._authSession) {
    _dio.options.validateStatus = (_) => true;
  }

  Future<MonetizationStateModel> getCurrent() async {
    final response = await _dio.get<dynamic>(
      'api/v2/me/monetization',
      options: await _currentUserOptions(),
    );
    final status = response.statusCode ?? 0;
    if (status >= 200 &&
        status < 300 &&
        response.data is Map<String, dynamic>) {
      return MonetizationStateModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception(_message(response) ?? 'HTTP $status');
  }

  Future<List<WalletHistoryEntryModel>> getWalletHistory({
    int limit = 50,
  }) async {
    final response = await _dio.get<dynamic>(
      'api/v2/me/wallet/entries',
      queryParameters: {'limit': limit},
      options: await _currentUserOptions(),
    );
    final status = response.statusCode ?? 0;
    if (status >= 200 &&
        status < 300 &&
        response.data is Map<String, dynamic>) {
      final items =
          (response.data as Map<String, dynamic>)['items'] as List<dynamic>? ??
          const [];
      return items
          .map(
            (item) => WalletHistoryEntryModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
    }
    throw Exception(_message(response) ?? 'HTTP $status');
  }

  Future<WalletHistoryPageModel> getWalletHistoryPage({
    int limit = 50,
    WalletHistoryFilter filter = WalletHistoryFilter.all,
    int? beforeSequence,
  }) async {
    final response = await _dio.get<dynamic>(
      'api/v2/me/wallet/entries',
      queryParameters: {
        'limit': limit,
        'filter': filter.name,
        if (beforeSequence != null) 'before_sequence': beforeSequence,
      },
      options: await _currentUserOptions(),
    );
    final status = response.statusCode ?? 0;
    if (status >= 200 &&
        status < 300 &&
        response.data is Map<String, dynamic>) {
      return WalletHistoryPageModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception(_message(response) ?? 'HTTP $status');
  }

  Future<Map<String, RequestQuotaModel>> getRequestQuotas() async {
    final response = await _dio.get<dynamic>(
      'api/v2/me/request-quotas',
      options: await _currentUserOptions(),
    );
    final status = response.statusCode ?? 0;
    if (status >= 200 &&
        status < 300 &&
        response.data is Map<String, dynamic>) {
      final items = Map<String, dynamic>.from(
        (response.data as Map<String, dynamic>)['items'] as Map? ?? const {},
      );
      return items.map(
        (key, value) => MapEntry(
          key,
          RequestQuotaModel.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      );
    }
    throw Exception(_message(response) ?? 'HTTP $status');
  }

  Future<RequestQuotaPurchaseResultModel> purchaseRequestPack({
    required String feature,
    required int quantity,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<dynamic>(
      'api/v2/me/request-quotas/purchases',
      data: {'feature': feature, 'quantity': quantity},
      options: await _currentUserOptions(
        headers: {'Idempotency-Key': idempotencyKey},
      ),
    );
    final status = response.statusCode ?? 0;
    if (status >= 200 &&
        status < 300 &&
        response.data is Map<String, dynamic>) {
      return RequestQuotaPurchaseResultModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    final data = response.data;
    final detail = data is Map ? data['detail'] : null;
    if (detail is Map && detail['code'] == 'wallet_insufficient_funds') {
      throw FeatureExecutionInsufficientStarsException(
        _message(response) ?? 'insufficient_stars',
      );
    }
    throw Exception(_message(response) ?? 'HTTP $status');
  }

  Future<RequestQuotaPurchaseResultModel> purchaseShopRequestPack({
    required String productId,
    required int quantity,
    required int expectedPrice,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<dynamic>(
      'api/v2/me/request-quotas/shop-purchases',
      data: {
        'product_id': productId,
        'quantity': quantity,
        'expected_price': expectedPrice,
      },
      options: await _currentUserOptions(
        headers: {'Idempotency-Key': idempotencyKey},
      ),
    );
    final status = response.statusCode ?? 0;
    if (status >= 200 &&
        status < 300 &&
        response.data is Map<String, dynamic>) {
      return RequestQuotaPurchaseResultModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    final data = response.data;
    final detail = data is Map ? data['detail'] : null;
    if (detail is Map && detail['code'] == 'wallet_insufficient_funds') {
      throw FeatureExecutionInsufficientStarsException(
        _message(response) ?? 'insufficient_stars',
      );
    }
    throw Exception(_message(response) ?? 'HTTP $status');
  }

  Future<RequestQuotaConsumeResultModel> consumeRequest({
    required String feature,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<dynamic>(
      'api/v2/me/request-quotas/consume',
      data: {'feature': feature},
      options: await _currentUserOptions(
        headers: {'Idempotency-Key': idempotencyKey},
      ),
    );
    final status = response.statusCode ?? 0;
    if (status >= 200 &&
        status < 300 &&
        response.data is Map<String, dynamic>) {
      return RequestQuotaConsumeResultModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception(_message(response) ?? 'HTTP $status');
  }

  Future<RequestQuotaCommandResultModel> executeRequestQuotaCommand({
    required String feature,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<dynamic>(
      'api/v2/me/request-quotas/commands/$feature',
      data: {'payload': payload},
      options: await _currentUserOptions(
        headers: {'Idempotency-Key': idempotencyKey},
      ),
    );
    final status = response.statusCode ?? 0;
    if (status >= 200 &&
        status < 300 &&
        response.data is Map<String, dynamic>) {
      return RequestQuotaCommandResultModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception(_message(response) ?? 'HTTP $status');
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
}
