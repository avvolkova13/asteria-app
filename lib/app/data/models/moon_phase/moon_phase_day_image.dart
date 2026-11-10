class MoonPhaseDayImage {
  const MoonPhaseDayImage._();

  static String resolve(int moonAgeDayIndex) {
    final imageIndex = imageIndexForMoonAgeDayIndex(moonAgeDayIndex);
    return 'assets/images/moon_phase_days/day_${imageIndex.toString().padLeft(2, '0')}.webp';
  }

  static String assetForLunarDay(int moonAgeDayIndex) {
    return resolve(moonAgeDayIndex);
  }

  static int imageIndexForMoonAgeDayIndex(int moonAgeDayIndex) {
    if (moonAgeDayIndex < 0 || moonAgeDayIndex > 29) {
      throw ArgumentError.value(
        moonAgeDayIndex,
        'moonAgeDayIndex',
        'Expected moon age day index in range 0..29',
      );
    }

    return moonAgeDayIndex;
  }
}
