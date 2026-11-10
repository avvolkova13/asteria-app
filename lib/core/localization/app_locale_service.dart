import 'package:flutter/widgets.dart';

/// Resolves the locale used by Asteria before the widget tree and remote
/// content are initialized.
///
/// English is the global fallback. Russian is preserved for Russian devices,
/// while the priority English markets keep their country code so regional
/// formatting remains available.
class AppLocaleService extends ChangeNotifier with WidgetsBindingObserver {
  AppLocaleService({List<Locale>? platformLocales})
    : _platformLocales = List<Locale>.unmodifiable(
        platformLocales ?? WidgetsBinding.instance.platformDispatcher.locales,
      ),
      _effectiveLocale = resolveLocales(
        platformLocales ?? WidgetsBinding.instance.platformDispatcher.locales,
      );

  static const Locale russianLocale = Locale('ru');
  static const Locale globalEnglishLocale = Locale('en', 'US');

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'US'),
    Locale('en', 'CA'),
    Locale('en', 'GB'),
    Locale('en', 'AU'),
    russianLocale,
  ];

  static const Set<String> _regionalEnglishCountries = <String>{
    'US',
    'CA',
    'GB',
    'AU',
  };

  List<Locale> _platformLocales;
  Locale _effectiveLocale;
  bool _isObserving = false;

  List<Locale> get platformLocales => _platformLocales;
  Locale get effectiveLocale => _effectiveLocale;
  bool get isRussian => _effectiveLocale.languageCode == 'ru';
  bool get isGlobal => !isRussian;

  /// BCP-47 tag suitable for HTTP `Accept-Language`.
  String get languageTag {
    final countryCode = _effectiveLocale.countryCode;
    if (countryCode == null || countryCode.isEmpty) {
      return _effectiveLocale.languageCode;
    }
    return '${_effectiveLocale.languageCode}-$countryCode';
  }

  /// Base content language used by localized content fields and AI prompts.
  String get contentLanguage => isRussian ? 'ru' : 'en';

  void startObserving() {
    if (_isObserving) return;
    WidgetsBinding.instance.addObserver(this);
    _isObserving = true;
  }

  void stopObserving() {
    if (!_isObserving) return;
    WidgetsBinding.instance.removeObserver(this);
    _isObserving = false;
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    updatePlatformLocales(locales ?? const <Locale>[]);
  }

  @visibleForTesting
  void updatePlatformLocales(List<Locale> locales) {
    final nextLocales = List<Locale>.unmodifiable(locales);
    final nextEffectiveLocale = resolveLocales(nextLocales);
    _platformLocales = nextLocales;
    if (nextEffectiveLocale == _effectiveLocale) return;
    _effectiveLocale = nextEffectiveLocale;
    notifyListeners();
  }

  static Locale resolveLocales(List<Locale> locales) {
    for (final locale in locales) {
      final languageCode = locale.languageCode.toLowerCase();
      if (languageCode == 'ru') return russianLocale;
      if (languageCode != 'en') continue;

      final countryCode = locale.countryCode?.toUpperCase();
      if (countryCode != null &&
          _regionalEnglishCountries.contains(countryCode)) {
        return Locale('en', countryCode);
      }
      return globalEnglishLocale;
    }
    return globalEnglishLocale;
  }

  @override
  void dispose() {
    stopObserving();
    super.dispose();
  }
}
