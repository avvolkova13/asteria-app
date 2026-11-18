import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/data/models/user/rune_deck_model.dart';
import 'package:asteria_app/app/data/models/user/tarot_deck_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/content_scroll_behavior.dart';
import 'package:asteria_app/core/ui_kit/widgets/custom_button.dart';
import 'package:asteria_app/features/runes/runes_screen.dart';
import 'package:asteria_app/features/taro_cards/taro_cards_screen.dart';
import 'package:asteria_app/features/taro_cards/widgets/special_decks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  late _User user;
  late _Content content;

  setUp(() {
    user = _User();
    content = _Content();
    di.registerSingleton<UserProvider>(user);
    di.registerSingleton<ContentProvider>(content);
    di.registerSingleton<AnalyticsFacade>(_Analytics());
    di.registerSingleton<ProductAnalyticsService>(_ProductAnalytics());
  });

  tearDown(() async {
    await di.reset();
    user.dispose();
    content.dispose();
  });

  for (final size in [const Size(390, 844), const Size(375, 667)]) {
    for (final runes in [true, false]) {
      testWidgets(
        '${runes ? 'runes' : 'tarot'} spread stops with compact safe-area spacing at ${size.width}',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            ChangeNotifierProvider<UserProvider>.value(
              value: user,
              child: MaterialApp(
                scrollBehavior: const ContentScrollBehavior(),
                locale: const Locale('ru'),
                supportedLocales: AppLocaleService.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  ...GlobalMaterialLocalizations.delegates,
                ],
                builder: (context, child) => Theme(
                  data: AppThemeDark.instance
                      .getThemeData(context)
                      .copyWith(platform: TargetPlatform.iOS),
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      padding: const EdgeInsets.only(top: 47, bottom: 34),
                      disableAnimations: true,
                    ),
                    child: child!,
                  ),
                ),
                home: runes
                    ? const RunesScreen(initialTab: RunesTab.layout)
                    : const TaroCardsScreen(initialTab: TaroCardsTab.layout),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final scroll = find.byType(CustomScrollView);
          final position = tester
              .state<ScrollableState>(
                find
                    .descendant(of: scroll, matching: find.byType(Scrollable))
                    .first,
              )
              .position;
          expect(position.maxScrollExtent, greaterThan(0));
          position.jumpTo(position.maxScrollExtent);
          await tester.pumpAndSettle();

          // Check the actual last content, not a trailing wrapper or spacer.
          final lastContent = runes
              ? find.byType(CustomButton).last
              : find.byType(SpecialDecks);
          expect(lastContent, findsOneWidget);
          final gap = size.height - tester.getBottomLeft(lastContent).dy;
          expect(gap, closeTo(34 + 24, 1));
          final end = position.maxScrollExtent;
          await tester.fling(scroll, const Offset(0, -500), 1800);
          await tester.pumpAndSettle();
          expect(position.pixels, closeTo(end, 0.1));
          expect(
            size.height - tester.getBottomLeft(lastContent).dy,
            closeTo(gap, 0.1),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

class _User extends ChangeNotifier implements UserProvider {
  @override
  UserModel get currentUser => UserModel.empty().copyWith(
    id: 'scroll-test-user',
    runeDeck: RuneDeckModel(
      cards: [
        for (var i = 0; i < 3; i++)
          RuneInDeckModel(id: 'rune-$i', isOpened: true),
      ],
    ),
    tarotDeck: TarotDeckModel(
      cards: [
        for (var i = 0; i < 3; i++)
          TarotCardInDeckModel(id: 'card-$i', isOpened: true),
      ],
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Content extends ChangeNotifier implements ContentProvider {
  @override
  RuneOfDayModel getTodayRune() => _rune;
  @override
  TarotCardModel getTodayTarotCard() => tarotCards.first;
  @override
  void resetRuneOpenState() {}
  @override
  void resetTarotOpenState() {}
  @override
  Future<void> ensureRuneDeckLayoutReady() async {}
  @override
  Future<void> ensureTarotDeckLayoutReady() async {}
  @override
  bool areAllRuneDeckCardsOpened() => true;
  @override
  bool areAllTarotDeckCardsOpened() => true;
  @override
  bool isRuneInDeckOpened(String key) => true;
  @override
  bool isTarotCardInDeckOpened(String key) => true;
  @override
  RuneOfDayModel? getRuneInDeck(String key) => _rune;
  @override
  List<TarotCardModel> get tarotCards => [
    for (var i = 0; i < 3; i++)
      TarotCardModel(
        id: 'card-$i',
        title: 'Карта $i',
        imageName: 'the_strength',
        sort: i,
        keywords: const [],
        cardOfDayDescription: '',
        generalDescription: '',
        shortDescription: '',
        textInDecks: const [],
        keltDeck: const [],
        keltDeckImpact: const [],
        loveDeck: const [],
      ),
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _rune = RuneOfDayModel(
  id: 'rune-0',
  title: 'Альгиз',
  imageName: 'algiz',
  sort: 0,
  cardOfDayDescription: '',
  generalDescription: '',
  pastDeck: 'Прошлое',
  presentDeck: 'Настоящее',
  futureDeck: 'Будущее',
  keywords: [],
  definitions: [],
);

class _Analytics implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ProductAnalytics implements ProductAnalyticsService {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}
