import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/features/auth/presentation/widgets/radio_button_group.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/custom_checkbox.dart';
import 'package:asteria_app/core/ui_kit/widgets/purchase_offer_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/settings_list_tile.dart';
import 'package:asteria_app/core/ui_kit/widgets/text_input_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {bool dark = true, double textScale = 1}) =>
    MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocaleService.supportedLocales,
      builder: (context, child) => Theme(
        data: (dark ? AppThemeDark.instance : AppThemeLight.instance)
            .getThemeData(context),
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );

void main() {
  testWidgets(
    'clear works at the edge of a 44 point target and reports the empty value',
    (tester) async {
      final controller = TextEditingController(text: 'Стрижка');
      addTearDown(controller.dispose);
      var clears = 0;
      final changes = <String>[];
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, setState) => TextInputFieldWidget(
              controller: controller,
              showClearButton: true,
              onClear: () => clears++,
              onChanged: (value) {
                changes.add(value);
                setState(() {});
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final target = find.byTooltip('Очистить');
      expect(target, findsOneWidget);
      final rect = tester.getRect(target);
      expect(rect.width, greaterThanOrEqualTo(44));
      expect(rect.height, greaterThanOrEqualTo(44));
      await tester.tapAt(rect.topLeft + const Offset(3, 3));
      await tester.pumpAndSettle();
      expect(controller.text, isEmpty);
      expect(clears, 1);
      expect(changes, ['']);
      expect(find.byTooltip('Очистить'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'checkbox label and keyboard toggle once and disabled control stays unchanged',
    (tester) async {
      var value = false;
      var enabled = true;
      var changes = 0;
      late StateSetter update;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return CustomCheckbox(
                value: value,
                label: 'Запомнить выбор',
                onChanged: enabled
                    ? (next) {
                        setState(() {
                          value = next;
                          changes++;
                        });
                      }
                    : null,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Запомнить выбор'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(changes, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(value, isFalse);
      expect(changes, 2);
      update(() {
        enabled = false;
      });
      await tester.pumpAndSettle();
      await tester.tap(find.text('Запомнить выбор'));
      await tester.pumpAndSettle();
      expect(changes, 2);
    },
  );

  testWidgets(
    'birth-time choices wrap and preserve disabled behavior with large text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 700);
      addTearDown(tester.view.reset);
      var selected = TimeOfDayEnum.morning;
      var enabled = true;
      var changes = 0;
      late StateSetter update;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return RadioButtonGroup(
                selectedValue: selected,
                isEnabled: enabled,
                onChanged: (value) {
                  setState(() {
                    selected = value;
                    changes++;
                  });
                },
              );
            },
          ),
          textScale: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final choices = find.byType(Text);
      await tester.tap(choices.at(1));
      await tester.pumpAndSettle();
      expect(selected, TimeOfDayEnum.unknown);
      expect(changes, 1);
      update(() {
        enabled = false;
      });
      await tester.pumpAndSettle();
      await tester.tap(choices.at(2));
      await tester.pumpAndSettle();
      expect(selected, TimeOfDayEnum.unknown);
      expect(changes, 1);
      expect(tester.takeException(), isNull);
    },
  );

  for (final dark in [false, true]) {
    testWidgets(
      'reusable actions fit long labels at 320 points in ${dark ? 'dark' : 'light'} appearance',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 900);
        addTearDown(tester.view.reset);
        for (final font in [
          ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
          ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
        ]) {
          await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
        }
        var actions = 0;
        final boundary = GlobalKey();
        await tester.pumpWidget(
          app(
            RepaintBoundary(
              key: boundary,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsListTile(
                    title: 'Настройки уведомлений приложения',
                    icon: 'repeat_icon',
                    onTap: () => actions++,
                  ),
                  const SizedBox(height: 16),
                  PurchaseOfferButton(
                    buttonText: 'Дополнительный расклад',
                    purchaseName: 'Таро',
                    purchaseIcon: 'star_coin_icon',
                    onTap: () => actions++,
                  ),
                  const SizedBox(height: 16),
                  CustomCheckbox(
                    value: true,
                    label: 'Сохранить выбранные настройки',
                    onChanged: (_) => actions++,
                  ),
                  const SizedBox(height: 16),
                  const CustomCheckbox(
                    value: false,
                    label: 'Недоступный выбор',
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Сохранить изменения',
                    onPressed: () => actions++,
                  ),
                  const SizedBox(height: 16),
                  const CustomButton(text: 'Сохранить изменения'),
                ],
              ),
            ),
            dark: dark,
            textScale: 1.6,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Настройки уведомлений приложения'));
        await tester.tap(find.text('Таро Дополнительный расклад'));
        await tester.tap(find.text('Сохранить выбранные настройки'));
        await tester.tap(find.text('Сохранить изменения').first);
        await tester.pumpAndSettle();
        expect(actions, 4);
        // Optional local render for a visual audit, never a fixture dependency.
        if (Platform.environment['ASTERIA_BUTTON_AUDIT_IMAGES'] == '1') {
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await render.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              '/private/tmp/asteria-buttons-${dark ? 'dark' : 'light'}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      },
    );
  }
}
