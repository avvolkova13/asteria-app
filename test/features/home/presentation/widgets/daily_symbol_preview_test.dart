import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/entry_surface.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/daily_symbol_of_the_day_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/rune_of_the_day_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/tarot_card_of_the_day_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'the daily tarot starts face down and reveals the selected card on tap',
    (tester) async {
      final user = _User();
      final content = _Content();
      final starts = _Analytics();
      await di.reset();
      di
        ..registerSingleton<UserProvider>(user)
        ..registerSingleton<ContentProvider>(content)
        ..registerSingleton<AnalyticsFacade>(_Facade())
        ..registerSingleton<ProductAnalyticsService>(starts);
      addTearDown(() async {
        await di.reset();
        user.dispose();
        content.dispose();
      });
      var tarotTaps = 0;
      var tarotOpened = false;
      var runeTaps = 0;
      var refreshes = 0;
      var runeTabSelections = 0;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (context, setState) => DailySymbolOfTheDayWidget(
                    tarotCard: _tarot,
                    rune: _rune,
                    onTarotRefresh: () => refreshes++,
                    onRuneRefresh: () => refreshes++,
                    isTarotOpened: tarotOpened,
                    onCardTap: () {
                      tarotTaps++;
                      setState(() => tarotOpened = true);
                    },
                    onRuneTap: () => runeTaps++,
                    onRuneTabSelected: () => runeTabSelections++,
                  ),
                ),
              ),
            ),
          ),
          TaroCardsRoute(),
          RunesRoute(),
        ],
      );
      addTearDown(router.dispose);
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          locale: const Locale('ru'),
          supportedLocales: AppLocaleService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (context, child) =>
              ChangeNotifierProvider<UserProvider>.value(
                value: user,
                child: Theme(
                  data: AppThemeDark.instance.getThemeData(context),
                  child: child!,
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();

      final tarotImage = find.image(
        const AssetImage('assets/images/cards/the_star.webp'),
      );
      final back = find.image(
        const AssetImage('assets/images/home/daily_symbol_tarot_back.webp'),
      );
      expect(tester.getSize(back), const Size(219, 328));
      expect(tarotImage, findsNothing);
      expect(find.text(_tarot.cardOfDayDescription), findsNothing);
      expect(
        find.bySemanticsLabel('Перевернуть карту Таро дня'),
        findsOneWidget,
      );
      expect(find.text('Нажми на карту, чтобы перевернуть'), findsOneWidget);
      await tester.tap(find.text('Сделать расклад'));
      await tester.pumpAndSettle();
      expect(find.text('Расклад Таро'), findsOneWidget);
      expect(starts.tarot, 1);
      expect(tarotTaps, 0);
      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(tarotTaps, 1);
      expect(tarotImage, findsOneWidget);
      expect(back, findsNothing);
      expect(find.text(_tarot.cardOfDayDescription), findsOneWidget);
      expect(find.bySemanticsLabel('Карта Таро дня: Звезда'), findsOneWidget);
      await tester.tap(tarotImage);
      expect(tarotTaps, 1);
      await tester.tap(find.text('Руна'));
      await tester.pumpAndSettle();
      expect(runeTabSelections, 1);
      expect(
        find.image(const AssetImage('assets/images/runes/algiz.webp')),
        findsOneWidget,
      );
      expect(find.text(_rune.title), findsOneWidget);
      expect(find.text(_rune.cardOfDayDescription), findsOneWidget);
      await tester.tap(find.text('Разложить руны'));
      await tester.pumpAndSettle();
      expect(find.text('Расклад рун'), findsOneWidget);
      expect(starts.runes, 1);
      expect(runeTaps, 0);
      expect(refreshes, 0);
      router.go(TaroCardsRoute.routeName);
      await tester.pumpAndSettle();
      expect(find.text('Расклад Таро'), findsNothing);
      expect(find.byType(TarotCardOfTheDayWidget), findsOneWidget);
      router.go(RunesRoute.routeName);
      await tester.pumpAndSettle();
      expect(find.text('Расклад рун'), findsNothing);
      expect(find.byType(RuneOfTheDayWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

const _tarot = TarotCardModel(
  id: 'star',
  title: 'Звезда',
  imageName: 'the_star',
  sort: 17,
  keywords: [],
  cardOfDayDescription: 'Трактовка выбранной карты.',
  generalDescription: '',
  shortDescription: '',
  textInDecks: [],
  keltDeck: [],
  keltDeckImpact: [],
  loveDeck: [],
);
const _rune = RuneOfDayModel(
  id: 'algiz',
  title: 'Альгиз',
  imageName: 'algiz',
  sort: 15,
  cardOfDayDescription: 'Трактовка выбранной руны.',
  generalDescription: '',
  pastDeck: '',
  presentDeck: '',
  futureDeck: '',
  keywords: [],
  definitions: [],
);

class _User extends ChangeNotifier implements UserProvider {
  @override
  UserModel? get currentUser => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Content extends ChangeNotifier implements ContentProvider {
  @override
  TarotCardModel getTodayTarotCard() => _tarot;
  @override
  RuneOfDayModel getTodayRune() => _rune;
  @override
  RuneOfDayModel? getRuneInDeck(String key) => null;
  @override
  bool isRuneInDeckOpened(String key) => false;
  @override
  bool isTarotCardInDeckOpened(String key) => false;
  @override
  bool isTodayRuneOpened() => false;
  @override
  bool isTodayTarotCardOpened() => false;
  @override
  void resetTarotOpenState() {}
  @override
  void resetRuneOpenState() {}
  @override
  Future<void> ensureRuneDeckLayoutReady() async {}
  @override
  Future<void> ensureTarotDeckLayoutReady() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Facade extends Fake implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
}

class _Analytics extends Fake implements ProductAnalyticsService {
  var tarot = 0;
  var runes = 0;
  @override
  Future<void> trackTarotStart({
    EntrySurface entrySurface = EntrySurface.unknown,
  }) async => tarot++;
  @override
  Future<void> trackRunesStart({
    EntrySurface entrySurface = EntrySurface.unknown,
  }) async => runes++;
}
