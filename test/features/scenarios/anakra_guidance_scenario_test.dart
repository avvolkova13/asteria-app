import 'dart:async';
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:asteria_app/features/scenarios/daily_guidance_store.dart';
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
  TarotCardModel homeCard = card;
  Completer<void>? gate;

  @override
  List<TarotCardModel> get tarotCards =>
      empty ? [] : [card, card.copyWith(id: 'other', title: 'Other card')];
  @override
  bool isTodayTarotCardOpened() => opened;
  @override
  Future<void> loadContent() async {}
  @override
  TarotCardModel getTodayTarotCard() {
    if (empty) throw StateError('No cards');
    draws++;
    return homeCard;
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

  setUp(() async {
    await Hive.openBox<Map>(HiveBoxNames.appSettings, bytes: Uint8List(0));
    users = _Users();
    content = _Content();
    di.registerSingleton<UserProvider>(users);
    di.registerSingleton<ContentProvider>(content);
  });
  tearDown(() async {
    await di.unregister<UserProvider>();
    await di.unregister<ContentProvider>();
    users.dispose();
    await Hive.close();
  });

  Future<void> start(
    WidgetTester tester, {
    bool ru = false,
    bool reduced = true,
    bool settleConversation = true,
  }) async {
    await tester.binding.setSurfaceSize(const Size(320, 680));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(ru ? 'ru' : 'en'),
        supportedLocales: AppLocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c).copyWith(
            disableAnimations: reduced,
            textScaler: TextScaler.linear(ru ? 1.3 : 1),
          ),
          child: Theme(
            data: AppThemeDark.instance.getThemeData(c),
            child: child!,
          ),
        ),
        home: const StrengthScenarioScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('My tips'), findsNothing);
    await tester.ensureVisible(
      find.text(ru ? 'Принять решение' : 'Make a decision'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(ru ? 'Принять решение' : 'Make a decision'));
    if (settleConversation) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump();
    }
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
      await tester.tap(find.text('Draw a card'));
      await tester.tap(find.text('Draw a card'));
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
      expect(find.textContaining('Come back tomorrow'), findsOneWidget);
      expect(find.text('Available tomorrow'), findsNWidgets(3));
      await tester.ensureVisible(find.text('Start a conversation'));
      await tester.tap(find.text('Start a conversation'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text(card.title), findsNothing);
      await tester.tap(find.text('Make a decision'));
      await tester.pumpAndSettle();
      expect(find.text(card.title), findsOneWidget);
      expect(find.text('Draw a card'), findsNothing);
      expect(content.reveals, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'empty catalog can retry without spending or starting a second draw',
    (tester) async {
      content.empty = true;
      await start(tester);
      await tester.tap(find.text('Draw a card'));
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
      expect(find.text('Draw a card'), findsNothing);
      expect(content.reveals, 0);
    },
  );

  testWidgets('a saved insight stays face up on entry and app resume', (
    tester,
  ) async {
    final store = DailyGuidanceStore(users.owner);
    await store.save(GuidanceSituation.decision, card.id, store.day);
    await start(tester, reduced: false, settleConversation: false);
    DailySymbolFlip turn() =>
        tester.widget<DailySymbolFlip>(find.byType(DailySymbolFlip));
    expect(turn().animation.value, 1);
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(turn().animation.value, 1);
    await tester.pump(const Duration(milliseconds: 300));
    expect(turn().animation.value, 1);
    expect(content.reveals, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'an account change during the reveal hides the old account’s result',
    (tester) async {
      content.gate = Completer<void>();
      await start(tester);
      await tester.tap(find.text('Draw a card'));
      users.switchAccount();
      content.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.textContaining('Your account has changed'), findsOneWidget);
      expect(find.text(card.title), findsNothing);
      expect(content.shownOnHome, isFalse);
    },
  );

  test(
    'saved insight survives reopening, expires daily and is account scoped',
    () async {
      var now = DateTime(2026, 11, 16, 23, 59);
      final store = DailyGuidanceStore('account', now: () => now);
      await store.save(GuidanceSituation.decision, card.id, store.day);
      expect(
        DailyGuidanceStore('account', now: () => now).read()?.cardId,
        card.id,
      );
      expect(DailyGuidanceStore('different', now: () => now).read(), isNull);
      await expectLater(
        store.save(GuidanceSituation.change, 'other', store.day),
        throwsStateError,
      );
      now = DateTime(2026, 11, 17);
      expect(store.read(), isNull);
      await expectLater(
        store.save(GuidanceSituation.change, 'other', '2026-11-16'),
        throwsStateError,
      );
      await store.save(GuidanceSituation.change, 'other', store.day);
      expect(store.read()?.situation, GuidanceSituation.change);
    },
  );

  testWidgets(
    'restores the saved card even after Home replaces its daily card',
    (tester) async {
      final store = DailyGuidanceStore(users.owner);
      await store.save(GuidanceSituation.decision, card.id, store.day);
      await start(tester);
      expect(find.text(card.title), findsOneWidget);
      expect(content.draws, 0);
      expect(content.reveals, 0);
      await tester.pageBack();
      await tester.pumpAndSettle();
      users.switchAccount();
      await tester.pumpAndSettle();
      expect(find.text('Available tomorrow'), findsNothing);
    },
  );

  testWidgets('Russian locked cards fit a compact screen with enlarged text', (
    tester,
  ) async {
    await DailyGuidanceStore(users.owner).save(
      GuidanceSituation.decision,
      card.id,
      DailyGuidanceStore(users.owner).day,
    );
    await start(tester, ru: true);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    expect(find.text('Доступно завтра'), findsNWidgets(3));
    await tester.ensureVisible(find.text('Освоиться с переменами'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

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
