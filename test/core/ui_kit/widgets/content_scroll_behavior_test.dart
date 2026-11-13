import 'package:asteria_app/core/ui_kit/widgets/content_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mobile scroll thumb decorates vertical content only', (
    tester,
  ) async {
    for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
      for (final direction in Axis.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            scrollBehavior: const ContentScrollBehavior(),
            home: ListView(
              scrollDirection: direction,
              children: const [SizedBox(width: 2000, height: 2000)],
            ),
          ),
        );
        final thumb = find.byType(RawScrollbar);
        if (direction == Axis.vertical) {
          expect(thumb, findsOneWidget);
          final widget = tester.widget<RawScrollbar>(thumb);
          expect(widget.interactive, isFalse);
          expect(widget.thickness, 3);
        } else {
          expect(thumb, findsNothing);
        }
      }
    }
  });

  testWidgets(
    'iOS vertical content stops at its bottom and can pull at the top',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          scrollBehavior: const ContentScrollBehavior(),
          home: ListView(
            controller: controller,
            children: const [SizedBox(height: 2000)],
          ),
        ),
      );
      final list = find.byType(ListView);
      final bottom = controller.position.maxScrollExtent;
      controller.jumpTo(bottom - 10);
      final drag = await tester.startGesture(tester.getCenter(list));
      await drag.moveBy(const Offset(0, -150));
      await tester.pump();
      expect(controller.offset, bottom);
      await drag.up();
      controller.jumpTo(0);
      final pull = await tester.startGesture(tester.getCenter(list));
      await pull.moveBy(const Offset(0, 150));
      await tester.pump();
      expect(controller.offset, lessThan(0));
      await pull.up();
      await tester.pumpAndSettle();
    },
  );
}
