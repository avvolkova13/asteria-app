import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

/// Explains the language of a saved interpretation without altering the result.
Widget? savedResultLanguageNotice(BuildContext context, String? sourceLocale) {
  final language = Localizations.localeOf(context).languageCode;
  final source = sourceLocale?.toLowerCase().split(RegExp('[-_]')).first;
  final message = switch ((language, source)) {
    ('en', 'ru') => 'Showing the original result in Russian.',
    ('ru', 'en') => 'Показан оригинал на английском языке.',
    _ => null,
  };

  if (message == null) return null;

  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(message, style: context.textTheme.inverseUrbanistRegular14),
  );
}
