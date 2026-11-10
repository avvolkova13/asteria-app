import 'package:asteria_app/core/localization/localized_content_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves exact locale, then base language', () {
    const resolver = LocalizedContentResolver();
    final document = <String, dynamic>{
      'title': 'Legacy',
      'i18n': {
        'title': {'ru': 'Русский', 'en': 'Color', 'en_GB': 'Colour'},
      },
    };

    expect(resolver.resolveDocument(document, 'en-GB')['title'], 'Colour');
    expect(resolver.resolveDocument(document, 'en-AU')['title'], 'Color');
  });

  test('falls back to Russian and reports it for English', () {
    final fallbacks = <String>[];
    final resolver = LocalizedContentResolver(
      onFallback: (field, requested, resolved) {
        fallbacks.add('$field:$requested:$resolved');
      },
    );

    final resolved = resolver.resolveDocument(<String, dynamic>{
      'title': 'Legacy',
      'i18n': {
        'title': {'ru': 'Русский'},
      },
    }, 'en-US');

    expect(resolved['title'], 'Русский');
    expect(fallbacks, ['title:en-US:ru']);
  });

  test('keeps the legacy flat field when no translation exists', () {
    const resolver = LocalizedContentResolver();
    final resolved = resolver.resolveDocument(<String, dynamic>{
      'title': 'Legacy',
      'i18n': {'title': <String, String>{}},
    }, 'en-US');

    expect(resolved['title'], 'Legacy');
  });
}
