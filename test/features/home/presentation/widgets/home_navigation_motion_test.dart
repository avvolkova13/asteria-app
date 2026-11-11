import 'package:asteria_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('switching tabs preserves input and mutes the hidden tab', (
    tester,
  ) async {
    final index = ValueNotifier(0);
    addTearDown(index.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: index,
            builder: (_, value, _) => HomeTabContents(
              index: value,
              children: const [
                TextField(key: Key('first')),
                TextField(key: Key('second')),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byKey(const Key('first')), 'saved value');
    final first = tester.element(find.byKey(const Key('first')));
    final second = tester.element(
      find.byKey(const Key('second'), skipOffstage: false),
    );
    expect(TickerMode.valuesOf(first).enabled, isTrue);
    expect(TickerMode.valuesOf(second).enabled, isFalse);
    double opacity(Element tab) =>
        tab.findAncestorWidgetOfExactType<Opacity>()!.opacity;
    index.value = 1;
    await tester.pump();
    expect(TickerMode.valuesOf(first).enabled, isFalse);
    expect(TickerMode.valuesOf(second).enabled, isTrue);
    await tester.pump(const Duration(milliseconds: 125));
    expect(opacity(first), 1);
    expect(opacity(second), inExclusiveRange(0, 1));
    final secondShare = opacity(second);
    index.value = 0;
    await tester.pump();
    // Retarget the same composite without flashing either page or the canvas.
    expect(opacity(second), 1);
    expect(opacity(first), closeTo(1 - secondShare, .001));
    await tester.pumpAndSettle();
    expect(tester.element(find.byKey(const Key('first'))), same(first));
    expect(find.text('saved value'), findsOneWidget);
    expect(opacity(first), 1);
    expect(opacity(second), 0);
  });
}
