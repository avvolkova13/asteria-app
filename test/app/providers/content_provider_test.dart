import 'package:asteria_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_state.dart';
import 'package:asteria_app/features/achievements/data/achievement_recorder.dart';
import 'package:asteria_app/features/achievements/domain/achievement_event.dart';
import 'package:asteria_app/app/data/models/user/tarot_card_of_day_item_model.dart';
import 'package:asteria_app/app/data/models/user/rune_of_day_item_model.dart';
import 'package:asteria_app/core/utils/utils.dart';
import 'dart:async';
import 'dart:ui';

import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/data/models/energy_of_day/energy_of_day_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_shared_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_year_model.dart';
import 'package:asteria_app/app/data/models/natal_card/natal_card_model.dart';
import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/data/models/user/rune_deck_model.dart';
import 'package:asteria_app/app/data/models/user/tarot_deck_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/const/keys_const.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/features/compatibility/domain/repositories/compatibility_repository.dart';
import 'package:asteria_app/features/monetization/data/feature_execution_api.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/data/pending_feature_execution_store.dart';
import 'package:asteria_app/features/monetization/domain/feature_execution_models.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('daily symbols emit one account-scoped event per opened day', () async {
    final userProvider = UserProvider(userRepository: _FakeUserRepository());
    final today = formatDateKey(DateTime.now());
    userProvider.applyServerUserSnapshot(
      _natalUser().copyWith(
        tarotCardOfDayItem: TarotCardOfDayItemModel(
          cardId: 'card-a',
          date: today,
          isOpened: false,
        ),
        runeOfDayItem: RuneOfDayItemModel(
          runeId: 'rune-a',
          date: today,
          isOpened: false,
        ),
      ),
    );
    final achievements = _AchievementRecorder();
    final provider = ContentProvider(
      contentRepository: _FakeContentRepository(),
      userProvider: userProvider,
      achievementRecorder: achievements,
    );
    di.registerSingleton<AnalyticsFacade>(_FakeAnalyticsFacade());
    addTearDown(() => di.unregister<AnalyticsFacade>());
    addTearDown(provider.dispose);
    addTearDown(userProvider.dispose);
    await provider.setTodayTarotCardOpened();
    await provider.setTodayTarotCardOpened();
    await provider.setTodayRuneOpened();
    await provider.setTodayRuneOpened();
    expect(achievements.events.map((event) => event.kind), [
      AchievementEventKind.tarotDay,
      AchievementEventKind.runeDay,
    ]);
    expect(
      achievements.events.every(
        (event) => event.userId == 'natal-user' && event.reference == today,
      ),
      isTrue,
    );
  });

  test(
    'daily symbols and home flags reset on a new day in the same session',
    () async {
      var now = DateTime(2026, 9, 16, 23, 59);
      final repository = _FakeUserRepository();
      final userProvider = UserProvider(userRepository: repository);
      UserModel dailyUser(int index) => _natalUser().copyWith(
        tarotCardOfDayItem: TarotCardOfDayItemModel(
          cardId: 'card-$index',
          date: formatDateKey(now),
          isOpened: false,
        ),
        runeOfDayItem: RuneOfDayItemModel(
          runeId: 'rune-$index',
          date: formatDateKey(now),
          isOpened: false,
        ),
      );
      userProvider.applyServerUserSnapshot(dailyUser(0));
      final achievements = _AchievementRecorder();
      final provider = ContentProvider(
        now: () => now,
        contentRepository: _FakeContentRepository(
          tarotCards: _tarotCards(),
          runes: _runes(),
        ),
        userProvider: userProvider,
        achievementRecorder: achievements,
      );
      final home = HomeCubit(
        userRepository: repository,
        contentProvider: provider,
        userProvider: userProvider,
      );
      di.registerSingleton<AnalyticsFacade>(_FakeAnalyticsFacade());
      addTearDown(() => di.unregister<AnalyticsFacade>());
      addTearDown(provider.dispose);
      addTearDown(userProvider.dispose);
      addTearDown(home.close);
      await provider.loadContent();
      await home.start();
      provider.getTodayTarotCard();
      provider.getTodayRune();
      await provider.setTodayTarotCardOpened();
      await provider.setTodayRuneOpened();
      home.syncTarotCard();
      home.syncRune();
      expect((home.state as HomeLoaded).isTarotCardOpened, isTrue);
      expect((home.state as HomeLoaded).isRuneOpened, isTrue);

      now = DateTime(2026, 9, 17, 0, 1);
      userProvider.applyServerUserSnapshot(dailyUser(1));
      home.syncTarotCard();
      home.syncRune();
      expect((home.state as HomeLoaded).isTarotCardOpened, isFalse);
      expect((home.state as HomeLoaded).isRuneOpened, isFalse);
      expect(provider.getTodayTarotCard().id, 'card-1');
      expect(provider.getTodayRune().id, 'rune-1');
      await provider.setTodayTarotCardOpened();
      await provider.setTodayRuneOpened();
      expect(achievements.events.map((event) => event.reference), [
        '2026-09-16',
        '2026-09-16',
        '2026-09-17',
        '2026-09-17',
      ]);
    },
  );

  test(
    'hidden horoscopes cannot be requested or purchased for any period',
    () async {
      final provider = _contentProvider(_FakeContentRepository());
      addTearDown(provider.dispose);
      for (final period in HoroscopeTypeEnum.values) {
        await expectLater(
          provider.buyHoroscope(period),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'reason',
              'Feature is unavailable',
            ),
          ),
        );
      }
    },
  );

  test(
    'catalog and direct article lookup hide both languages, including body text',
    () async {
      const plain = ArticleModel(
        id: 'visible',
        title: 'Фазы Луны',
        category: 'Луна',
        intro: 'Moonlight',
        text: 'Как наблюдать Луну',
        conclusion: 'Продолжить',
        timeToRead: 1,
      );
      final repository = _FakeContentRepository(
        articles: [
          plain,
          plain.copyWith(id: 'ru-title', title: 'Кратко о гороскопах'),
          plain.copyWith(id: 'en-category', category: 'Weekly HOROSCOPES'),
          plain.copyWith(id: 'ru-intro', intro: 'Как читать гороскоп?'),
          plain.copyWith(id: 'en-body', text: 'See the horoscope for more.'),
          plain.copyWith(id: 'en-conclusion', conclusion: 'Your horoscope'),
        ],
      );
      final provider = _contentProvider(repository);
      addTearDown(provider.dispose);
      await provider.loadContent();
      expect(provider.articles.map((item) => item.id), ['visible']);
      expect(provider.getArticleById('visible'), same(plain));
      for (final hidden in repository.articles.skip(1)) {
        expect(provider.getArticleById(hidden.id), isNull);
      }
      expect(repository.articles.length, 6);
    },
  );

  test('continues loading affirmations when tarot loading fails', () async {
    final repository = _FakeContentRepository(
      failTarot: true,
      affirmations: [_affirmation()],
    );
    final provider = _contentProvider(repository);

    await provider.loadContent();

    expect(provider.affirmations, hasLength(1));
    expect(provider.affirmations.single.text, 'Я доверяю себе');
    expect(provider.isLoadingContent, isFalse);
    expect(repository.refreshVersionsCalls, 1);
  });

  test('preserves loaded content when a later reload fails', () async {
    final repository = _FakeContentRepository(
      tarotCards: [_tarotCard()],
      affirmations: [_affirmation()],
    );
    final provider = _contentProvider(repository);
    await provider.loadContent();

    final loadedTarotCards = provider.tarotCards;
    final loadedAffirmations = provider.affirmations;
    repository.failAll = true;

    await provider.loadContent();

    expect(provider.tarotCards, same(loadedTarotCards));
    expect(provider.affirmations, same(loadedAffirmations));
    expect(provider.isLoadingContent, isFalse);
  });

  test('loads content after a failed attempt is retried', () async {
    final repository = _FakeContentRepository(failAll: true);
    final provider = _contentProvider(repository);

    await provider.loadContent();
    expect(provider.affirmations, isEmpty);

    repository
      ..failAll = false
      ..affirmations = [_affirmation()];
    await provider.loadContent();

    expect(provider.affirmations, hasLength(1));
    expect(provider.isLoadingContent, isFalse);
  });

  test('reuses the in-flight content load', () async {
    final tarotLoad = Completer<List<TarotCardModel>>();
    final repository = _FakeContentRepository(tarotLoad: tarotLoad);
    final provider = _contentProvider(repository);

    final firstLoad = provider.loadContent();
    final secondLoad = provider.loadContent();

    expect(provider.isLoadingContent, isTrue);
    expect(secondLoad, same(firstLoad));

    tarotLoad.complete([]);
    await firstLoad;

    expect(provider.isLoadingContent, isFalse);
  });

  test('reloads content when the app returns to foreground', () async {
    final binding = TestWidgetsFlutterBinding.instance;
    final repository = _FakeContentRepository(affirmations: [_affirmation()]);
    final provider = _contentProvider(repository);
    addTearDown(provider.dispose);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);

    expect(repository.refreshVersionsCalls, 1);
  });

  test(
    'clears and reloads locale-dependent content after locale change',
    () async {
      final localeService = AppLocaleService(
        platformLocales: const <Locale>[Locale('ru', 'RU')],
      );
      final repository = _FakeContentRepository(
        tarotCards: [_tarotCard(title: 'Шут')],
      );
      final provider = _contentProvider(
        repository,
        localeService: localeService,
      );
      await provider.loadContent();
      expect(provider.tarotCards.single.title, 'Шут');

      repository
        ..tarotCards = [_tarotCard(title: 'The Fool')]
        ..tarotReloaded = Completer<void>();
      localeService.updatePlatformLocales(const <Locale>[Locale('en', 'US')]);

      expect(provider.tarotCards, isEmpty);
      await repository.tarotReloaded!.future.timeout(
        const Duration(seconds: 1),
      );
      await Future<void>.delayed(Duration.zero);

      expect(provider.tarotCards.single.title, 'The Fool');
      expect(repository.getTarotCalls, 2);
      provider.dispose();
      localeService.dispose();
    },
  );

  test('buys natal card through backend generated feature execution', () async {
    final userRepository = _FakeUserRepository();
    final userProvider = UserProvider(userRepository: userRepository);
    userProvider.applyServerUserSnapshot(_natalUser());
    final repository = _FakeContentRepository();
    final functionsApi = _FakeBackendApi();
    final featureApi = _FakeFeatureExecutionApi();
    final provider = ContentProvider(
      contentRepository: repository,
      userProvider: userProvider,
      monetizationProvider: _fakeMonetizationProvider(userProvider),
      featureExecutionApi: featureApi,
      pendingFeatureExecutionStore: _FakePendingFeatureExecutionStore(),
      compatibilityRepository: _FakeCompatibilityRepository(),
      backendApi: functionsApi,
    );
    addTearDown(provider.dispose);
    addTearDown(userProvider.dispose);

    await provider.buyNatalCard();

    expect(functionsApi.planetsCalls, 1);
    expect(functionsApi.lastPlanetsRequest, {
      'year': 2000,
      'month': 8,
      'day': 19,
      'hour': 12,
      'minute': 45,
      'latitude': 51.4964778,
      'longitude': 44.4818327,
    });
    expect(repository.natalCalls, 0);
    expect(featureApi.featureKey, 'natal_chart');
    expect(
      featureApi.generatedPayload?['planets_birthdate'],
      contains('Солнце - Лев - 10'),
    );
    expect(
      featureApi.generatedPayload?['planets_birthdate'],
      isNot(contains('Солнце - Лев - 4')),
    );
    expect(featureApi.idempotencyKey, isNotEmpty);
    expect(userRepository.updatedUser?.planetsHousesData.positions, isNotEmpty);
    expect(userProvider.currentUser?.natalCard, isNotNull);
    expect(userProvider.currentUser?.natalCard?.hasLanguage('ru'), isTrue);
    expect(userRepository.getUserByIdCalls, 1);
  });

  test(
    'keeps generated natal card visible when profile refresh is stale',
    () async {
      final userRepository = _FakeUserRepository();
      final userProvider = UserProvider(userRepository: userRepository);
      final staleUser = _natalUser().copyWith(
        planetsHousesData: _completePlanetsHousesData(),
      );
      userProvider.applyServerUserSnapshot(staleUser);
      userRepository.refreshedUser = staleUser;
      final featureApi = _FakeFeatureExecutionApi();
      final provider = ContentProvider(
        contentRepository: _FakeContentRepository(),
        userProvider: userProvider,
        monetizationProvider: _fakeMonetizationProvider(userProvider),
        featureExecutionApi: featureApi,
        pendingFeatureExecutionStore: _FakePendingFeatureExecutionStore(),
        compatibilityRepository: _FakeCompatibilityRepository(),
        backendApi: _FakeBackendApi(),
      );
      addTearDown(provider.dispose);
      addTearDown(userProvider.dispose);

      await provider.buyNatalCard();

      expect(featureApi.featureKey, 'natal_chart');
      expect(userRepository.updatedUser, isNull);
      expect(userRepository.getUserByIdCalls, 1);
      expect(userProvider.currentUser?.natalCard?.hasLanguage('ru'), isTrue);
    },
  );

  test(
    'rejects legacy natal generated result without clearing pending execution',
    () async {
      final userRepository = _FakeUserRepository();
      final userProvider = UserProvider(userRepository: userRepository);
      userProvider.applyServerUserSnapshot(_natalUser());
      final pendingStore = _FakePendingFeatureExecutionStore();
      final provider = ContentProvider(
        contentRepository: _FakeContentRepository(),
        userProvider: userProvider,
        monetizationProvider: _fakeMonetizationProvider(userProvider),
        featureExecutionApi: _FakeFeatureExecutionApi(
          generatedOutcomes: [
            ClientFeatureResultModel(
              executionId: 'legacy-natal-result',
              featureKey: 'natal_chart',
              result: {'final_conclusion': 'legacy final'},
            ),
          ],
        ),
        pendingFeatureExecutionStore: pendingStore,
        compatibilityRepository: _FakeCompatibilityRepository(),
        backendApi: _FakeBackendApi(),
      );
      addTearDown(provider.dispose);
      addTearDown(userProvider.dispose);

      await expectLater(provider.buyNatalCard(), throwsA(isA<Exception>()));

      expect(userProvider.currentUser?.natalCard, isNull);
      expect(pendingStore.deleteCalls, 0);
      expect(pendingStore.pending?.idempotencyKey, 'pending-key');
    },
  );

  for (final useRegisteredApi in [false, true]) {
    test(
      'translates existing natal card without payment (registered API: $useRegisteredApi)',
      () async {
        final localeService = AppLocaleService(
          platformLocales: const <Locale>[Locale('en', 'US')],
        );
        final userRepository = _FakeUserRepository();
        final userProvider = UserProvider(userRepository: userRepository);
        userProvider.applyServerUserSnapshot(
          _natalUser().copyWith(natalCard: _natalCard(language: 'ru')),
        );
        final featureApi = _FakeFeatureExecutionApi(
          translatedUser: _natalUser().copyWith(
            natalCard: _natalCard(language: 'ru').copyWithInterpretation(
              language: 'en',
              interpretation: _natalInterpretation('en'),
            ),
          ),
        );
        if (useRegisteredApi) {
          di.registerSingleton<FeatureExecutionApi>(featureApi);
          addTearDown(() => di.unregister<FeatureExecutionApi>());
        }
        final provider = ContentProvider(
          contentRepository: _FakeContentRepository(),
          userProvider: userProvider,
          monetizationProvider: _fakeMonetizationProvider(userProvider),
          featureExecutionApi: useRegisteredApi ? null : featureApi,
          pendingFeatureExecutionStore: _FakePendingFeatureExecutionStore(),
          compatibilityRepository: _FakeCompatibilityRepository(),
          backendApi: _FakeBackendApi(),
          localeService: localeService,
        );
        addTearDown(provider.dispose);
        addTearDown(userProvider.dispose);
        addTearDown(localeService.dispose);

        await provider.translateNatalCardIfNeeded();

        expect(featureApi.translatedLanguage, 'en');
        expect(featureApi.generatedIdempotencyKeys, isEmpty);
        expect(userProvider.currentUser?.natalCard?.hasLanguage('en'), isTrue);
        expect(
          userProvider.currentUser?.natalCard
              ?.interpretationFor('en')
              .finalConclusion,
          'en final',
        );
      },
    );
  }

  test(
    'retries generated horoscope once with a fresh command after stale pending conflict',
    () async {
      final userRepository = _FakeUserRepository();
      final userProvider = UserProvider(userRepository: userRepository);
      userProvider.applyServerUserSnapshot(_natalUser());
      final featureApi = _FakeFeatureExecutionApi(
        generatedOutcomes: [
          const FeatureExecutionException(
            'idempotency_conflict',
            'idempotency key was reused with another request payload',
          ),
          ClientFeatureResultModel(
            executionId: 'execution-year',
            featureKey: 'yearly_personal_horoscope',
            result: _yearHoroscope().toJson(),
          ),
        ],
      );
      final pendingStore = _FakePendingFeatureExecutionStore(
        idempotencyKeys: ['stale-key', 'fresh-key'],
      );
      final achievements = _AchievementRecorder();
      final provider = ContentProvider(
        horoscopesEnabled: true,
        achievementRecorder: achievements,
        contentRepository: _FakeContentRepository(),
        userProvider: userProvider,
        monetizationProvider: _fakeMonetizationProvider(userProvider),
        featureExecutionApi: featureApi,
        pendingFeatureExecutionStore: pendingStore,
        compatibilityRepository: _FakeCompatibilityRepository(),
      );
      addTearDown(provider.dispose);
      addTearDown(userProvider.dispose);

      await provider.buyHoroscope(HoroscopeTypeEnum.year);

      expect(featureApi.generatedIdempotencyKeys, ['stale-key', 'fresh-key']);
      expect(pendingStore.deleteCalls, 2);
      expect(pendingStore.pending, isNull);
      expect(achievements.events.single.kind, AchievementEventKind.horoscope);
      expect(
        achievements.events.single.reference,
        'year:${formatDateKey(_yearHoroscope().dateUntil)}',
      );
      expect(
        userProvider.currentUser?.horoscopeYear?.astroMetaphor,
        'Метафора',
      );
    },
  );

  test(
    'retries generated horoscope once after terminal replay without a result',
    () async {
      final userRepository = _FakeUserRepository();
      final userProvider = UserProvider(userRepository: userRepository);
      userProvider.applyServerUserSnapshot(_natalUser());
      final featureApi = _FakeFeatureExecutionApi(
        generatedOutcomes: [
          const FeatureExecutionException(
            'execution_compensated',
            'Feature execution did not finish: compensated',
          ),
          ClientFeatureResultModel(
            executionId: 'execution-year',
            featureKey: 'yearly_personal_horoscope',
            result: _yearHoroscope().toJson(),
          ),
        ],
      );
      final pendingStore = _FakePendingFeatureExecutionStore(
        idempotencyKeys: ['terminal-key', 'fresh-key'],
      );
      final achievements = _AchievementRecorder();
      final provider = ContentProvider(
        horoscopesEnabled: true,
        achievementRecorder: achievements,
        contentRepository: _FakeContentRepository(),
        userProvider: userProvider,
        monetizationProvider: _fakeMonetizationProvider(userProvider),
        featureExecutionApi: featureApi,
        pendingFeatureExecutionStore: pendingStore,
        compatibilityRepository: _FakeCompatibilityRepository(),
      );
      addTearDown(provider.dispose);
      addTearDown(userProvider.dispose);

      await provider.buyHoroscope(HoroscopeTypeEnum.year);

      expect(featureApi.generatedIdempotencyKeys, [
        'terminal-key',
        'fresh-key',
      ]);
      expect(pendingStore.deleteCalls, 2);
      expect(pendingStore.pending, isNull);
      expect(achievements.events.single.kind, AchievementEventKind.horoscope);
      expect(
        achievements.events.single.reference,
        'year:${formatDateKey(_yearHoroscope().dateUntil)}',
      );
      expect(userProvider.currentUser?.horoscopeYear?.emotionalWorld, 'Эмоции');
    },
  );

  test(
    'does not refresh generated horoscope command after insufficient stars',
    () async {
      final userProvider = UserProvider(userRepository: _FakeUserRepository());
      userProvider.applyServerUserSnapshot(_natalUser());
      final featureApi = _FakeFeatureExecutionApi(
        generatedOutcomes: [
          const FeatureExecutionInsufficientStarsException(
            'insufficient_stars',
          ),
        ],
      );
      final pendingStore = _FakePendingFeatureExecutionStore(
        idempotencyKeys: ['pending-key', 'fresh-key'],
      );
      final achievements = _AchievementRecorder();
      final provider = ContentProvider(
        horoscopesEnabled: true,
        achievementRecorder: achievements,
        contentRepository: _FakeContentRepository(),
        userProvider: userProvider,
        monetizationProvider: _fakeMonetizationProvider(userProvider),
        featureExecutionApi: featureApi,
        pendingFeatureExecutionStore: pendingStore,
        compatibilityRepository: _FakeCompatibilityRepository(),
      );
      addTearDown(provider.dispose);
      addTearDown(userProvider.dispose);

      await expectLater(
        provider.buyHoroscope(HoroscopeTypeEnum.year),
        throwsA(isA<Exception>()),
      );

      expect(featureApi.generatedIdempotencyKeys, ['pending-key']);
      expect(pendingStore.deleteCalls, 0);
      expect(pendingStore.pending, isNotNull);
      expect(userProvider.currentUser?.horoscopeYear, isNull);
      expect(achievements.events, isEmpty);
    },
  );

  test('creates sonnik through backend quota command', () async {
    final userProvider = UserProvider(userRepository: _FakeUserRepository());
    userProvider.applyServerUserSnapshot(
      UserModel.empty().copyWith(id: 'natal-user', name: 'Антон'),
    );
    final api = _FakeMonetizationApi();
    final pendingStore = _FakePendingFeatureExecutionStore();
    final monetizationProvider = MonetizationProvider(
      api: api,
      userProvider: userProvider,
      pendingStore: pendingStore,
    );
    final provider = ContentProvider(
      contentRepository: _FakeContentRepository(),
      userProvider: userProvider,
      monetizationProvider: monetizationProvider,
      pendingFeatureExecutionStore: pendingStore,
      compatibilityRepository: _FakeCompatibilityRepository(),
    );
    addTearDown(provider.dispose);
    addTearDown(userProvider.dispose);

    final sonnik = await provider.createSonnik('море');

    expect(api.commandFeature, 'sonnik');
    expect(api.commandIdempotencyKey, 'pending-key');
    expect(api.commandPayload, {
      'text': 'море',
      'locale': 'ru',
      'name': 'Антон',
    });
    expect(sonnik.id, 'sonnik-command-1');
    expect(
      userProvider.currentUser?.sonnikHistory.single.id,
      'sonnik-command-1',
    );
    expect(pendingStore.pending, isNull);
  });

  group('interactive spread state', () {
    late _FakeAnalyticsFacade analytics;

    setUp(() async {
      await di.reset();
      analytics = _FakeAnalyticsFacade();
      di.registerSingleton<AnalyticsFacade>(analytics);
    });

    tearDown(() async {
      await di.reset();
    });

    test(
      'preserves spread selection but resets transient open state',
      () async {
        final userRepository = _FakeUserRepository();
        final userProvider = UserProvider(userRepository: userRepository);
        userProvider.applyServerUserSnapshot(_spreadUser());
        final repository = _FakeContentRepository(
          tarotCards: _tarotCards(),
          runes: _runes(),
        );
        final provider = ContentProvider(
          contentRepository: repository,
          userProvider: userProvider,
          compatibilityRepository: _FakeCompatibilityRepository(),
        );
        addTearDown(provider.dispose);
        addTearDown(userProvider.dispose);

        await provider.loadContent();
        await provider.ensureTarotDeckLayoutReady();
        await provider.ensureRuneDeckLayoutReady();

        final initialTarotDeck = userProvider.currentUser!.tarotDeck!;
        final initialRuneDeck = userProvider.currentUser!.runeDeck!;
        expect(
          initialTarotDeck.cards.map((card) => card.id).toSet(),
          hasLength(3),
        );
        expect(initialTarotDeck.cards.every((card) => !card.isOpened), isTrue);
        expect(
          initialRuneDeck.cards.map((rune) => rune.id).toSet(),
          hasLength(3),
        );
        expect(initialRuneDeck.cards.every((rune) => !rune.isOpened), isTrue);

        await provider.openTarotCardInDeck(
          KeysConst.tarotDeckCardLeftKey,
          cardId: initialTarotDeck.cards.first.id,
        );
        await provider.openRuneInDeck(KeysConst.runeDeckLeftKey);
        expect(
          provider.isTarotCardInDeckOpened(KeysConst.tarotDeckCardLeftKey),
          isTrue,
        );
        expect(provider.isRuneInDeckOpened(KeysConst.runeDeckLeftKey), isTrue);
        final persistedTarotIds = userProvider.currentUser!.tarotDeck!.cards
            .map((card) => card.id)
            .toList();
        final persistedRuneIds = userProvider.currentUser!.runeDeck!.cards
            .map((rune) => rune.id)
            .toList();

        await provider.ensureTarotDeckLayoutReady();
        await provider.ensureRuneDeckLayoutReady();
        provider.resetTarotAndRuneOpenState();

        expect(
          userProvider.currentUser!.tarotDeck!.cards.map((card) => card.id),
          persistedTarotIds,
        );
        expect(
          userProvider.currentUser!.tarotDeck!.cards.every(
            (card) => !card.isOpened,
          ),
          isTrue,
        );
        expect(
          userProvider.currentUser!.runeDeck!.cards.map((rune) => rune.id),
          persistedRuneIds,
        );
        expect(
          userProvider.currentUser!.runeDeck!.cards.every(
            (rune) => !rune.isOpened,
          ),
          isTrue,
        );
        expect(
          provider.isTarotCardInDeckOpened(KeysConst.tarotDeckCardLeftKey),
          isFalse,
        );
        expect(provider.isRuneInDeckOpened(KeysConst.runeDeckLeftKey), isFalse);
      },
    );

    test(
      'opens only the selected position and ignores repeated opens',
      () async {
        final userRepository = _FakeUserRepository();
        final userProvider = UserProvider(userRepository: userRepository);
        userProvider.applyServerUserSnapshot(
          _spreadUser(
            tarotDeck: TarotDeckModel(
              cards: _tarotCards()
                  .take(3)
                  .map(
                    (card) =>
                        TarotCardInDeckModel(id: card.id, isOpened: false),
                  )
                  .toList(),
            ),
            runeDeck: RuneDeckModel(
              cards: _runes()
                  .take(3)
                  .map((rune) => RuneInDeckModel(id: rune.id, isOpened: false))
                  .toList(),
            ),
          ),
        );
        final provider = ContentProvider(
          contentRepository: _FakeContentRepository(
            tarotCards: _tarotCards(),
            runes: _runes(),
          ),
          userProvider: userProvider,
          compatibilityRepository: _FakeCompatibilityRepository(),
        );
        addTearDown(provider.dispose);
        addTearDown(userProvider.dispose);
        await provider.loadContent();

        final tarotId = userProvider.currentUser!.tarotDeck!.cards[1].id;
        await provider.openTarotCardInDeck(
          KeysConst.tarotDeckCardCenterKey,
          cardId: tarotId,
        );
        await provider.openTarotCardInDeck(
          KeysConst.tarotDeckCardCenterKey,
          cardId: tarotId,
        );
        await provider.openRuneInDeck(KeysConst.runeDeckCenterKey);
        await provider.openRuneInDeck(KeysConst.runeDeckCenterKey);

        expect(
          userProvider.currentUser!.tarotDeck!.cards.map(
            (card) => card.isOpened,
          ),
          [false, false, false],
        );
        expect(
          userProvider.currentUser!.runeDeck!.cards.map(
            (rune) => rune.isOpened,
          ),
          [false, false, false],
        );
        expect(
          provider.isTarotCardInDeckOpened(KeysConst.tarotDeckCardCenterKey),
          isTrue,
        );
        expect(
          provider.isRuneInDeckOpened(KeysConst.runeDeckCenterKey),
          isTrue,
        );
        expect(analytics.eventCount, 3);
      },
    );

    test('refresh creates closed spreads and clears interpretations', () async {
      final userRepository = _FakeUserRepository();
      final userProvider = UserProvider(userRepository: userRepository);
      userProvider.applyServerUserSnapshot(
        _spreadUser(
          tarotDeck: TarotDeckModel(
            cards: _tarotCards()
                .take(3)
                .map(
                  (card) => TarotCardInDeckModel(id: card.id, isOpened: true),
                )
                .toList(),
            interpretation: const InterpretationModel(
              love: 'love',
              selfRealization: '',
              spirituality: '',
              health: '',
              family: '',
              career: '',
              creativity: '',
              other: '',
            ),
          ),
          runeDeck: RuneDeckModel(
            cards: _runes()
                .take(3)
                .map((rune) => RuneInDeckModel(id: rune.id, isOpened: true))
                .toList(),
            interpretation: 'insight',
          ),
        ),
      );
      final provider = ContentProvider(
        contentRepository: _FakeContentRepository(
          tarotCards: _tarotCards(),
          runes: _runes(),
        ),
        userProvider: userProvider,
        compatibilityRepository: _FakeCompatibilityRepository(),
      );
      addTearDown(provider.dispose);
      addTearDown(userProvider.dispose);
      await provider.loadContent();

      expect(await provider.refreshTarotDeckLayout(), isTrue);
      expect(await provider.refreshRuneDeckLayout(), isTrue);

      final tarotDeck = userProvider.currentUser!.tarotDeck!;
      final runeDeck = userProvider.currentUser!.runeDeck!;
      expect(tarotDeck.cards.map((card) => card.id).toSet(), hasLength(3));
      expect(tarotDeck.cards.every((card) => !card.isOpened), isTrue);
      expect(tarotDeck.interpretation, isNull);
      expect(runeDeck.cards.map((rune) => rune.id).toSet(), hasLength(3));
      expect(runeDeck.cards.every((rune) => !rune.isOpened), isTrue);
      expect(runeDeck.interpretation, isNull);
    });

    test('rejects insight requests until all positions are opened', () async {
      final userRepository = _FakeUserRepository();
      final userProvider = UserProvider(userRepository: userRepository);
      userProvider.applyServerUserSnapshot(
        _spreadUser(
          tarotDeck: TarotDeckModel(
            cards: _tarotCards()
                .take(3)
                .map(
                  (card) => TarotCardInDeckModel(id: card.id, isOpened: false),
                )
                .toList(),
          ),
          runeDeck: RuneDeckModel(
            cards: _runes()
                .take(3)
                .map((rune) => RuneInDeckModel(id: rune.id, isOpened: false))
                .toList(),
          ),
        ),
      );
      final provider = ContentProvider(
        contentRepository: _FakeContentRepository(
          tarotCards: _tarotCards(),
          runes: _runes(),
        ),
        userProvider: userProvider,
        compatibilityRepository: _FakeCompatibilityRepository(),
      );
      addTearDown(provider.dispose);
      addTearDown(userProvider.dispose);
      await provider.loadContent();

      await expectLater(
        provider.getTarotDeckLayoutInsight(),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        provider.getRuneDeckLayoutInsight(),
        throwsA(isA<Exception>()),
      );
    });
  });
}

ContentProvider _contentProvider(
  _FakeContentRepository repository, {
  AppLocaleService? localeService,
}) {
  return ContentProvider(
    contentRepository: repository,
    userProvider: UserProvider(userRepository: _FakeUserRepository()),
    compatibilityRepository: _FakeCompatibilityRepository(),
    localeService: localeService,
  );
}

MonetizationProvider _fakeMonetizationProvider(UserProvider userProvider) {
  return MonetizationProvider(
    api: _FakeMonetizationApi(),
    userProvider: userProvider,
  );
}

AffirmationModel _affirmation() {
  return AffirmationModel(
    id: 'affirmation-id',
    category: 'Сила',
    text: 'Я доверяю себе',
    sort: 0,
  );
}

TarotCardModel _tarotCard({String title = 'Шут'}) {
  return TarotCardModel(
    id: 'the-fool',
    title: title,
    imageName: '',
    sort: 0,
    keywords: [],
    cardOfDayDescription: '',
    generalDescription: '',
    shortDescription: '',
    textInDecks: [],
    keltDeck: [],
    keltDeckImpact: [],
    loveDeck: [],
  );
}

List<TarotCardModel> _tarotCards() => List.generate(
  4,
  (index) => _tarotCard(
    title: 'Card $index',
  ).copyWith(id: 'card-$index', imageName: 'card-$index'),
);

List<RuneOfDayModel> _runes() => List.generate(
  4,
  (index) => RuneOfDayModel(
    id: 'rune-$index',
    title: 'Rune $index',
    imageName: 'rune-$index',
    sort: index,
    cardOfDayDescription: '',
    generalDescription: '',
    pastDeck: '',
    presentDeck: '',
    futureDeck: '',
    keywords: const [],
    definitions: const [],
  ),
);

UserModel _spreadUser({TarotDeckModel? tarotDeck, RuneDeckModel? runeDeck}) {
  return UserModel.empty().copyWith(
    id: 'spread-user',
    phoneNumber: '+10000000000',
    tarotDeck: tarotDeck,
    runeDeck: runeDeck,
  );
}

UserModel _natalUser() {
  return UserModel.empty().copyWith(
    id: 'natal-user',
    name: 'Антон',
    personalInfo: PersonalInfoModel(
      birthDate: BirthDateModel(
        birthDate: DateTime(2000, 8, 19),
        birthTime: DateTime(0, 1, 1, 12, 45),
      ),
      birthPlace: const BirthPlaceModel(
        location: 'Калининск, Саратовская область, Россия',
        latitude: 51.4964778,
        longitude: 44.4818327,
      ),
    ),
    planetsHousesData: const PlanetsHousesDataModel(
      data: 'Солнце - Лев - 4',
      elements: Elements(fire: '5', earth: '4', air: '6', water: '2'),
    ),
  );
}

NatalCardModel _natalCard({String language = 'ru'}) {
  return NatalCardModel(
    sourceLanguage: language,
    interpretations: {language: _natalInterpretation(language)},
  );
}

NatalCardInterpretationModel _natalInterpretation(String language) {
  return NatalCardInterpretationModel(
    personality: '$language personality',
    intellectualArea: '$language intellectual',
    loveArea: '$language love',
    talentArea: '$language talent',
    energyArea: '$language energy',
    insideArea: '$language inside',
    finalConclusion: '$language final',
  );
}

PlanetsHousesDataModel _completePlanetsHousesData() {
  return const PlanetsHousesDataModel(
    data: 'Солнце - Лев - 10',
    elements: Elements(fire: '5', earth: '4', air: '6', water: '2'),
    positions: [
      PlanetHousePositionModel(
        code: 'sun',
        name: 'Солнце',
        signCode: 'leo',
        sign: 'Лев',
        house: 10,
        longitude: 120.0,
      ),
    ],
    calculation: PlanetsHousesCalculationModel(
      localDateTime: '2000-08-19T12:45:00',
      timezone: 'Europe/Moscow',
      timezoneOffsetHours: 3,
      utcDateTime: '2000-08-19T09:45:00Z',
      houseSystem: 'placidus',
      zodiac: 'tropical',
    ),
    promptContext: 'structured context',
  );
}

HoroscopeYearModel _yearHoroscope() {
  const planet = HoroscopePlanetInSignModel(
    planetInSign: 'Солнце в Льве',
    description: 'Описание',
  );
  const weakPoint = HoroscopeWeakPointModel(
    title: 'Слабое место',
    description: 'Описание',
  );
  const transit = HoroscopeTransitModel(
    planet: 'Юпитер',
    description: 'Транзит',
  );
  return HoroscopeYearModel(
    dateUntil: DateTime.parse('2027-09-07T00:00:00Z'),
    coreDescription: const HoroscopeCoreDescriptionModel(
      sunInSign: planet,
      moonInSign: planet,
      ascendantInSign: planet,
    ),
    emotionalWorld: 'Эмоции',
    weakPoints: const [weakPoint],
    recommendations: const ['Рекомендация'],
    astroMetaphor: 'Метафора',
    love: const HoroscopeLoveModel(
      general: 'Любовь',
      lesson: 'Урок',
      compatibility: ['Лев'],
    ),
    work: const HoroscopeWorkModel(
      general: 'Работа',
      important: 'Важное',
      successExamples: ['Пример'],
    ),
    finance: const HoroscopeFinanceModel(
      general: 'Финансы',
      risk: 'Риск',
      advice: 'Совет',
    ),
    transformation: const HoroscopeTransformationModel(
      general: 'Рост',
      transits: [transit],
    ),
  );
}

class _FakeContentRepository implements ContentRepository {
  _FakeContentRepository({
    this.failTarot = false,
    this.failAll = false,
    this.tarotCards = const [],
    this.runes = const [],
    this.articles = const [],
    this.affirmations = const [],
    this.tarotLoad,
  });

  bool failTarot;
  bool failAll;
  int refreshVersionsCalls = 0;
  int getTarotCalls = 0;
  int natalCalls = 0;
  String? natalPlanetsBirthdate;
  List<TarotCardModel> tarotCards;
  List<RuneOfDayModel> runes;
  List<AffirmationModel> affirmations;
  final List<ArticleModel> articles;
  final Completer<List<TarotCardModel>>? tarotLoad;
  Completer<void>? tarotReloaded;

  @override
  Future<void> refreshContentVersions() async {
    refreshVersionsCalls++;
  }

  @override
  Future<List<TarotCardModel>> getTarotCards() async {
    getTarotCalls++;
    if (getTarotCalls > 1 && tarotReloaded?.isCompleted == false) {
      tarotReloaded!.complete();
    }
    if (tarotLoad != null) {
      return tarotLoad!.future;
    }
    if (failAll || failTarot) {
      throw Exception('tarot unavailable');
    }
    return tarotCards;
  }

  @override
  Future<List<RuneOfDayModel>> getRunes() async {
    if (failAll) {
      throw Exception('runes unavailable');
    }
    return runes;
  }

  @override
  Future<List<ArticleModel>> getArticles() async {
    if (failAll) {
      throw Exception('articles unavailable');
    }
    return articles;
  }

  @override
  Future<List<AffirmationModel>> getAffirmations() async {
    if (failAll) {
      throw Exception('affirmations unavailable');
    }
    return affirmations;
  }

  @override
  Future<bool> shouldReloadEnergyOfDay() async => false;

  @override
  Future<List<EnergyOfDayModel>> getEnergyOfDayFromCache() async => [];

  @override
  Future<List<EnergyOfDayModel>> getEnergyOfDay() async => [];

  @override
  Future<NatalCardModel> getNatalCard(
    String name,
    String birthdate,
    String birthtime,
    String fire,
    String earth,
    String air,
    String water,
    String city,
    String planetsBirthdate,
  ) async {
    natalCalls++;
    natalPlanetsBirthdate = planetsBirthdate;
    return _natalCard();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBackendApi implements BackendApi {
  int planetsCalls = 0;
  Map<String, dynamic>? lastPlanetsRequest;

  @override
  Future<Response<dynamic>> getPlanetsHousesPosition({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required double latitude,
    required double longitude,
  }) async {
    planetsCalls++;
    lastPlanetsRequest = {
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'latitude': latitude,
      'longitude': longitude,
    };
    return Response<dynamic>(
      data: {
        'data': 'Солнце - Лев - 10',
        'elements': {'fire': '5', 'earth': '4', 'air': '6', 'water': '2'},
        'positions': [
          {
            'code': 'sun',
            'name': 'Солнце',
            'sign': 'Лев',
            'house': 10,
            'longitude': 146.667661,
          },
        ],
        'calculation': {
          'timezone': 'Europe/Saratov',
          'timezone_offset_hours': 4.0,
          'local_datetime': '2000-08-19T12:45:00',
          'utc_datetime': '2000-08-19T08:45:00+00:00',
          'house_system': 'Placidus',
          'zodiac': 'Tropical',
        },
        'prompt_context': 'Солнце | Лев | дом 10 | долгота 146.667661°',
      },
      requestOptions: RequestOptions(path: '/api/v1/planets_houses_position'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFeatureExecutionApi extends FeatureExecutionApi {
  _FakeFeatureExecutionApi({
    List<Object>? generatedOutcomes,
    this.translatedUser,
  }) : generatedOutcomes = generatedOutcomes ?? <Object>[],
       super.forDio(Dio(), _FakeSession());

  String? featureKey;
  String? idempotencyKey;
  String? translatedLanguage;
  Map<String, dynamic>? generatedPayload;
  final List<String> generatedIdempotencyKeys = [];
  final List<Object> generatedOutcomes;
  final UserModel? translatedUser;

  @override
  Future<ClientFeatureResultModel> createClientResultFeature({
    required String featureKey,
    required Map<String, dynamic> result,
    required int expectedCatalogRevision,
    required String idempotencyKey,
    bool requirePro = false,
  }) async {
    this.featureKey = featureKey;
    this.idempotencyKey = idempotencyKey;
    return ClientFeatureResultModel(
      executionId: 'execution-client-result',
      featureKey: featureKey,
      result: result,
    );
  }

  @override
  Future<ClientFeatureResultModel> createGeneratedFeature({
    required String featureKey,
    required Map<String, dynamic> payload,
    required int expectedCatalogRevision,
    required String idempotencyKey,
    bool requirePro = false,
  }) async {
    this.featureKey = featureKey;
    this.idempotencyKey = idempotencyKey;
    generatedIdempotencyKeys.add(idempotencyKey);
    generatedPayload = payload;
    if (generatedOutcomes.isNotEmpty) {
      final outcome = generatedOutcomes.removeAt(0);
      if (outcome is Exception) {
        throw outcome;
      }
      return outcome as ClientFeatureResultModel;
    }
    return ClientFeatureResultModel(
      executionId: 'execution-generated-result',
      featureKey: featureKey,
      result: _natalCard().toJson(),
    );
  }

  @override
  Future<UserModel> translateNatalCard({required String language}) async {
    translatedLanguage = language;
    return translatedUser ??
        _natalUser().copyWith(natalCard: _natalCard(language: language));
  }
}

class _FakePendingFeatureExecutionStore extends PendingFeatureExecutionStore {
  _FakePendingFeatureExecutionStore({List<String>? idempotencyKeys})
    : idempotencyKeys = idempotencyKeys ?? const ['pending-key'];

  PendingFeatureExecution? pending;
  final List<String> idempotencyKeys;
  int _nextIdempotencyKeyIndex = 0;
  int deleteCalls = 0;

  @override
  Future<PendingFeatureExecution> findOrCreate({
    required String userId,
    required String featureKey,
    required String payloadKey,
    String? idempotencyKey,
    Map<String, dynamic>? result,
  }) async {
    if (pending != null) return pending!;
    final nextKey = idempotencyKey ?? _nextIdempotencyKey();
    pending ??= PendingFeatureExecution(
      operationId: '$userId:$featureKey:$payloadKey',
      userId: userId,
      featureKey: featureKey,
      payloadKey: payloadKey,
      idempotencyKey: nextKey,
      result: result,
      createdAt: DateTime.parse('2026-08-30T12:00:00Z'),
    );
    return pending!;
  }

  String _nextIdempotencyKey() {
    if (_nextIdempotencyKeyIndex >= idempotencyKeys.length) {
      return idempotencyKeys.last;
    }
    return idempotencyKeys[_nextIdempotencyKeyIndex++];
  }

  @override
  Future<void> delete({
    required String userId,
    required String featureKey,
    required String payloadKey,
  }) async {
    deleteCalls++;
    pending = null;
  }
}

class _FakeMonetizationApi extends MonetizationApi {
  _FakeMonetizationApi() : super.forDio(Dio(), _FakeSession());

  String? commandFeature;
  String? commandIdempotencyKey;
  Map<String, dynamic>? commandPayload;

  @override
  Future<MonetizationStateModel> getCurrent() async {
    final now = DateTime.parse('2026-08-30T12:00:00Z');
    return MonetizationStateModel(
      uid: 'natal-user',
      catalogRevision: 1,
      wallet: WalletSnapshotModel(
        uid: 'natal-user',
        balance: 100,
        debt: 0,
        sequence: 1,
        version: 1,
        updatedAt: now,
      ),
      effectivePro: false,
      effectiveGrants: const [],
      rewards: const [],
      requestQuotas: const {},
      rolloutPolicy: const {},
    );
  }

  @override
  Future<RequestQuotaCommandResultModel> executeRequestQuotaCommand({
    required String feature,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
  }) async {
    commandFeature = feature;
    commandPayload = payload;
    commandIdempotencyKey = idempotencyKey;
    final now = DateTime.parse('2026-08-30T12:00:00Z');
    final sonnik = SonnikModel(
      id: 'sonnik-command-1',
      dateGenerated: now,
      title: 'Сон про море',
      interpretation: 'Море показывает спокойное движение вперед.',
    );
    return RequestQuotaCommandResultModel(
      uid: 'natal-user',
      feature: feature,
      source: 'free',
      replayed: false,
      quota: RequestQuotaModel(
        feature: feature,
        freeRemaining: 2,
        paidRemaining: 0,
        freeLimit: 3,
        periodStartedAt: now,
        periodEndsAt: now.add(const Duration(days: 7)),
        updatedAt: now,
      ),
      result: sonnik.toJson(),
      user: UserModel.empty().copyWith(
        id: 'natal-user',
        sonnikHistory: [sonnik],
      ),
    );
  }
}

class _FakeSession implements AuthSessionService {
  @override
  String? get currentUid => 'natal-user';

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

class _FakeUserRepository implements UserRepository {
  UserModel? updatedUser;
  UserModel? refreshedUser;
  int getUserByIdCalls = 0;
  UserModel? setUserValue;

  @override
  Future<void> updateCurrentUser(UserModel user) async {
    updatedUser = user;
  }

  @override
  Future<UserModel?> getUserById(String userId) async {
    getUserByIdCalls++;
    return refreshedUser;
  }

  @override
  Future<void> setCurrentUser(UserModel user) async {
    setUserValue = user;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAnalyticsFacade implements AnalyticsFacade {
  int eventCount = 0;

  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    eventCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCompatibilityRepository implements CompatibilityRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AchievementRecorder extends Fake implements AchievementRecorder {
  final events = <AchievementEvent>[];
  @override
  Future<void> record(AchievementEvent event) async => events.add(event);
}
