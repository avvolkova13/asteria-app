import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:asteria_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('brand mark moves once and settles into the original artwork', (
    tester,
  ) async {
    await _mountSplash(tester);
    final first = await _pixels(tester);
    await tester.pump(const Duration(milliseconds: 520));
    expect(await _pixels(tester), isNot(equals(first)));
    await tester.pump(const Duration(seconds: 2));
    expect(await _pixels(tester), equals(first));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion keeps the full mark still during launch', (
    tester,
  ) async {
    await _mountSplash(tester, reduced: true);
    final first = await _pixels(tester);
    await tester.pump(const Duration(milliseconds: 650));
    expect(await _pixels(tester), equals(first));
    expect(find.bySemanticsLabel('Asteria'), findsOneWidget);
  });
}

Future<void> _mountSplash(WidgetTester tester, {bool reduced = false}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: ValueKey('mark'),
            child: SizedBox.square(dimension: 104, child: SplashScreen()),
          ),
        ),
      ),
    ),
  );
  // Asset decoding uses the engine's image decoder outside the fake clock.
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
    if (find
        .descendant(
          of: find.byType(SplashScreen),
          matching: find.byType(CustomPaint),
        )
        .evaluate()
        .isNotEmpty) {
      return;
    }
  }
  fail('The brand artwork did not decode.');
}

Future<Uint8List> _pixels(WidgetTester tester) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('mark')),
  );
  return (await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    try {
      return (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }))!;
}
