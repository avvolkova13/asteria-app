import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_journal_story.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_lighthouse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'intro_stories_test.dart' as fixture;

Finder stage(String name) => find.byKey(ValueKey(name));

void main() {
  testWidgets(
    'dictation becomes a saved entry and a reading while the light sweeps',
    (tester) async {
      await fixture.host(tester, const IntroJournalStory.dream(active: true));
      final painting = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is IntroLighthouse,
      );
      expect(painting, findsOneWidget);
      expect(stage('intro-dream-dictation'), findsOneWidget);
      expect(stage('intro-dream-result'), findsNothing);
      final start =
          tester.widget<CustomPaint>(painting).painter as IntroLighthouse;
      await tester.pump(const Duration(seconds: 2));
      final advancing =
          tester.widget<CustomPaint>(painting).painter as IntroLighthouse;
      expect(advancing.shouldRepaint(start), isTrue);
      await tester.pump(const Duration(milliseconds: 2100));
      expect(stage('intro-dream-dictation'), findsNothing);
      expect(stage('intro-dream-saved'), findsOneWidget);
      expect(stage('intro-dream-result'), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(stage('intro-dream-result'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'selecting another practice cover keeps its matching note after autoplay',
    (tester) async {
      await fixture.host(
        tester,
        const IntroJournalStory.practice(active: true),
      );
      expect(stage('intro-practice-selected-0'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2800));
      expect(stage('intro-practice-selected-1'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2100));
      expect(stage('intro-practice-selected-2'), findsOneWidget);
      await tester.tap(stage('intro-practice-cover-1'));
      await tester.pump();
      expect(stage('intro-practice-selected-1'), findsOneWidget);
      final result = tester.widget<Text>(stage('intro-practice-result'));
      expect(result.data, contains('дня за столом'));
      await tester.pump(const Duration(seconds: 7));
      expect(stage('intro-practice-selected-1'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
