import 'package:asteria_app/features/affirmation/player/body_motion_artwork.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_journal_story.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_lighthouse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'intro_stories_test.dart' as fixture;

Finder stage(String name) => find.byKey(ValueKey(name));

void main() {
  testWidgets(
    'the saved dream leads to a reading and then a personal decision',
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
      expect(stage('intro-dream-reading'), findsOneWidget);
      expect(stage('intro-dream-result'), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      expect(stage('intro-dream-result'), findsOneWidget);
      expect(stage('intro-dream-transcript'), findsNothing);
      expect(find.textContaining('на чай'), findsOneWidget);
      expect(stage('intro-dream-wish'), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(stage('intro-dream-wish'), findsOneWidget);
      expect(stage('intro-dream-reading'), findsNothing);
      expect(stage('intro-dream-saved'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('reduced motion opens on the complete dream story', (
    tester,
  ) async {
    await fixture.host(
      tester,
      const IntroJournalStory.dream(active: true),
      reduced: true,
    );
    expect(stage('intro-dream-saved'), findsOneWidget);
    expect(stage('intro-dream-reading'), findsOneWidget);
    expect(stage('intro-dream-result'), findsOneWidget);
    expect(find.textContaining('на чай'), findsOneWidget);
    expect(stage('intro-dream-wish'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'three covers lead to the real practice description and a saved note',
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
      for (var i = 0; i < 3; i++) {
        expect(stage('intro-practice-cover-$i'), findsOneWidget);
      }
      final centers = List.generate(
        3,
        (i) => tester.getCenter(stage('intro-practice-cover-$i')).dx,
      );
      expect(centers.toSet().length, 3);
      final coffee = find.descendant(
        of: stage('intro-practice-cover-2'),
        matching: find.byType(BodyMotionArtwork),
      );
      final startingPhase = tester.widget<BodyMotionArtwork>(coffee).phase;
      expect(stage('intro-practice-selected-0'), findsOneWidget);
      expect(stage('intro-practice-description'), findsNothing);
      await tester.pump(const Duration(milliseconds: 2300));
      expect(stage('intro-practice-selected-1'), findsOneWidget);
      expect(
        tester.widget<BodyMotionArtwork>(coffee).phase,
        greaterThan(startingPhase),
      );
      await tester.pump(const Duration(milliseconds: 1700));
      expect(stage('intro-practice-selected-2'), findsOneWidget);
      expect(stage('intro-practice-description'), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(stage('intro-practice-description'), findsOneWidget);
      expect(find.textContaining('Переведи внимание с дел'), findsOneWidget);
      expect(find.text('4 мин · Сидя · без инвентаря'), findsOneWidget);
      expect(stage('intro-practice-note'), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Добавить заметку'), findsOneWidget);
      expect(stage('intro-practice-result'), findsNothing);
      await tester.pump(const Duration(seconds: 4));
      expect(stage('intro-practice-result'), findsOneWidget);
      expect(find.textContaining('«Мои заметки»'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'reduced motion shows all covers, the guide and the note together',
    (tester) async {
      await fixture.host(
        tester,
        const IntroJournalStory.practice(active: true),
        reduced: true,
        textScale: 2,
      );
      final coffee = find.byType(BodyMotionArtwork);
      final phase = tester.widget<BodyMotionArtwork>(coffee).phase;
      await tester.pump(const Duration(seconds: 2));
      expect(tester.widget<BodyMotionArtwork>(coffee).phase, phase);
      expect(stage('intro-practice-cover-0'), findsOneWidget);
      expect(stage('intro-practice-cover-1'), findsOneWidget);
      expect(stage('intro-practice-cover-2'), findsOneWidget);
      expect(stage('intro-practice-description'), findsOneWidget);
      expect(stage('intro-practice-result'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
