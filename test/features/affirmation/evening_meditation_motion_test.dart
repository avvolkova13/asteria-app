import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:asteria_app/features/affirmation/player/player_artwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'steam rises above a still cup and the intact moon cushion rocks',
    (tester) async {
      final boundary = GlobalKey();
      tester.view.physicalSize = const Size(760, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      Future<void> show(Duration position, {bool reduced = false}) =>
          tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: RepaintBoundary(
                  key: boundary,
                  child: Row(
                    children: [
                      for (final (name, scene, minutes) in const [
                        ('workday-is-over', PracticeScene.dusk, 4),
                        ('time-for-sleep', PracticeScene.moon, 5),
                      ])
                        Expanded(
                          child: PlayerArtwork(
                            scene: scene,
                            subjectAsset: 'assets/images/practices/$name.webp',
                            duration: Duration(minutes: minutes),
                            position: position,
                            playing: false,
                            showBackground: false,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );

      Future<Uint8List> pixels() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await render.toImage();
        try {
          final bytes = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          return bytes!.buffer.asUint8List();
        } finally {
          image.dispose();
        }
      }

      int changed(Uint8List a, Uint8List b, Rect region) {
        var count = 0;
        for (var y = region.top.toInt(); y < region.bottom; y++) {
          for (var x = region.left.toInt(); x < region.right; x++) {
            final i = (y * 760 + x) * 4;
            if ((a[i] - b[i]).abs() > 5 || (a[i + 3] - b[i + 3]).abs() > 5) {
              count++;
            }
          }
        }
        return count;
      }

      await show(Duration.zero);
      await tester.runAsync(() async {
        final context = boundary.currentContext!;
        await Future.wait([
          for (final name in ['time-for-sleep', 'motion-tea'])
            precacheImage(
              AssetImage('assets/images/practices/$name.webp'),
              context,
            ),
        ]);
      });
      await tester.pump();
      final start = (await tester.runAsync(pixels))!;
      await show(const Duration(seconds: 1));
      final next = (await tester.runAsync(pixels))!;
      expect(
        changed(start, next, const Rect.fromLTRB(230, 185, 288, 254)),
        greaterThan(300),
      );
      expect(
        changed(start, next, const Rect.fromLTRB(230, 268, 312, 320)),
        isZero,
      );
      expect(
        changed(start, next, const Rect.fromLTRB(455, 215, 610, 307)),
        greaterThan(75),
      );
      expect(
        changed(start, next, const Rect.fromLTRB(590, 135, 662, 212)),
        greaterThan(500),
      );
      // A rigid pose preserves silhouette area. Integrating alpha includes
      // antialiased edges even when the gold trim rotates between pixels.
      int cushionCoverage(Uint8List rgba) {
        var coverage = 0;
        for (var y = 0; y < 480; y++) {
          for (var x = 380; x < 760; x++) {
            coverage += rgba[4 * (y * 760 + x) + 3];
          }
        }
        return coverage;
      }

      final restCoverage = cushionCoverage(start);
      for (final second in [3, 9]) {
        await show(Duration(seconds: second));
        final extreme = (await tester.runAsync(pixels))!;
        expect(
          cushionCoverage(extreme),
          closeTo(restCoverage, restCoverage * .002),
        );
      }

      await show(const Duration(seconds: 2), reduced: true);
      final quiet = (await tester.runAsync(pixels))!;
      expect(quiet, orderedEquals(start));
    },
  );
}
