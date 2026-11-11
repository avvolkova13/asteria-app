import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
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
    final entrance = tester.element(find.byType(AsteriaEntrance));
    expect((entrance.widget as AsteriaEntrance).animateInitially, isTrue);
    index.value = 1;
    await tester.pump();
    expect(TickerMode.valuesOf(first).enabled, isFalse);
    expect(TickerMode.valuesOf(second).enabled, isTrue);
    expect((entrance.widget as AsteriaEntrance).replayKey, 1);
    index.value = 0;
    await tester.pumpAndSettle();
    expect(tester.element(find.byKey(const Key('first'))), same(first));
    expect(find.text('saved value'), findsOneWidget);
    expect((entrance.widget as AsteriaEntrance).replayKey, 0);
  });
}
