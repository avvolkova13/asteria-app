import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/scenarios/practice_scenario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> start(
    WidgetTester tester,
    List<ScenarioPractice> recordings,
  ) async {
    await tester.pumpWidget(_app(recordings));
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'one recording still asks how the visitor feels and offers a way back',
    (tester) async {
      final played = <String>[];
      await start(tester, [
        _fixture(played, 'Slow practice', PracticeMood.slowDown),
      ]);
      expect(find.text('How are you feeling right now?'), findsOneWidget);
      expect(played, isEmpty);
      await tester.tap(find.text('I feel rushed'));
      await tester.pumpAndSettle();
      expect(played, ['Slow practice']);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Start'), findsOneWidget);
    },
  );

  testWidgets(
    'a missing match offers an explicitly optional alternative and preserves the return path',
    (tester) async {
      final played = <String>[];
      await start(tester, [
        _fixture(played, 'Available recording', PracticeMood.slowDown),
        _fixture(
          played,
          'Restricted recording',
          PracticeMood.focus,
          available: false,
        ),
      ]);
      await tester.tap(find.text('I find it hard to focus'));
      await tester.pumpAndSettle();
      expect(played, isEmpty);
      expect(
        find.textContaining('There isn’t a recording for this feeling yet.'),
        findsOneWidget,
      );
      expect(find.text('Restricted recording'), findsNothing);
      expect(find.text('Listen · 1:15'), findsOneWidget);
      await tester.tap(find.text('Available recording'));
      await tester.pumpAndSettle();
      expect(played, ['Available recording']);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('I find it hard to focus'), findsOneWidget);
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
      await tester.tap(find.text('I find it hard to focus'));
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
  builder: (c, child) =>
      Theme(data: AppThemeDark.instance.getThemeData(c), child: child!),
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
