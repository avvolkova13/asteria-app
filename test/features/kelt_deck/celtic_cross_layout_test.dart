import 'package:asteria_app/app/data/models/kelt_deck/kelt_deck_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_turn.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/features/kelt_deck/widgets/celtic_cross_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _User user;
  late _Content content;

  setUp(() {
    user = _User();
    content = _Content();
    di.registerSingleton<UserProvider>(user);
    di.registerSingleton<ContentProvider>(content);
  });

  tearDown(() async {
    await di.unregister<UserProvider>();
    await di.unregister<ContentProvider>();
    user.dispose();
    content.dispose();
  });

  Future<void> host(WidgetTester tester, {bool reducedMotion = false}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: AppLocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reducedMotion),
          child: child!,
        ),
        home: const Scaffold(body: CelticCrossLayout()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder slot(int number) => find.byKey(ValueKey('celtic_slot_$number'));

  testWidgets('first reveal retreats so the center of the second card opens it', (
    tester,
  ) async {
    await host(tester);
    await tester.tapAt(tester.getCenter(slot(1)));
    await tester.pump();
    // Repeated taps during the reveal must not start another save or modal.
    await tester.tapAt(tester.getCenter(slot(1)));
    await tester.pump(const Duration(milliseconds: 900));
    expect(user.openCalls, ['card-1']);
    await tester.pump(const Duration(milliseconds: 550));
    await tester.pumpAndSettle();

    // This point overlaps card 1. A semantic callback alone would miss the bug.
    await tester.tapAt(tester.getCenter(slot(2)));
    await tester.pumpAndSettle();
    expect(user.openCalls, ['card-1', 'card-2']);
    final secondTurn = find.descendant(
      of: slot(2),
      matching: find.byType(CardTurn),
    );
    expect(tester.widget<CardTurn>(secondTurn).horizontal, isTrue);
    final face = find.descendant(
      of: secondTurn,
      matching: find.byType(RotatedBox),
    );
    expect(tester.widget<RotatedBox>(face).quarterTurns, -1);
    expect(
      find.descendant(of: secondTurn, matching: find.byType(AsteriaEntrance)),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reset first card reopens with a full turn before saving', (
    tester,
  ) async {
    await host(tester);
    await tester.tapAt(tester.getCenter(slot(1)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 550));
    await tester.pumpAndSettle();
    user.opened.clear();
    user.notifyListeners();
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(slot(1)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    final firstTurn = find.descendant(
      of: slot(1),
      matching: find.byType(CardTurn),
    );
    expect(tester.widget<CardTurn>(firstTurn).progress, inExclusiveRange(0, 1));
    expect(user.openCalls, ['card-1']);
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pump(const Duration(milliseconds: 550));
    await tester.pumpAndSettle();
    expect(user.openCalls, ['card-1', 'card-1']);
    await tester.tapAt(tester.getCenter(slot(2)));
    await tester.pumpAndSettle();
    expect(user.openCalls.last, 'card-2');
  });

  testWidgets('an already opened first card does not cover the second card', (
    tester,
  ) async {
    user.opened.add('card-1');
    await host(tester);
    await tester.tapAt(tester.getCenter(slot(2)));
    await tester.pumpAndSettle();
    expect(user.openCalls, ['card-2']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion exposes the second card without a timed hold', (
    tester,
  ) async {
    await host(tester, reducedMotion: true);
    await tester.tapAt(tester.getCenter(slot(1)));
    await tester.pump();
    await tester.pump();
    expect(user.openCalls, ['card-1']);
    await tester.tapAt(tester.getCenter(slot(2)));
    await tester.pump();
    await tester.pump();
    expect(user.openCalls, ['card-1', 'card-2']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving during a flip cancels it without saving or exceptions', (
    tester,
  ) async {
    await host(tester);
    await tester.tapAt(tester.getCenter(slot(1)));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    expect(user.openCalls, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'leaving during the first card hold does not use disposed controllers',
    (tester) async {
      await host(tester);
      await tester.tapAt(tester.getCenter(slot(1)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      expect(user.openCalls, ['card-1']);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a failed save restores the first card so it can be retried', (
    tester,
  ) async {
    user.failNextOpen = true;
    await host(tester, reducedMotion: true);
    await tester.tapAt(tester.getCenter(slot(1)));
    await tester.pumpAndSettle();
    expect(user.opened, isEmpty);
    await tester.tapAt(tester.getCenter(slot(1)));
    await tester.pumpAndSettle();
    expect(user.openCalls, ['card-1', 'card-1']);
    expect(user.opened, {'card-1'});
    await tester.tapAt(tester.getCenter(slot(2)));
    await tester.pumpAndSettle();
    expect(user.opened, {'card-1', 'card-2'});
    expect(tester.takeException(), isNull);
  });
}

class _User extends ChangeNotifier implements UserProvider {
  final opened = <String>{};
  final openCalls = <String>[];
  bool failNextOpen = false;

  @override
  UserModel get currentUser => UserModel.empty().copyWith(
    id: 'test-user',
    keltDeck: KeltDeckModel(
      keltDeckCards: {for (var i = 1; i <= 10; i++) 'card-$i': false},
    ),
  );

  @override
  bool isDeckCardOpened(DeckType deckType, String cardId) =>
      opened.contains(cardId);

  @override
  Future<void> openKeltDeckCard(String cardId) async {
    openCalls.add(cardId);
    if (failNextOpen) {
      failNextOpen = false;
      throw StateError('Test save failure');
    }
    opened.add(cardId);
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Content extends ChangeNotifier implements ContentProvider {
  @override
  List<TarotCardModel> get tarotCards => [
    for (var i = 1; i <= 10; i++)
      TarotCardModel(
        id: 'card-$i',
        title: 'Карта $i',
        imageName: 'ace_of_cups',
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
