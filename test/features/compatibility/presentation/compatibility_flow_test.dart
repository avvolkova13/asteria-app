import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import '../support/selection_test_support.dart';
import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/data/models/energy_of_day/energy_of_day_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/durable/analytics_taxonomy.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_state.dart';
import 'package:asteria_app/features/home/presentation/screens/personal_screen.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asteria_app/features/scenarios/relationships_scenario.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/features/compatibility/presentation/provider/compatibility_provider.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/create_compatibility_initial_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/create_compatibility_history_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/create_compatibility_loaded_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../support/compatibility_fixture.dart';

void main() {
  late _User user;
  late _Content content;
  late _Home home;
  late _Monetization monetization;
  late CompatibilityProvider selection;
  late _SelectionStore selectionStore;
  late GoRouter router;

  setUp(() async {
    await di.reset();
    user = _User()
      ..currentUser = UserModel.empty().copyWith(
        id: 'user-a',
        personalInfo: PersonalInfoModel(
          birthDate: BirthDateModel(birthDate: DateTime(1995, 5, 13)),
        ),
        compatibilityHistory: [
          savedCompatibility(),
          savedCompatibility(id: 'older', percentage: '42%'),
        ],
      );
    content = _Content(user);
    home = _Home();
    monetization = _Monetization();
    selectionStore = _SelectionStore();
    selection = CompatibilityProvider(
      userProvider: user,
      store: selectionStore,
    );
    final analytics = _Analytics();
    di.registerSingleton<UserProvider>(user);
    di.registerSingleton<ContentProvider>(content);
    di.registerSingleton<MonetizationProvider>(monetization);
    di.registerSingleton<CompatibilityProvider>(selection);
    di.registerSingleton<AnalyticsFacade>(analytics);
    di.registerSingleton<ProductAnalyticsService>(
      ProductAnalyticsService(analytics),
    );
    di.registerSingleton<GlobalLoaderService>(GlobalLoaderService());
    router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const PersonalScreen()),
        GoRoute(
          path: '/relationships',
          builder: (_, __) => const RelationshipsScenarioScreen(),
        ),
        GoRoute(
          path: CompatibilityRoutes.createCompatibilityInitialRouteName,
          name: CompatibilityRoutes.createCompatibilityInitialRouteName,
          builder: (_, __) => const CreateCompatibilityInitialScreen(),
        ),
        GoRoute(
          path: CompatibilityRoutes.createCompatibilityHistoryRouteName,
          name: CompatibilityRoutes.createCompatibilityHistoryRouteName,
          builder: (_, __) => const CreateCompatibilityHistoryScreen(),
        ),
        GoRoute(
          path: CompatibilityRoutes.createCompatibilityLoadedRouteName,
          name: CompatibilityRoutes.createCompatibilityLoadedRouteName,
          builder: (_, __) => const CreateCompatibilityLoadedScreen(),
        ),
      ],
    );
  });
  tearDown(() async {
    router.dispose();
    selection.dispose();
    user.dispose();
    content.dispose();
    monetization.dispose();
    await home.close();
    await di.reset();
  });

  Future<void> mount(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
        builder: (context, child) => Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<UserProvider>.value(value: user),
              ChangeNotifierProvider<MonetizationProvider>.value(
                value: monetization,
              ),
              BlocProvider<HomeCubit>.value(value: home),
            ],
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('themed reading reuses a saved pair and shares only its question', (
    tester,
  ) async {
    const channel = MethodChannel('dev.fluttercommunity.plus/share');
    MethodCall? share;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      share = call;
      return '';
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await mount(tester);
    router.push('/relationships');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Напряжение и разногласия'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Открыть разбор пары'));
    await tester.tap(find.text('Открыть разбор пары'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('42%'));
    await tester.pumpAndSettle();
    expect(find.text('Общее описание совместимости.'), findsOneWidget);
    await tester.ensureVisible(find.text('Как снизить напряжение?'));
    await tester.tap(find.text('Как снизить напряжение?'));
    await tester.pumpAndSettle();
    expect(find.text('Конфликты'), findsOneWidget);
    expect(find.text('Любовь'), findsNothing);
    await tester.ensureVisible(find.text('Поделиться вопросом'));
    await tester.tap(find.text('Поделиться вопросом'));
    await tester.pumpAndSettle();
    expect(share?.method, 'share');
    final payload = share!.arguments as Map;
    expect(
      payload['text'],
      'Хочу вернуться к нашему разговору. Тебе удобнее сейчас или немного позже?',
    );
    expect(payload.keys.where((key) => !(key as String).startsWith('origin')), [
      'text',
    ]);
    expect(find.text('Конфликты'), findsOneWidget);
    expect(user.currentUser!.compatibilityHistory, hasLength(2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'empty history opens the existing pair form and returns its saved result to the chosen topic',
    (tester) async {
      user.currentUser = user.currentUser!.copyWith(compatibilityHistory: []);
      await mount(tester);
      router.push('/relationships');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Отношения с партнёром'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Открыть разбор пары'));
      await tester.tap(find.text('Открыть разбор пары'));
      await tester.pumpAndSettle();
      expect(find.byType(CreateCompatibilityInitialScreen), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Партнёр');
      await tester.tap(find.text('Дата рождения'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Выбрать'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Рассчитать'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Рассчитать'));
      await tester.pumpAndSettle();
      expect(find.byType(RelationshipPairResult), findsOneWidget);
      expect(find.text('Общее описание совместимости.'), findsOneWidget);
      await tester.ensureVisible(find.text('Как поддерживать друг друга?'));
      await tester.tap(find.text('Как поддерживать друг друга?'));
      await tester.pumpAndSettle();
      expect(find.text('Семья'), findsOneWidget);
      expect(find.text('Любовь'), findsNothing);
      await tester.ensureVisible(find.text('На главную'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('На главную'));
      await tester.pumpAndSettle();
      expect(find.byType(PersonalScreen), findsOneWidget);
      expect(user.currentUser!.compatibilityHistory, hasLength(1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'reset keeps history, opens input, and history selection restores preview',
    (tester) async {
      await mount(tester);
      final preview = find.byKey(const ValueKey('personal-compatibility-card'));
      expect(preview, findsOneWidget);
      final reset = find.byWidgetPredicate(
        (widget) =>
            widget is SvgPicture &&
            widget.bytesLoader is SvgAssetLoader &&
            (widget.bytesLoader as SvgAssetLoader).assetName ==
                'assets/icons/repeat_icon.svg',
      );
      await tester.ensureVisible(reset);
      await tester.pumpAndSettle();
      await tester.tap(reset);
      await tester.pumpAndSettle();
      expect(find.byType(CreateCompatibilityLoadedScreen), findsNothing);
      expect(find.byType(PersonalScreen), findsOneWidget);
      expect(preview, findsNothing);
      expect(user.currentUser!.compatibilityHistory, hasLength(2));
      await tester.ensureVisible(find.text('Проверить совместимость'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Проверить совместимость'));
      await tester.pumpAndSettle();
      expect(find.byType(CreateCompatibilityInitialScreen), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      await tester.ensureVisible(find.text('Посмотреть историю'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Посмотреть историю'));
      await tester.pumpAndSettle();
      expect(find.byType(CreateCompatibilityHistoryScreen), findsOneWidget);
      await tester.ensureVisible(find.text('42%'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('42%'));
      await tester.pumpAndSettle();
      expect(find.byType(CreateCompatibilityLoadedScreen), findsOneWidget);
      expect(selection.selectedCompatibility?.id, 'older');
      expect(find.text('42%'), findsOneWidget);
      router.go('/home');
      await tester.pumpAndSettle();
      expect(preview, findsOneWidget);
      // Opening the preview must preserve the older selection, not pick history.first.
      await tester.ensureVisible(preview);
      await tester.pumpAndSettle();
      await tester.tap(preview);
      await tester.pumpAndSettle();
      expect(selection.selectedCompatibility?.id, 'older');
      expect(find.text('42%'), findsOneWidget);
      expect(user.currentUser!.compatibilityHistory, hasLength(2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('new calculation after reset becomes the home preview', (
    tester,
  ) async {
    await selection.clear();
    await mount(tester);
    router.pushNamed(CompatibilityRoutes.createCompatibilityInitialRouteName);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Партнёр');
    await tester.tap(find.text('Дата рождения'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Выбрать'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Рассчитать'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Рассчитать'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateCompatibilityLoadedScreen), findsOneWidget);
    expect(find.text('88%'), findsOneWidget);
    router.go('/home');
    await tester.pumpAndSettle();
    expect(find.text('88%'), findsOneWidget);
    expect(user.currentUser!.compatibilityHistory, hasLength(3));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'local save failure after calculation reports a refresh error and keeps history',
    (tester) async {
      await selection.clear();
      selectionStore.failWrites = true;
      await mount(tester);
      router.pushNamed(CompatibilityRoutes.createCompatibilityInitialRouteName);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Партнёр');
      await tester.tap(find.text('Дата рождения'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Выбрать'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Рассчитать'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Рассчитать'));
      await tester.pumpAndSettle();

      expect(
        find.text('Не удалось обновить данные. Попробуйте снова.'),
        findsOneWidget,
      );
      expect(
        find.text('Не удалось рассчитать совместимость. Попробуйте снова.'),
        findsNothing,
      );
      expect(user.currentUser!.compatibilityHistory, hasLength(3));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

class _Analytics implements AnalyticsFacade {
  final cards = <String>[];
  final warehouseEvents = <CanonicalAnalyticsEvent>[];

  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    if (name == 'ast_home_card_view') {
      cards.add(params!['entry_point_id'] as String);
    }
    final event = AnalyticsTaxonomy.map(name, params ?? {});
    if (event != null) warehouseEvents.add(event);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Content extends ChangeNotifier implements ContentProvider {
  _Content(this.user);
  final _User user;

  @override
  Future<SavedCompatibilityModel> createCompatibility({
    required String firstName,
    required String firstDate,
    required String secondName,
    required String secondDate,
  }) async {
    final result = savedCompatibility(id: 'new', percentage: '88%');
    user.currentUser = user.currentUser!.copyWith(
      compatibilityHistory: [result, ...user.currentUser!.compatibilityHistory],
    );
    user.notifyListeners();
    return result;
  }

  bool get isObserved => hasListeners;

  @override
  List<AffirmationModel> affirmations = [];

  void loadAffirmation() {
    affirmations = const [
      AffirmationModel(id: 'test', category: 'calm', text: 'Calm', sort: 0),
    ];
    notifyListeners();
  }

  @override
  AffirmationModel getTodayAffirmation() => affirmations.single;
  @override
  List<ArticleModel> get articles => [];
  @override
  bool get isLoadingContent => false;
  @override
  EnergyOfDayModel? getTodayEnergyOfDay() => null;
  @override
  void resetTarotAndRuneOpenState() {}
  @override
  bool isDailySymbolTarotOpened() => false;
  @override
  bool isDailySymbolRuneOpened() => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _User extends ChangeNotifier implements UserProvider {
  @override
  UserModel? currentUser;

  void signIn() {
    currentUser = UserModel.empty();
    notifyListeners();
  }

  @override
  bool showHoroscope(HoroscopeTypeEnum type) => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Home extends Cubit<HomeState> implements HomeCubit {
  _Home() : super(const HomeLoaded());
  @override
  void changeTab(int index) => emit(HomeLoaded(currentTabIndex: index));
  @override
  Future<void> loadDailySelection() async {}
  @override
  void resetTarotAndRuneOpenState() {}
  @override
  void syncTarotCard() {}
  @override
  void syncRune() {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Monetization extends ChangeNotifier implements MonetizationProvider {
  @override
  int get balance => 0;
  @override
  int requestsLeft(String feature) => 10;
  @override
  Future<void> refreshForAccess() async {}
  @override
  bool isFeatureEnabled(String feature) => true;
  @override
  bool canMakeRequest(String feature) => true;
  @override
  bool get effectivePro => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SelectionStore extends MemoryCompatibilitySelectionStore {
  bool failWrites = false;

  @override
  Future<void> write(String userId, String? compatibilityId) async {
    if (failWrites) throw StateError('Storage unavailable');
    await super.write(userId, compatibilityId);
  }
}
