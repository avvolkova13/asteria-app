import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:asteria_app/features/affirmation/player/player_artwork.dart';
import 'package:asteria_app/features/affirmation/player/affirmation_motion_artwork.dart';
import 'package:asteria_app/features/affirmation/player/player_subject_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('full Moon stays connected to its star through the float', (
    tester,
  ) async {
    tester.view.physicalSize = const Size.square(430);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    Future<void> show(double phase) => tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: AffirmationMotionArtwork(
            motion: PlayerSubjectMotion.fullMoon,
            phase: phase,
          ),
        ),
      ),
    );
    await show(0);
    final providers = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => image.image)
        .toSet();
    await tester.runAsync(
      () => Future.wait(
        providers.map((image) => precacheImage(image, key.currentContext!)),
      ),
    );
    await tester.pump();
    for (var step = 0; step <= 12; step++) {
      final phase = math.pi * 2 * step / 12;
      await show(phase);
      final alpha = await tester.runAsync(() async {
        final frame =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage();
        try {
          final bytes = (await frame.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          final x = (215 + 5 * math.sin(phase) * 430 / 250).round();
          final y = (265 - 6 * (1 - math.cos(phase)) * 430 / 250).round();
          return bytes.getUint8((430 * y + x) * 4 + 3);
        } finally {
          frame.dispose();
        }
      });
      expect(
        alpha,
        greaterThan(180),
        reason: 'Disconnected lunar ornament at phase $step/12',
      );
    }
  });

  testWidgets('all lunar foregrounds and skies keep moving gently after Pause', (
    tester,
  ) async {
    const tileWidth = 390;
    const height = 844;
    const width = tileWidth * 6;
    tester.view.physicalSize = Size(width.toDouble(), height.toDouble());
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final boundary = GlobalKey();
    Future<void> show({
      bool reduced = false,
      bool playing = false,
      bool hidden = false,
    }) => tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: TickerMode(
            enabled: !hidden,
            child: RepaintBoundary(
              key: boundary,
              child: Row(
                children: [
                  for (final suffix in ['', '_2', '_3'])
                    for (final background in [false, true])
                      Expanded(
                        child: PlayerArtwork(
                          scene: PracticeScene.moon,
                          portraitAsset:
                              'assets/images/affirmation/category_moon$suffix.webp',
                          duration: const Duration(seconds: 30),
                          position: const Duration(seconds: 4),
                          playing: playing,
                          showSubject: !background,
                          showBackground: background,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Future<Uint8List> capture() async {
      final frame =
          await (boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary)
              .toImage();
      try {
        final bytes = await frame.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        return bytes!.buffer.asUint8List();
      } finally {
        frame.dispose();
      }
    }

    await show();
    await tester.runAsync(() async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final plates = manifest.listAssets().where(
        (name) =>
            name.startsWith(
              'assets/images/affirmation/motion/subjects/category_moon',
            ) ||
            name == 'assets/images/sonnik/sonnik_clouds.webp',
      );
      await Future.wait(
        plates.map(
          (asset) => precacheImage(AssetImage(asset), boundary.currentContext!),
        ),
      );
    });
    await tester.pump();
    // Exercise the same Play -> Pause path as the real player before measuring.
    await show(playing: true);
    await tester.pump();
    await show();
    await tester.pump();
    for (final mode in ['ambient', 'reduced', 'hidden']) {
      await show(reduced: mode == 'reduced', hidden: mode == 'hidden');
      await tester.pump();
      final before = (await tester.runAsync(capture))!;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1200)),
      );
      await tester.pump(const Duration(milliseconds: 1200));
      final after = (await tester.runAsync(capture))!;
      for (var tile = 0; tile < 6; tile++) {
        var changed = 0;
        for (var y = 0; y < height; y++) {
          for (var x = tile * tileWidth; x < (tile + 1) * tileWidth; x++) {
            final index = (width * y + x) * 4;
            if ((before[index] - after[index]).abs() > 3 ||
                (before[index + 1] - after[index + 1]).abs() > 3 ||
                (before[index + 3] - after[index + 3]).abs() > 3) {
              changed++;
            }
          }
        }
        expect(
          changed,
          mode == 'ambient' ? greaterThan(tile.isEven ? 600 : 5000) : isZero,
          reason:
              '$mode: lunar ${tile ~/ 2 + 1}, ${tile.isEven ? 'foreground' : 'background'}',
        );
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
