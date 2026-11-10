import 'package:asteria_app/app/data/models/energy_of_day/energy_of_day_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes the current API response without the retired lunar day', () {
    final energy = EnergyOfDayModel.fromJson(_payload);

    expect(energy.date, DateTime(2026, 9, 14));
    expect(energy.focusPercentage, '85%');
    expect(energy.riskPercentage, '27%');
    expect(energy.phrase, 'Ясность и гармония дня');
  });

  test('reads legacy cache and writes only the current content fields', () {
    final energy = EnergyOfDayModel.fromJson({..._payload, 'lunar_day': 5});
    final cached = energy.toJson();

    expect(cached.containsKey('lunar_day'), isFalse);
    expect(EnergyOfDayModel.fromJson(cached).focusPercentage, '85%');
    expect(energy.copyWith(focusPercentage: '0%').focusPercentage, '0%');
    expect(energy.copyWith(focusPercentage: '0%').riskPercentage, '27%');
  });

  test('still rejects missing required percentage data', () {
    final malformed = {..._payload, 'lunar_day': 5}..remove('focus_percentage');
    expect(
      () => EnergyOfDayModel.fromJson(malformed),
      throwsA(isA<TypeError>()),
    );
  });
}

const _payload = <String, dynamic>{
  'id': 'energy-2026-09-14',
  'date': '2026-09-14',
  'focus_percentage': '85%',
  'risk_percentage': '27%',
  'focus': 'Благоприятный день для завершения дел.',
  'risk': 'Избегайте спешки и переутомления.',
  'phrase': 'Ясность и гармония дня',
};
