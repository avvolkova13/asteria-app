import 'dart:ui' as ui;

import 'package:asteria_app/features/affirmation/player/player_artwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (category, scene) in const [
    ('creative', PracticeScene.bloom),
    ('moon', PracticeScene.moon),
    ('calm', PracticeScene.dusk),
  ]) {
    testWidgets(
      '$category illustrations move before Play and respect Reduce Motion',
      (tester) async {
        final keys = List.generate(3, (_) => GlobalKey());
        final assets = [
          for (final suffix in ['', '_2', '_3'])
            'assets/images/affirmation/category_$category$suffix.webp',
        ];
        tester.view.physicalSize = const Size(900, 300);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        Future<void> show({required bool reduced}) => tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: Row(
                children: [
                  for (var i = 0; i < assets.length; i++)
                    Expanded(
                      child: RepaintBoundary(
                        key: keys[i],
                        child: PlayerArtwork(
                          scene: scene,
                          portraitAsset: assets[i],
                          duration: const Duration(seconds: 30),
                          position: Duration.zero,
                          playing: false,
                          previewMotion: true,
                          showBackground: false,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );

        Future<List<Uint8List>> capture() async {
          final result = <Uint8List>[];
          for (final key in keys) {
            final boundary =
                key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage();
            try {
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.rawRgba,
              );
              result.add(bytes!.buffer.asUint8List());
            } finally {
              image.dispose();
            }
          }
          return result;
        }

        await show(reduced: true);
        // Decode every plate before comparison so incoming artwork cannot count as motion.
        await tester.runAsync(() async {
          final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
          final context = keys.first.currentContext!;
          final plates = manifest.listAssets().where(
            (name) => name.startsWith(
              'assets/images/affirmation/motion/subjects/category_$category',
            ),
          );
          await Future.wait(
            plates.map((name) => precacheImage(AssetImage(name), context)),
          );
        });
        await tester.pump();

        for (final reduced in [false, true]) {
          await show(reduced: reduced);
          await tester.pump();
          final before = (await tester.runAsync(capture))!;
          // The real preview uses a monotonic clock independent of the audio position.
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 550)),
          );
          await tester.pump(const Duration(milliseconds: 550));
          final after = (await tester.runAsync(capture))!;
          for (var i = 0; i < assets.length; i++) {
            var movingPixels = 0;
            for (var p = 0; p < before[i].length; p += 4) {
              if ((before[i][p] - after[i][p]).abs() > 12 ||
                  (before[i][p + 3] - after[i][p + 3]).abs() > 12) {
                movingPixels++;
              }
            }
            expect(
              movingPixels,
              reduced ? isZero : greaterThan(500),
              reason: assets[i],
            );
          }
        }
      },
    );
  }
}
