import 'dart:ui' as ui;

import 'package:asteria_app/features/affirmation/player/cover_motion_artwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _assetFolder = 'assets/images/affirmation/motion/subjects';
const _specialized = {
  'i5x8b2lu1nOvj0VPF8zi', // Linked stones
  'be-kinder', // Rose in the mirror
  '5UgabJFV5M2TiptnhZMm', // Door
  '9Mvd1yeBUDmiLPRdJ1mv', // Ribbon
  'EG8DuZL1V6idVvW0jp4B', // Crane
  'aivVFq7TD00qsfLg4VzX', // Plate
  'choose-yourself', // Compass
};

String _asset(String id) => '$_assetFolder/cover-$id.webp';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every transparent cover is assigned an animation', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    const prefix = '$_assetFolder/cover-';
    final subjects = {
      for (final asset in manifest.listAssets())
        if (asset.startsWith(prefix) && asset.endsWith('.webp'))
          asset.substring(prefix.length, asset.length - '.webp'.length),
    };
    expect(subjects, unorderedEquals({..._specialized, ...coverMotions.keys}));
    expect(coverMotions, hasLength(42));
  });

  testWidgets(
    'every cover changes over time and stays still with Reduce Motion',
    (tester) async {
      const width = 800;
      const height = 600;
      const tile = 100;
      tester.view.physicalSize = Size(width.toDouble(), height.toDouble());
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final key = GlobalKey();
      final entries = coverMotions.entries.toList();
      Future<void> show(double progress, {bool reduced = false}) =>
          tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: RepaintBoundary(
                  key: key,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      children: [
                        for (final scene in entries)
                          SizedBox.square(
                            dimension: tile.toDouble(),
                            child: CoverMotionArtwork(
                              asset: _asset(scene.key),
                              scene: scene.value,
                              seconds: progress * scene.value.period,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );

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
      await tester.runAsync(
        () => Future.wait([
          for (final scene in entries)
            precacheImage(AssetImage(_asset(scene.key)), key.currentContext!),
        ]),
      );
      await tester.pump();

      final first = (await tester.runAsync(capture))!;
      final changedAcrossPhases = List.filled(entries.length, 0);
      for (final progress in [.25, .43, .63]) {
        await show(progress);
        final later = (await tester.runAsync(capture))!;
        for (var index = 0; index < entries.length; index++) {
          final originX = index % 8 * tile;
          final originY = index ~/ 8 * tile;
          var changed = 0;
          for (var y = originY; y < originY + tile; y++) {
            for (var x = originX; x < originX + tile; x++) {
              final offset = (y * width + x) * 4;
              for (var c = 0; c < 4; c++) {
                if ((first[offset + c] - later[offset + c]).abs() > 2) {
                  changed++;
                  break;
                }
              }
            }
          }
          changedAcrossPhases[index] += changed;
        }
      }

      for (final (index, scene) in entries.indexed) {
        expect(
          changedAcrossPhases[index],
          greaterThanOrEqualTo(4),
          reason: scene.key,
        );
      }

      await show(0, reduced: true);
      final still = (await tester.runAsync(capture))!;
      await show(.43, reduced: true);
      final later = (await tester.runAsync(capture))!;
      expect(later, orderedEquals(still));
    },
  );
}
