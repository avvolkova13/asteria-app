import 'dart:ui' as ui;

import 'package:asteria_app/features/affirmation/player/player_artwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (id, scene, cycleMs) in const [
    ('MOgdL3XZWW6ZLIDUCmfH', PracticeScene.dusk, 20000),
    ('5UgabJFV5M2TiptnhZMm', PracticeScene.dusk, 24000),
    ('EG8DuZL1V6idVvW0jp4B', PracticeScene.dusk, 16000),
    ('9Mvd1yeBUDmiLPRdJ1mv', PracticeScene.dusk, 36000),
    ('aivVFq7TD00qsfLg4VzX', PracticeScene.dusk, 24000),
    ('choose-yourself', PracticeScene.dusk, 20000),
    ('km6gqT17HfO35Q4t0WQo', PracticeScene.moon, 10000),
  ]) {
    testWidgets('$id moves on a transparent layer and loops', (tester) async {
      final key = GlobalKey();
      const cover = '$playerArtDirectory/cover-';
      Future<void> show(int milliseconds, {bool reduced = false}) {
        return tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: Center(
                child: RepaintBoundary(
                  key: key,
                  child: SizedBox.square(
                    dimension: 300,
                    child: PlayerArtwork(
                      scene: scene,
                      portraitAsset: '$cover$id.webp',
                      duration: const Duration(seconds: 30),
                      position: Duration(milliseconds: milliseconds),
                      playing: false,
                      showBackground: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      Future<List<int>> capture() async {
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
      }

      await show(0);
      if (scene == PracticeScene.dusk) {
        await tester.runAsync(
          () => precacheImage(
            AssetImage('$playerArtDirectory/motion/subjects/cover-$id.webp'),
            key.currentContext!,
          ),
        );
      }
      await tester.pump();
      final first = (await tester.runAsync(capture))!;
      final width = 300;
      for (final corner in [
        0,
        width - 1,
        width * (width - 1),
        width * width - 1,
      ]) {
        expect(first[corner * 4 + 3], 0);
      }
      expect(
        Iterable<int>.generate(width * width)
            .where((p) => first[p * 4 + 3] > 20),
        isNotEmpty,
      );

      await show(cycleMs ~/ 3);
      final later = (await tester.runAsync(capture))!;
      expect(later, isNot(orderedEquals(first)));
      if (id == 'EG8DuZL1V6idVvW0jp4B') {
        final cranePixels = <int>[];
        for (var y = 0; y < width; y++) {
          for (var x = 0; x < width ~/ 2; x++) {
            final offset = (y * width + x) * 4;
            if (first[offset + 3] > 20) cranePixels.add(offset);
          }
        }
        expect(cranePixels, isNotEmpty);
        expect(
          cranePixels.every(
            (p) => List.generate(
              4,
              (c) => first[p + c] == later[p + c],
            ).every((equal) => equal),
          ),
          isTrue,
          reason: 'the crane stays still while the gift moves',
        );
      }

      await show(cycleMs);
      final loop = (await tester.runAsync(capture))!;
      expect(loop, orderedEquals(first));

      await show(cycleMs ~/ 3, reduced: true);
      final reduced = (await tester.runAsync(capture))!;
      expect(reduced, orderedEquals(first));
    });
  }
}
