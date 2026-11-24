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
    'practice catalogue pages turn, then the meditation gains a note',
    (tester) async {
      await fixture.host(
        tester,
        const IntroJournalStory.practice(active: true),
      );
      final scene = find.byType(IntroJournalStory);
      expect(
        find.descendant(of: scene, matching: find.byType(GestureDetector)),
        findsNothing,
      );
      expect(stage('intro-practice-selected-0'), findsOneWidget);
      expect(find.text('Сейчас можно никуда не спешить.'), findsOneWidget);
      expect(
        tester.getSize(stage('intro-practice-cover-0')).height,
        greaterThan(200),
      );
      await tester.pump(const Duration(milliseconds: 3400));
      expect(stage('intro-practice-selected-1'), findsOneWidget);
      expect(stage('intro-practice-selected-0'), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      expect(stage('intro-practice-selected-2'), findsOneWidget);
      expect(stage('intro-practice-result'), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(stage('intro-practice-result'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
