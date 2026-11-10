import 'dart:convert';
import 'dart:typed_data';

import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/monetization/data/feature_execution_api.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'PRO-only execution intent reaches the server for tarot and generated content',
    () async {
      final adapter = _MonetizationAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final api = FeatureExecutionApi.forDio(dio, _FakeSession());
      await api.createTarotSpread(
        spreadType: 'love',
        expectedCatalogRevision: 3,
        idempotencyKey: 'pro-tarot',
        requirePro: true,
      );
      await api.createGeneratedFeature(
        featureKey: 'natal_chart',
        payload: {'locale': 'ru'},
        expectedCatalogRevision: 3,
        idempotencyKey: 'pro-natal',
        requirePro: true,
      );
      final posts = adapter.jsonBodies.where(
        (body) => body.containsKey('expected_catalog_revision'),
      );
      expect(posts, hasLength(2));
      expect(posts.every((body) => body['require_pro'] == true), isTrue);
    },
  );

  test('loads a filtered wallet page with cursor and authentication', () async {
    final adapter = _MonetizationAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final page = await MonetizationApi.forDio(dio, _FakeSession())
        .getWalletHistoryPage(
          filter: WalletHistoryFilter.deposits,
          beforeSequence: 20,
          limit: 10,
        );
    expect(adapter.requests.single.queryParameters, {
      'limit': 10,
      'filter': 'deposits',
      'before_sequence': 20,
    });
    expect(
      adapter.requests.single.headers['X-Asteria-User-Token'],
      'user-token',
    );
    expect(page.hasEntries, isTrue);
    expect(page.nextBeforeSequence, isNull);
    expect(page.items.length, 2);
  });

  test('malformed or legacy page is not interpreted as empty history', () {
    expect(
      () => WalletHistoryPageModel.fromJson({'items': []}),
      throwsFormatException,
    );
    expect(
      () => WalletHistoryPageModel.fromJson({
        'items': [],
        'has_entries': false,
        'next_before_sequence': 0,
      }),
      throwsFormatException,
    );
  });
  test(
    'creates Tarot feature execution and loads result with user token',
    () async {
      final adapter = _MonetizationAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final api = FeatureExecutionApi.forDio(dio, _FakeSession());

      final result = await api.createTarotSpread(
        spreadType: 'love',
        expectedCatalogRevision: 3,
        idempotencyKey: 'tarot-command-1',
      );

      expect(adapter.requests.length, 2);
      expect(
        adapter.requests.first.uri.path,
        '/api/v2/features/tarot_spread/executions',
      );
      expect(adapter.requests.first.method, 'POST');
      expect(
        adapter.requests.first.headers['Idempotency-Key'],
        'tarot-command-1',
      );
      expect(
        adapter.requests.first.headers['X-Asteria-User-Token'],
        'user-token',
      );
      expect(adapter.jsonBodies.first, {
        'payload': {'spread_type': 'love'},
        'expected_catalog_revision': 3,
      });
      expect(
        adapter.requests.last.uri.path,
        '/api/v2/features/tarot_spread/executions/execution-love/result',
      );
      expect(result.executionId, 'execution-love');
      expect(result.spreadType, 'love');
      expect(result.cardIds, ['card-1', 'card-2']);
    },
  );

  test('loads latest Tarot spread result with user token', () async {
    final adapter = _MonetizationAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = FeatureExecutionApi.forDio(dio, _FakeSession());

    final result = await api.getLatestTarotSpread(spreadType: 'celtic');

    expect(
      adapter.requests.single.uri.path,
      '/api/v2/features/tarot_spread/results/latest',
    );
    expect(adapter.requests.single.uri.queryParameters, {
      'spread_type': 'celtic',
    });
    expect(
      adapter.requests.single.headers['X-Asteria-User-Token'],
      'user-token',
    );
    expect(result?.executionId, 'execution-celtic');
    expect(result?.spreadType, 'celtic');
    expect(result?.cardIds, [
      'card-0',
      'card-1',
      'card-2',
      'card-3',
      'card-4',
      'card-5',
      'card-6',
      'card-7',
      'card-8',
      'card-9',
    ]);
  });

  test('returns null when latest Tarot spread is absent', () async {
    final adapter = _MonetizationAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = FeatureExecutionApi.forDio(dio, _FakeSession());

    final result = await api.getLatestTarotSpread(spreadType: 'missing');

    expect(result, isNull);
    expect(
      adapter.requests.single.uri.path,
      '/api/v2/features/tarot_spread/results/latest',
    );
    expect(adapter.requests.single.uri.queryParameters, {
      'spread_type': 'missing',
    });
  });

  test(
    'creates generated paid feature execution without sending client result',
    () async {
      final adapter = _MonetizationAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final api = FeatureExecutionApi.forDio(dio, _FakeSession());

      final result = await api.createGeneratedFeature(
        featureKey: 'natal_chart',
        payload: {'name': 'Антон', 'locale': 'ru'},
        expectedCatalogRevision: 3,
        idempotencyKey: 'natal-command-1',
      );

      expect(adapter.requests.length, 2);
      expect(
        adapter.requests.first.uri.path,
        '/api/v2/features/natal_chart/executions',
      );
      expect(adapter.jsonBodies.first, {
        'payload': {'name': 'Антон', 'locale': 'ru'},
        'expected_catalog_revision': 3,
      });
      expect(adapter.jsonBodies.first['payload'], isNot(contains('result')));
      expect(
        adapter.requests.last.uri.path,
        '/api/v2/features/client-results/execution-natal',
      );
      expect(result.featureKey, 'natal_chart');
      expect(result.result['final_conclusion'], 'Карта собрана.');
    },
  );

  test(
    'surfaces insufficient stars from generated feature execution as typed failure',
    () async {
      final adapter = _MonetizationAdapter()..generatedFeatureFailure = true;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final api = FeatureExecutionApi.forDio(dio, _FakeSession());

      await expectLater(
        api.createGeneratedFeature(
          featureKey: 'natal_chart',
          payload: {'name': 'Антон', 'locale': 'ru'},
          expectedCatalogRevision: 3,
          idempotencyKey: 'natal-command-1',
        ),
        throwsA(
          predicate(
            (error) =>
                error.runtimeType.toString() ==
                    'FeatureExecutionInsufficientStarsException' &&
                error.toString().contains('insufficient_stars'),
          ),
        ),
      );

      expect(adapter.requests.length, 1);
    },
  );

  test('surfaces terminal generated feature replay as typed failure', () async {
    final adapter = _MonetizationAdapter()
      ..generatedFeatureTerminalStatus = 'compensated';
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = FeatureExecutionApi.forDio(dio, _FakeSession());

    await expectLater(
      api.createGeneratedFeature(
        featureKey: 'natal_chart',
        payload: {'name': 'Антон', 'locale': 'ru'},
        expectedCatalogRevision: 3,
        idempotencyKey: 'stale-command-1',
      ),
      throwsA(
        isA<FeatureExecutionException>()
            .having((error) => error.code, 'code', 'execution_compensated')
            .having(
              (error) => error.message,
              'message',
              contains('compensated'),
            ),
      ),
    );

    expect(adapter.requests.length, 1);
  });

  test(
    'does not send feature execution when session changes before token read',
    () async {
      final adapter = _MonetizationAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final api = FeatureExecutionApi.forDio(
        dio,
        _SwitchingSession(initialUid: 'user-1', switchedUid: 'user-2'),
      );

      await expectLater(
        api.createTarotSpread(
          spreadType: 'love',
          expectedCatalogRevision: 3,
          idempotencyKey: 'tarot-command-race',
        ),
        throwsException,
      );

      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'loads monetization state from v2 me endpoint with user token',
    () async {
      final adapter = _MonetizationAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final api = MonetizationApi.forDio(dio, _FakeSession());

      final state = await api.getCurrent();

      expect(adapter.requests.single.uri.path, '/api/v2/me/monetization');
      expect(
        adapter.requests.single.headers['X-Asteria-User-Token'],
        'user-token',
      );
      expect(state.uid, 'user-1');
      expect(state.balance, 77);
      expect(state.effectivePro, isTrue);
      expect(state.effectiveGrants.single.provider, 'apple');
      expect(
        state.effectiveGrants.single.endsAt,
        DateTime.parse('2026-09-30T12:00:00Z'),
      );
      expect(state.rewards.map((item) => item.id), ['onboarding', 'tarot']);
      expect(state.requestQuota('sonnik').freeRemaining, 10);
      expect(state.requestQuota('sonnik').paidRemaining, 2);
      expect(state.requestQuota('sonnik').totalRemaining, 12);
    },
  );

  test('purchases request packs through v2 quota endpoint', () async {
    final adapter = _MonetizationAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = MonetizationApi.forDio(dio, _FakeSession());

    final result = await api.purchaseRequestPack(
      feature: 'sonnik',
      quantity: 3,
      idempotencyKey: 'purchase-key-1',
    );

    expect(
      adapter.requests.single.uri.path,
      '/api/v2/me/request-quotas/purchases',
    );
    expect(adapter.requests.single.method, 'POST');
    expect(
      adapter.requests.single.headers['Idempotency-Key'],
      'purchase-key-1',
    );
    expect(
      adapter.requests.single.headers['X-Asteria-User-Token'],
      'user-token',
    );
    expect(adapter.lastJsonBody, {'feature': 'sonnik', 'quantity': 3});
    expect(result.wallet.balance, 57);
    expect(result.quota.paidRemaining, 5);
  });

  test(
    'does not send quota purchase when session changes before token read',
    () async {
      final adapter = _MonetizationAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      final api = MonetizationApi.forDio(
        dio,
        _SwitchingSession(initialUid: 'user-1', switchedUid: 'user-2'),
      );

      await expectLater(
        api.purchaseRequestPack(
          feature: 'sonnik',
          quantity: 3,
          idempotencyKey: 'purchase-key-race',
        ),
        throwsException,
      );

      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'quota purchase reports stale insufficient balance as typed failure',
    () async {
      final adapter = _MonetizationAdapter()..quotaInsufficient = true;
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
        ..httpClientAdapter = adapter;
      await expectLater(
        MonetizationApi.forDio(dio, _FakeSession()).purchaseRequestPack(
          feature: 'sonnik',
          quantity: 3,
          idempotencyKey: 'stale-wallet',
        ),
        throwsA(isA<FeatureExecutionInsufficientStarsException>()),
      );
    },
  );

  test('consumes request quota through v2 quota endpoint', () async {
    final adapter = _MonetizationAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = MonetizationApi.forDio(dio, _FakeSession());

    final result = await api.consumeRequest(
      feature: 'anakra',
      idempotencyKey: 'consume-key-1',
    );

    expect(
      adapter.requests.single.uri.path,
      '/api/v2/me/request-quotas/consume',
    );
    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.headers['Idempotency-Key'], 'consume-key-1');
    expect(adapter.lastJsonBody, {'feature': 'anakra'});
    expect(result.source, 'free');
    expect(result.quota.freeRemaining, 2);
  });

  test('executes quota command through v2 command endpoint', () async {
    final adapter = _MonetizationAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = MonetizationApi.forDio(dio, _FakeSession());

    final result = await api.executeRequestQuotaCommand(
      feature: 'sonnik',
      payload: {'text': 'море', 'locale': 'ru'},
      idempotencyKey: 'command-key-1',
    );

    expect(
      adapter.requests.single.uri.path,
      '/api/v2/me/request-quotas/commands/sonnik',
    );
    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.headers['Idempotency-Key'], 'command-key-1');
    expect(
      adapter.requests.single.headers['X-Asteria-User-Token'],
      'user-token',
    );
    expect(adapter.lastJsonBody, {
      'payload': {'text': 'море', 'locale': 'ru'},
    });
    expect(result.uid, 'user-1');
    expect(result.result['title'], 'Сон про море');
    expect(result.user.sonnikHistory.single.title, 'Сон про море');
    expect(result.quota.freeRemaining, 2);
  });

  test('purchases shop request packs through v2 quota endpoint', () async {
    final adapter = _MonetizationAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = MonetizationApi.forDio(dio, _FakeSession());

    final result = await api.purchaseShopRequestPack(
      productId: 'VY7UBP2lTsNLj96hMqWi',
      quantity: 3,
      expectedPrice: 21,
      idempotencyKey: 'shop-purchase-key-1',
    );

    expect(
      adapter.requests.single.uri.path,
      '/api/v2/me/request-quotas/shop-purchases',
    );
    expect(adapter.requests.single.method, 'POST');
    expect(adapter.lastJsonBody, {
      'product_id': 'VY7UBP2lTsNLj96hMqWi',
      'quantity': 3,
      'expected_price': 21,
    });
    expect(result.wallet.balance, 56);
    expect(result.quota.paidRemaining, 3);
  });

  test('loads wallet history from v2 wallet entries endpoint', () async {
    final adapter = _MonetizationAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com/'))
      ..httpClientAdapter = adapter;
    final api = MonetizationApi.forDio(dio, _FakeSession());

    final history = await api.getWalletHistory();

    expect(adapter.requests.single.uri.path, '/api/v2/me/wallet/entries');
    expect(
      adapter.requests.single.headers['X-Asteria-User-Token'],
      'user-token',
    );
    expect(history.map((item) => item.amount), [15, 40]);
    expect(history.first.isDeposit, isFalse);
    expect(history.last.isDeposit, isTrue);
  });
}

class _MonetizationAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final List<Map<String, dynamic>> jsonBodies = [];
  Map<String, dynamic>? lastJsonBody;
  bool generatedFeatureFailure = false;
  bool quotaInsufficient = false;
  String? generatedFeatureTerminalStatus;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (requestStream != null) {
      final body = await utf8.decodeStream(requestStream);
      if (body.isNotEmpty) {
        lastJsonBody = Map<String, dynamic>.from(jsonDecode(body) as Map);
        jsonBodies.add(lastJsonBody!);
      }
    }
    if (options.path == 'api/v2/features/tarot_spread/executions') {
      return ResponseBody.fromString(
        jsonEncode({
          'execution_id': 'execution-love',
          'uid': 'user-1',
          'feature_key': 'tarot_spread',
          'catalog_revision': 3,
          'access_decision': 'stars',
          'charged_stars': 15,
          'wallet_entry_id': 'entry-1',
          'status': 'succeeded',
          'result_reference': 'tarot_spread:execution-love',
          'replayed': false,
          'created_at': '2026-08-30T12:00:00Z',
          'updated_at': '2026-08-30T12:00:00Z',
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path == 'api/v2/features/natal_chart/executions') {
      if (generatedFeatureFailure) {
        return ResponseBody.fromString(
          jsonEncode({
            'detail': {
              'code': 'insufficient_stars',
              'message': 'insufficient_stars',
            },
          }),
          409,
          headers: const {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      final terminalStatus = generatedFeatureTerminalStatus;
      if (terminalStatus != null) {
        return ResponseBody.fromString(
          jsonEncode({
            'execution_id': 'execution-terminal',
            'uid': 'user-1',
            'feature_key': 'natal_chart',
            'catalog_revision': 3,
            'access_decision': 'stars',
            'charged_stars': 0,
            'wallet_entry_id': null,
            'status': terminalStatus,
            'result_reference': null,
            'replayed': true,
            'created_at': '2026-08-30T12:00:00Z',
            'updated_at': '2026-08-30T12:00:00Z',
          }),
          200,
          headers: const {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      return ResponseBody.fromString(
        jsonEncode({
          'execution_id': 'execution-natal',
          'uid': 'user-1',
          'feature_key': 'natal_chart',
          'catalog_revision': 3,
          'access_decision': 'stars',
          'charged_stars': 100,
          'wallet_entry_id': 'entry-1',
          'status': 'succeeded',
          'result_reference': 'client_feature_result:execution-natal',
          'replayed': false,
          'created_at': '2026-08-30T12:00:00Z',
          'updated_at': '2026-08-30T12:00:00Z',
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path ==
        'api/v2/features/tarot_spread/executions/execution-love/result') {
      return ResponseBody.fromString(
        jsonEncode({
          'execution_id': 'execution-love',
          'spread_type': 'love',
          'card_ids': ['card-1', 'card-2'],
          'cards': [],
          'created_at': '2026-08-30T12:00:00Z',
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path == 'api/v2/features/tarot_spread/results/latest') {
      if (options.uri.queryParameters['spread_type'] == 'missing') {
        return ResponseBody.fromString(
          jsonEncode({'detail': 'not found'}),
          404,
          headers: const {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      return ResponseBody.fromString(
        jsonEncode({
          'execution_id': 'execution-celtic',
          'spread_type': 'celtic',
          'card_ids': [
            'card-0',
            'card-1',
            'card-2',
            'card-3',
            'card-4',
            'card-5',
            'card-6',
            'card-7',
            'card-8',
            'card-9',
          ],
          'cards': [],
          'created_at': '2026-08-30T12:00:00Z',
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path == 'api/v2/features/client-results/execution-natal') {
      return ResponseBody.fromString(
        jsonEncode({
          'execution_id': 'execution-natal',
          'feature_key': 'natal_chart',
          'result': {'final_conclusion': 'Карта собрана.'},
          'created_at': '2026-08-30T12:00:00Z',
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path == 'api/v2/me/request-quotas/purchases') {
      if (quotaInsufficient) {
        return ResponseBody.fromString(
          jsonEncode({
            'detail': {
              'code': 'wallet_insufficient_funds',
              'message': 'wallet balance is insufficient',
            },
          }),
          402,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      return ResponseBody.fromString(
        jsonEncode({
          'feature': 'sonnik',
          'quantity': 3,
          'price': 20,
          'replayed': false,
          'wallet': {
            'uid': 'user-1',
            'balance': 57,
            'debt': 0,
            'sequence': 10,
            'version': 10,
            'updated_at': '2026-08-30T12:00:00Z',
          },
          'quota': {
            'feature': 'sonnik',
            'free_remaining': 10,
            'paid_remaining': 5,
            'free_limit': 10,
            'period_started_at': '2026-08-30T12:00:00Z',
            'period_ends_at': '2026-09-06T12:00:00Z',
            'updated_at': '2026-08-30T12:00:00Z',
          },
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path == 'api/v2/me/request-quotas/consume') {
      return ResponseBody.fromString(
        jsonEncode({
          'feature': 'anakra',
          'source': 'free',
          'replayed': false,
          'quota': {
            'feature': 'anakra',
            'free_remaining': 2,
            'paid_remaining': 0,
            'free_limit': 3,
            'period_started_at': '2026-08-30T12:00:00Z',
            'period_ends_at': '2026-09-06T12:00:00Z',
            'updated_at': '2026-08-30T12:00:00Z',
          },
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path == 'api/v2/me/request-quotas/commands/sonnik') {
      final sonnik = {
        'id': 'sonnik-1',
        'date_generated': '2026-08-30T12:00:00Z',
        'title': 'Сон про море',
        'interpretation': 'Море показывает спокойное движение вперед.',
        'locale': 'ru',
      };
      return ResponseBody.fromString(
        jsonEncode({
          'uid': 'user-1',
          'feature': 'sonnik',
          'source': 'free',
          'replayed': false,
          'quota': {
            'feature': 'sonnik',
            'free_remaining': 2,
            'paid_remaining': 0,
            'free_limit': 3,
            'period_started_at': '2026-08-30T12:00:00Z',
            'period_ends_at': '2026-09-06T12:00:00Z',
            'updated_at': '2026-08-30T12:00:00Z',
          },
          'result': sonnik,
          'user': _userJson(sonnikHistory: [sonnik]),
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path == 'api/v2/me/request-quotas/shop-purchases') {
      return ResponseBody.fromString(
        jsonEncode({
          'feature': 'sonnik',
          'quantity': 3,
          'price': 21,
          'replayed': false,
          'wallet': {
            'uid': 'user-1',
            'balance': 56,
            'debt': 0,
            'sequence': 10,
            'version': 10,
            'updated_at': '2026-08-30T12:00:00Z',
          },
          'quota': {
            'feature': 'sonnik',
            'free_remaining': 10,
            'paid_remaining': 3,
            'free_limit': 10,
            'period_started_at': '2026-08-30T12:00:00Z',
            'period_ends_at': '2026-09-06T12:00:00Z',
            'updated_at': '2026-08-30T12:00:00Z',
          },
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    if (options.path == 'api/v2/me/wallet/entries') {
      return ResponseBody.fromString(
        jsonEncode({
          'has_entries': true,
          'next_before_sequence': null,
          'items': [
            {
              'entry_id': 'entry-2',
              'sequence': 2,
              'amount': -15,
              'entry_type': 'feature_debit',
              'description': 'Списание за функцию',
              'business_key': 'feature:one',
              'balance_after': 25,
              'created_at': '2026-08-25T11:59:00+00:00',
            },
            {
              'entry_id': 'entry-1',
              'sequence': 1,
              'amount': 40,
              'entry_type': 'payment_credit',
              'description': 'Пополнение баланса',
              'business_key': 'payment:one',
              'balance_after': 40,
              'created_at': '2026-08-25T11:58:00+00:00',
            },
          ],
        }),
        200,
        headers: const {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString(
      jsonEncode({
        'uid': 'user-1',
        'catalog_revision': 3,
        'wallet': {
          'uid': 'user-1',
          'balance': 77,
          'debt': 0,
          'sequence': 9,
          'version': 9,
          'updated_at': null,
        },
        'effective_pro': true,
        'effective_grants': [
          {
            'entitlement': 'pro',
            'provider': 'apple',
            'product_id': 'pro_monthly',
            'status': 'active',
            'ends_at': '2026-09-30T12:00:00Z',
            'grace_until': null,
            'cancel_at_period_end': false,
          },
        ],
        'rewards': [
          {
            'key': 'onboarding_complete',
            'status': 'completed',
            'current': 1,
            'target': 1,
            'amount': 5,
            'next_available_at': null,
          },
          {
            'key': 'first_tarot_spread',
            'status': 'available',
            'current': 0,
            'target': 1,
            'amount': 5,
            'next_available_at': null,
          },
        ],
        'request_quotas': {
          'compatibility': {
            'feature': 'compatibility',
            'free_remaining': 8,
            'paid_remaining': 0,
            'free_limit': 8,
            'period_started_at': '2026-08-30T12:00:00Z',
            'period_ends_at': '2026-09-06T12:00:00Z',
            'updated_at': '2026-08-30T12:00:00Z',
          },
          'sonnik': {
            'feature': 'sonnik',
            'free_remaining': 10,
            'paid_remaining': 2,
            'free_limit': 10,
            'period_started_at': '2026-08-30T12:00:00Z',
            'period_ends_at': '2026-09-06T12:00:00Z',
            'updated_at': '2026-08-30T12:00:00Z',
          },
          'anakra': {
            'feature': 'anakra',
            'free_remaining': 10,
            'paid_remaining': 0,
            'free_limit': 10,
            'period_started_at': '2026-08-30T12:00:00Z',
            'period_ends_at': '2026-09-06T12:00:00Z',
            'updated_at': '2026-08-30T12:00:00Z',
          },
        },
        'rollout_policy': {},
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

Map<String, dynamic> _userJson({
  List<Map<String, dynamic>> sonnikHistory = const [],
  List<Map<String, dynamic>> compatibilityHistory = const [],
  List<Map<String, dynamic>> anakraMessages = const [],
}) {
  return {
    'id': 'user-1',
    'email': 'user@example.com',
    'auth_method': 'email',
    'balance': 0,
    'user_group': 'user',
    'subscription_type': 'free',
    'created_at': '2026-08-30T11:00:00Z',
    'updated_at': '2026-08-30T12:00:00Z',
    'compatibility_history': compatibilityHistory,
    'viewed_content_ids': [],
    'kelt_deck_impact': [],
    'sonnik_history': sonnikHistory,
    'balance_history': [],
    'solar_data': {'data': ''},
    'planets_houses_data': {
      'data': '',
      'elements': {'fire': '', 'earth': '', 'air': '', 'water': ''},
    },
    'anakra_messages': anakraMessages,
  };
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
