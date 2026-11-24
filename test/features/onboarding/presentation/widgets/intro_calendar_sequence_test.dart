import 'package:asteria_app/features/home/presentation/widgets/moon_phase_widget.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_calendar_story.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'intro_stories_test.dart' as fixture;

Finder day(int index) => find.byKey(ValueKey('intro-calendar-day-$index'));

Future<void> start(
  WidgetTester tester, {
  double width = 390,
  bool reduced = false,
}) async {
  await fixture.host(
    tester,
    IntroCalendarStory(active: true, now: () => DateTime(2026, 11, 30)),
    reduced: reduced,
  );
  tester.view.physicalSize = Size(width, width == 320 ? 568 : 844);
  await tester.pump();
}

void main() {
  for (final width in [390.0, 320.0]) {
    testWidgets('native calendar strip compares dates on its own at $width', (
      tester,
    ) async {
      await start(tester, width: width);
      expect(find.byType(MoonDayPreview), findsNWidgets(width == 320 ? 3 : 5));
      for (var i = 0; i < 3; i++) {
        if (i > 0) await tester.pump(const Duration(milliseconds: 1500));
        final date = DateTime(2026, 11, 30 + i);
        final tile = tester.widget<MoonDayPreview>(day(i));
        expect(tile.date, date);
        expect(tile.isSelected, isTrue);
        expect(
          tester.getSemantics(day(i)),
          isSemantics(isSelected: true, hasTapAction: false, isButton: false),
        );
        expect(find.byKey(ValueKey(date)), findsOneWidget);
      }
      expect(find.byKey(const ValueKey('intro-day-result')), findsOneWidget);
      expect(find.text('Благоприятный день'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('touching a date cannot change or pause the demonstration', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(day(2), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 1800));
    expect(tester.widget<MoonDayPreview>(day(1)).isSelected, isTrue);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.widget<MoonDayPreview>(day(2)).isSelected, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reduced motion shows the favorable date immediately', (
    tester,
  ) async {
    await start(tester, reduced: true);
    expect(tester.widget<MoonDayPreview>(day(2)).isSelected, isTrue);
    expect(find.byKey(ValueKey(DateTime(2026, 12, 2))), findsOneWidget);
    expect(find.byKey(const ValueKey('intro-day-result')), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
