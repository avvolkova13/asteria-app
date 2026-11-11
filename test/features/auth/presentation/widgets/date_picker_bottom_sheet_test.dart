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

  testWidgets(
    'cancel discards a scrolled date and select applies the next one once',
    (tester) async {
      final dates = <DateTime>[];
      final initial = DateTime(2000, 1, 15);
      await _pumpPickerRoute(
        tester,
        mode: CupertinoDatePickerMode.date,
        initial: initial,
        onDate: dates.add,
      );
      Future<void> openAndScroll() async {
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final wheel = find.byType(ListWheelScrollView).first;
        await tester.drag(wheel, const Offset(0, -88));
        await tester.pumpAndSettle();
      }

      await openAndScroll();
      final picker = tester.element(find.byType(CupertinoDatePicker));
      expect(CupertinoTheme.of(picker).brightness, Brightness.dark);
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(dates, isEmpty);
      await openAndScroll();
      await tester.tap(find.text('Выбрать'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoDatePicker), findsNothing);
      expect(dates, hasLength(1));
      expect(dates.single, isNot(initial));
    },
  );

  testWidgets(
    'time can be applied on a compact screen with large type and bottom insets',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      tester.view.viewInsets = const FakeViewPadding(bottom: 180);
      addTearDown(tester.view.reset);
      final times = <TimeOfDay>[];
      await _pumpPickerRoute(
        tester,
        mode: CupertinoDatePickerMode.time,
        initial: DateTime(2000, 1, 1, 14, 30),
        onDate: (_) => fail('Time selection should use onTimeChanged'),
        onTime: times.add,
        textScale: 2,
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Выбрать'));
      await tester.pumpAndSettle();
      final select = find.byType(ElevatedButton);
      expect(tester.getSize(select).height, greaterThanOrEqualTo(44));
      expect(tester.getRect(select).bottom, lessThanOrEqualTo(568 - 180));
      await tester.tap(select);
      await tester.pumpAndSettle();
      expect(times, const [TimeOfDay(hour: 14, minute: 30)]);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _pumpPickerRoute(
  WidgetTester tester, {
  required CupertinoDatePickerMode mode,
  required DateTime initial,
  required ValueChanged<DateTime> onDate,
  ValueChanged<TimeOfDay>? onTime,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocaleService.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => DateTimePickerBottomSheet(
                  title: mode == CupertinoDatePickerMode.time
                      ? 'Выберите время рождения'
                      : 'Выберите дату рождения',
                  mode: mode,
                  initialDate: initial,
                  use24hFormat: true,
                  onDateChanged: onDate,
                  onTimeChanged: onTime,
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
}
