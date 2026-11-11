import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _tile = SizedBox.square(
  dimension: 32,
  child: ColoredBox(color: Color(0xff9f81b5)),
);

Widget _screen(Widget child, {bool reducedMotion = false}) => Directionality(
  textDirection: TextDirection.ltr,
  child: MediaQuery(
    data: MediaQueryData(disableAnimations: reducedMotion),
    child: Align(alignment: Alignment.topLeft, child: child),
  ),
);

List<OpacityLayer> _fades(WidgetTester tester) =>
    tester.layers.whereType<OpacityLayer>().toList();

void main() {
  testWidgets('only the first asynchronously decoded image frame enters', (
    tester,
  ) async {
    Widget frame(int? index, {bool cached = false}) => _screen(
      Builder(
        builder: (context) =>
            AsteriaEntrance.imageFrame(context, _tile, index, cached),
      ),
    );

    await tester.pumpWidget(frame(null));
    expect(_fades(tester), isEmpty);
    await tester.pumpWidget(frame(0));
    expect(_fades(tester).single.alpha, inExclusiveRange(0, 255));
    await tester.pumpAndSettle();
    await tester.pumpWidget(frame(1));
    expect(_fades(tester), isEmpty);
    await tester.pumpWidget(frame(0, cached: true));
    expect(_fades(tester), isEmpty);
  });

  testWidgets('fades and rises without moving the layout or tap target', (
    tester,
  ) async {
    var taps = 0;
    const target = Key('tap target');
    await tester.pumpWidget(
      _screen(
        AsteriaEntrance(
          child: GestureDetector(
            key: target,
            onTap: () => taps++,
            child: _tile,
          ),
        ),
      ),
    );

    final initial = _fades(tester).single;
    final startAlpha = initial.alpha!;
    final startY = initial.offset.dy;
    expect(startAlpha, inExclusiveRange(0, 255));
    expect(startY, AsteriaEntrance.distance);
    final layout = tester.getRect(find.byKey(target));
    await tester.tapAt(layout.topLeft + const Offset(1, 1));
    expect(taps, 1);

    await tester.pump();
    await tester.pump(AsteriaEntrance.duration ~/ 2);
    final middle = _fades(tester).single;
    expect(middle.alpha, inExclusiveRange(startAlpha, 255));
    expect(middle.offset.dy, inExclusiveRange(0, startY));
    await tester.pumpAndSettle();
    expect(_fades(tester), isEmpty);
    expect(tester.getRect(find.byKey(target)), layout);
  });

  testWidgets('coalesces nested reveals, then allows a later child to enter', (
    tester,
  ) async {
    Widget scene(bool insert) => _screen(
      AsteriaEntrance(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RepaintBoundary(child: AsteriaEntrance(child: _tile)),
            if (insert)
              const AsteriaEntrance(key: ValueKey('new'), child: _tile),
          ],
        ),
      ),
    );

    await tester.pumpWidget(scene(false));
    expect(_fades(tester), hasLength(1));
    await tester.pumpAndSettle();
    expect(_fades(tester), isEmpty);
    await tester.pumpWidget(scene(true));
    final inserted = _fades(tester).single;
    expect(inserted.alpha, inExclusiveRange(0, 255));
    expect(
      inserted.offset.dy,
      tester.getTopLeft(find.byKey(const ValueKey('new'))).dy +
          AsteriaEntrance.distance,
    );
    await tester.pumpAndSettle();
    expect(_fades(tester), isEmpty);
  });

  testWidgets('waits until a cached row enters and skips replay on return', (
    tester,
  ) async {
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await tester.pumpWidget(
      _screen(
        SizedBox(
          width: 160,
          height: 60,
          child: SingleChildScrollView(
            controller: scroll,
            child: const Column(
              children: [
                SizedBox(height: 180),
                RepaintBoundary(child: AsteriaEntrance(child: _tile)),
                SizedBox(height: 180),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AsteriaEntrance), findsOneWidget);
    await tester.pump(AsteriaEntrance.duration * 3);
    expect(_fades(tester), isEmpty);
    scroll.jumpTo(160);
    await tester.pump();
    expect(_fades(tester).single.alpha, inExclusiveRange(0, 255));
    await tester.pumpAndSettle();
    scroll.jumpTo(0);
    await tester.pump();
    scroll.jumpTo(160);
    await tester.pump();
    expect(_fades(tester), isEmpty);
  });

  testWidgets('zero-height content waits for its first visible layout', (
    tester,
  ) async {
    Widget section(double height) => _screen(
      AsteriaEntrance(
        child: SizedBox(width: 60, height: height, child: _tile),
      ),
    );
    await tester.pumpWidget(section(0));
    expect(_fades(tester), isEmpty);
    await tester.pumpAndSettle();
    await tester.pumpWidget(section(32));
    expect(_fades(tester).single.alpha, inExclusiveRange(0, 255));
    await tester.pumpAndSettle();
  });

  testWidgets('a cached row enters when its viewport grows without scrolling', (
    tester,
  ) async {
    const list = SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 100),
          RepaintBoundary(child: AsteriaEntrance(child: _tile)),
          SizedBox(height: 200),
        ],
      ),
    );
    Widget scene(double height) =>
        _screen(SizedBox(width: 60, height: height, child: list));

    await tester.pumpWidget(scene(60));
    await tester.pumpAndSettle();
    expect(_fades(tester), isEmpty);
    await tester.pumpWidget(scene(150));
    await tester.pump();
    expect(_fades(tester).single.alpha, inExclusiveRange(0, 255));
    await tester.pumpAndSettle();
  });

  testWidgets('a retained row enters when the section above collapses', (
    tester,
  ) async {
    Widget scene(double spacer) => _screen(
      SizedBox(
        height: 80,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: spacer),
              const RepaintBoundary(child: AsteriaEntrance(child: _tile)),
              SizedBox(height: 240 - spacer),
            ],
          ),
        ),
      ),
    );
    await tester.pumpWidget(scene(100));
    await tester.pumpAndSettle();
    expect(_fades(tester), isEmpty);
    await tester.pumpWidget(scene(40));
    await tester.pump();
    expect(_fades(tester).single.alpha, inExclusiveRange(0, 255));
    await tester.pumpAndSettle();
  });

  testWidgets('a row in a carousel waits for the enclosing feed viewport', (
    tester,
  ) async {
    final feed = ScrollController();
    addTearDown(feed.dispose);
    await tester.pumpWidget(
      _screen(
        SizedBox(
          width: 160,
          height: 60,
          child: SingleChildScrollView(
            controller: feed,
            child: Column(
              children: [
                const SizedBox(height: 180),
                SizedBox(
                  height: 40,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: const [
                        RepaintBoundary(child: AsteriaEntrance(child: _tile)),
                        SizedBox(width: 240),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 180),
              ],
            ),
          ),
        ),
      ),
    );
    expect(_fades(tester), isEmpty);
    await tester.pumpAndSettle();
    feed.jumpTo(160);
    await tester.pump();
    expect(_fades(tester).single.alpha, inExclusiveRange(0, 255));
    await tester.pumpAndSettle();
  });

  testWidgets('rebuild keeps settled content, new replay key restarts it', (
    tester,
  ) async {
    Widget scene(String key, double width) => _screen(
      AsteriaEntrance(
        replayKey: key,
        animateInitially: false,
        child: SizedBox(width: width, child: _tile),
      ),
    );
    await tester.pumpWidget(scene('first', 32));
    expect(_fades(tester), isEmpty);
    await tester.pumpWidget(scene('next', 32));
    expect(_fades(tester).single.alpha, inExclusiveRange(0, 255));
    await tester.pumpAndSettle();
    await tester.pumpWidget(scene('next', 48));
    expect(_fades(tester), isEmpty);
  });

  testWidgets(
    'Reduce Motion presents content immediately and ends active motion',
    (tester) async {
      Widget scene(bool reduce, String key) => _screen(
        AsteriaEntrance(replayKey: key, child: _tile),
        reducedMotion: reduce,
      );
      await tester.pumpWidget(scene(true, 'first'));
      expect(_fades(tester), isEmpty);
      await tester.pumpWidget(scene(false, 'first'));
      expect(_fades(tester), isEmpty);
      await tester.pumpWidget(scene(false, 'second'));
      expect(_fades(tester), hasLength(1));
      await tester.pumpWidget(scene(true, 'second'));
      expect(_fades(tester), isEmpty);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    },
  );
}
