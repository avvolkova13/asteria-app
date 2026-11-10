import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses sign codes and canonical house summary', () {
    final data = PlanetsHousesDataModel.fromJson({
      'data': 'Солнце - Лев - 10',
      'elements': {'fire': '2', 'earth': '1', 'air': '3', 'water': '4'},
      'positions': [
        {
          'code': 'sun',
          'name': 'Солнце',
          'sign_code': 'leo',
          'sign': 'Лев',
          'house': 10,
          'longitude': 120.0,
        },
      ],
      'house_summary': {
        'strong_house': {'house_number': 10, 'object_count': 4},
        'weak_house': {'house_number': 4, 'object_count': 0},
        'accent_house': {'house_number': 1, 'source': 'ascendant'},
      },
    });

    expect(data.positions.single.signCode, 'leo');
    expect(data.houseSummary?.strongHouse.houseNumber, 10);
    expect(data.houseSummary?.weakHouse.objectCount, 0);
    expect(data.houseSummary?.accentHouse.source, 'ascendant');
  });
}
