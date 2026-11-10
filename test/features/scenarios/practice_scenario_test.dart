import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/scenarios/practice_scenario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'one accessible recording opens directly; restricted mood stays hidden',
    (tester) async {
      final played = <String>[];
      final recordings = [
        _fixture(played, 'Only recording', PracticeMood.slowDown),
        _fixture(
          played,
          'Restricted recording',
          PracticeMood.focus,
          available: false,
        ),
      ];
      await tester.pumpWidget(_app(recordings));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(played, ['Only recording']);
      expect(find.text('What do you need right now?'), findsNothing);
    },
  );

  testWidgets(
    'actual mood opens its assigned recording and offers another when returning',
    (tester) async {
      final played = <String>[];
      final recordings = [
        _fixture(played, 'Quiet', PracticeMood.slowDown),
        _fixture(played, 'First focus recording', PracticeMood.focus),
        _fixture(played, 'Second focus recording', PracticeMood.focus),
        _fixture(played, 'Locked', PracticeMood.unwind, available: false),
      ];
      await tester.pumpWidget(_app(recordings));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(find.text('Slow down'), findsOneWidget);
      expect(find.text('Unwind after a long day'), findsNothing);
      await tester.tap(find.text('Find focus'));
      await tester.pumpAndSettle();
      expect(played, ['First focus recording']);
      expect(find.text('Second focus recording · 1:15'), findsOneWidget);
      await tester.tap(find.text('Find focus'));
      await tester.pumpAndSettle();
      expect(played, ['First focus recording', 'Second focus recording']);
    },
  );
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
