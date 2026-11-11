import '../../../compatibility/support/selection_test_support.dart';
import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/data/models/energy_of_day/energy_of_day_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/analytics_route_observer.dart';
import 'package:asteria_app/core/analytics/durable/analytics_taxonomy.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/subscription_widget.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_state.dart';
import 'package:asteria_app/features/home/presentation/screens/main_screen.dart';
import 'package:asteria_app/features/home/presentation/widgets/daily_symbol_of_the_day_widget.dart';
import 'package:asteria_app/features/home/presentation/screens/personal_screen.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  late _Content content;
  late _User user;
  late _Home home;
  late _Monetization monetization;
  late _Analytics analytics;
  late _RouteObserver observer;
  late GoRouter router;
  late ValueNotifier<int> tab;

  setUp(() async {
    await di.reset();
    content = _Content();
    user = _User();
    home = _Home();
    monetization = _Monetization();
    analytics = _Analytics();
    observer = _RouteObserver();
    tab = ValueNotifier(3);
    di.registerSingleton<ContentProvider>(content);
    di.registerSingleton<UserProvider>(user);
    registerTestCompatibilityProvider(user);
    di.registerSingleton<MonetizationProvider>(monetization);
    di.registerSingleton<AnalyticsRouteObserver>(observer);
    di.registerSingleton<ProductAnalyticsService>(
      ProductAnalyticsService(analytics),
    );
  });

  tearDown(() async {
    observer.detach();
    observer.dispose();
    router.dispose();
    tab.dispose();
    await home.close();
    content.dispose();
    user.dispose();
    monetization.dispose();
    await di.reset();
  });

  Future<void> mount(WidgetTester tester, {int initialTab = 3}) async {
    tab.value = initialTab;
    router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          name: '/home',
          builder: (context, state) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<UserProvider>.value(value: user),
                ChangeNotifierProvider<MonetizationProvider>.value(
                  value: monetization,
                ),
                BlocProvider<HomeCubit>.value(value: home),
              ],
              child: ValueListenableBuilder<int>(
                valueListenable: tab,
                builder: (_, index, __) => IndexedStack(
                  index: index,
                  children: const [
                    MainScreen(),
                    PersonalScreen(),
                    SizedBox.shrink(),
                    SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
    observer.attach(router);
    observer.homeTab(initialTab);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  void showTab(int index) {
    tab.value = index;
    observer.homeTab(index);
  }

  for (final width in [320.0, 393.0]) {
    testWidgets(
      'the last home block stays in place while dragging at ${width}pt',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 780);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await mount(tester, initialTab: 0);
        final viewport = find.descendant(
          of: find.byType(MainScreen),
          matching: find.byType(CustomScrollView),
        );
        final symbols = find.byType(DailySymbolOfTheDayWidget);
        final position = Scrollable.of(tester.element(symbols)).position;
        for (final showRune in [false, true]) {
          if (showRune) {
            final runeTab = find.descendant(
              of: symbols,
              matching: find.text('Руна'),
            );
            await tester.ensureVisible(runeTab);
            await tester.tap(runeTab);
            await tester.pump(const Duration(milliseconds: 700));
          }
          position.jumpTo(position.maxScrollExtent);
          await tester.pump();
          final gesture = await tester.startGesture(tester.getCenter(viewport));
          await gesture.moveBy(const Offset(0, -180));
          await tester.pump();
          await gesture.moveBy(const Offset(0, -120));
          await tester.pump();
          expect(position.pixels, position.maxScrollExtent);
          expect(
            tester.getBottomLeft(viewport).dy -
                tester.getBottomLeft(symbols).dy,
            closeTo(24, .5),
          );
          await gesture.up();
          await tester.pump(const Duration(milliseconds: 600));
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  testWidgets('home has one calendar entry and opens the lunar tab', (
    tester,
  ) async {
    await mount(tester, initialTab: 0);
    expect(find.text('С чего начнём?'), findsNothing);
    expect(find.text('Подобрать день для дела'), findsNothing);
    final entry = find.text('Выбрать день').hitTestable();
    expect(entry, findsOneWidget);
    await tester.tap(entry);
    await tester.pump();
    expect(home.selectedTab, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('main header stays below the status bar inset', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 62);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    await mount(tester, initialTab: 0);
    final headerAction = find.descendant(
      of: find.byType(PinnedHeaderSliver),
      matching: find.byType(SubscriptionWidget),
    );
    expect(headerAction, findsOneWidget);
    expect(tester.getTopLeft(headerAction).dy, greaterThanOrEqualTo(62));
    expect(
      find.text(LocaleFormatters.dayMonth(DateTime.now(), const Locale('ru'))),
      findsNothing,
    );
    final overlay = find.descendant(
      of: find.byType(MainScreen),
      matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    expect(overlay, findsOneWidget);
    final style = tester
        .widget<AnnotatedRegion<SystemUiOverlayStyle>>(overlay)
        .value;
    expect(style.statusBarBrightness, Brightness.dark);
    expect(style.statusBarIconBrightness, Brightness.light);
    expect(tester.getTopLeft(overlay).dy, 0);

    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('hidden data is reported once on the next visible home frame', (
    tester,
  ) async {
    await mount(tester, initialTab: 0);
    expect(analytics.cards, ['home_tarot_card', 'home_affirmation_card']);
    showTab(3);
    await tester.pump();
    content.loadAffirmation();
    user.signIn();
    await tester.pump();
    expect(analytics.cards, ['home_tarot_card', 'home_affirmation_card']);

    showTab(0);
    expect(analytics.cards, ['home_tarot_card', 'home_affirmation_card']);
    await tester.pump();
    expect(
      analytics.cards,
      unorderedEquals([
        'home_tarot_card',
        'home_affirmation_card',
        'home_pro_promo_card',
      ]),
    );

    content.loadAffirmation();
    showTab(3);
    await tester.pump();
    showTab(0);
    await tester.pump();
    expect(analytics.cards, hasLength(3));
    expect(analytics.warehouseEvents, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'hidden initial mount waits for each tab and does not duplicate',
    (tester) async {
      await mount(tester);
      expect(analytics.cards, isEmpty);
      showTab(1);
      expect(analytics.cards, isEmpty);
      await tester.pump();
      expect(analytics.cards, ['home_natal_card', 'home_compatibility_card']);
      showTab(0);
      await tester.pump();
      expect(analytics.cards, [
        'home_natal_card',
        'home_compatibility_card',
        'home_tarot_card',
        'home_affirmation_card',
      ]);
      showTab(1);
      await tester.pump();
      expect(analytics.cards, hasLength(4));
      expect(analytics.warehouseEvents, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('personal impressions also work when mounted on personal tab', (
    tester,
  ) async {
    await mount(tester, initialTab: 1);
    expect(analytics.cards, ['home_natal_card', 'home_compatibility_card']);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('leaving before the frame does not consume impression flags', (
    tester,
  ) async {
    await mount(tester);
    showTab(1);
    showTab(3);
    await tester.pump();
    expect(analytics.cards, isEmpty);
    showTab(1);
    await tester.pump();
    expect(analytics.cards, ['home_natal_card', 'home_compatibility_card']);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('dispose removes listeners and cancels queued impressions', (
    tester,
  ) async {
    await mount(tester);
    expect(observer.isObserved, isTrue);
    showTab(0);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(observer.isObserved, isFalse);
    expect(content.isObserved, isFalse);
    content.loadAffirmation();
    observer.homeTab(1);
    await tester.pump();
    expect(analytics.cards, isEmpty);
    expect(tester.takeException(), isNull);
  });
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
  int? selectedTab;
  @override
  void changeTab(int index) => selectedTab = index;
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
  bool get effectivePro => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RouteObserver extends AnalyticsRouteObserver {
  _RouteObserver() : super(onScreen: (_, __) {});

  bool get isObserved => hasListeners;
}
