import 'package:asteria_app/features/splash/presentation/widgets/splash_handoff.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({
    bool ready = false,
    bool reduced = false,
    bool canReveal = true,
    VoidCallback? onTap,
  }) => MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: SplashHandoff(
        canReveal: canReveal,        splash: const ColoredBox(color: Colors.purple, child: Text('Splash')),
        destination: ready
            ? GestureDetector(
                onTap: onTap,
                child: const ColoredBox(
                  color: Colors.black,
                  child: Text('Today'),
                ),
              )
            : null,
      ),
    ),
  );

  testWidgets('retains splash over the mounted destination, then removes it', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(host());
    await tester.pump(const Duration(seconds: 8));
    expect(find.text('Splash'), findsOneWidget);
    await tester.pumpWidget(host(ready: true, canReveal: false));
    final destination = tester.element(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.text('Splash'), findsOneWidget);
    await tester.pumpWidget(host(ready: true, onTap: () => taps++));
    expect(find.text('Splash'), findsOneWidget);
    expect(
      tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value,
      1,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    expect(
      tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity.value,
      inExclusiveRange(.2, .8),
    );
    await tester.tapAt(const Offset(100, 100));
    expect(taps, 0);
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pumpAndSettle();
    expect(find.text('Splash'), findsNothing);
    expect(tester.element(find.text('Today')), same(destination));
    await tester.tapAt(const Offset(100, 100));
    expect(taps, 1);
    await tester.pumpWidget(host(ready: true));
    expect(find.text('Splash'), findsNothing);
  });

  testWidgets(
    'reduced motion removes splash immediately and can interrupt fade',
    (tester) async {
      await tester.pumpWidget(host());
      await tester.pumpWidget(host(ready: true));
      await tester.pump(const Duration(milliseconds: 160));
      await tester.pumpWidget(host(ready: true, reduced: true));
      expect(find.text('Splash'), findsNothing);
      expect(find.text('Today'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('retry restores splash; disposal cancels pending handoff', (
    tester,
  ) async {
    await tester.pumpWidget(host(ready: true));
    await tester.pumpAndSettle();
    await tester.pumpWidget(host());
    expect(find.text('Splash'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
    await tester.pumpWidget(host(ready: true));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
