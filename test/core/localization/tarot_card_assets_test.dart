import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'every Russian face card has a decodable English asset in the bundle',
    () async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final assets = manifest.listAssets();
      final russian = assets.where(
        (path) => RegExp(r'^assets/images/cards/[^/]+\.webp$').hasMatch(path),
      );
      final english = assets.where(
        (path) =>
            RegExp(r'^assets/images/cards/en/[^/]+\.webp$').hasMatch(path),
      );

      expect(russian, hasLength(78));
      expect(english, hasLength(78));
      expect(
        english.map((path) => path.split('/').last).toSet(),
        russian.map((path) => path.split('/').last).toSet(),
      );
      for (final path in english) {
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        try {
          final frame = await codec.getNextFrame();
          expect(frame.image.width, 682, reason: path);
          expect(frame.image.height, 1024, reason: path);
          frame.image.dispose();
        } finally {
          codec.dispose();
        }
      }
    },
  );
}
