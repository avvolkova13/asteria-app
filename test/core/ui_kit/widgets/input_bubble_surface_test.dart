import 'package:asteria_app/core/ui_kit/widgets/input_bubble_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'bubble preserves editing and next-field focus in $brightness',
      (tester) async {
        final first = FocusNode();
        final second = FocusNode();
        final text = TextEditingController();
        addTearDown(first.dispose);
        addTearDown(second.dispose);
        addTearDown(text.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: Scaffold(
              body: Column(
                children: [
                  InputBubbleSurface(
                    child: TextField(
                      key: const ValueKey('first'),
                      controller: text,
                      focusNode: first,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  InputBubbleSurface(
                    child: TextField(
                      key: const ValueKey('second'),
                      focusNode: second,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.byKey(const ValueKey('first')));
        await tester.enterText(find.byKey(const ValueKey('first')), 'Анна');
        await tester.pump(const Duration(milliseconds: 90));
        expect(first.hasFocus, isTrue);
        expect(text.text, 'Анна');
        await tester.pumpAndSettle();
        await tester.testTextInput.receiveAction(TextInputAction.next);
        await tester.pumpAndSettle();
        expect(second.hasFocus, isTrue);
        expect(first.hasFocus, isFalse);
        expect(text.text, 'Анна');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
