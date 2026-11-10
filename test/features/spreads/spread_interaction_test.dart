import 'dart:async';

import 'package:asteria_app/app/data/models/love_deck/love_deck_model.dart';
import 'package:asteria_app/features/scenarios/relationships_scenario.dart';

import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/kelt_deck/kelt_deck_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/data/models/user/tarot_deck_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/features/balance/presentation/provider/rewards_provider.dart';
import 'package:asteria_app/features/compatibility/domain/repositories/compatibility_repository.dart';
import 'package:asteria_app/features/kelt_deck/widgets/celtic_cross_layout.dart';
import 'package:asteria_app/features/runes/widgets/runes_block.dart';
import 'package:asteria_app/features/taro_cards/widgets/tarot_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('runes open independently and block a repeated pending tap', (
    tester,
  ) async {
    final runes = _runes();
    final pendingOpen = Completer<void>();
    var leftOpenCalls = 0;
    var leftOpening = false;
    var leftOpened = false;
    var centerOpened = false;
    var rightOpened = false;

    await tester.pumpWidget(
      _localizedApp(
        StatefulBuilder(
          builder: (context, setState) => RunesBlock(
            rune1: runes[0],
            rune2: runes[1],
            rune3: runes[2],
            isRuneLeftOpened: leftOpened,
            isRuneCenterOpened: centerOpened,
            isRuneRightOpened: rightOpened,
            onOpenRuneLeft: leftOpening
                ? null
                : () {
                    leftOpenCalls++;
                    setState(() => leftOpening = true);
                    unawaited(
                      pendingOpen.future.then((_) {
                        setState(() {
                          leftOpening = false;
                          leftOpened = true;
                        });
                      }),
                    );
                  },
            onOpenRuneCenter: () => setState(() => centerOpened = true),
            onOpenRuneRight: () => setState(() => rightOpened = true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('rune_layout_back_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('rune_layout_back_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('rune_layout_back_2')), findsOneWidget);
    expect(
      find.image(
        const AssetImage('assets/images/home/daily_symbol_rune_back.webp'),
      ),
      findsNWidgets(3),
    );
    final closedRuneImageSize = tester.getSize(
      find.byKey(const ValueKey('rune_layout_back_visual_0')),
    );

    await tester.tap(find.byKey(const ValueKey('rune_layout_back_0')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('rune_layout_back_0')));
    await tester.pump();
    expect(leftOpenCalls, 1);

    pendingOpen.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('rune_layout_front_0')), findsOneWidget);
    final openedRuneImageSize = tester.getSize(
      find.byKey(const ValueKey('rune_layout_front_visual_0')),
    );
    expect(openedRuneImageSize, closedRuneImageSize);
    expect(find.byKey(const ValueKey('rune_layout_back_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('rune_layout_back_2')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('rune_layout_back_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('rune_layout_back_2')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('rune_layout_front_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('rune_layout_front_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('rune_layout_front_2')), findsOneWidget);
  });

  group('tarot layout interaction', () {
    late UserProvider userProvider;
    late ContentProvider contentProvider;

    setUp(() async {
      await di.reset();
      final cards = _tarotCards();
      userProvider = UserProvider(userRepository: _FakeUserRepository());
      userProvider.applyServerUserSnapshot(
        UserModel.empty().copyWith(
          id: 'widget-user',
          phoneNumber: '+10000000000',
          tarotDeck: TarotDeckModel(
            cards: cards
                .map(
                  (card) => TarotCardInDeckModel(id: card.id, isOpened: false),
                )
                .toList(),
          ),
        ),
      );
      contentProvider = ContentProvider(
        contentRepository: _FakeContentRepository(cards),
        userProvider: userProvider,
        compatibilityRepository: _FakeCompatibilityRepository(),
      );
      await contentProvider.loadContent();
      di
        ..registerSingleton<UserProvider>(userProvider)
        ..registerSingleton<ContentProvider>(contentProvider)
        ..registerSingleton<AnalyticsFacade>(_FakeAnalyticsFacade())
        ..registerSingleton<RewardsProvider>(_FakeRewardsProvider());
    });

    tearDown(() async {
      contentProvider.dispose();
      userProvider.dispose();
      await di.reset();
    });

    testWidgets('starts closed, opens one at a time, and resets on re-entry', (
      tester,
    ) async {
      await tester.pumpWidget(_localizedApp(const TarotLayout()));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('tarot_layout_back_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('tarot_layout_back_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('tarot_layout_back_2')), findsOneWidget);

      for (var index = 0; index < 3; index++) {
        await tester.tap(find.byKey(ValueKey('tarot_layout_card_$index')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(ValueKey('tarot_layout_front_$index')),
          findsOneWidget,
        );
        for (var closedIndex = index + 1; closedIndex < 3; closedIndex++) {
          expect(
            find.byKey(ValueKey('tarot_layout_back_$closedIndex')),
            findsOneWidget,
          );
        }
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      contentProvider.resetTarotOpenState();
      await tester.pumpWidget(_localizedApp(const TarotLayout()));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('tarot_layout_back_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('tarot_layout_back_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('tarot_layout_back_2')), findsOneWidget);
    });
  });

  group('saved spread interaction', () {
    late UserProvider userProvider;
    late ContentProvider contentProvider;
    late List<TarotCardModel> cards;

    setUp(() async {
      await di.reset();
      cards = _tarotCards(count: 10);
      userProvider = UserProvider(userRepository: _FakeUserRepository());
      userProvider.applyServerUserSnapshot(
        UserModel.empty().copyWith(
          id: 'kelt-widget-user',
          phoneNumber: '+10000000001',
          keltDeck: KeltDeckModel(
            keltDeckCards: {for (final card in cards) card.id: false},
          ),
        ),
      );
      contentProvider = ContentProvider(
        contentRepository: _FakeContentRepository(cards),
        userProvider: userProvider,
        compatibilityRepository: _FakeCompatibilityRepository(),
      );
      await contentProvider.loadContent();
      di
        ..registerSingleton<UserProvider>(userProvider)
        ..registerSingleton<ContentProvider>(contentProvider)
        ..registerSingleton<AnalyticsFacade>(_FakeAnalyticsFacade())
        ..registerSingleton<RewardsProvider>(_FakeRewardsProvider());
    });

    tearDown(() async {
      contentProvider.dispose();
      userProvider.dispose();
      await di.reset();
    });

    testWidgets(
      'relationship entry opens the saved love spread and reveals a question after the sixth card',
      (tester) async {
        final savedCards = cards.take(6);
        userProvider.applyServerUserSnapshot(
          userProvider.currentUser!.copyWith(
            loveDeck: LoveDeckModel(
              loveDeckCards: {for (final card in savedCards) card.id: false},
            ),
          ),
        );
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          ChangeNotifierProvider<UserProvider>.value(
            value: userProvider,
            child: _localizedApp(const RelationshipsScenarioScreen()),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Хочу разобраться в своих чувствах'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Начать любовный расклад'));
        await tester.pumpAndSettle();
        expect(find.text('Вопрос для размышления'), findsNothing);
        for (int index = 1; index <= 6; index++) {
          final card = find.byKey(ValueKey('love_deck_card_$index'));
          await tester.ensureVisible(card);
          await tester.pumpAndSettle();
          await tester.tap(card);
          await tester.pumpAndSettle();
        }
        expect(userProvider.isAllCardsOpened('love_deck'), isTrue);
        expect(find.text('Вопрос для размышления'), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Начать любовный расклад'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('opens a visible non-first card when it is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(_localizedApp(const CelticCrossLayout()));
      await tester.pumpAndSettle();

      final layoutTopLeft = tester.getTopLeft(find.byType(CelticCrossLayout));
      await tester.tapAt(layoutTopLeft + const Offset(43, 291.5));
      await tester.pumpAndSettle();

      expect(userProvider.isDeckCardOpened(DeckType.kelt, cards[2].id), isTrue);
    });

    testWidgets('keeps the last tapped overlapping card above neighbours', (
      tester,
    ) async {
      await tester.pumpWidget(_localizedApp(const CelticCrossLayout()));
      await tester.pumpAndSettle();

      final layoutTopLeft = tester.getTopLeft(find.byType(CelticCrossLayout));

      await tester.tapAt(layoutTopLeft + const Offset(75, 313));
      await tester.pumpAndSettle();

      expect(userProvider.isDeckCardOpened(DeckType.kelt, cards[1].id), isTrue);

      await tester.tapAt(layoutTopLeft + const Offset(185, 313));
      await tester.pumpAndSettle();

      expect(
        userProvider.isDeckCardOpened(DeckType.kelt, cards[3].id),
        isFalse,
      );
    });
  });
}

Widget _localizedApp(Widget child) {
  return MaterialApp(
    locale: const Locale('ru'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.delegate.supportedLocales,
    builder: (context, navigator) => Theme(
      data: AppThemeDark.instance.getThemeData(context),
      child: navigator!,
    ),
    home: Scaffold(
      body: Center(child: SizedBox(width: 358, child: child)),
    ),
  );
}

List<RuneOfDayModel> _runes() => List.generate(
  3,
  (index) => RuneOfDayModel(
    id: 'rune-$index',
    title: 'Rune $index',
    imageName: 'rune-$index',
    sort: index,
    cardOfDayDescription: '',
    generalDescription: '',
    pastDeck: 'Past $index',
    presentDeck: 'Present $index',
    futureDeck: 'Future $index',
    keywords: const [],
    definitions: const [],
  ),
);

List<TarotCardModel> _tarotCards({int count = 3}) {
  const imageNames = [
    'the_fool',
    'the_magician',
    'the_high_priestess',
    'the_empress',
    'the_emperor',
    'the_hierophant',
    'the_lovers',
    'the_chariot',
    'the_strength',
    'the_hermit',
  ];

  return List.generate(
    count,
    (index) => TarotCardModel(
      id: 'card-$index',
      title: 'Card $index',
      imageName: imageNames[index % imageNames.length],
      sort: index,
      keywords: const [],
      cardOfDayDescription: '',
      generalDescription: '',
      shortDescription: '',
      textInDecks: const [],
      keltDeck: const [],
      keltDeckImpact: const [],
      loveDeck: const [],
    ),
  );
}

class _FakeContentRepository implements ContentRepository {
  _FakeContentRepository(this.cards);

  final List<TarotCardModel> cards;

  @override
  Future<void> refreshContentVersions() async {}

  @override
  Future<List<TarotCardModel>> getTarotCards() async => cards;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<void> updateCurrentUser(UserModel user) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCompatibilityRepository implements CompatibilityRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAnalyticsFacade implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRewardsProvider implements RewardsProvider {
  @override
  Future<void> recordTarotSpread(String deckType) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
