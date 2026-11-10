import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract final class LocaleFormatters {
  static String shortDate(DateTime date, Locale locale) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');

    if (locale.languageCode == 'ru') return '$day.$month.$year';
    if (locale.languageCode == 'en' && locale.countryCode == 'US') {
      return '$month/$day/$year';
    }
    if (locale.languageCode == 'en' &&
        const <String>{'CA', 'GB', 'AU'}.contains(locale.countryCode)) {
      return '$day/$month/$year';
    }
    return '$month/$day/$year';
  }

  static String mediumDate(DateTime date, Locale locale) {
    return DateFormat.yMMMd(_intlLocale(locale)).format(date);
  }

  static String longDate(DateTime date, Locale locale) {
    return DateFormat.yMMMMd(_intlLocale(locale)).format(date);
  }

  static String dayMonth(DateTime date, Locale locale) {
    return DateFormat.MMMd(_intlLocale(locale)).format(date);
  }

  static String monthYear(DateTime date, Locale locale) {
    return DateFormat.yMMMM(_intlLocale(locale)).format(date);
  }

  static String timeOfDay(BuildContext context, TimeOfDay time) {
    return MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(time, alwaysUse24HourFormat: uses24HourFormat(context));
  }

  /// Keeps time labels and pickers consistent. US English always uses AM/PM;
  /// other locales retain their locale default and system 24-hour override.
  static bool uses24HourFormat(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'en' && locale.countryCode == 'US') {
      return false;
    }
    final format = MaterialLocalizations.of(context).timeOfDayFormat(
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return hourFormat(of: format) != HourFormat.h;
  }

  static String _intlLocale(Locale locale) {
    final countryCode = locale.countryCode;
    return countryCode == null || countryCode.isEmpty
        ? locale.languageCode
        : '${locale.languageCode}_$countryCode';
  }
}
