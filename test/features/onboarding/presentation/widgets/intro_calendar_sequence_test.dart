import 'dart:io';
import 'dart:ui' as ui;
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_calendar_story.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_story.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'intro_stories_test.dart' as fixture;

void main() {
  setUpAll(() async {
    for (final font in [
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
    ]) {
      await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
    }
    await (FontLoader('MaterialIcons')..addFont(
          File(
            '/opt/homebrew/share/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
          ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        ))
        .load();
  });
  for (final width in [390.0, 320.0]) {
    testWidgets(
      'calendar shows plan, reminder, complete sequentially at $width',
      (tester) async {
        await fixture.host(
          tester,
          RepaintBoundary(
            key: const ValueKey('calendar-preview'),
            child: IntroCalendarStory(
              active: true,
              now: () => DateTime(2026, 11, 18),
            ),
          ),
        );
        tester.view.physicalSize = Size(width, 844);
        await tester.pump();
        for (final phase in [
          (9500, 'intro-calendar-plan'),
          (12500, 'intro-calendar-reminder'),
          (17000, 'intro-calendar-complete'),
        ]) {
          final previous = phase.$1 == 9500
              ? 0
              : phase.$1 == 12500
              ? 9500
              : 12500;
          await tester.pump(Duration(milliseconds: phase.$1 - previous));
          expect(find.byKey(ValueKey(phase.$2)), findsOneWidget);
          for (final other in [
            'intro-calendar-plan',
            'intro-calendar-reminder',
            'intro-calendar-complete',
          ].where((key) => key != phase.$2)) {
            expect(find.byKey(ValueKey(other)), findsNothing);
          }
          if (const bool.fromEnvironment('CALENDAR_REVIEW_CAPTURE')) {
            await tester.runAsync(() async {
              await Future<void>.delayed(const Duration(milliseconds: 100));
            });
            await tester.pump();
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('calendar-preview')),
            );
            await tester.runAsync(() async {
              final image = await boundary.toImage(pixelRatio: 2);
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final out = Directory(
                '/private/tmp/asteria-design-review/calendar-sequence',
              );
              await out.create(recursive: true);
              await File(
                '${out.path}/${width.toInt()}_${phase.$2}.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        }
        expect(
          tester.widget<IntroStory>(find.byType(IntroStory)).duration,
          const Duration(seconds: 18),
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets(
    'static calendar presents one complete plan without permission controls',
    (tester) async {
      await fixture.host(
        tester,
        IntroCalendarStory(active: true, now: () => DateTime(2026, 11, 18)),
        reduced: true,
        textScale: 2,
      );
      expect(
        find.byKey(const ValueKey('intro-calendar-complete')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('intro-calendar-reminder')),
        findsNothing,
      );
      expect(find.byType(StoryCard), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
