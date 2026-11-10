import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/localization/localized_display_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('zodiac sign display names use language neutral sign code', () async {
    final en = await AppLocalizations.load(const Locale('en', 'US'));
    expect(en.zodiacSignName('leo'), 'Leo');

    final ru = await AppLocalizations.load(const Locale('ru'));
    expect(ru.zodiacSignName('leo'), 'Лев');
  });
}
