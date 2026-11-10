import 'package:asteria_app/app/data/models/moon_phase/moon_phase_day_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps moon age day indexes to day-specific moon assets', () {
    expect(
      MoonPhaseDayImage.assetForLunarDay(0),
      'assets/images/moon_phase_days/day_00.webp',
    );
    expect(
      MoonPhaseDayImage.assetForLunarDay(1),
      'assets/images/moon_phase_days/day_01.webp',
    );
    expect(
      MoonPhaseDayImage.assetForLunarDay(14),
      'assets/images/moon_phase_days/day_14.webp',
    );
    expect(
      MoonPhaseDayImage.assetForLunarDay(29),
      'assets/images/moon_phase_days/day_29.webp',
    );
  });

  test('rejects indexes outside the supported 0-29 range', () {
    expect(() => MoonPhaseDayImage.assetForLunarDay(-1), throwsArgumentError);
    expect(() => MoonPhaseDayImage.assetForLunarDay(30), throwsArgumentError);
  });
}
