import 'dart:io';

import 'package:hive/hive.dart';
import 'package:asteria_app/features/affirmation/player/affirmation_player_screen.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/scenarios/practice_scenario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory playerData;
  setUpAll(() async {
    playerData = await Directory.systemTemp.createTemp('scenario-player');
    Hive.init(playerData.path);
    await Hive.openBox<bool>('affirmation_player_favorites');
  });
  tearDownAll(() async {
    await Hive.close();
    await playerData.delete(recursive: true);
  });

  Future<void> start(
    WidgetTester tester,
    List<ScenarioPractice> recordings,
  ) async {
    await tester.pumpWidget(_app(recordings));
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
  }

  testWidgets('onboarding practice provides the bundled recording in English', (
    tester,
  ) async {
    await start(tester, availablePracticeRecordings);
    await tester.ensureVisible(find.text('Find calm'));
    await tester.tap(find.text('Find calm'));
    await tester.pumpAndSettle();
    final player = tester.widget<AffirmationPlayerScreen>(
      find.byType(AffirmationPlayerScreen),
    );
    expect(player.autoPlay, isTrue);
    expect(player.session?.audioAsset, 'assets/audio/affirmation-time-en.mp3');
    expect(player.session?.duration, const Duration(minutes: 3, seconds: 30));
    expect(player.session?.title, 'I Have Time');
  });

  testWidgets(
    'each mood opens the available recording directly and back restores the mood choices',
    (tester) async {
      final played = <String>[];
      await start(tester, [
        ScenarioPractice(
          id: 'available',
          mood: PracticeMood.slowDown,
          title: 'Available',
          duration: const Duration(seconds: 75),
          open: (context) async {
            played.add('available');
            await Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) =>
                    Scaffold(appBar: AppBar(title: const Text('Player'))),
              ),
            );
          },
        ),
        _fixture(played, 'Restricted', PracticeMood.focus, available: false),
      ]);
      for (final mood in ['Find calm', 'Gather my thoughts', 'Unwind']) {
        expect(find.text('What do you need right now?'), findsOneWidget);
        await tester.ensureVisible(find.text(mood));
        await tester.tap(find.text(mood));
        await tester.pumpAndSettle();
        expect(find.text('Player'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text(mood), findsOneWidget);
      }
      expect(played, ['available', 'available', 'available']);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Start'), findsOneWidget);
    },
  );

  testWidgets(
    'post-practice check-in gives a next step and a working home action',
    (tester) async {
      var wentHome = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: const [Locale('en'), Locale('ru')],
          builder: (context, child) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
          ),
          home: PracticeReflectionScreen(onHome: () => wentHome = true),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('How do you feel now?'), findsOneWidget);
      await tester.tap(find.text('A little calmer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Keep this pace:'), findsOneWidget);
      await tester.ensureVisible(find.text('Go home'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Go home'));
      expect(wentHome, isTrue);
      await tester.ensureVisible(find.text('About the same'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('About the same'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('You do not have to feel a change'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('matching recordings rotate within the selected mood', (
    tester,
  ) async {
    final played = <String>[];
    await start(tester, [
      _fixture(played, 'Quiet', PracticeMood.slowDown),
      _fixture(played, 'First focus recording', PracticeMood.focus),
      _fixture(played, 'Second focus recording', PracticeMood.focus),
      _fixture(played, 'Locked', PracticeMood.focus, available: false),
    ]);
    for (var i = 0; i < 3; ++i) {
      await tester.tap(find.text('Gather my thoughts'));
      await tester.pumpAndSettle();
    }
    expect(played, [
      'First focus recording',
      'Second focus recording',
      'First focus recording',
    ]);
  });

  testWidgets('an empty catalog can be left through the visible back button', (
    tester,
  ) async {
    await start(tester, []);
    expect(
      find.text('No audio practices are available right now.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);
  });
}

ScenarioPractice _fixture(
  List<String> played,
  String title,
  PracticeMood mood, {
  bool available = true,
}) => ScenarioPractice(
  id: title,
  title: title,
  mood: mood,
  duration: const Duration(seconds: 75),
  isAvailable: (_) => available,
  open: (_) async {
    played.add(title);
  },
);

Widget _app(List<ScenarioPractice> recordings) => MaterialApp(
  locale: const Locale('en'),
  supportedLocales: AppLocaleService.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  builder: (c, child) => Theme(
    data: AppThemeDark.instance.getThemeData(c),
    child: MediaQuery(
      data: MediaQuery.of(c).copyWith(disableAnimations: true),
      child: child!,
    ),
  ),
  home: Scaffold(
    body: Builder(
      builder: (c) => Center(
        child: TextButton(
          child: const Text('Start'),
          onPressed: () => openPracticeScenario(c, recordings: recordings),
        ),
      ),
    ),
  ),
);
