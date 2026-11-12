import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/custom_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/segmented_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const labels = ['Планеты', 'Дома и темы', 'Стихии'];
  for (final scale in [1.0, 1.6, 2.0]) {
    testWidgets('controls fit and remain tappable at text scale $scale', (
      tester,
    ) async {
      await (FontLoader('Onest')..addFont(
            rootBundle.load('assets/fonts/onest/Onest-VariableFont_wght.ttf'),
          ))
          .load();
      var selected = 0;
      var presses = 0;
      const action = 'Перейти к выбору даты рождения';
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 288,
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.linear(scale)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatefulBuilder(
                            builder: (context, update) =>
                                SegmentedPicker.indexed(
                                  titles: labels,
                                  selectedIndex: selected,
                                  onTabSelected: (value) =>
                                      update(() => selected = value),
                                ),
                          ),
                          CustomButton(
                            text: action,
                            isFullWidth: true,
                            icon: Icons.star,
                            onPressed: () => presses++,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final first = tester.getRect(find.text(labels.first));
      expect(first.height, lessThan(13 * scale * 1.2 + 2));
      if (scale == 1) {
        expect(first.center.dy, tester.getCenter(find.text(labels.last)).dy);
      }
      final button = tester.getRect(find.byType(ElevatedButton));
      final caption = tester.getRect(find.text(action));
      expect(button.contains(caption.topLeft), isTrue);
      expect(button.contains(caption.bottomRight), isTrue);
      await tester.tap(find.text(labels.last));
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      expect(selected, 2);
      expect(presses, 1);
    });
  }
}
