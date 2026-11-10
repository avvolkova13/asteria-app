import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlanetsHousesDataModel.fromJson', () {
    test('keeps structured positions and calculation context from backend', () {
      final model = PlanetsHousesDataModel.fromJson({
        'data': 'Солнце - Козерог - 3',
        'elements': {'fire': '5', 'earth': '4', 'air': '6', 'water': '2'},
        'positions': [
          {
            'code': 'sun',
            'name': 'Солнце',
            'sign': 'Козерог',
            'house': 3,
            'longitude': 271.289494,
          },
        ],
        'calculation': {
          'timezone': 'Asia/Almaty',
          'timezone_offset_hours': 6.0,
          'local_datetime': '2000-12-23T02:00:00',
          'utc_datetime': '2000-12-22T20:00:00+00:00',
          'house_system': 'Placidus',
          'zodiac': 'Tropical',
        },
        'prompt_context': 'Место рождения: Шымкент\nСолнце | Козерог | дом 3',
      });

      expect(model.positions.single.code, 'sun');
      expect(model.positions.single.sign, 'Козерог');
      expect(model.calculation?.timezone, 'Asia/Almaty');
      expect(model.promptContext, contains('Солнце | Козерог | дом 3'));
      expect(model.toPromptContext(), contains('Солнце - Козерог - 3'));
      expect(model.toPromptContext(), contains('Солнце | Козерог | дом 3'));
    });

    test(
      'builds prompt context from legacy raw data when structured fields are absent',
      () {
        final model = PlanetsHousesDataModel.fromJson({
          'data': 'Солнце - Козерог - 3, Луна - Скорпион - 2',
          'elements': {'fire': '5', 'earth': '4', 'air': '6', 'water': '2'},
        });

        expect(model.positions, isEmpty);
        expect(model.calculation, isNull);
        expect(model.toPromptContext(), contains('Солнце - Козерог - 3'));
        expect(model.toPromptContext(), contains('Огонь: 5'));
        expect(model.toPromptContext(), contains('Воздух: 6'));
      },
    );
  });
}
