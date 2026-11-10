import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/auth/presentation/widgets/date_time_picker_widget.dart';
import 'package:asteria_app/core/localization/locale_formatters.dart';
import 'package:flutter/material.dart';

String formatDate(
  BuildContext context,
  DateTime? date,
  String? birthDateLabel,
) {
  if (date == null) return birthDateLabel ?? '';
  return LocaleFormatters.longDate(date, Localizations.localeOf(context));
}

String formatTime(
  BuildContext context,
  TimeOfDay? time,
  String? birthTimeLabel,
) {
  if (time == null) return birthTimeLabel ?? '';
  return LocaleFormatters.timeOfDay(context, time);
}

Widget buildDateTimeField({
  required BuildContext context,
  required String? text,
  required String hintText,
  required VoidCallback onTap,
  required bool isSelected,
  required Key key,
  bool isEnabled = true,
}) {
  return LotusTap(
    onTap: isEnabled ? onTap : null,
    child: DateTimePickerWidget(key: key, text: text, hintText: hintText),
  );
}

String formatDateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
