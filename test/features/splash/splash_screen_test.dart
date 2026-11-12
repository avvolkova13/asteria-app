import 'dart:ui' as ui;

import 'package:asteria_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('reduced motion skips playback and releases launch immediately', (
    tester,
  ) async {
    var finished = false;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SplashScreen(onFinished: () => finished = true),
        ),
      ),
    );
    expect(finished, isTrue);
    expect(find.bySemanticsLabel('Asteria'), findsOneWidget);
    expect(
      tester.widget<Image>(find.byType(Image)).image,
      const AssetImage('assets/images/auth/fluid_launch_still.webp'),
    );
  });

  testWidgets('the bundled splash decodes as a complete one-shot sequence', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final data = await rootBundle.load(
        'assets/images/auth/fluid_launch.webp',
      );
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      try {
        expect(codec.repetitionCount, 0);
        expect(codec.frameCount, greaterThan(30));
        var duration = Duration.zero;
        for (var frame = 0; frame < codec.frameCount; frame++) {
          final info = await codec.getNextFrame();
          duration += info.duration;
          info.image.dispose();
        }
        expect(duration.inMilliseconds, inInclusiveRange(3650, 4000));
      } finally {
        codec.dispose();
      }
    });
  });
}
