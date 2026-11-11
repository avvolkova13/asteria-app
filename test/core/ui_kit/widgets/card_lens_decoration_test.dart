import 'dart:ui' as ui;

import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const radius = BorderRadius.all(Radius.circular(20));

  for (final light in [false, true]) {
    testWidgets(
      'rounded glass keeps its edge and reading area (light: $light)',
      (tester) async {
        await tester.runAsync(() async {
          const size = Size(160, 96);
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);
          final surface = CardLensDecoration(
            color: light ? Colors.white : const Color(0xff23182d),
            borderRadius: radius,
          ).createBoxPainter();
          surface.paint(
            canvas,
            Offset.zero,
            const ImageConfiguration(size: size),
          );
          surface.dispose();
          final picture = recorder.endRecording();
          final image = await picture.toImage(160, 96);
          final bytes = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          final data = bytes!.buffer.asUint8List();
          image.dispose();
          picture.dispose();
          int red(int x, int y) => data[4 * (y * 160 + x)];
          expect(data[3], 0, reason: 'outside rounded corner');
          if (light) {
            expect(red(80, 48), closeTo(255, 5));
            expect(red(140, 94), lessThan(red(80, 48) - 10));
          } else {
            expect(red(80, 48), closeTo(0x23, 8));
            expect(red(50, 1), greaterThan(red(80, 48) + 20));
            expect(red(140, 93), greaterThan(red(80, 48) + 10));
          }
        });
      },
    );
  }

  test(
    'selection changes interpolate the base with the same glass material',
    () {
      const a = CardLensDecoration(color: Colors.black, borderRadius: radius);
      const b = CardLensDecoration(color: Colors.white, borderRadius: radius);
      final middle = Decoration.lerp(a, b, .5) as CardLensDecoration;
      expect(middle.color, Color.lerp(Colors.black, Colors.white, .5));
      expect(middle.borderRadius, radius);
    },
  );
}
