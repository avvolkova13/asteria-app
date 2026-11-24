import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_calendar_story.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'intro_stories_test.dart' as fixture;

Finder day(int index) => find.byKey(ValueKey('intro-calendar-day-$index'));

Finder get save => find.byKey(const ValueKey('intro-calendar-save'));
Finder get remind => find.byKey(const ValueKey('intro-calendar-remind'));
Finder get result => find.byKey(const ValueKey('intro-day-result'));

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
  tester.view.physicalSize = Size(width, 844);
  await tester.pump();
}

void main() {
  for (final width in [390.0, 320.0]) {
    testWidgets(
      'calendar demonstrates selecting, saving and reminding at $width',
      (tester) async {
        await start(tester, width: width);
        expect(day(2), findsOneWidget);
        expect(day(4), width == 390 ? findsOneWidget : findsNothing);
        expect(tester.getSemantics(day(0)), isSemantics(isSelected: true));
        expect(result, findsNothing);
        await tester.pump(const Duration(milliseconds: 1300));
        expect(tester.getSemantics(day(1)), isSemantics(isSelected: true));
        await tester.pump(const Duration(milliseconds: 1500));
        expect(tester.getSemantics(day(2)), isSemantics(isSelected: true));
        expect(save, findsOneWidget);
        expect(result, findsNothing);
        await tester.pump(const Duration(milliseconds: 2500));
        expect(remind, findsOneWidget);
        expect(result, findsNothing);
        await tester.pump(const Duration(milliseconds: 3000));
        expect(result, findsOneWidget);
        expect(find.textContaining('1 декабря'), findsWidgets);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'choosing today keeps that selection and saves a same-day reminder',
    (tester) async {
      await start(tester);
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(day(0));
      await tester.pump();
      await tester.pump(const Duration(seconds: 7));
      expect(tester.getSemantics(day(0)), isSemantics(isSelected: true));
      expect(result, findsNothing);
      await tester.tap(save);
      await tester.pump();
      expect(remind, findsOneWidget);
      await tester.tap(remind);
      await tester.pump();
      expect(result, findsOneWidget);
      expect(find.textContaining('30 ноября'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('reduced motion opens on a complete but editable plan', (
    tester,
  ) async {
    await start(tester, reduced: true);
    expect(result, findsOneWidget);
    expect(tester.getSemantics(day(2)), isSemantics(isSelected: true));
    await tester.tap(day(1));
    await tester.pump();
    expect(tester.getSemantics(day(1)), isSemantics(isSelected: true));
    expect(save, findsOneWidget);
    await tester.tap(save);
    await tester.pump();
    await tester.tap(remind);
    await tester.pump();
    expect(result, findsOneWidget);
    expect(find.textContaining('30 ноября'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });
}
