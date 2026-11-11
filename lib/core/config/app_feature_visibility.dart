/// Product visibility gates. Keep stored user content and feature code intact.
abstract final class AppFeatureVisibility {
  static const bool horoscopes = false;

  /// Recognise product-owned names, including Russian inflections, English
  /// plurals and backend identifiers such as weekly_horoscope.
  static bool containsHoroscope(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('гороскоп') || normalized.contains('horoscop');
  }
}
