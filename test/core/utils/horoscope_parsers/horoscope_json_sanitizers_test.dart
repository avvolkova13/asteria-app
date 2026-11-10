import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_json_sanitizers.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_day_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daily horoscope sanitizer opens free day sections by default', () {
    final sanitized = sanitizeDayHoroscopeJson(_rawDayJson());

    expect(sanitized['is_key_theme_opened'], isTrue);
    expect(sanitized['is_weakness_opened'], isTrue);
  });

  test('daily horoscope sanitizer ignores stale closed day section flags', () {
    final sanitized = sanitizeDayHoroscopeJson({
      ..._rawDayJson(),
      'is_key_theme_opened': false,
      'is_weakness_opened': false,
    });

    expect(sanitized['is_key_theme_opened'], isTrue);
    expect(sanitized['is_weakness_opened'], isTrue);
  });

  test(
    'daily horoscope model treats persisted closed section flags as open',
    () {
      final day = HoroscopeDayModel.fromJson({
        ..._rawDayJson(),
        'date_until': DateTime(2026, 9, 9).toIso8601String(),
        'is_key_theme_opened': false,
        'is_weakness_opened': false,
      });

      expect(day.isKeyThemeOpened, isTrue);
      expect(day.isWeaknessOpened, isTrue);
    },
  );
}

Map<String, dynamic> _rawDayJson() {
  return {
    'focus': 'Общение и укрепление связей.',
    'risk': 'Избегайте поспешных решений.',
    'personal_area': _area(),
    'personal_weak_points': [_weakPoint()],
    'personal_area_persentage': '71%',
    'love_area': _area(themeTitle: 'Тема отношений'),
    'love_weak_points': [_weakPoint()],
    'love_area_persentage': '89%',
    'finance_area': _area(),
    'finance_weak_points': [_weakPoint()],
    'finance_area_persentage': '64%',
    'spotlight': 'В центре внимания — отношения',
  };
}

Map<String, dynamic> _area({String themeTitle = 'Тема баланса'}) {
  return {
    'key_theme': 'Баланс',
    'theme_title': themeTitle,
    'description': 'Описание баланса',
  };
}

Map<String, dynamic> _weakPoint() {
  return {'title': 'Слабое место', 'description': 'Описание слабого места.'};
}
