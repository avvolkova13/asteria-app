import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:asteria_app/features/affirmation/player/player_artwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('all six body practice illustrations move in the first second', (
    tester,
  ) async {
    const scenes = [
      ('easy-breathing-rhythm', PracticeScene.bloom, 2),
      ('gentle-exhale', PracticeScene.moon, 2),
      ('shake-off-the-day', PracticeScene.ribbon, 2),
      ('feel-the-difference', PracticeScene.dawn, 3),
      ('cloud-hands', PracticeScene.ribbon, 3),
      ('sadhu-board', PracticeScene.dusk, 3),
    ];
    const tile = 300;
    final root = GlobalKey();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 600);
    addTearDown(tester.view.reset);
    Future<void> show(Duration at, {bool reduced = false}) => tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: RepaintBoundary(
            key: root,
            child: Wrap(
              children: [
                for (final (asset, scene, minutes) in scenes)
                  SizedBox.square(
                    dimension: tile.toDouble(),
                    child: PlayerArtwork(
                      subjectAsset: 'assets/images/practices/$asset.webp',
                      scene: scene,
                      duration: Duration(minutes: minutes),
                      position: at,
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
      final boundary =
          root.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      try {
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        return bytes!.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    }

    await show(Duration.zero);
    // Await the actual source images so decoding cannot masquerade as movement.
    await tester.runAsync(() async {
      final names = tester
          .widgetList<Image>(find.byType(Image))
          .map((w) => w.image)
          .toSet();
      final context = root.currentContext!;
      await Future.wait(
        names.map((provider) => precacheImage(provider, context)),
      );
    });
    await tester.pump();
    final start = (await tester.runAsync(pixels))!;
    await show(const Duration(milliseconds: 650));
    final moved = (await tester.runAsync(pixels))!;
    final counts = List<int>.filled(scenes.length, 0);
    for (var y = 0; y < 2 * tile; y++) {
      for (var x = 0; x < 3 * tile; x++) {
        final offset = 4 * (3 * tile * y + x);
        if ((moved[offset] - start[offset]).abs() > 12 ||
            (moved[offset + 3] - start[offset + 3]).abs() > 12) {
          counts[3 * (y ~/ tile) + (x ~/ tile)]++;
        }
      }
    }
    for (var i = 0; i < scenes.length; i++) {
      expect(counts[i], greaterThan(300), reason: scenes[i].$1);
    }
    await show(const Duration(seconds: 2), reduced: true);
    final quiet = (await tester.runAsync(pixels))!;
    expect(quiet, orderedEquals(start));
  });
}
