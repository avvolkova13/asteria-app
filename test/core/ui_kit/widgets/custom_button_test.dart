import 'package:asteria_app/core/extensions/build_context_extensions.dart';
import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final appTheme in [AppThemeLight.instance, AppThemeDark.instance]) {
    for (final type in CustomButtonType.values) {
      testWidgets(
        '${appTheme.runtimeType} $type label follows enabled and disabled colors',
        (tester) async {
          const label = 'Продолжить';
          const explicitColor = Color(0xFFFFCF73);
          late BuildContext screen;
          var presses = 0;

          Future<void> show({required bool enabled, Color? textColor}) async {
            await tester.pumpWidget(
              MaterialApp(
                home: Builder(
                  builder: (context) => Theme(
                    data: appTheme.getThemeData(context),
                    child: Scaffold(
                      body: Builder(
                        builder: (context) {
                          screen = context;
                          return Center(
                            // A label must inherit the button's resolved color,
                            // even when the surrounding screen uses another one.
                            child: DefaultTextStyle(
                              style: const TextStyle(color: Color(0xFF00AA44)),
                              child: CustomButton(
                                text: label,
                                type: type,
                                textColor: textColor,
                                onPressed: enabled ? () => presses++ : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
          }

          Color? renderedLabelColor() {
            final richText = tester.widget<RichText>(
              find.descendant(
                of: find.text(label),
                matching: find.byType(RichText),
              ),
            );
            return richText.text.style?.color;
          }

          await show(enabled: true);
          final colors = screen.colors;
          final activeColor = type == CustomButtonType.text
              ? colors.customButtonOutlineText
              : AppColors.white;
          final disabledColor = type == CustomButtonType.text
              ? colors.customButtonDisabledText
              : AppColors.white;
          expect(renderedLabelColor(), activeColor);
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
          expect(presses, 1);

          await show(enabled: false);
          expect(renderedLabelColor(), disabledColor);
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
          expect(presses, 1);

          await show(enabled: true, textColor: explicitColor);
          expect(
            renderedLabelColor(),
            type == CustomButtonType.text ? explicitColor : AppColors.white,
          );

          await show(enabled: false, textColor: explicitColor);
          expect(renderedLabelColor(), disabledColor);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
