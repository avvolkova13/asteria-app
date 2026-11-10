import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> readArb(String name) {
    final source = File('lib/core/localization/l10n/$name').readAsStringSync();
    return jsonDecode(source) as Map<String, dynamic>;
  }

  Set<String> messageKeys(Map<String, dynamic> arb) => arb.keys
      .where((key) => !key.startsWith('@') && key != '@@locale')
      .toSet();

  test('English and Russian ARB catalogs have identical message keys', () {
    final en = messageKeys(readArb('intl_en.arb'));
    final ru = messageKeys(readArb('intl_ru.arb'));

    expect(en.difference(ru), isEmpty, reason: 'Missing Russian keys');
    expect(ru.difference(en), isEmpty, reason: 'Missing English keys');
  });

  test('regional English catalogs only override base English keys', () {
    final base = messageKeys(readArb('intl_en.arb'));

    for (final name in const [
      'intl_en_US.arb',
      'intl_en_CA.arb',
      'intl_en_GB.arb',
      'intl_en_AU.arb',
    ]) {
      final regional = messageKeys(readArb(name));
      expect(
        regional.difference(base),
        isEmpty,
        reason: '$name contains keys missing from intl_en.arb',
      );
    }
  });
}
