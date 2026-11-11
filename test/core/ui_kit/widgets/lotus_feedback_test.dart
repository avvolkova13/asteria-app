import 'dart:ui' show SemanticsAction;

import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_glyph_motion.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_inline_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final haptics = <Object?>[];
  setUp(() {
    haptics.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments);
          }
          return null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null),
  );

  Widget screen(Widget content, {bool reduceMotion = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(body: Center(child: content)),
    ),
  );
  double scale(WidgetTester tester, Finder target) {
    final transform = find
        .ancestor(of: target, matching: find.byType(Transform))
        .first;
    return tester.widget<Transform>(transform).transform.entry(0, 0);
  }

  testWidgets('only the winning nested action moves and sends one selection', (
    tester,
  ) async {
    final calls = <String>[];
    await tester.pumpWidget(
      screen(
        LotusTap(
          onTap: () => calls.add('outer'),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: LotusTap(
              onTap: () => calls.add('inner'),
              child: const Text('Inner'),
            ),
          ),
        ),
      ),
    );
    final target = find.text('Inner');
    final finger = await tester.startGesture(tester.getCenter(target));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    expect(scale(tester, target), closeTo(.96, .001));
    final outer = find
        .ancestor(of: target, matching: find.byType(Transform))
        .last;
    expect(tester.widget<Transform>(outer).transform.entry(0, 0), 1);
    expect(haptics, isEmpty);
    await finger.up();
    await tester.pumpAndSettle();
    expect(calls, ['inner']);
    expect(haptics, ['HapticFeedbackType.selectionClick']);
    expect(scale(tester, target), 1);
  });

  testWidgets(
    'artwork responds during contact without firing on a cancelled press',
    (tester) async {
      const artKey = Key('glyph');
      await tester.pumpWidget(
        screen(
          LotusTap(
            onTap: () {},
            child: const LotusGlyphMotion(
              child: SizedBox.square(key: artKey, dimension: 32),
            ),
          ),
        ),
      );
      final art = find.byKey(artKey);
      final origin = tester.getRect(art);
      final finger = await tester.startGesture(origin.center);
      await tester.pump();
      await tester.pump(LotusMotionScope.pressDuration);
      final held = tester.getRect(art);
      expect(held.height / origin.height, lessThan(held.width / origin.width));
      expect(haptics, isEmpty);
      await finger.cancel();
      await tester.pumpAndSettle();
      expect(tester.getRect(art), origin);
      expect(haptics, isEmpty);
    },
  );

  testWidgets(
    'inline links clear their highlight on cancellation and acknowledge only activation',
    (tester) async {
      var visits = 0;
      await tester.pumpWidget(screen(_TestLink(onOpen: () => visits++)));
      final target = find.text('Read', findRichText: true);
      Color? highlight() => (tester.widget<RichText>(target).text as TextSpan)
          .style
          ?.backgroundColor;
      final finger = await tester.startGesture(tester.getCenter(target));
      await tester.pump(const Duration(milliseconds: 200));
      expect(highlight(), isNotNull);
      expect(haptics, isEmpty);
      await finger.cancel();
      await tester.pumpAndSettle();
      expect(highlight(), isNull);
      expect(visits, 0);
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(visits, 1);
      expect(haptics, ['HapticFeedbackType.selectionClick']);
    },
  );

  testWidgets(
    'reduced motion still acknowledges contact, cancel and a quick tap',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        screen(
          LotusTap(onTap: () => calls++, child: const Text('Action')),
          reduceMotion: true,
        ),
      );
      final target = find.text('Action');
      bool dimmed() => find
          .ancestor(
            of: target,
            matching: find.byWidgetPredicate(
              (w) => w is Opacity && w.opacity < 1,
            ),
          )
          .evaluate()
          .isNotEmpty;
      final finger = await tester.startGesture(tester.getCenter(target));
      await tester.pump();
      expect(dimmed(), isTrue);
      expect(scale(tester, target), 1);
      await finger.cancel();
      await tester.pump();
      expect(dimmed(), isFalse);
      expect(haptics, isEmpty);
      await tester.tap(target);
      await tester.pump();
      expect(dimmed(), isTrue);
      expect(scale(tester, target), 1);
      expect(calls, 1);
      expect(haptics, ['HapticFeedbackType.selectionClick']);
      await tester.pump(const Duration(milliseconds: 200));
      expect(dimmed(), isFalse);
    },
  );

  testWidgets('scroll, cancellation and disabled controls stay silent', (
    tester,
  ) async {
    var count = 0;
    await tester.pumpWidget(
      screen(
        ListView(
          children: [
            LotusTap(
              onTap: () => count++,
              child: const SizedBox(height: 110, child: Text('Drag')),
            ),
            const LotusTap(
              onTap: null,
              child: SizedBox(height: 100, child: Text('Disabled')),
            ),
            const SizedBox(height: 1200),
          ],
        ),
      ),
    );
    final target = find.text('Drag');
    final finger = await tester.startGesture(tester.getCenter(target));
    await finger.cancel();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disabled'));
    await tester.drag(target, const Offset(0, -85));
    await tester.pumpAndSettle();
    expect(count, 0);
    expect(haptics, isEmpty);
  });

  testWidgets('keyboard activation gives a visible pulse and one selection', (
    tester,
  ) async {
    var count = 0;
    await tester.pumpWidget(
      screen(LotusTap(onTap: () => count++, child: const Text('Action'))),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 65));
    expect(count, 1);
    expect(haptics, hasLength(1));
    expect(scale(tester, find.text('Action')), lessThan(1));
    await tester.pumpAndSettle();
    expect(scale(tester, find.text('Action')), 1);
  });

  testWidgets(
    'Reduce Motion keeps geometry stable and accessibility activation works',
    (tester) async {
      var count = 0;
      await tester.pumpWidget(
        screen(
          LotusFeedback(
            onActivate: () => count++,
            builder: (activate) => Semantics(
              button: true,
              label: 'Open',
              excludeSemantics: true,
              onTap: activate,
              child: GestureDetector(
                onTap: activate,
                child: const Text('Content'),
              ),
            ),
          ),
          reduceMotion: true,
        ),
      );
      final target = find.text('Content');
      final finger = await tester.startGesture(tester.getCenter(target));
      await tester.pump(const Duration(milliseconds: 90));
      expect(scale(tester, target), 1);
      await finger.up();
      await tester.pump(const Duration(milliseconds: 65));
      expect(scale(tester, target), 1);
      final semantics = tester.getSemantics(find.bySemanticsLabel('Open'));
      expect(count, 1);
      semantics.owner!.performAction(semantics.id, SemanticsAction.tap);
      await tester.pump();
      expect(count, 2);
      expect(haptics, hasLength(2));
    },
  );
}

class _TestLink extends StatefulWidget {
  const _TestLink({required this.onOpen});
  final VoidCallback onOpen;
  @override
  State<_TestLink> createState() => _TestLinkState();
}

class _TestLinkState extends State<_TestLink> with LotusInlineLinks<_TestLink> {
  @override
  Widget build(BuildContext context) => RichText(
    text: linkSpan(
      id: 'terms',
      text: 'Read',
      style: const TextStyle(color: Colors.black),
      onTap: widget.onOpen,
    ),
  );
}
