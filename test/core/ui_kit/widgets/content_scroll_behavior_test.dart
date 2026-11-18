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

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final contentHeight in [120.0, 2400.0]) {
      testWidgets(
        '$platform content $contentHeight cannot fling beyond the end',
        (tester) async {
          final controller = ScrollController();
          addTearDown(controller.dispose);
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(platform: platform),
              scrollBehavior: const ContentScrollBehavior(),
              home: ListView(
                controller: controller,
                children: [SizedBox(height: contentHeight)],
              ),
            ),
          );
          final end = controller.position.maxScrollExtent;
          controller.jumpTo(end > 50 ? end - 50 : 0);
          await tester.fling(
            find.byType(ListView),
            const Offset(0, -500),
            5000,
          );
          for (var frame = 0; frame < 90; frame++) {
            await tester.pump(const Duration(milliseconds: 16));
            expect(controller.offset, lessThanOrEqualTo(end + .01));
          }
          final drag = await tester.startGesture(
            tester.getCenter(find.byType(ListView)),
          );
          await drag.moveBy(const Offset(0, -300));
          await tester.pump();
          expect(controller.offset, lessThanOrEqualTo(end + .01));
          await drag.up();
          await tester.pumpAndSettle();
        },
      );
    }
  }

  testWidgets('switching from a long tab to a short tab removes stale offset', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    var height = 2400.0;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        scrollBehavior: const ContentScrollBehavior(),
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return SingleChildScrollView(
              controller: controller,
              child: SizedBox(height: height),
            );
          },
        ),
      ),
    );
    controller.jumpTo(controller.position.maxScrollExtent);
    update(() => height = 120);
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
    expect(controller.position.maxScrollExtent, 0);
  });

  testWidgets('horizontal carousels retain their native boundary feedback', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        scrollBehavior: const ContentScrollBehavior(),
        home: ListView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          children: const [SizedBox(width: 2400)],
        ),
      ),
    );
    final end = controller.position.maxScrollExtent;
    controller.jumpTo(end);
    final drag = await tester.startGesture(
      tester.getCenter(find.byType(ListView)),
    );
    await drag.moveBy(const Offset(-200, 0));
    await tester.pump();
    expect(controller.offset, greaterThan(end));
    await drag.up();
    await tester.pumpAndSettle();
  });
}
