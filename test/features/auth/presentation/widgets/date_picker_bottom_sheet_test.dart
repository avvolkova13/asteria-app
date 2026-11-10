import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/auth/presentation/widgets/date_picker_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('passes use24hFormat to the Cupertino time picker', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
        home: Builder(
          builder: (context) {
            return Theme(
              data: AppThemeLight.instance.getThemeData(context),
              child: Scaffold(
                body: DateTimePickerBottomSheet(
                  mode: CupertinoDatePickerMode.time,
                  initialDate: DateTime(0, 0, 0, 12, 0),
                  title: 'Выберите время рождения',
                  use24hFormat: true,
                  onDateChanged: (_) {},
                ),
              ),
            );
          },
        ),
      ),
    );

    final picker = tester.widget<CupertinoDatePicker>(
      find.byType(CupertinoDatePicker),
    );

    expect(picker.mode, CupertinoDatePickerMode.time);
    expect(picker.use24hFormat, isTrue);
  });
}
