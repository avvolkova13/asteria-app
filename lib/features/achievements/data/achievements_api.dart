import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/achievements/domain/achievement_event.dart';
import 'package:dio/dio.dart';

class AchievementsApi {
  AchievementsApi(Environment environment, this._session)
    : _dio = Dio(
        BaseOptions(
          baseUrl: environment.asteriaBackendUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: {'Authorization': 'Bearer ${environment.asteriaApiKey}'},
        ),
      );

  AchievementsApi.forDio(this._dio, this._session);
  final Dio _dio;
  final AuthSessionService _session;

  Future<UserStatisticsModel> record(AchievementEvent event) async {
    final token = await _session.getAccessTokenForUid(event.userId);
    if (token == null || token.isEmpty || _session.currentUid != event.userId) {
      throw StateError('Achievement account changed');
    }
    final response = await _dio.post<Map<String, dynamic>>(
      'api/v1/users/me/achievement-events',
      data: {'kind': event.kind.wireValue, 'reference': event.reference},
      options: Options(headers: {'X-Asteria-User-Token': token}),
    );
    final data = response.data;
    if (response.statusCode != 200 ||
        data == null ||
        data['uid'] != event.userId ||
        data['statistics'] is! Map<String, dynamic>) {
      throw StateError('Invalid achievement response');
    }
    return UserStatisticsModel.fromJson(
      data['statistics'] as Map<String, dynamic>,
    );
  }
}
