import 'package:asteria_app/app/data/models/lunar_calendar/lunar_month_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses current lunar month contract', () {
    final month = LunarMonthModel.fromJson(_monthJson());
    final day = month.days.single;

    expect(month.year, 2026);
    expect(month.month, 8);
    expect(month.timezone, 'Europe/Saratov');
    expect(month.anchorLocalTime, '12:00');
    expect(day.lunarContext.lunarDayNumber, 2);
    expect(day.lunarContext.moonAgeDayIndex, 0);
    expect(day.dailyBackground.tone, PhaseTone.recovery);
    expect(day.spheres['gardening']?.status, RecommendationStatus.favorable);
  });

  test('rejects missing lunar_day_number instead of defaulting to zero', () {
    final json = _monthJson();
    (json['days'] as List).single['lunar_context'].remove('lunar_day_number');

    expect(() => LunarMonthModel.fromJson(json), throwsFormatException);
  });

  test('rejects out of range lunar_day_number', () {
    final json = _monthJson();
    (json['days'] as List).single['lunar_context']['lunar_day_number'] = 0;

    expect(() => LunarMonthModel.fromJson(json), throwsFormatException);
  });

  test('rejects an unknown phase tone', () {
    final json = _monthJson()
      ..['days'][0]['daily_background']['tone'] = 'lucky';

    expect(() => LunarMonthModel.fromJson(json), throwsFormatException);
  });

  test('rejects an unknown recommendation status', () {
    final json = _monthJson()
      ..['days'][0]['spheres']['gardening']['status'] = 'great';

    expect(() => LunarMonthModel.fromJson(json), throwsFormatException);
  });
}

Map<String, dynamic> _monthJson() {
  return {
    'year': 2026,
    'month': 8,
    'timezone': 'Europe/Saratov',
    'anchor_local_time': '12:00',
    'days': [
      {
        'date': '2026-08-13',
        'lunar_context': {
          'lunar_day_number': 2,
          'moon_age_days': 0.64,
          'moon_age_day_index': 0,
          'moon_phase_code': 'waxing_crescent',
          'moon_phase_name': 'Растущий серп',
          'moon_sign_code': 'cancer',
          'moon_sign_name': 'Рак',
          'phase_event': null,
        },
        'daily_background': {
          'tone': 'recovery',
          'title': 'Восстановление',
          'summary': 'Время восстановления и тишины.',
        },
        'spheres': {
          'gardening': {
            'status': 'favorable',
            'tasks': {
              'watering_and_fertilizing': {
                'status': 'neutral',
                'description': 'Полив без перегруза.',
              },
            },
          },
        },
      },
    ],
  };
}
