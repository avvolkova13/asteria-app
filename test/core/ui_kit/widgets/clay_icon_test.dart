import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_glyph_motion.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_sprite.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a constrained slot displays exactly one atlas cell', (
    tester,
  ) async {
    for (final slot in [24.0, 16.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox.square(
              dimension: slot,
              child: const LotusSprite(LotusPose.play, size: 20, frame: 5),
            ),
          ),
        ),
      );
      final sprite = find.byType(LotusSprite);
      final clip = find.descendant(of: sprite, matching: find.byType(ClipRect));
      final plate = tester.renderObject<RenderBox>(clip);
      expect(plate.size, const Size.square(20));
      final visible =
          plate.localToGlobal(plate.size.bottomRight(Offset.zero)) -
          plate.localToGlobal(Offset.zero);
      expect(visible.dx, slot.clamp(0, 20));
      expect(visible.dy, slot.clamp(0, 20));
      expect(tester.getCenter(clip), tester.getCenter(sprite));
    }
  });

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
    'navigation uses the player atlas and keeps its direction during a pulse',
    (tester) async {
      final timeline = AnimationController(vsync: tester);
      addTearDown(timeline.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: LotusMotionScope(
              pulse: timeline,
              child: const ClayIcon(
                Icons.arrow_back_ios_new_rounded,
                size: 22,
                semanticLabel: 'Back',
              ),
            ),
          ),
        ),
      );
      final glyph = find.byType(LotusSprite);
      expect(tester.getSize(glyph), const Size.square(22));
      expect(tester.widget<LotusSprite>(glyph).pose, LotusPose.chevron);
      expect(tester.widget<LotusSprite>(glyph).flip, isTrue);
      expect(tester.widget<LotusSprite>(glyph).frame, 0);
      timeline.value = .5;
      await tester.pump();
      expect(tester.widget<LotusSprite>(glyph).frame, 8);
      expect(tester.widget<LotusSprite>(glyph).flip, isTrue);
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/affirmation/iconity-clay.webp',
      );
    },
  );

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
