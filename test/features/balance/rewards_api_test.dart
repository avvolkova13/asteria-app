import 'dart:convert';
import 'dart:typed_data';

import 'package:asteria_app/features/balance/data/rewards_api.dart';
import 'package:asteria_app/features/balance/domain/reward_models.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses rewards v2 contract and serializes event wire values', () async {
    final adapter = _RewardsAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = RewardsApi.forDio(dio, _FakeSession());

    final getResponse = await api.getRewards(
      userId: 'user-1',
      timezoneOffsetMinutes: 300,
    );
    final postResponse = await api.postEvent(
      PendingRewardEvent(
        eventId: '11111111-1111-4111-8111-111111111111',
        userId: 'user-1',
        eventType: RewardEventType.shareComplete,
        timezoneOffsetMinutes: 300,
        createdAt: DateTime.utc(2026, 8, 12),
      ),
    );

    expect(getResponse.items, hasLength(5));
    expect(postResponse.grantedAmount, 30);
    expect(adapter.requests.map((request) => request.uri.path), [
      '/api/v2/me/monetization',
      '/api/v2/rewards/events',
    ]);
    expect(
      adapter.requests.first.headers['X-Asteria-User-Token'],
      'user-token',
    );
    expect(adapter.requests.last.headers['X-Asteria-User-Token'], 'user-token');
    expect(
      adapter.requests.last.headers['Idempotency-Key'],
      '11111111-1111-4111-8111-111111111111',
    );
    expect(adapter.postedBody, {
      'reward_key': 'monthly_share',
      'evidence': {'timezone_offset_minutes': 300, 'client_attested': true},
    });
  });

  test('default section contains only the five document rewards', () {
    expect(defaultRewardStatuses.map((item) => item.id), [
      'onboarding',
      'tarot',
      'articles',
      'share',
      'login_streak',
    ]);
    expect(defaultRewardStatuses.map((item) => item.amount), [5, 5, 5, 30, 25]);
  });

  test('serves article read receipt before article reward event', () async {
    final adapter = _RewardsAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = RewardsApi.forDio(dio, _FakeSession());

    final receiptId = await api.serveArticleRead(
      articleId: 'article-1',
      idempotencyKey: 'article-read:article-1',
    );

    expect(receiptId, 'receipt-1');
    expect(
      adapter.requests.single.uri.path,
      '/api/v2/content/articles/article-1/reads',
    );
    expect(adapter.requests.single.method, 'POST');
    expect(
      adapter.requests.single.headers['Idempotency-Key'],
      'article-read:article-1',
    );
    expect(
      adapter.requests.single.headers['X-Asteria-User-Token'],
      'user-token',
    );
  });

  test(
    'does not send reward event when session changes before token read',
    () async {
      final adapter = _RewardsAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final api = RewardsApi.forDio(
        dio,
        _SwitchingSession(initialUid: 'user-1', switchedUid: 'user-2'),
      );

      await expectLater(
        api.postEvent(
          PendingRewardEvent(
            eventId: '22222222-2222-4222-8222-222222222222',
            userId: 'user-1',
            eventType: RewardEventType.dailyCheckIn,
            timezoneOffsetMinutes: 180,
            createdAt: DateTime.utc(2026, 8, 12),
          ),
        ),
        throwsException,
      );

      expect(adapter.requests, isEmpty);
    },
  );
}

class _RewardsAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  Map<String, dynamic>? postedBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.method == 'POST' && options.data is Map) {
      postedBody = Map<String, dynamic>.from(options.data as Map);
    }
    if (options.path == 'api/v2/content/articles/article-1/reads') {
      return ResponseBody.fromString(
        jsonEncode({
          'uid': 'user-1',
          'read_receipt_id': 'receipt-1',
          'article': {'id': 'article-1'},
          'replayed': false,
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    const items = [
      {
        'key': 'onboarding_complete',
        'amount': 5,
        'status': 'completed',
        'current': 1,
        'target': 1,
        'next_available_at': null,
      },
      {
        'key': 'first_tarot_spread',
        'amount': 5,
        'status': 'available',
        'current': 0,
        'target': 1,
        'next_available_at': null,
      },
      {
        'key': 'read_three_articles',
        'amount': 5,
        'status': 'in_progress',
        'current': 1,
        'target': 3,
        'next_available_at': null,
      },
      {
        'key': 'monthly_share',
        'amount': 30,
        'status': 'available',
        'current': 0,
        'target': 1,
        'next_available_at': null,
      },
      {
        'key': 'five_day_streak',
        'amount': 25,
        'status': 'in_progress',
        'current': 2,
        'target': 5,
        'next_available_at': null,
      },
    ];
    final body = options.method == 'POST'
        ? jsonEncode({
            'uid': 'user-1',
            'event_id': 'event-1',
            'reward_key': 'monthly_share',
            'natural_period': '2026-08',
            'granted_amount': 30,
            'grant_id': 'grant-1',
            'replayed': false,
            'wallet': {
              'uid': 'user-1',
              'balance': 42,
              'debt': 0,
              'sequence': 2,
              'version': 2,
              'updated_at': null,
            },
            'items': items,
          })
        : jsonEncode({
            'uid': 'user-1',
            'catalog_revision': 1,
            'wallet': {
              'uid': 'user-1',
              'balance': 42,
              'debt': 0,
              'sequence': 2,
              'version': 2,
              'updated_at': null,
            },
            'effective_pro': false,
            'effective_grants': [],
            'rewards': items,
            'rollout_policy': {},
          });
    return ResponseBody.fromString(
      body,
      200,
      headers: const {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeSession implements AuthSessionService {
  @override
  String? get currentUid => 'user-1';

  @override
  String? get currentEmail => 'user@example.com';

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => true;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async =>
      'user-token';

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

  @override
  Future<void> deleteCurrentIdentity() async {}
}

class _SwitchingSession implements AuthSessionService {
  _SwitchingSession({required this.initialUid, required this.switchedUid});

  final String initialUid;
  final String switchedUid;
  bool _switched = false;

  @override
  String? get currentUid => _switched ? switchedUid : initialUid;

  @override
  String? get currentEmail => 'user@example.com';

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => true;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async {
    _switched = true;
    return 'user-2-token';
  }

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

  @override
  Future<void> deleteCurrentIdentity() async {}
}
