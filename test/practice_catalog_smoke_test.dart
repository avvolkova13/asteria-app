import 'package:asteria_app/features/affirmation/player/player_artwork.dart';
import 'package:asteria_app/features/affirmation/player/practice_playback_controller.dart';

import 'dart:io';

import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_card_widget.dart';
import 'package:asteria_app/features/scenarios/scenario_ui.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/practices/practice_catalog_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory hiveDirectory;
  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp(
      'asteria-player-test-',
    );
    Hive.init(hiveDirectory.path);
    await Hive.openBox<bool>('affirmation_player_favorites');
    for (final (family, path) in [
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(path))).load();
    }
  });
  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });
  testWidgets('a bundled practice recording opens on the native channel', (
    tester,
  ) async {
    const channel = MethodChannel('asteria/practice-audio');
    final messenger = tester.binding.defaultBinaryMessenger;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return {
        'position': 0,
        'duration': 75000,
        'playing': call.method == 'toggle',
        'loop': false,
        'complete': false,
      };
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    const asset = 'assets/audio/practice-75.wav';
    final player = PracticePlaybackController(
      audioAsset: asset,
      previewDuration: const Duration(minutes: 3),
    );
    await player.toggle();
    expect(player.isPreview, isFalse);
    expect(player.isPlaying, isTrue);
    expect(player.duration, const Duration(seconds: 75));
    expect(calls.first.method, 'load');
    expect(calls.first.arguments['asset'], asset);
    player.dispose();
    expect(calls.last.method, 'close');
  });

  for (final (locale, width, height, scale) in [
    ('ru', 390.0, 844.0, 1.0),
    ('en', 320.0, 844.0, 2.0),
    ('ru', 1032.0, 1376.0, 1.0),
    ('en', 1376.0, 1032.0, 1.0),
  ]) {
    testWidgets('browse practices in $locale at $width', (tester) async {
      final tablet = width >= 600;
      tester.view.physicalSize = Size(width, height);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      const channel = MethodChannel('asteria/practice-audio');
      final messenger = tester.binding.defaultBinaryMessenger;
      var playing = false;
      messenger.setMockMethodCallHandler(channel, (call) async {
        switch (call.method) {
          case 'load':
          case 'close':
            playing = false;
          case 'toggle':
            playing = !playing;
        }
        return {
          'position': 0,
          'duration': 75000,
          'playing': playing,
          'loop': false,
          'complete': false,
        };
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(locale),
          supportedLocales: AppLocaleService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (context, child) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
                disableAnimations: true,
              ),
              child: child!,
            ),
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  for (final category in PracticeCategory.values)
                    TextButton(
                      onPressed: () => openPracticeCatalog(context, category),
                      child: Text(category.name),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      for (final (category, ruTitle, enTitle) in [
        ('meditation', 'Утро без спешки', 'An Unhurried Morning'),
        ('body', 'Гвоздестояние', 'Sadhu Board Practice'),
      ]) {
        await tester.tap(find.text(category));
        await tester.pumpAndSettle();
        final cards = find.byType(PracticeDeckCard);
        final artwork = <String>{};
        for (final card in tester.widgetList<PracticeDeckCard>(cards)) {
          final foreground = find.descendant(
            of: find.byWidget(card),
            matching: find.byWidgetPredicate(
              (widget) => widget is Image && widget.fit == BoxFit.contain,
            ),
          );
          expect(foreground, findsOneWidget);
          if (tablet) {
            expect(tester.getSize(foreground).height, greaterThan(150));
          } else {
            expect(tester.getSize(foreground), const Size(174, 150));
          }
          final image = tester.widget<Image>(foreground).image as AssetImage;
          artwork.add(image.assetName);
        }
        expect(
          artwork,
          category == 'body'
              ? {
                  for (final id in [
                    'easy-breathing-rhythm',
                    'gentle-exhale',
                    'shake-off-the-day',
                    'cloud-hands',
                    'feel-the-difference',
                    'sadhu-board',
                  ])
                    'assets/images/practices/$id.webp',
                }
              : {
                  'assets/images/home/hand_with_star.webp',
                  'assets/images/practices/workday-is-over.webp',
                  'assets/images/practices/time-for-sleep.webp',
                },
        );
        if (category == 'body') {
          // Exercise each body deck, including sections with just one card.
          for (final (first, nextTitle) in [
            (
              locale == 'ru' ? 'Стряхнуть день' : 'Shake Off the Day',
              locale == 'ru' ? 'Облачные руки' : 'Cloud Hands',
            ),
            (
              locale == 'ru' ? 'Почувствуй разницу' : 'Feel the Difference',
              null,
            ),
            (locale == 'ru' ? 'Гвоздестояние' : 'Sadhu Board Practice', null),
          ]) {
            final front = find.ancestor(
              of: find.text(first).last,
              matching: find.byType(PracticeDeckCard),
            );
            await tester.ensureVisible(front);
            await tester.pumpAndSettle();
            final point =
                tester.getRect(front).topCenter + const Offset(0, 110);
            await tester.dragFrom(point, const Offset(-86, 0));
            await tester.pumpAndSettle();
            if (nextTitle != null) {
              expect(find.text(nextTitle).hitTestable(), findsOneWidget);
              await tester.dragFrom(point, const Offset(-86, 0));
              await tester.pumpAndSettle();
            }
            expect(find.text(first).last.hitTestable(), findsOneWidget);
          }
          await tester.ensureVisible(
            find.ancestor(
              of: find.text(
                locale == 'ru' ? 'Ровное дыхание' : 'An Easy Breathing Rhythm',
              ),
              matching: find.byType(PracticeDeckCard),
            ),
          );
          await tester.pumpAndSettle();
          final here = find
              .text(
                locale == 'ru' ? 'Ровное дыхание' : 'An Easy Breathing Rhythm',
              )
              .hitTestable();
          final next = find.text(
            locale == 'ru' ? 'Мягкий выдох' : 'A Gentle Exhale',
          );
          final card = find.ancestor(
            of: here,
            matching: find.byType(PracticeDeckCard),
          );
          final frame = tester.getRect(card);
          await tester.dragFrom(
            Offset(frame.center.dx, frame.top + 147),
            const Offset(0, -113),
          );
          await tester.pumpAndSettle();
          expect(next.hitTestable(), findsOneWidget);
          final nextCard = find.ancestor(
            of: next.hitTestable(),
            matching: find.byType(PracticeDeckCard),
          );
          await tester.tap(nextCard);
          await tester.pumpAndSettle();
          expect(
            find.text(locale == 'ru' ? 'Мягкий выдох' : 'A Gentle Exhale'),
            findsOneWidget,
          );
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
        }
        if (category == 'meditation' && tablet) {
          expect(cards, findsNWidgets(3));
          final featured = tester.getRect(cards.at(0));
          final second = tester.getRect(cards.at(1));
          final third = tester.getRect(cards.at(2));
          expect(featured.bottom, lessThan(second.top));
          expect(second.top, third.top);
          expect(second.right, lessThan(third.left));
        }
        if (category == 'meditation' && !tablet) {
          final stack = find.byType(PracticeDeckCard);
          final card = stack.last;
          final original = find.text(
            locale == 'ru' ? 'Утро без спешки' : 'An Unhurried Morning',
          );
          final next = find.text(
            locale == 'ru' ? 'Рабочий день закончился' : 'The Workday Is Over',
          );
          expect(original.hitTestable(), findsOneWidget);
          final frame = tester.getRect(card);
          await tester.dragFrom(
            Offset(frame.center.dx, frame.top + 150),
            const Offset(0, -120),
          );
          await tester.pumpAndSettle();
          expect(next.hitTestable(), findsOneWidget);
          await tester.dragFrom(
            Offset(frame.center.dx, frame.top + 100),
            const Offset(0, 118),
          );
          await tester.pumpAndSettle();
          expect(original.hitTestable(), findsOneWidget);
        }
        final title = find.text(locale == 'ru' ? ruTitle : enTitle);
        await tester.ensureVisible(title.last);
        await tester.pumpAndSettle();
        await tester.tap(
          find
              .ancestor(of: title.last, matching: find.byType(PracticeDeckCard))
              .last,
        );
        await tester.pumpAndSettle();
        final expectedArt = category == 'meditation'
            ? 'assets/images/home/hand_with_star.webp'
            : 'assets/images/practices/sadhu-board.webp';
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName == expectedArt,
          ),
          findsOneWidget,
        );
        final guide = find.text(
          locale == 'ru' ? 'Как проходит практика' : 'Session guide',
        );
        expect(find.byType(ScenarioPage), findsOneWidget);
        final launch = find.byKey(const ValueKey('open-practice-player'));
        expect(launch, findsOneWidget);
        expect(
          find.text(locale == 'ru' ? 'Начать практику' : 'Start practice'),
          findsOneWidget,
        );
        final viewport = find.byType(ListView).last;
        if (tablet) {
          expect(
            find.descendant(of: viewport, matching: launch),
            findsOneWidget,
          );
          await tester.ensureVisible(launch);
        } else {
          final startPosition = tester.getRect(launch);
          expect(
            startPosition.top,
            greaterThanOrEqualTo(tester.getRect(viewport).bottom),
          );
          await tester.drag(viewport, const Offset(0, -220));
          await tester.pumpAndSettle();
          expect(tester.getRect(launch), startPosition);
        }
        expect(launch.hitTestable(), findsOneWidget);
        await tester.tap(launch);
        await tester.pumpAndSettle();
        final id = category == 'meditation'
            ? 'unhurried-morning'
            : 'sadhu-board';
        final hasAudio = File('assets/audio/$id-$locale.m4a').existsSync();
        expect(
          find.text(
            locale == 'ru' ? 'Пока без озвучки' : 'Voice recording coming soon',
          ),
          hasAudio ? findsNothing : findsOneWidget,
        );
        expect(find.byType(Slider), findsOneWidget);
        final foreground = tester
            .widgetList<PlayerArtwork>(find.byType(PlayerArtwork))
            .singleWhere((layer) => layer.showSubject);
        expect(
          foreground.scene,
          category == 'meditation' ? PracticeScene.dawn : PracticeScene.dusk,
        );
        expect(foreground.subjectAsset, expectedArt);
        expect(
          find.bySemanticsLabel(
            AppLocalizations.of(
              tester.element(find.byType(Slider)),
            ).playerPause,
          ),
          findsWidgets,
        );
        final strings = AppLocalizations.of(
          tester.element(find.byType(Slider)),
        );
        final pause = find.bySemanticsLabel(strings.playerPause).first;
        await tester.ensureVisible(pause);
        await tester.tap(pause);
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel(strings.playerPlay), findsWidgets);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(
          find.text(locale == 'ru' ? 'Открыть практику' : 'Open session'),
          findsNothing,
        );
        await tester.scrollUntilVisible(
          guide,
          150,
          scrollable: find.byType(Scrollable).last,
        );
        expect(guide, findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }
    });
  }
}
