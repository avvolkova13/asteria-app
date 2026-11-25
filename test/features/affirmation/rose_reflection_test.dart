import 'dart:ui' as ui;

import 'package:asteria_app/features/affirmation/player/affirmation_motion_artwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('rose moves inside its fixed frame and respects Reduce Motion', (
    tester,
  ) async {
    const asset =
        'assets/images/affirmation/motion/subjects/cover-be-kinder.webp';
    final key = GlobalKey();
    Future<Uint8List> frame(double seconds, {bool reduced = false}) async {
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: Center(
            child: SizedBox.square(
              dimension: 350,
              child: RepaintBoundary(
                key: key,
                child: RoseReflectionArtwork(asset: asset, seconds: seconds),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => precacheImage(const AssetImage(asset), key.currentContext!),
      );
      await tester.pump();
      return (await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage();
        try {
          final data = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          return data!.buffer.asUint8List();
        } finally {
          image.dispose();
        }
      }))!;
    }

    final start = await frame(0);
    for (final seconds in [.6, 1.5, 4.5]) {
      final moved = await frame(seconds);
      int changed = 0, outside = 0;
      for (var y = 0; y < 350; y++) {
        for (var x = 0; x < 350; x++) {
          final i = (350 * y + x) * 4;
          if ((moved[i] - start[i]).abs() > 8) {
            if (x >= 99 && x <= 250 && y >= 68 && y <= 268) {
              changed++;
            } else {
              outside++;
            }
          }
        }
      }
      expect(changed, greaterThan(900));
      expect(outside, 0);
    }
    expect(await frame(6), orderedEquals(start));
    expect(await frame(1.5, reduced: true), orderedEquals(start));
  });
}
