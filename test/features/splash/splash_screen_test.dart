import 'package:asteria_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget scene(bool reduced, VoidCallback done, {bool ready = true}) =>
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SplashScreen(onFinished: done, destinationReady: ready),
        ),
      );

  testWidgets('background keeps animating during the hold and handoff', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(scene(false, () => calls++));
    await tester.pump(); // First tick after the opening scene has laid out.
    await tester.pump(const Duration(milliseconds: 3850));
    expect(calls, 0);
    await tester.pump(const Duration(milliseconds: 1999));
    expect(calls, 0);
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pump(const Duration(milliseconds: 1));
    expect(calls, 1);
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pump(const Duration(seconds: 5));
    expect(calls, 1);
  });
  testWidgets('a slow destination cannot block the intro', (tester) async {
    var calls = 0;
    await tester.pumpWidget(scene(false, () => calls++, ready: false));
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 5849));
    expect(calls, 0);
    await tester.pump(const Duration(milliseconds: 1));
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
