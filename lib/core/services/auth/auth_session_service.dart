import 'package:flutter/foundation.dart';
import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:dio/dio.dart';

class RecentLoginRequiredException implements Exception {
  const RecentLoginRequiredException();
}

class AuthSessionSnapshot {
  final String uid;
  final String? email;
  final String accessToken;
  final String refreshToken;
  final DateTime signedInAt;
  final DateTime accessTokenExpiresAt;

  const AuthSessionSnapshot({
    required this.uid,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.signedInAt,
    required this.accessTokenExpiresAt,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'signed_in_at': signedInAt.toIso8601String(),
    'access_token_expires_at': accessTokenExpiresAt.toIso8601String(),
  };

  factory AuthSessionSnapshot.fromJson(Map<dynamic, dynamic> json) {
    return AuthSessionSnapshot(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      signedInAt: DateTime.parse(json['signed_in_at'] as String),
      accessTokenExpiresAt: DateTime.parse(
        json['access_token_expires_at'] as String,
      ),
    );
  }
}

abstract class AuthSessionStore {
  AuthSessionSnapshot? read();
  Future<void> write(AuthSessionSnapshot session);
  Future<void> clear();
}

class HiveAuthSessionStore implements AuthSessionStore {
  static const _key = 'auth_session';

  @override
  AuthSessionSnapshot? read() {
    final value = HiveService.appSettingsBox.get(_key);
    if (value == null) return null;
    return AuthSessionSnapshot.fromJson(value);
  }

  @override
  Future<void> write(AuthSessionSnapshot session) {
    return HiveService.appSettingsBox.put(_key, session.toJson());
  }

  @override
  Future<void> clear() => HiveService.appSettingsBox.delete(_key);
}

abstract class AuthSessionService {
  String? get currentUid;
  String? get currentEmail;
  bool get hasSession;
  bool get hasRecentSignIn;

  Future<String?> getAccessToken({bool forceRefresh = false});

  Future<void> saveSession({
    required String uid,
    required String? email,
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  });
  Future<void> signOut();
  Future<void> deleteCurrentIdentity();
}

extension SessionBoundAccessToken on AuthSessionService {
  Future<String?> getAccessTokenForUid(
    String expectedUid, {
    bool forceRefresh = false,
  }) async {
    if (currentUid != expectedUid) return null;
    final token = await getAccessToken(forceRefresh: forceRefresh);
    if (currentUid != expectedUid) return null;
    return token;
  }
}

abstract interface class SessionIdentityVersion {
  int get identityVersion;
  bool get identityReady;
}

class BackendAuthSessionService
    with ChangeNotifier
    implements AuthSessionService, SessionIdentityVersion {
  @override
  int identityVersion = 0;
  int _identityTransitions = 0;
  @override
  bool get identityReady => _identityTransitions == 0;
  final Future<void> Function()? beforeSessionEnd;
  final Future<void> Function()? onSessionSaved;
  final Future<void> Function(String uid)? onIdentityDeleted;
  final AuthSessionStore _store;
  final String? _backendUrl;
  final String? _apiKey;
  final Dio _dio;
  AuthSessionSnapshot? _session;
  AuthSessionSnapshot? _refreshInFlightSession;
  Future<AuthSessionSnapshot?>? _refreshInFlight;

  BackendAuthSessionService({
    this.beforeSessionEnd,
    this.onSessionSaved,
    this.onIdentityDeleted,
    AuthSessionStore? store,
    Environment? environment,
    String? backendUrl,
    String? apiKey,
    Dio? dio,
  }) : _store = store ?? HiveAuthSessionStore(),
       _backendUrl = backendUrl ?? environment?.asteriaBackendUrl,
       _apiKey = apiKey ?? environment?.asteriaApiKey,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 30),
               receiveTimeout: const Duration(seconds: 30),
               sendTimeout: const Duration(seconds: 30),
               validateStatus: (_) => true,
             ),
           ) {
    _session = _store.read();
  }

  @override
  String? get currentUid => _session?.uid;

  @override
  String? get currentEmail => _session?.email;

  @override
  bool get hasSession => _session != null;

  @override
  bool get hasRecentSignIn {
    final signedInAt = _session?.signedInAt;
    if (signedInAt == null) return false;
    return DateTime.now().difference(signedInAt) < const Duration(minutes: 4);
  }

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async {
    final session = _session;
    if (session == null) return null;

    final shouldRefresh =
        forceRefresh ||
        !session.accessTokenExpiresAt.isAfter(
          DateTime.now().add(const Duration(seconds: 30)),
        );
    if (!shouldRefresh) {
      return session.accessToken;
    }
    final refreshed = await _refreshSession(session);
    if (refreshed != null) return refreshed.accessToken;
    if (!_isCurrentSession(session)) return null;
    return _session?.accessToken;
  }

  @override
  Future<void> saveSession({
    required String uid,
    required String? email,
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    identityVersion += 1;
    _identityTransitions += 1;
    notifyListeners();
    try {
      if (_session != null) await beforeSessionEnd?.call();
      final now = DateTime.now();
      final session = AuthSessionSnapshot(
        uid: uid,
        email: email,
        accessToken: accessToken,
        refreshToken: refreshToken,
        signedInAt: now,
        accessTokenExpiresAt: now.add(Duration(seconds: expiresIn)),
      );
      await _store.write(session);
      _session = session;
      await onSessionSaved?.call();
    } finally {
      identityVersion += 1;
      _identityTransitions -= 1;
      notifyListeners();
    }
  }

  @override
  Future<void> signOut() async {
    identityVersion += 1;
    _identityTransitions += 1;
    notifyListeners();
    try {
      final session = _session;
      await beforeSessionEnd?.call();
      await _logoutSession(session);
      if (!_isCurrentLoginSession(session)) return;
      await _store.clear();
      _session = null;
    } finally {
      identityVersion += 1;
      _identityTransitions -= 1;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteCurrentIdentity() async {
    final uid = currentUid;
    if (uid != null) await onIdentityDeleted?.call(uid);
    await signOut();
  }

  Future<AuthSessionSnapshot?> _refreshSession(
    AuthSessionSnapshot session,
  ) async {
    final inFlight = _refreshInFlight;
    final inFlightSession = _refreshInFlightSession;
    if (inFlight != null &&
        inFlightSession != null &&
        _sameRefreshSession(inFlightSession, session)) {
      return inFlight;
    }

    final refresh = _performRefreshSession(session);
    _refreshInFlight = refresh;
    _refreshInFlightSession = session;
    refresh.whenComplete(() {
      if (identical(_refreshInFlight, refresh)) {
        _refreshInFlight = null;
        _refreshInFlightSession = null;
      }
    });
    return refresh;
  }

  Future<AuthSessionSnapshot?> _performRefreshSession(
    AuthSessionSnapshot session,
  ) async {
    final backendUrl = _backendUrl;
    final apiKey = _apiKey;
    if (backendUrl == null || apiKey == null) return null;
    final normalizedBackendUrl = backendUrl.endsWith('/')
        ? backendUrl
        : '$backendUrl/';

    try {
      final response = await _dio.post<Object?>(
        '${normalizedBackendUrl}api/v1/auth/email/refresh',
        data: {'refresh_token': session.refreshToken},
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );
      final status = response.statusCode ?? 0;
      if (status == 401) {
        await _clearIfCurrent(session);
        return null;
      }
      final data = response.data;
      if (status < 200 || status >= 300 || data is! Map<String, dynamic>) {
        return null;
      }
      if (!_isCurrentSession(session)) return null;

      final refreshed = AuthSessionSnapshot(
        uid: data['uid'] as String,
        email: session.email,
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
        signedInAt: session.signedInAt,
        accessTokenExpiresAt: DateTime.now().add(
          Duration(seconds: (data['expires_in'] as num).toInt()),
        ),
      );
      await _store.write(refreshed);
      _session = refreshed;
      return refreshed;
    } on DioException {
      return null;
    }
  }

  bool _isCurrentSession(AuthSessionSnapshot? session) {
    if (session == null) return _session == null;
    final current = _session;
    return current != null && _sameRefreshSession(current, session);
  }

  bool _sameRefreshSession(
    AuthSessionSnapshot left,
    AuthSessionSnapshot right,
  ) {
    return left.uid == right.uid && left.refreshToken == right.refreshToken;
  }

  bool _isCurrentLoginSession(AuthSessionSnapshot? session) {
    if (session == null) return _session == null;
    final current = _session;
    return current?.uid == session.uid &&
        current?.signedInAt == session.signedInAt;
  }

  Future<void> _clearIfCurrent(AuthSessionSnapshot session) async {
    if (!_isCurrentSession(session)) return;
    identityVersion += 1;
    _identityTransitions += 1;
    notifyListeners();
    try {
      await _store.clear();
      _session = null;
    } finally {
      identityVersion += 1;
      _identityTransitions -= 1;
      notifyListeners();
    }
  }

  Future<void> _logoutSession(AuthSessionSnapshot? session) async {
    if (session == null) return;
    final backendUrl = _backendUrl;
    final apiKey = _apiKey;
    if (backendUrl == null || apiKey == null) return;
    final normalizedBackendUrl = backendUrl.endsWith('/')
        ? backendUrl
        : '$backendUrl/';

    try {
      await _dio.post<Object?>(
        '${normalizedBackendUrl}api/v1/auth/email/logout',
        data: {'refresh_token': session.refreshToken},
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException {
      return;
    }
  }
}
