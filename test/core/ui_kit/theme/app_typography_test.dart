import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final appTheme in [AppThemeLight.instance, AppThemeDark.instance]) {
    testWidgets(
      'Material and Cupertino inherit Asteria fonts in ${appTheme.runtimeType}',
      (tester) async {
        late BuildContext screen;
        await tester.pumpWidget(
          Builder(
            builder: (context) => MaterialApp(
              theme: appTheme.getThemeData(context),
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    screen = context;
                    return const Column(
                      children: [
                        Text('Обычный текст'),
                        TextField(decoration: InputDecoration(hintText: 'Имя')),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        final theme = Theme.of(screen);
        final ios = CupertinoTheme.of(screen).textTheme;
        final body = tester
            .widget<RichText>(
              find.descendant(
                of: find.text('Обычный текст'),
                matching: find.byType(RichText),
              ),
            )
            .text
            .style!;
        final input = tester
            .widget<EditableText>(find.byType(EditableText))
            .style;

        expect(body.fontFamily, AppTypography.bodyFamily);
        expect(input.fontFamily, AppTypography.bodyFamily);
        expect(
          theme.inputDecorationTheme.hintStyle?.fontFamily,
          AppTypography.bodyFamily,
        );
        expect(theme.inputDecorationTheme.hintStyle?.fontSize, 17);
        expect(
          theme.appBarTheme.titleTextStyle?.fontFamily,
          AppTypography.headingFamily,
        );
        expect(
          theme.textButtonTheme.style?.textStyle?.resolve({})?.fontFamily,
          AppTypography.bodyFamily,
        );
        expect(ios.actionTextStyle.fontFamily, AppTypography.bodyFamily);
        expect(ios.navTitleTextStyle.fontFamily, AppTypography.headingFamily);
        expect(ios.navLargeTitleTextStyle.fontSize, 34);
        expect(
          ios.dateTimePickerTextStyle.fontFamily,
          AppTypography.bodyFamily,
        );
        expect(
          theme.textTheme.headlineLarge?.fontFamily,
          AppTypography.headingFamily,
        );
        expect(theme.textTheme.headlineLarge?.fontSize, 32);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
