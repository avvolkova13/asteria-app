import 'dart:async';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/scenarios/guidance_situation.dart';
import 'package:asteria_app/features/scenarios/strength_scenario.dart';
import 'package:flutter/material.dart';
import 'package:asteria_app/features/home/presentation/widgets/daily_symbol_of_the_day_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const card = TarotCardModel(
  id: 'cups',
  title: 'Ace of Cups',
  imageName: 'ace_of_cups',
  sort: 1,
  keywords: ['feelings'],
  cardOfDayDescription: 'Notice a feeling that returns today.',
  generalDescription: '',
  shortDescription: '',
  textInDecks: [],
  keltDeck: [],
  keltDeckImpact: [],
  loveDeck: [],
);

class _Content extends Fake implements ContentProvider {
  bool opened = false, shownOnHome = false, empty = false;
  int draws = 0, reveals = 0;
  Completer<void>? gate;

  @override
  List<TarotCardModel> get tarotCards => empty ? [] : [card];
  @override
  bool isTodayTarotCardOpened() => opened;
  @override
  Future<void> loadContent() async {}
  @override
  TarotCardModel getTodayTarotCard() {
    if (empty) throw StateError('No cards');
    draws++;
    return card;
  }

  @override
  Future<void> setTodayTarotCardOpened() async {
    reveals++;
    await gate?.future;
    opened = true;
  }

  @override
  void setDailySymbolTarotOpened() {
    shownOnHome = true;
  }
}

class _Users extends ChangeNotifier implements UserProvider {
  String owner = 'account';
  @override
  UserModel get currentUser => UserModel.empty().copyWith(id: owner);
  void switchAccount() {
    owner = 'different';
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Users users;
  late _Content content;

  setUp(() {
    users = _Users();
    content = _Content();
    di.registerSingleton<UserProvider>(users);
    di.registerSingleton<ContentProvider>(content);
  });
  tearDown(() async {
    await di.unregister<UserProvider>();
    await di.unregister<ContentProvider>();
    users.dispose();
  });

  Future<void> start(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 680));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c).copyWith(disableAnimations: true),
          child: Theme(
            data: AppThemeDark.instance.getThemeData(c),
            child: child!,
          ),
        ),
        home: const StrengthScenarioScreen(),
      ),
    );
    expect(find.text('My tips'), findsNothing);
    await tester.ensureVisible(find.text('Make a decision'));
    await tester.tap(find.text('Make a decision'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'revealing once shares the card with Home and returning reuses it',
    (tester) async {
      await start(tester);
      expect(
        find.textContaining('Imagine you have already decided'),
        findsOneWidget,
      );
      content.gate = Completer<void>();
      await tester.tap(find.text('Draw my daily card'));
      await tester.tap(find.text('Draw my daily card'));
      expect(content.reveals, 1);
      content.gate!.complete();
      await tester.pumpAndSettle();
      expect(content.shownOnHome, isTrue);
      expect(find.text(card.title), findsOneWidget);
      expect(find.textContaining(card.cardOfDayDescription), findsOneWidget);
      expect(
        find.textContaining(GuidanceSituation.decision.nextStep(card, false)),
        findsOneWidget,
      );

      expect(find.text('Go home'), findsNothing);
      await tester.ensureVisible(find.text('I’ll try this step today'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I’ll try this step today'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Go home'));
      expect(find.text('One step is enough for today.'), findsOneWidget);
      expect(find.text('Go home'), findsOneWidget);
      expect(content.reveals, 1);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start a conversation'));
      await tester.pumpAndSettle();
      expect(find.text(card.title), findsOneWidget);
      expect(find.text('Draw my daily card'), findsNothing);
      expect(content.reveals, 1);
      expect(
        find.textContaining(
          GuidanceSituation.conversation.nextStep(card, false),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'empty catalog can retry without spending or starting a second draw',
    (tester) async {
      content.empty = true;
      await start(tester);
      await tester.tap(find.text('Draw my daily card'));
      await tester.pumpAndSettle();
      expect(find.textContaining('haven’t loaded'), findsOneWidget);
      expect(content.reveals, 0);
      content.empty = false;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text(card.title), findsOneWidget);
      expect(content.reveals, 1);
    },
  );

  testWidgets(
    'tapping the face-down artwork reveals it in compact reduced-motion layout',
    (tester) async {
      await start(tester);
      final back = find.byType(DailyTarotCardFace);
      await tester.ensureVisible(back);
      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(content.reveals, 1);
      expect(find.text(card.title), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'an already opened Home card is available without another reveal',
    (tester) async {
      content.opened = true;
      await start(tester);
      expect(find.text(card.title), findsOneWidget);
      expect(find.text('Draw my daily card'), findsNothing);
      expect(content.reveals, 0);
    },
  );

  testWidgets(
    'an account change during the reveal hides the old account’s result',
    (tester) async {
      content.gate = Completer<void>();
      await start(tester);
      await tester.tap(find.text('Draw my daily card'));
      users.switchAccount();
      content.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.textContaining('Your account has changed'), findsOneWidget);
      expect(find.text(card.title), findsNothing);
      expect(content.shownOnHome, isFalse);
    },
  );

  test(
    'the same situation receives distinct actions from different card suits',
    () {
      final other = card.copyWith(imageName: 'three_of_swords');
      for (final ru in [true, false]) {
        expect(
          GuidanceSituation.decision.nextStep(card, ru),
          isNot(GuidanceSituation.decision.nextStep(other, ru)),
        );
      }
    },
  );
}
