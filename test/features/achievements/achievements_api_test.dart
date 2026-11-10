import 'dart:convert';
import 'dart:typed_data';

import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/achievements/data/achievements_api.dart';
import 'package:asteria_app/features/achievements/domain/achievement_event.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const event = AchievementEvent(
    userId: 'a',
    kind: AchievementEventKind.horoscope,
    reference: 'week:2026-09-23',
  );
  test(
    'posts authenticated action and reads persisted server counters',
    () async {
      final adapter = _Adapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/'))
        ..httpClientAdapter = adapter;
      final api = AchievementsApi.forDio(dio, _Session());
      final statistics = await api.record(event);
      expect(statistics.horoscopeOpened, 2);
      expect(adapter.request!.uri.path, '/api/v1/users/me/achievement-events');
      expect(adapter.request!.headers['X-Asteria-User-Token'], 'test-token');
      expect(adapter.request!.data, {
        'kind': 'horoscope',
        'reference': 'week:2026-09-23',
      });
    },
  );
  test('does not send event with another account token', () async {
    final adapter = _Adapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/'))
      ..httpClientAdapter = adapter;
    final api = AchievementsApi.forDio(dio, _Session()..uid = 'b');
    await expectLater(api.record(event), throwsA(isA<StateError>()));
    expect(adapter.request, isNull);
  });
  test('rejects response belonging to another account', () async {
    final adapter = _Adapter()..responseUid = 'b';
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/'))
      ..httpClientAdapter = adapter;
    await expectLater(
      AchievementsApi.forDio(dio, _Session()).record(event),
      throwsA(isA<StateError>()),
    );
  });
}

class _Session extends Fake implements AuthSessionService {
  String uid = 'a';
  @override
  String? get currentUid => uid;
  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async =>
      'test-token';
}

class _Adapter implements HttpClientAdapter {
  RequestOptions? request;
  String responseUid = 'a';
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({
        'uid': responseUid,
        'statistics': {'horoscope_opened': 2},
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
