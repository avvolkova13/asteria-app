import 'package:asteria_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget scene(bool reduced, VoidCallback done) => MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: SplashScreen(onFinished: done),
    ),
  );

  testWidgets('one-shot launch holds until the drawing finishes', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(scene(false, () => calls++));
    await tester.pump(const Duration(seconds: 2));
    expect(calls, 0);
    await tester.pump(const Duration(seconds: 2));
    expect(calls, 1);
    await tester.pump(const Duration(seconds: 5));
    expect(calls, 1);
  });
  for (final alreadyPlaying in [false, true]) {
    testWidgets(
      'reduced motion releases launch once (already playing: $alreadyPlaying)',
      (tester) async {
        var calls = 0;
        if (alreadyPlaying) {
          await tester.pumpWidget(scene(false, () => calls++));
          await tester.pump(const Duration(milliseconds: 800));
        }
        await tester.pumpWidget(scene(true, () => calls++));
        expect(find.bySemanticsLabel('Asteria'), findsOneWidget);
        expect(calls, 1);
        await tester.pump(const Duration(seconds: 4));
        expect(calls, 1);
      },
    );
  }
}
