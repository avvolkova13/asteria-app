import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:asteria_app/features/affirmation/player/affirmation_motion_artwork.dart';
import 'package:asteria_app/features/affirmation/player/player_subject_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('open book has no cover protruding below the floating star', (
    tester,
  ) async {
    tester.view.physicalSize = const Size.square(430);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: const AffirmationMotionArtwork(
            motion: PlayerSubjectMotion.book,
            phase: math.pi / 2,
          ),
        ),
      ),
    );
    final context = key.currentContext!;
    final images = tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => image.image)
        .toSet();
    await tester.runAsync(
      () => Future.wait(images.map((asset) => precacheImage(asset, context))),
    );
    await tester.pump();
    final opaque = await tester.runAsync(() async {
      final frame =
          await (key.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary)
              .toImage();
      try {
        final pixels = (await frame.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        var count = 0;
        for (var y = 174; y < 182; y++) {
          for (var x = 212; x < 218; x++) {
            if (pixels.getUint8((430 * y + x) * 4 + 3) > 20) count++;
          }
        }
        return count;
      } finally {
        frame.dispose();
      }
    });
    expect(
      opaque,
      0,
      reason: 'The gap between the pages should reveal the background.',
    );
  });
}
