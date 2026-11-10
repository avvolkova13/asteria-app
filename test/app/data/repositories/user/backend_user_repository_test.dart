import 'dart:convert';
import 'dart:typed_data';

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_profile_api.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads current user from backend /users/me', () async {
    final adapter = _UserProfileAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final session = _FakeSession();
    final repository = UserRepositoryImpl(
      profileApi: UserProfileApi.forDio(dio, session),
      authSessionService: session,
    );

    final user = await repository.getCurrentUser();

    expect(user?.id, 'mongo-user');
    expect(adapter.requests.single.uri.path, '/api/v1/users/me');
    expect(
      adapter.requests.single.headers['X-Asteria-User-Token'],
      'access-token',
    );
  });

  test(
    'patches current user through backend without server-owned fields',
    () async {
      final adapter = _UserProfileAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final session = _FakeSession();
      final repository = UserRepositoryImpl(
        profileApi: UserProfileApi.forDio(dio, session),
        authSessionService: session,
      );

      final user = UserModel.fromJson(
        _userJson(),
      ).copyWith(name: 'Updated User', balance: 999);

      await repository.updateCurrentUser(user);

      final request = adapter.requests.single;
      expect(request.method, 'PATCH');
      expect(request.uri.path, '/api/v1/users/me');
      expect(request.headers['X-Asteria-User-Token'], 'access-token');
      expect(request.data, isNot(contains('balance')));
      expect(request.data, isNot(contains('statistics')));
      expect(request.data, isNot(contains('subscription_type')));
      expect(request.data, isNot(contains('balance_history')));
      expect(request.data, isNot(contains('paid_requests')));
      expect(request.data, isNot(contains('free_requests')));
      expect(request.data, isNot(contains('love_deck')));
      expect(request.data, isNot(contains('kelt_deck')));
      expect(request.data, isNot(contains('kelt_deck_impact')));
      expect(request.data, isNot(contains('sonnik_history')));
      expect(request.data, isNot(contains('compatibility_history')));
      expect(request.data, isNot(contains('anakra_messages')));
      expect(request.data, containsPair('name', 'Updated User'));
    },
  );

  test(
    'does not send stale profile payload when session changes before token read',
    () async {
      final adapter = _UserProfileAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final session = _SwitchingSession(
        initialUid: 'mongo-user',
        switchedUid: 'other-user',
      );
      final repository = UserRepositoryImpl(
        profileApi: UserProfileApi.forDio(dio, session),
        authSessionService: session,
      );

      await expectLater(
        repository.updateCurrentUser(UserModel.fromJson(_userJson())),
        throwsException,
      );

      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'does not send complete-profile payload when session changes before token read',
    () async {
      final adapter = _UserProfileAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final session = _SwitchingSession(
        initialUid: 'mongo-user',
        switchedUid: 'other-user',
      );
      final api = UserProfileApi.forDio(dio, session);

      await expectLater(
        api.createUser(UserModel.fromJson(_userJson())),
        throwsException,
      );

      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'ignores a loaded profile when the session changes mid-request',
    () async {
      final adapter = _UserProfileAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final session = _MutableSession('mongo-user');
      final repository = UserRepositoryImpl(
        profileApi: UserProfileApi.forDio(dio, session),
        authSessionService: session,
      );

      final load = repository.getCurrentUser();
      session.uid = 'other-user';

      final user = await load;

      expect(user, isNull);
      expect(await repository.getCurrentUser(), isNull);
    },
  );

  test('deletes current user through backend /users/me', () async {
    final adapter = _UserProfileAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final session = _FakeSession();
    final repository = UserRepositoryImpl(
      profileApi: UserProfileApi.forDio(dio, session),
      authSessionService: session,
    );
    await repository.setCurrentUser(UserModel.fromJson(_userJson()));

    await repository.deleteUser('mongo-user');

    expect(adapter.requests.single.method, 'DELETE');
    expect(adapter.requests.single.uri.path, '/api/v1/users/me');
    expect(
      adapter.requests.single.headers['X-Asteria-User-Token'],
      'access-token',
    );
    expect(await repository.getCurrentUser(), isNull);
  });

  test(
    'does not send delete request when session changes before token read',
    () async {
      final adapter = _UserProfileAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final session = _SwitchingSession(
        initialUid: 'mongo-user',
        switchedUid: 'other-user',
      );
      final repository = UserRepositoryImpl(
        profileApi: UserProfileApi.forDio(dio, session),
        authSessionService: session,
      );
      await repository.setCurrentUser(UserModel.fromJson(_userJson()));

      await expectLater(repository.deleteUser('mongo-user'), throwsException);

      expect(adapter.requests, isEmpty);
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
  'kelt_deck': {
    'kelt_deck_cards': {'card-1': true},
  },
  'love_deck': {
    'love_deck_cards': {'card-1': true},
  },
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

class _MutableSession implements AuthSessionService {
  _MutableSession(this.uid);

  String? uid;

  @override
  String? get currentEmail => 'user@example.com';

  @override
  String? get currentUid => uid;

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => uid != null;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async =>
      uid == null ? null : 'access-token';

  @override
  Future<void> deleteCurrentIdentity() async {}

  @override
  Future<void> saveSession({
    required String uid,
    required String? email,
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    this.uid = uid;
  }

  @override
  Future<void> signOut() async {
    uid = null;
  }
}

class _SwitchingSession implements AuthSessionService {
  _SwitchingSession({required this.initialUid, required this.switchedUid});

  final String initialUid;
  final String switchedUid;
  bool _switched = false;

  @override
  String? get currentEmail => 'user@example.com';

  @override
  String? get currentUid => _switched ? switchedUid : initialUid;

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => true;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async {
    _switched = true;
    return 'other-user-token';
  }

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
  bool deleted = false;

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
    if (options.method == 'DELETE') {
      deleted = true;
      return ResponseBody.fromString(
        jsonEncode({'success': true}),
        200,
        headers: headers,
      );
    }
    if (deleted && options.method == 'GET') {
      return ResponseBody.fromString(
        jsonEncode({'detail': 'User not found'}),
        404,
        headers: headers,
      );
    }
    return ResponseBody.fromString(
      jsonEncode(_userJson()),
      200,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}
}
