import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/localization/locale_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final date = DateTime(2026, 8, 7);

  test('formats numeric dates by locale', () {
    expect(
      LocaleFormatters.shortDate(date, const Locale('en', 'US')),
      '08/07/2026',
    );
    expect(
      LocaleFormatters.shortDate(date, const Locale('en', 'CA')),
      '07/08/2026',
    );
    expect(
      LocaleFormatters.shortDate(date, const Locale('en', 'GB')),
      '07/08/2026',
    );
    expect(
      LocaleFormatters.shortDate(date, const Locale('en', 'AU')),
      '07/08/2026',
    );
    expect(LocaleFormatters.shortDate(date, const Locale('ru')), '07.08.2026');
    expect(date.toIsoDate(), '2026-08-07');
  });

  testWidgets('en-US always uses AM/PM including midnight and noon', (
    tester,
  ) async {
    Future<String> renderTime({
      required bool use24Hour,
      required TimeOfDay time,
      Locale locale = const Locale('en', 'US'),
    }) async {
      late String formatted;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('en', 'GB'),
            Locale('en', 'CA'),
            Locale('en', 'AU'),
            Locale('ru'),
          ],
          home: MediaQuery(
            data: MediaQueryData(alwaysUse24HourFormat: use24Hour),
            child: Builder(
              builder: (context) {
                formatted = LocaleFormatters.timeOfDay(context, time);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      return formatted;
    }

    for (final use24Hour in [false, true]) {
      for (final entry in <TimeOfDay, String>{
        const TimeOfDay(hour: 0, minute: 0): '12:00 AM',
        const TimeOfDay(hour: 9, minute: 5): '9:05 AM',
        const TimeOfDay(hour: 12, minute: 0): '12:00 PM',
        const TimeOfDay(hour: 17, minute: 5): '5:05 PM',
        const TimeOfDay(hour: 23, minute: 59): '11:59 PM',
      }.entries) {
        expect(
          await renderTime(use24Hour: use24Hour, time: entry.key),
          entry.value,
        );
      }
    }
    for (final locale in [const Locale('ru'), const Locale('en', 'GB')]) {
      for (final use24Hour in [false, true]) {
        expect(
          await renderTime(
            locale: locale,
            use24Hour: use24Hour,
            time: const TimeOfDay(hour: 17, minute: 5),
          ),
          '17:05',
        );
      }
    }
    for (final locale in [const Locale('en', 'CA'), const Locale('en', 'AU')]) {
      expect(
        await renderTime(
          locale: locale,
          use24Hour: false,
          time: const TimeOfDay(hour: 17, minute: 5),
        ),
        '5:05 PM',
      );
      expect(
        await renderTime(
          locale: locale,
          use24Hour: true,
          time: const TimeOfDay(hour: 17, minute: 5),
        ),
        '17:05',
      );
    }
  });
}
