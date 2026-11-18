import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_profile_api.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'refresh rejection clears established account and redirects protected screen',
    (tester) async {
      final adapter = _RejectedRefreshAdapter(delayed: false);
      final service = BackendAuthSessionService(
        store: _MemoryAuthSessionStore(),
        backendUrl: 'https://api.example.com',
        apiKey: 'test-key',
        dio: Dio(BaseOptions(validateStatus: (_) => true))
          ..httpClientAdapter = adapter,
      );
      await service.saveSession(
        uid: 'alice',
        email: null,
        accessToken: 'a',
        refreshToken: 'r',
        expiresIn: 0,
      );
      final repository = UserRepositoryImpl(
        profileApi: UserProfileApi.forDio(Dio(), service),
        authSessionService: service,
      );
      addTearDown(repository.dispose);
      final user = UserModel.empty().copyWith(id: 'alice');
      await repository.setCurrentUser(user);
      final provider = UserProvider(
        userRepository: repository,
        authSessionService: service,
      )..applyServerUserSnapshot(user);
      addTearDown(provider.dispose);
      final router = GoRouter(
        initialLocation: '/home',
        refreshListenable: service,
        redirect: (_, state) => authSessionRedirect(service, state.uri.path),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const Text('Private account'),
          ),
          GoRoute(
            path: '/auth/login',
            builder: (_, __) => const Text('Sign in'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('Private account'), findsOneWidget);
      await tester.runAsync(() async {
        await service.getAccessToken();
      });
      await tester.pumpAndSettle();
      expect(provider.currentUser, isNull);
      expect(provider.isAuthenticated, isFalse);
      expect(await repository.getCurrentUser(), isNull);
      expect(router.routeInformationProvider.value.uri.path, '/auth/login');
      expect(find.text('Sign in'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('old refresh rejection cannot clear a replacement account', () async {
    final adapter = _RejectedRefreshAdapter();
    final service = BackendAuthSessionService(
      store: _MemoryAuthSessionStore(),
      backendUrl: 'https://api.example.com',
      apiKey: 'test-key',
      dio: Dio(BaseOptions(validateStatus: (_) => true))
        ..httpClientAdapter = adapter,
    );
    await service.saveSession(
      uid: 'alice',
      email: null,
      accessToken: 'a',
      refreshToken: 'r',
      expiresIn: 0,
    );
    final repository = UserRepositoryImpl(
      profileApi: UserProfileApi.forDio(Dio(), service),
      authSessionService: service,
    );
    addTearDown(repository.dispose);
    final provider = UserProvider(
      userRepository: repository,
      authSessionService: service,
    );
    addTearDown(provider.dispose);
    provider.applyServerUserSnapshot(UserModel.empty().copyWith(id: 'alice'));
    final oldRefresh = service.getAccessToken();
    await adapter.started.future;
    await service.saveSession(
      uid: 'bob',
      email: null,
      accessToken: 'b',
      refreshToken: 's',
      expiresIn: 900,
    );
    provider.applyServerUserSnapshot(UserModel.empty().copyWith(id: 'bob'));
    adapter.reject();
    await oldRefresh;
    expect(service.currentUid, 'bob');
    expect(provider.currentUser?.id, 'bob');
    expect(authSessionRedirect(service, '/home'), isNull);
    provider.applyServerUserSnapshot(UserModel.empty().copyWith(id: 'alice'));
    expect(provider.currentUser?.id, 'bob');
  });

  test('session guard preserves signup and reauthentication routes', () async {
    final service = BackendAuthSessionService(store: _MemoryAuthSessionStore());
    for (final path in [
      '/auth/login',
      '/auth/email',
      '/auth/email/code',
      '/onboarding',
    ]) {
      expect(authSessionRedirect(service, path), isNull);
    }
    expect(authSessionRedirect(service, '/auth/personal-info'), '/auth/login');
    await service.saveSession(
      uid: 'signup',
      email: null,
      accessToken: 'a',
      refreshToken: 'r',
      expiresIn: 900,
    );
    expect(authSessionRedirect(service, '/auth/personal-info'), isNull);
    expect(authSessionRedirect(service, '/auth/email/code'), isNull);
  });

  test(
    'session revision fences same UID relogin from start through persistence',
    () async {
      final pause = Completer<void>();
      final service = BackendAuthSessionService(
        store: _MemoryAuthSessionStore(),
        beforeSessionEnd: () => pause.future,
      );
      await service.saveSession(
        uid: 'A',
        email: null,
        accessToken: 'a',
        refreshToken: 'r',
        expiresIn: 900,
      );
      var notices = 0;
      service.addListener(() {
        notices++;
      });
      final old = service.identityVersion;
      final logout = service.signOut();
      expect(service.identityVersion, greaterThan(old));
      expect(service.identityReady, isFalse);
      pause.complete();
      await logout;
      await service.saveSession(
        uid: 'A',
        email: null,
        accessToken: 'b',
        refreshToken: 's',
        expiresIn: 900,
      );
      expect(service.identityReady, isTrue);
      expect(notices, greaterThanOrEqualTo(4));
      expect(service.identityVersion, greaterThan(old));
    },
  );
  test('identity deletion invokes account cleanup before logout', () async {
    final store = _MemoryAuthSessionStore();
    String? removed;
    final service = BackendAuthSessionService(
      store: store,
      onIdentityDeleted: (uid) async {
        removed = uid;
      },
    );
    await service.saveSession(
      uid: 'alice',
      email: null,
      accessToken: 'a',
      refreshToken: 'r',
      expiresIn: 900,
    );
    await service.deleteCurrentIdentity();
    expect(removed, 'alice');
    expect(service.hasSession, isFalse);
  });

  test('saves, restores and clears backend auth session', () async {
    final store = _MemoryAuthSessionStore();
    final service = BackendAuthSessionService(store: store);

    expect(service.hasSession, isFalse);

    await service.saveSession(
      uid: 'mongo-user',
      email: 'user@example.com',
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      expiresIn: 900,
    );

    expect(service.hasSession, isTrue);
    expect(service.currentUid, 'mongo-user');
    expect(service.currentEmail, 'user@example.com');
    expect(await service.getAccessToken(), 'access-token');

    final restored = BackendAuthSessionService(store: store);
    expect(restored.hasSession, isTrue);
    expect(restored.currentUid, 'mongo-user');
    expect(await restored.getAccessToken(), 'access-token');

    await restored.signOut();
    expect(restored.hasSession, isFalse);
    expect(BackendAuthSessionService(store: store).hasSession, isFalse);
  });

  test(
    'refreshes expired access token through backend session endpoint',
    () async {
      final store = _MemoryAuthSessionStore();
      final adapter = _RefreshAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://unused.example.com/'))
        ..httpClientAdapter = adapter;
      final expiredSession = AuthSessionSnapshot(
        uid: 'mongo-user',
        email: 'user@example.com',
        accessToken: 'old-access-token',
        refreshToken: 'old-refresh-token',
        signedInAt: DateTime.now().subtract(const Duration(minutes: 10)),
        accessTokenExpiresAt: DateTime.now().subtract(
          const Duration(seconds: 1),
        ),
      );
      await store.write(expiredSession);

      final service = BackendAuthSessionService(
        store: store,
        backendUrl: 'https://api.example.com',
        apiKey: 'app-api-key',
        dio: dio,
      );

      expect(await service.getAccessToken(), 'new-access-token');
      expect(store.value?.refreshToken, 'new-refresh-token');
      expect(adapter.requests.single.uri.path, '/api/v1/auth/email/refresh');
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer app-api-key',
      );
      expect(adapter.requests.single.data, {
        'refresh_token': 'old-refresh-token',
      });
    },
  );

  test('coalesces concurrent refreshes for the same session', () async {
    final store = _MemoryAuthSessionStore();
    final adapter = _CountingDelayedRefreshAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://unused.example.com/'))
      ..httpClientAdapter = adapter;
    await store.write(
      AuthSessionSnapshot(
        uid: 'mongo-user',
        email: 'user@example.com',
        accessToken: 'old-access-token',
        refreshToken: 'old-refresh-token',
        signedInAt: DateTime.now().subtract(const Duration(minutes: 10)),
        accessTokenExpiresAt: DateTime.now().subtract(
          const Duration(seconds: 1),
        ),
      ),
    );
    final service = BackendAuthSessionService(
      store: store,
      backendUrl: 'https://api.example.com',
      apiKey: 'app-api-key',
      dio: dio,
    );

    final first = service.getAccessToken();
    final second = service.getAccessToken();
    await adapter.refreshStarted.future;
    await Future<void>.delayed(Duration.zero);

    expect(adapter.requests, hasLength(1));

    adapter.complete();

    expect(await first, 'new-access-token');
    expect(await second, 'new-access-token');
    expect(store.value?.refreshToken, 'new-refresh-token');
  });

  test(
    'signOut revokes backend refresh session before clearing local state',
    () async {
      final store = _MemoryAuthSessionStore();
      final adapter = _LogoutAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://unused.example.com/'))
        ..httpClientAdapter = adapter;
      await store.write(
        AuthSessionSnapshot(
          uid: 'mongo-user',
          email: 'user@example.com',
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          signedInAt: DateTime.now(),
          accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 15)),
        ),
      );
      final service = BackendAuthSessionService(
        store: store,
        backendUrl: 'https://api.example.com',
        apiKey: 'app-api-key',
        dio: dio,
      );

      await service.signOut();

      expect(service.hasSession, isFalse);
      expect(store.value, isNull);
      expect(adapter.requests.single.uri.path, '/api/v1/auth/email/logout');
      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer app-api-key',
      );
      expect(adapter.requests.single.data, {'refresh_token': 'refresh-token'});
    },
  );

  test(
    'ignores refresh response and does not return newer session token',
    () async {
      final store = _MemoryAuthSessionStore();
      final adapter = _DelayedRefreshAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://unused.example.com/'))
        ..httpClientAdapter = adapter;
      await store.write(
        AuthSessionSnapshot(
          uid: 'user-a',
          email: 'a@example.com',
          accessToken: 'old-access-a',
          refreshToken: 'refresh-a',
          signedInAt: DateTime.now().subtract(const Duration(minutes: 10)),
          accessTokenExpiresAt: DateTime.now().subtract(
            const Duration(seconds: 1),
          ),
        ),
      );
      final service = BackendAuthSessionService(
        store: store,
        backendUrl: 'https://api.example.com',
        apiKey: 'app-api-key',
        dio: dio,
      );

      final refresh = service.getAccessToken();
      await service.saveSession(
        uid: 'user-b',
        email: 'b@example.com',
        accessToken: 'access-b',
        refreshToken: 'refresh-b',
        expiresIn: 900,
      );
      adapter.complete(uid: 'user-a');

      expect(await refresh, isNull);
      expect(service.currentUid, 'user-b');
      expect(store.value?.refreshToken, 'refresh-b');
    },
  );

  test('signOut does not clear a newer session saved during logout', () async {
    final store = _MemoryAuthSessionStore();
    final adapter = _DelayedLogoutAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://unused.example.com/'))
      ..httpClientAdapter = adapter;
    await store.write(
      AuthSessionSnapshot(
        uid: 'user-a',
        email: 'a@example.com',
        accessToken: 'access-a',
        refreshToken: 'refresh-a',
        signedInAt: DateTime.now(),
        accessTokenExpiresAt: DateTime.now().add(const Duration(minutes: 15)),
      ),
    );
    final service = BackendAuthSessionService(
      store: store,
      backendUrl: 'https://api.example.com',
      apiKey: 'app-api-key',
      dio: dio,
    );

    final logout = service.signOut();
    await service.saveSession(
      uid: 'user-b',
      email: 'b@example.com',
      accessToken: 'access-b',
      refreshToken: 'refresh-b',
      expiresIn: 900,
    );
    adapter.complete();
    await logout;

    expect(service.currentUid, 'user-b');
    expect(store.value?.refreshToken, 'refresh-b');
  });

  test(
    'signOut clears the same login session even when refresh rotates token first',
    () async {
      final store = _MemoryAuthSessionStore();
      final adapter = _RefreshThenLogoutAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://unused.example.com/'))
        ..httpClientAdapter = adapter;
      await store.write(
        AuthSessionSnapshot(
          uid: 'user-a',
          email: 'a@example.com',
          accessToken: 'old-access-a',
          refreshToken: 'refresh-a',
          signedInAt: DateTime.now().subtract(const Duration(minutes: 10)),
          accessTokenExpiresAt: DateTime.now().subtract(
            const Duration(seconds: 1),
          ),
        ),
      );
      final service = BackendAuthSessionService(
        store: store,
        backendUrl: 'https://api.example.com',
        apiKey: 'app-api-key',
        dio: dio,
      );

      final refresh = service.getAccessToken();
      await adapter.refreshStarted.future;
      final logout = service.signOut();
      adapter.completeRefresh();
      expect(await refresh, 'new-access-a');
      adapter.completeLogout();
      await logout;

      expect(service.hasSession, isFalse);
      expect(store.value, isNull);
    },
  );
}

class _MemoryAuthSessionStore implements AuthSessionStore {
  AuthSessionSnapshot? value;

  @override
  AuthSessionSnapshot? read() => value;

  @override
  Future<void> write(AuthSessionSnapshot session) async {
    value = session;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

class _RefreshAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({
        'uid': 'mongo-user',
        'access_token': 'new-access-token',
        'refresh_token': 'new-refresh-token',
        'token_type': 'bearer',
        'expires_in': 900,
        'profile_exists': true,
      }),
      200,
      headers: const {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _LogoutAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({'success': true}),
      200,
      headers: const {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _DelayedRefreshAdapter implements HttpClientAdapter {
  final _completer = Completer<ResponseBody>();

  void complete({required String uid}) {
    _completer.complete(
      ResponseBody.fromString(
        jsonEncode({
          'uid': uid,
          'access_token': 'new-access-a',
          'refresh_token': 'new-refresh-a',
          'token_type': 'bearer',
          'expires_in': 900,
          'profile_exists': true,
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _completer.future;
  }

  @override
  void close({bool force = false}) {}
}

class _CountingDelayedRefreshAdapter implements HttpClientAdapter {
  final refreshStarted = Completer<void>();
  final requests = <RequestOptions>[];
  final _completer = Completer<ResponseBody>();

  void complete() {
    _completer.complete(
      ResponseBody.fromString(
        jsonEncode({
          'uid': 'mongo-user',
          'access_token': 'new-access-token',
          'refresh_token': 'new-refresh-token',
          'token_type': 'bearer',
          'expires_in': 900,
          'profile_exists': true,
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    if (!refreshStarted.isCompleted) refreshStarted.complete();
    return _completer.future;
  }

  @override
  void close({bool force = false}) {}
}

class _DelayedLogoutAdapter implements HttpClientAdapter {
  final _completer = Completer<ResponseBody>();

  void complete() {
    _completer.complete(
      ResponseBody.fromString(
        jsonEncode({'success': true}),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _completer.future;
  }

  @override
  void close({bool force = false}) {}
}

class _RefreshThenLogoutAdapter implements HttpClientAdapter {
  final refreshStarted = Completer<void>();
  final _refreshCompleter = Completer<ResponseBody>();
  final _logoutCompleter = Completer<ResponseBody>();

  void completeRefresh() {
    _refreshCompleter.complete(
      ResponseBody.fromString(
        jsonEncode({
          'uid': 'user-a',
          'access_token': 'new-access-a',
          'refresh_token': 'refresh-a-rotated',
          'token_type': 'bearer',
          'expires_in': 900,
          'profile_exists': true,
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }

  void completeLogout() {
    _logoutCompleter.complete(
      ResponseBody.fromString(
        jsonEncode({'success': true}),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (options.path.endsWith('/api/v1/auth/email/refresh')) {
      if (!refreshStarted.isCompleted) refreshStarted.complete();
      return _refreshCompleter.future;
    }
    if (options.path.endsWith('/api/v1/auth/email/logout')) {
      return _logoutCompleter.future;
    }
    throw StateError('unexpected request ${options.path}');
  }

  @override
  void close({bool force = false}) {}
}

class _RejectedRefreshAdapter implements HttpClientAdapter {
  _RejectedRefreshAdapter({this.delayed = true});
  final bool delayed;
  final started = Completer<void>();
  final response = Completer<ResponseBody>();
  void reject() => response.complete(
    ResponseBody.fromString(
      '{}',
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    ),
  );
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (!started.isCompleted) started.complete();
    if (!delayed) {
      return Future.value(
        ResponseBody.fromString(
          '{}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      );
    }
    return response.future;
  }

  @override
  void close({bool force = false}) {}
}
