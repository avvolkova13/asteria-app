import 'package:asteria_app/core/ui_kit/widgets/lotus_glyph_motion.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Reduce Motion restores the resting artwork during a glyph pulse',
    (tester) async {
      final timeline = AnimationController(
        vsync: tester,
        duration: LotusMotionScope.duration,
      );
      addTearDown(timeline.dispose);
      const resting = Key('resting glyph');
      const moving = Key('illustrated pose');
      Widget render(bool reduced) => MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: LotusMotionScope(
          pulse: timeline,
          child: LotusGlyphMotion(
            frameBuilder: (frame) =>
                const SizedBox.square(key: moving, dimension: 24),
            child: const SizedBox.square(key: resting, dimension: 24),
          ),
        ),
      );

      await tester.pumpWidget(render(false));
      expect(find.byKey(resting), findsOneWidget);
      timeline.forward();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byKey(moving), findsOneWidget);
      await tester.pumpWidget(render(true));
      expect(find.byKey(moving), findsNothing);
      expect(find.byKey(resting), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.pumpWidget(render(false));
      expect(find.byKey(resting), findsOneWidget);
    },
  );
}
