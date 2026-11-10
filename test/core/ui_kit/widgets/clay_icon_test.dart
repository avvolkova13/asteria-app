import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a platform action keeps its layout, theme and accessible name', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: IconTheme(
            data: IconThemeData(size: 32, color: Colors.orange),
            child: ClayIcon(CupertinoIcons.search, semanticLabel: 'Search'),
          ),
        ),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(find.byIcon(CupertinoIcons.search), findsOneWidget);
    expect(find.bySemanticsLabel('Search'), findsOneWidget);
    expect(tester.getSize(find.byType(Image)), const Size.square(32));
    expect(image.color, Colors.orange);
    expect(image.colorBlendMode, BlendMode.modulate);
  });

  testWidgets('single-dimension vector controls keep their intrinsic ratio', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ClayAssetIcon(
            'assets/icons/back_icon.svg',
            height: 32,
            tint: Colors.white54,
            semanticsLabel: 'Back',
          ),
        ),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(tester.getSize(find.byType(Image)), const Size(24, 32));
    expect(image.color, Colors.white54);
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
  });
  testWidgets(
    'press feedback leaves the tap with its parent and respects reduced motion',
    (tester) async {
      var taps = 0;
      Widget button({required bool reduced}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: Center(
            child: GestureDetector(
              onTap: () => taps++,
              child: const ClayPressFeedback(child: ClayIcon(Icons.play_arrow)),
            ),
          ),
        ),
      );
      await tester.pumpWidget(button(reduced: false));
      final target = find.byIcon(Icons.play_arrow);
      final motion = find.descendant(
        of: find.byType(ClayPressFeedback),
        matching: find.byType(Transform),
      );
      final finger = await tester.startGesture(tester.getCenter(target));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 72));
      expect(
        tester.widget<Transform>(motion).transform.storage[0],
        closeTo(.97, .001),
      );
      await finger.up();
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(tester.widget<Transform>(motion).transform.storage[0], 1);
      await tester.pumpWidget(button(reduced: true));
      expect(motion, findsNothing);
      await tester.tap(target);
      expect(taps, 2);
    },
  );
}
