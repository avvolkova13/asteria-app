import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/balance/domain/reward_models.dart';
import 'package:dio/dio.dart';

class RewardsApi {
  final Dio _dio;
  final AuthSessionService _authSession;

  RewardsApi(Environment environment, this._authSession, {Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: environment.asteriaBackendUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
              headers: {
                'Authorization': 'Bearer ${environment.asteriaApiKey}',
                'Content-Type': 'application/json',
              },
            ),
          );

  RewardsApi.forDio(this._dio, this._authSession) {
    _dio.options.validateStatus = (_) => true;
  }

  Future<RewardsResponseModel> getRewards({
    required String userId,
    required int timezoneOffsetMinutes,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'api/v2/me/monetization',
      options: await _userOptions(expectedUid: userId),
    );
    return _parseResponse(response);
  }

  Future<RewardsResponseModel> postEvent(PendingRewardEvent event) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'api/v2/rewards/events',
      data: {
        'reward_key': rewardKeyForEvent(event.eventType),
        'evidence': _evidenceFor(event),
      },
      options: await _userOptions(
        expectedUid: event.userId,
        headers: {'Idempotency-Key': event.eventId},
      ),
    );
    return _parseResponse(response);
  }

  Future<String> serveArticleRead({
    required String articleId,
    required String idempotencyKey,
  }) async {
    final expectedUid = _authSession.currentUid;
    if (expectedUid == null) {
      throw Exception('User session is required');
    }
    final response = await _dio.post<Map<String, dynamic>>(
      'api/v2/content/articles/$articleId/reads',
      options: await _userOptions(
        expectedUid: expectedUid,
        headers: {'Idempotency-Key': idempotencyKey},
      ),
    );
    final status = response.statusCode ?? 0;
    final data = response.data;
    if (status >= 200 && status < 300 && data != null) {
      return data['read_receipt_id'] as String? ?? '';
    }
    throw Exception(_message(response) ?? 'HTTP $status');
  }

  Future<Options> _userOptions({
    String? expectedUid,
    Map<String, dynamic>? headers,
  }) async {
    if (expectedUid != null && _authSession.currentUid != expectedUid) {
      throw Exception('User session changed');
    }
    final token = expectedUid == null
        ? await _authSession.getAccessToken()
        : await _authSession.getAccessTokenForUid(expectedUid);
    if (token == null || token.isEmpty) {
      throw Exception('User session is required');
    }
    return Options(
      headers: {if (headers != null) ...headers, 'X-Asteria-User-Token': token},
    );
  }

  Map<String, dynamic> _evidenceFor(PendingRewardEvent event) {
    return (switch (event.eventType) {
      RewardEventType.onboardingComplete => {'completed': true},
      RewardEventType.tarotSpreadComplete => {
        'execution_id': event.referenceId,
      },
      RewardEventType.articleRead => {'read_receipt_id': event.referenceId},
      RewardEventType.shareComplete => {
        'timezone_offset_minutes': event.timezoneOffsetMinutes,
        'client_attested': true,
      },
      RewardEventType.dailyCheckIn => {
        'timezone_offset_minutes': event.timezoneOffsetMinutes,
      },
    })..removeWhere((_, value) => value == null);
  }

  RewardsResponseModel _parseResponse(Response<Map<String, dynamic>> response) {
    final status = response.statusCode ?? 0;
    final data = response.data;
    if (status >= 200 && status < 300 && data != null) {
      return RewardsResponseModel.fromJson(data);
    }
    throw Exception(_message(response) ?? 'HTTP $status');
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
