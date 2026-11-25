import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/prompt_response.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/article/presentation/article_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/compatibility_history_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/create_sonnik_history_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/provider/sonnik_provider.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void activate(WidgetTester tester, Pattern label) {
  final node = tester.getSemantics(find.bySemanticsLabel(label));
  expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
  expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
  node.owner!.performAction(node.id, SemanticsAction.tap);
}

Future<GoRouter> show(
  WidgetTester tester,
  Widget page, {
  String language = 'ru',
  bool loaded = false,
  UserModel? user,
}) async {
  final account = _Account(user);
  final wallet = _Wallet();
  di.registerSingleton<ContentProvider>(_Content(loaded));
  final analytics = _Analytics();
  di.registerSingleton<AnalyticsFacade>(analytics);
  di.registerSingleton<ProductAnalyticsService>(
    ProductAnalyticsService(analytics),
  );
  di.registerSingleton<SonnikProvider>(SonnikProvider());
  addTearDown(() async {
    await di.reset();
    account.dispose();
    wallet.dispose();
  });
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('Start')),
      ),
      GoRoute(path: '/page', builder: (_, _) => page),
      GoRoute(
        path: '/balance-target',
        name: BalanceRoute.routeName,
        builder: (_, _) => const Scaffold(body: Text('Balance destination')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: account),
        ChangeNotifierProvider<MonetizationProvider>.value(value: wallet),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: Locale(language),
        supportedLocales: AppLocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (context, child) => Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
        ),
      ),
    ),
  );
  router.push('/page');
  await tester.pumpAndSettle();
  return router;
}

void main() {
  setUpAll(() => Hive.openBox<Map>('dream_journal_v1', bytes: Uint8List(0)));
  tearDownAll(Hive.close);
  for (final language in ['ru', 'en']) {
    for (final loaded in [false, true]) {
      testWidgets(
        'article back and balance semantic actions $language loaded=$loaded',
        (tester) async {
          final handle = tester.ensureSemantics();
          final router = await show(
            tester,
            const ArticleScreen(articleId: 'fixture'),
            language: language,
            loaded: loaded,
          );
          final context = tester.element(find.byType(ArticleScreen));
          final back = MaterialLocalizations.of(context).backButtonTooltip;
          activate(tester, AppLocalizations.of(context).balanceStarsLabel(885));
          await tester.pumpAndSettle();
          expect(find.text('Balance destination'), findsOneWidget);
          router.pop();
          await tester.pumpAndSettle();
          activate(tester, back);
          await tester.pumpAndSettle();
          expect(find.text('Start'), findsOneWidget);
          expect(tester.takeException(), isNull);
          handle.dispose();
        },
      );
    }
  }
  for (final kind in ['account', 'home', 'profile']) {
    testWidgets('$kind header balance is one named actionable button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await show(
        tester,
        Scaffold(
          body: kind == 'account'
              ? const HomeAccountBar()
              : TopNavBar(
                  userName: 'Asteria',
                  type: kind == 'home'
                      ? TopNavBarType.home
                      : TopNavBarType.profile,
                ),
        ),
      );
      activate(tester, AppLocalizations.current.balanceStarsLabel(885));
      await tester.pumpAndSettle();
      expect(find.text('Balance destination'), findsOneWidget);
      expect(tester.takeException(), isNull);
      handle.dispose();
    });
  }
  testWidgets('dream history semantics opens the selected saved dream', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final dream = SonnikModel(
      id: 'dream',
      dateGenerated: DateTime(2026, 11, 11),
      title: 'Змея во сне',
      interpretation: 'Meaning',
    );
    await show(
      tester,
      const CreateSonnikHistoryScreen(),
      user: UserModel.empty().copyWith(
        id: 'journal-owner',
        sonnikHistory: [dream],
      ),
    );
    activate(tester, RegExp('Змея во сне'));
    await tester.pumpAndSettle();
    expect(find.text('Meaning'), findsOneWidget);
    expect(find.text('Дневник снов'), findsOneWidget);
    expect(di.get<SonnikProvider>().selectedSonnik?.id, 'dream');
    expect(tester.takeException(), isNull);
    handle.dispose();
  });
  testWidgets('compatibility history semantics opens the selected saved pair', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final pair = SavedCompatibilityModel(
      id: 'pair',
      compatibilityData: const CompatibilityData(
        generalCompatibility: '',
        loveCompatibility: '',
        loveCompatibilityPercentage: '',
        familyCompatibility: '',
        familyCompatibilityPercentage: '',
        conflicts: '',
        conflictsPercentage: '',
        percentage: '',
        phrase: '',
        introduction: '',
      ),
      firstBirthdate: DateTime(1990, 5, 1),
      secondBirthdate: DateTime(1990, 6, 1),
      generalPercentage: '74%',
      createdAt: DateTime(2026, 11, 11),
    );
    SavedCompatibilityModel? selected;
    await show(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: CompatibilityHistoryScreen(
            user: UserModel.empty().copyWith(compatibilityHistory: [pair]),
            onItemTap: (item) => selected = item,
            onNewPairPressed: () {},
          ),
        ),
      ),
    );
    activate(tester, RegExp('74%'));
    await tester.pump();
    expect(selected?.id, 'pair');
    expect(tester.takeException(), isNull);
    handle.dispose();
  });
}

class _Account extends ChangeNotifier implements UserProvider {
  _Account(this.currentUser);
  @override
  final UserModel? currentUser;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Wallet extends ChangeNotifier implements MonetizationProvider {
  @override
  int get balance => 885;
  @override
  bool get effectivePro => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Content extends Fake implements ContentProvider {
  _Content(this.loaded);
  final bool loaded;
  @override
  List<ArticleModel> get articles => const [];
  @override
  ArticleModel? getArticleById(String id) => !loaded
      ? null
      : ArticleModel(
          id: id,
          title: 'Article',
          category: 'Moon',
          intro: 'Introduction',
          text: List.filled(200, 'Long content.').join(' '),
          conclusion: 'End',
          timeToRead: 4,
        );
}

class _Analytics extends Fake implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
}
