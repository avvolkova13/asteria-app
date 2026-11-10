import 'package:flutter/foundation.dart';

typedef LocalizedFallbackLogger =
    void Function(String field, String requestedLocale, String resolvedLocale);

/// Resolves the additive `i18n` shape while preserving compatibility
/// with legacy documents that only contain flat Russian fields.
class LocalizedContentResolver {
  const LocalizedContentResolver({this.onFallback});

  final LocalizedFallbackLogger? onFallback;

  Map<String, dynamic> resolveDocument(
    Map<String, dynamic> document,
    String localeTag,
  ) {
    final resolved = Map<String, dynamic>.from(document);
    final rawI18n = document['i18n'];
    if (rawI18n is! Map) return resolved;

    final i18n = Map<String, dynamic>.from(rawI18n);
    for (final entry in i18n.entries) {
      if (entry.value is! Map) continue;
      final translations = Map<String, dynamic>.from(entry.value as Map);
      final selection = _select(translations, localeTag);
      if (selection == null) continue;
      resolved[entry.key] = selection.value;
      if (selection.locale == 'ru' && !_isRussian(localeTag)) {
        if (onFallback != null) {
          onFallback!(entry.key, localeTag, selection.locale);
        } else {
          _debugFallback(
            entry.key,
            localeTag,
            selection.locale,
            documentId: document['id']?.toString(),
          );
        }
      }
    }
    return resolved;
  }

  _LocalizedSelection? _select(
    Map<String, dynamic> translations,
    String localeTag,
  ) {
    final normalized = localeTag.replaceAll('_', '-');
    final exactCandidates = <String>{
      normalized,
      normalized.replaceAll('-', '_'),
      normalized.toLowerCase(),
    };
    for (final key in exactCandidates) {
      if (_hasValue(translations[key])) {
        return _LocalizedSelection(key, translations[key]);
      }
    }

    final baseLanguage = normalized.split('-').first.toLowerCase();
    if (_hasValue(translations[baseLanguage])) {
      return _LocalizedSelection(baseLanguage, translations[baseLanguage]);
    }
    if (_hasValue(translations['ru'])) {
      return _LocalizedSelection('ru', translations['ru']);
    }
    return null;
  }

  bool _hasValue(Object? value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is Iterable) return value.isNotEmpty;
    return true;
  }

  bool _isRussian(String localeTag) =>
      localeTag.toLowerCase().replaceAll('_', '-').split('-').first == 'ru';

  static void _debugFallback(
    String field,
    String requestedLocale,
    String resolvedLocale, {
    String? documentId,
  }) {
    debugPrint(
      '[ContentI18n] fallback document=${documentId ?? 'unknown'} '
      'field=$field requested=$requestedLocale '
      'resolved=$resolvedLocale',
    );
  }
}

class _LocalizedSelection {
  const _LocalizedSelection(this.locale, this.value);

  final String locale;
  final dynamic value;
}
