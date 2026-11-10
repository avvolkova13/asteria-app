import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:dio/dio.dart';

class UserProfileApi {
  final Dio _dio;
  final AuthSessionService _authSession;

  UserProfileApi(Environment environment, this._authSession)
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

  UserProfileApi.forDio(this._dio, this._authSession) {
    _dio.options.validateStatus = (_) => true;
  }

  Future<UserModel?> getCurrentUser() async {
    final expectedUid = _authSession.currentUid;
    if (expectedUid == null) {
      throw Exception('User session is required');
    }
    final response = await _dio.get<dynamic>(
      'api/v1/users/me',
      options: await _userOptions(expectedUid: expectedUid),
    );
    return _userOrNull(response);
  }

  Future<UserModel?> getUserById(String userId) async {
    if (_authSession.currentUid == userId) {
      return getCurrentUser();
    }
    throw Exception('Arbitrary user profile access is disabled');
  }

  Future<UserModel> completeCurrentProfile(UserModel user) async {
    final payload = _profilePayload(user)
      ..remove('auth_method')
      ..remove('phone_number');
    final response = await _dio.post<dynamic>(
      'api/v1/users/me/complete-profile',
      data: payload,
      options: await _userOptions(expectedUid: user.id),
    );
    return _requireUser(response);
  }

  Future<UserModel> createUser(UserModel user) async {
    if (_authSession.hasSession) {
      return completeCurrentProfile(user);
    }
    throw Exception('User session is required');
  }

  Future<UserModel> updateCurrentUser(UserModel user) async {
    final response = await _dio.patch<dynamic>(
      'api/v1/users/me',
      data: _profilePatchPayload(user),
      options: await _userOptions(expectedUid: user.id),
    );
    return _requireUser(response);
  }

  Future<UserModel> updateUser(UserModel user) async {
    if (_authSession.currentUid == user.id) {
      return updateCurrentUser(user);
    }
    throw Exception('Arbitrary user profile access is disabled');
  }

  Future<void> deleteCurrentUser() async {
    final expectedUid = _authSession.currentUid;
    if (expectedUid == null) {
      throw Exception('User session is required');
    }
    final response = await _dio.delete<dynamic>(
      'api/v1/users/me',
      options: await _userOptions(expectedUid: expectedUid),
    );
    if ((response.statusCode ?? 0) < 200 || (response.statusCode ?? 0) >= 300) {
      throw Exception(_message(response) ?? 'HTTP ${response.statusCode}');
    }
  }

  Future<void> deleteUserById(String userId) async {
    if (_authSession.currentUid == userId) {
      await deleteCurrentUser();
      return;
    }
    throw Exception('Arbitrary user profile access is disabled');
  }

  Future<Options> _userOptions({String? expectedUid}) async {
    if (expectedUid != null && _authSession.currentUid != expectedUid) {
      throw Exception('User session changed');
    }
    final token = expectedUid == null
        ? await _authSession.getAccessToken()
        : await _authSession.getAccessTokenForUid(expectedUid);
    if (token == null || token.isEmpty) {
      throw Exception('User session is required');
    }
    return Options(headers: {'X-Asteria-User-Token': token});
  }

  UserModel? _userOrNull(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    if (status == 404) return null;
    if (status >= 200 &&
        status < 300 &&
        response.data is Map<String, dynamic>) {
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception(_message(response) ?? 'HTTP $status');
  }

  UserModel _requireUser(Response<dynamic> response) {
    final user = _userOrNull(response);
    if (user == null) {
      throw Exception('User not found');
    }
    return user;
  }

  String? _message(Response<dynamic> response) {
    final data = response.data;
    if (data is Map) {
      return (data['detail'] ?? data['message'] ?? data['error'])?.toString();
    }
    return data?.toString();
  }

  Map<String, dynamic> _profilePayload(
    UserModel user, {
    bool includeId = true,
  }) {
    final payload = Map<String, dynamic>.from(user.toJson());
    if (!includeId) payload.remove('id');
    return payload..removeWhere((_, value) => value == null);
  }

  Map<String, dynamic> _profilePatchPayload(UserModel user) {
    final payload = _profilePayload(user);
    const serverOwned = {
      'statistics',
      'id',
      'phone_number',
      'auth_method',
      'balance',
      'user_group',
      'subscription_type',
      'subscription_provider',
      'subscription_status',
      'subscription_expires_at',
      'subscription_external_id',
      'arcopay_subscription_token',
      'arcopay_member_id',
      'cancel_at_period_end',
      'next_payment_date',
      'balance_history',
      'paid_requests',
      'free_requests',
      'created_at',
      'updated_at',
      'horoscope_week',
      'horoscope_month',
      'horoscope_year',
      'natal_card',
      'love_deck',
      'kelt_deck',
      'kelt_deck_impact',
      'sonnik_history',
      'compatibility_history',
      'anakra_messages',
    };
    for (final field in serverOwned) {
      payload.remove(field);
    }
    final horoscopeDay = payload['horoscope_day'];
    if (horoscopeDay is Map<String, dynamic>) {
      horoscopeDay.remove('is_key_theme_opened');
      horoscopeDay.remove('is_weakness_opened');
    }
    return payload;
  }
}
