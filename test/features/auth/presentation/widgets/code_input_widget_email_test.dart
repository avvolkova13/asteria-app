import 'package:asteria_app/features/auth/presentation/widgets/code_input_widget.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('accepts six digits without overflow at 320px width', (
    tester,
  ) async {
    String value = '';
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Theme(
            data: AppThemeLight.instance.getThemeData(context),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CodeInputWidget(
                  codeLength: 6,
                  onCodeEntered: (code) => value = code,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();

    expect(value, '123456');
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the default phone code length at four digits', (
    tester,
  ) async {
    String value = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Theme(
            data: AppThemeLight.instance.getThemeData(context),
            child: Scaffold(
              body: CodeInputWidget(onCodeEntered: (code) => value = code),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '123456');

    expect(value, '1234');
  });
}
