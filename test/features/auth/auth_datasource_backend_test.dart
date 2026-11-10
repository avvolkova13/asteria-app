import 'dart:convert';
import 'dart:typed_data';

import 'package:asteria_app/app/data/repositories/user/user_profile_api.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'creates the current user profile through backend completion endpoint',
    () async {
      final adapter = _UserProfileAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final dataSource = AuthDataSourceImpl(
        userProfileApi: UserProfileApi.forDio(dio, _FakeSession()),
      );
      final user = UserModel.fromJson(_userJson()).copyWith(id: 'mongo-user');

      final saved = await dataSource.createUser(user);

      expect(saved.id, 'mongo-user');
      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.uri.path, '/api/v1/users/me/complete-profile');
      expect(request.headers['X-Asteria-User-Token'], 'access-token');
      expect(request.data, containsPair('name', 'Test User'));
      expect(request.data, isNot(contains('auth_method')));
      expect(request.data, isNot(contains('phone_number')));
    },
  );
}

Map<String, dynamic> _userJson() => {
  'id': 'mongo-user',
  'email': 'user@example.com',
  'auth_method': 'email',
  'name': 'Test User',
  'balance': 10,
  'user_group': 'user',
  'subscription_type': 'free',
  'cancel_at_period_end': false,
  'created_at': '2026-08-28T12:00:00Z',
  'updated_at': '2026-08-28T12:00:00Z',
  'paid_requests': {'compatibility': 3, 'sonnik': 3, 'anakra': 3},
  'free_requests': {'compatibility': 3, 'sonnik': 3, 'anakra': 3},
  'solar_data': {'data': ''},
  'planets_houses_data': {
    'data': '',
    'elements': {'fire': '', 'earth': '', 'air': '', 'water': ''},
  },
  'compatibility_history': [],
  'viewed_content_ids': [],
  'kelt_deck_impact': [],
  'sonnik_history': [],
  'balance_history': [],
  'anakra_messages': [],
};

class _FakeSession implements AuthSessionService {
  @override
  String? get currentEmail => 'user@example.com';

  @override
  String? get currentUid => 'mongo-user';

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => true;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async =>
      'access-token';

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

class _UserProfileAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    const headers = {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    };
    return ResponseBody.fromString(
      jsonEncode(_userJson()),
      200,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}
}
