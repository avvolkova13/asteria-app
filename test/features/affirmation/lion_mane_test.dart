import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:asteria_app/features/affirmation/player/affirmation_motion_artwork.dart';
import 'package:asteria_app/features/affirmation/player/player_subject_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lion face stays registered while the whole mane sways', (
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
            motion: PlayerSubjectMotion.lion,
            phase: phase,
          ),
        ),
      ),
    );
    Future<Uint8List> pixels() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final frame = await boundary.toImage();
      try {
        final data = await frame.toByteData(format: ui.ImageByteFormat.rawRgba);
        return data!.buffer.asUint8List();
      } finally {
        frame.dispose();
      }
    }

    await show(0);
    final providers = tester
        .widgetList<Image>(find.byType(Image))
        .map((i) => i.image)
        .toSet();
    await tester.runAsync(
      () => Future.wait(
        providers.map((p) => precacheImage(p, key.currentContext!)),
      ),
    );
    await tester.pump();
    final rest = (await tester.runAsync(pixels))!;
    for (var y = 97; y < 121; y++) {
      for (var x = 103; x < 121; x++) {
        expect(rest[(430 * y + x) * 4 + 3], 255, reason: 'Hole in left ear');
      }
    }
    int changed(Uint8List frame, Rect patch) {
      var count = 0;
      for (var y = patch.top.toInt(); y < patch.bottom; y++) {
        for (var x = patch.left.toInt(); x < patch.right; x++) {
          final i = (430 * y + x) * 4;
          if ([0, 1, 2, 3].any((k) => (rest[i + k] - frame[i + k]).abs() > 3)) {
            count++;
          }
        }
      }
      return count;
    }

    const mane = [
      Rect.fromLTRB(164, 30, 266, 76),
      Rect.fromLTRB(42, 196, 101, 259),
      Rect.fromLTRB(328, 180, 390, 253),
      Rect.fromLTRB(147, 316, 273, 391),
    ];
    final movement = List.filled(mane.length, 0);
    for (var step = 1; step <= 12; step++) {
      await show(math.pi * 2 * step / 12);
      final frame = (await tester.runAsync(pixels))!;
      for (final patch in const [
        Rect.fromLTRB(153, 147, 274, 184), // Eyes and nose.
        Rect.fromLTRB(188, 201, 241, 244), // Muzzle.
        Rect.fromLTRB(100, 100, 119, 122), // Ears.
        Rect.fromLTRB(320, 102, 337, 122),
      ]) {
        expect(
          changed(frame, patch),
          0,
          reason: 'Head moved at phase $step in $patch',
        );
      }
      for (var i = 0; i < mane.length; i++) {
        movement[i] = math.max(movement[i], changed(frame, mane[i]));
      }
    }
    for (var i = 0; i < mane.length; i++) {
      expect(
        movement[i],
        greaterThan(100),
        reason: 'Stationary mane in ${mane[i]}',
      );
    }
  });
}
