import 'package:asteria_app/features/home/presentation/widgets/moon_phase_widget.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_calendar_story.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_story.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'intro_stories_test.dart' as fixture;

void main() {
  for (final width in [390.0, 320.0]) {
    testWidgets(
      'calendar chooses a day and reveals its reminder early at $width',
      (tester) async {
        await fixture.host(
          tester,
          IntroCalendarStory(active: true, now: () => DateTime(2026, 11, 18)),
        );
        tester.view.physicalSize = Size(width, 844);
        await tester.pump();
        final days = find.byType(MoonDayPreview);
        DateTime selectedDate() => tester
            .widgetList<MoonDayPreview>(days)
            .singleWhere((day) => day.isSelected)
            .date;
        expect(days, findsNWidgets(width == 320 ? 3 : 5));
        expect(selectedDate(), DateTime(2026, 11, 18));
        expect(find.byKey(const ValueKey('intro-day-result')), findsNothing);
        await tester.pump(const Duration(milliseconds: 800));
        expect(selectedDate(), DateTime(2026, 11, 19));
        await tester.pump(const Duration(milliseconds: 1200));
        expect(selectedDate(), DateTime(2026, 11, 20));
        expect(find.byKey(const ValueKey('intro-day-result')), findsOneWidget);
        expect(
          tester.widget<IntroStory>(find.byType(IntroStory)).duration,
          const Duration(seconds: 5),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'reduced motion presents the selected day and reminder immediately',
    (tester) async {
      await fixture.host(
        tester,
        IntroCalendarStory(active: true, now: () => DateTime(2026, 11, 18)),
        reduced: true,
        textScale: 2,
      );
      expect(find.byKey(const ValueKey('intro-day-result')), findsOneWidget);
      expect(find.textContaining('20 ноября'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
