import 'dart:io';
import 'dart:ui' as ui;

import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_wheel.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_natal_story.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_story.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const output = '/private/tmp/asteria-intro-natal';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final font in [
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
    ]) {
      await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
    }
  });
  for (final language in ['ru', 'en']) {
    testWidgets(
      '18 second natal sequence preserves chart size and one explanation in $language',
      (tester) async {
        await host(tester, language: language);
        final l = AppLocalizations.current;
        expect(
          tester.widget<IntroStory>(find.byType(IntroStory)).duration,
          const Duration(seconds: 18),
        );
        void checkChart() => expect(
          tester.getSize(find.byKey(const ValueKey('intro-natal-chart'))),
          const Size(250, 250),
        );
        void noBirthOrDemo() => expect(
          find.byWidgetPredicate(
            (w) =>
                w is Text &&
                RegExp(r'Пример|Example|1995').hasMatch(w.data ?? ''),
          ),
          findsNothing,
        );
        void onePanel() => expect(
          find.byType(HomeGlassSurface).evaluate().length,
          lessThanOrEqualTo(1),
        );
        checkChart();
        noBirthOrDemo();
        await tester.pump(const Duration(seconds: 2));
        expect(
          tester
              .widget<NatalWheel>(find.byType(NatalWheel))
              .data
              .positions
              .length,
          inExclusiveRange(0, 6),
        );
        if (language == 'ru') await capture(tester, 'v2-ru-390-assembling-2s');
        await tester.pump(const Duration(milliseconds: 2500));
        checkChart();
        expect(
          tester.widget<NatalWheel>(find.byType(NatalWheel)).data.positions,
          hasLength(6),
        );
        expect(find.byType(StoryCard), findsNothing);
        if (language == 'ru') await capture(tester, 'v2-ru-390-complete-4_5s');
        await tester.pump(const Duration(milliseconds: 2300));
        checkChart();
        onePanel();
        expect(find.text(l.introNatalStrength), findsOneWidget);
        expect(find.text(l.introNatalPattern), findsNothing);
        expect(find.text(l.introNatalQuestion), findsNothing);
        expect(
          find.byKey(const ValueKey('intro-natal-highlight-sun')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('intro-natal-highlight-moon')),
          findsNothing,
        );
        if (language == 'ru') await capture(tester, 'v2-ru-390-strength-6_8s');
        await tester.pump(const Duration(milliseconds: 2200));
        expect(find.byType(StoryCard), findsNothing);
        onePanel();
        await tester.pump(const Duration(seconds: 1));
        checkChart();
        onePanel();
        expect(find.text(l.introNatalPattern), findsOneWidget);
        expect(find.text(l.introNatalStrength), findsNothing);
        expect(find.text(l.introNatalQuestion), findsNothing);
        expect(
          find.byKey(const ValueKey('intro-natal-highlight-moon')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('intro-natal-highlight-sun')),
          findsNothing,
        );
        if (language == 'ru') await capture(tester, 'v2-ru-390-pattern-10s');
        await tester.pump(const Duration(milliseconds: 2350));
        expect(find.byType(StoryCard), findsNothing);
        onePanel();
        await tester.pump(const Duration(seconds: 1));
        checkChart();
        onePanel();
        expect(
          find.byKey(const ValueKey('intro-natal-question')),
          findsOneWidget,
        );
        expect(find.text(l.introNatalQuestion), findsOneWidget);
        expect(find.text(l.introNatalStrength), findsNothing);
        expect(find.text(l.introNatalPattern), findsNothing);
        expect(
          tester
              .getSize(find.byKey(const ValueKey('intro-natal-story')))
              .height,
          lessThanOrEqualTo(400),
        );
        if (language == 'ru')
          await capture(tester, 'v2-ru-390-reflection-13_35s');
        await tester.pump(const Duration(milliseconds: 4100));
        checkChart();
        onePanel();
        noBirthOrDemo();
        expect(find.text(l.introNatalQuestion), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        expect(find.byType(TextButton), findsNothing);
        expect(tester.takeException(), isNull);
        if (language == 'ru')
          await capture(tester, 'v2-ru-390-reflection-17_45s');
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
    for (final large in [false, true]) {
      testWidgets(
        'static natal keeps all meaning in one readable panel in $language large=$large',
        (tester) async {
          await host(tester, language: language, large: large, reduced: true);
          final l = AppLocalizations.current;
          expect(find.byType(HomeGlassSurface), findsOneWidget);
          for (final label in [
            l.introNatalStrength,
            l.introNatalPattern,
            l.introNatalQuestion,
          ]) {
            expect(find.text(label), findsOneWidget);
            final paragraph = tester.renderObject<RenderParagraph>(
              find.descendant(
                of: find.text(label),
                matching: find.byType(RichText),
              ),
            );
            expect(paragraph.didExceedMaxLines, isFalse);
          }
          expect(
            find.byWidgetPredicate(
              (w) =>
                  w is Text &&
                  RegExp(r'Пример|Example|1995').hasMatch(w.data ?? ''),
            ),
            findsNothing,
          );
          expect(
            tester.getSize(find.byKey(const ValueKey('intro-natal-chart'))),
            large ? const Size(207, 207) : const Size(250, 250),
          );
          expect(
            tester.widget<NatalWheel>(find.byType(NatalWheel)).data.positions,
            hasLength(6),
          );
          expect(find.byType(TextField), findsNothing);
          expect(find.byType(TextButton), findsNothing);
          await capture(
            tester,
            'v2-$language-${large ? '320-2x' : '390'}-static-first',
          );
          await tester.drag(
            find.byType(SingleChildScrollView),
            const Offset(0, -4000),
          );
          await tester.pump();
          expect(
            tester.getBottomRight(find.text(l.introNatalQuestion)).dy,
            lessThanOrEqualTo(tester.view.physicalSize.height),
          );
          expect(tester.takeException(), isNull);
          if (large) await capture(tester, 'v2-$language-320-2x-static-bottom');
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}

Future<void> host(
  WidgetTester tester, {
  String language = 'ru',
  bool large = false,
  bool reduced = false,
}) async {
  tester.view.physicalSize = large
      ? const Size(320, 568)
      : const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final playback = IntroPlaybackController();
  addTearDown(playback.dispose);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('capture'),
      child: MaterialApp(
        locale: Locale(language),
        supportedLocales: AppLocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (context, child) => Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: reduced,
              textScaler: TextScaler.linear(large ? 2 : 1),
            ),
            child: child!,
          ),
        ),
        home: Scaffold(
          backgroundColor: AppColorsDark.homeCanvas,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: IntroPlaybackScope(
                controller: playback,
                child: const IntroNatalStory(active: true),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 250)),
  );
  await tester.pump();
}

Future<void> capture(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('capture')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(output).create(recursive: true);
    await File('$output/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
