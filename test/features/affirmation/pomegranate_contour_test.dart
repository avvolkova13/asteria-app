import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:asteria_app/features/affirmation/player/affirmation_motion_artwork.dart';
import 'package:asteria_app/features/affirmation/player/player_subject_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'pomegranate stays opaque between crown and rind for the full cycle',
    (tester) async {
      final key = GlobalKey();
      tester.view.physicalSize = const Size(430, 430);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Future<void> show(double phase) => tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: key,
            child: AffirmationMotionArtwork(
              motion: PlayerSubjectMotion.pomegranate,
              phase: phase,
            ),
          ),
        ),
      );
      await show(0);
      final context = key.currentContext!;
      final images = tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => image.image)
          .toSet();
      await tester.runAsync(
        () => Future.wait(images.map((asset) => precacheImage(asset, context))),
      );
      await tester.pump();
      for (var step = 0; step <= 24; step++) {
        await show(2 * math.pi * step / 24);
        final holes = await tester.runAsync(() async {
          final frame =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          try {
            final pixels = (await frame.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!;
            var transparent = 0;
            // This patch lies inside the shoulder even at the extremes of the tilt.
            for (var y = 127; y < 170; y++) {
              for (var x = 238; x < 291; x++) {
                if (pixels.getUint8((430 * y + x) * 4 + 3) < 245) transparent++;
              }
            }
            return transparent;
          } finally {
            frame.dispose();
          }
        });
        expect(
          holes,
          0,
          reason: 'Exposed background inside rind at phase $step/24',
        );
      }
    },
  );
}
