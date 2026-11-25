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

  /// Keeps time labels and pickers consistent with the locale and device clock.
  static bool uses24HourFormat(BuildContext context) {
    final format = MaterialLocalizations.of(context).timeOfDayFormat(
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return hourFormat(of: format) != HourFormat.h;
  }

  static DateTime startOfWeek(BuildContext context, DateTime date) {
    final first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final daysSinceStart =
        (date.weekday - first + DateTime.daysPerWeek) % DateTime.daysPerWeek;
    return DateTime.utc(date.year, date.month, date.day - daysSinceStart);
  }

  static String weekDateRange(DateTime start, Locale locale) {
    final end = start.add(const Duration(days: 6));
    final tag = _intlLocale(locale);
    if (start.year != end.year) {
      final date = DateFormat.yMMMd(tag);
      return '${date.format(start)} — ${date.format(end)}';
    }
    final dayMonth = DateFormat.MMMd(tag);
    if (start.month != end.month) {
      return '${dayMonth.format(start)} — ${dayMonth.format(end)}';
    }
    if (locale.languageCode == 'ru') {
      return '${start.day}–${DateFormat.MMMMd(tag).format(end)}';
    }
    final dayFirst = dayMonth.pattern?.startsWith('d') ?? false;
    return dayFirst
        ? '${start.day}–${dayMonth.format(end)}'
        : '${dayMonth.format(start)}–${end.day}';
  }

  static String _intlLocale(Locale locale) {
    final countryCode = locale.countryCode;
    return countryCode == null || countryCode.isEmpty
        ? locale.languageCode
        : '${locale.languageCode}_$countryCode';
  }
}
