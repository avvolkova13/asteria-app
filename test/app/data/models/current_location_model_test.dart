import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes selected location country code for payment routing', () {
    const location = CurrentLocationModel(
      location: 'Москва, Россия',
      latitude: 55.7558,
      longitude: 37.6173,
      source: CurrentLocationSource.manual,
      countryCode: 'RU',
    );

    expect(location.toJson(), containsPair('country_code', 'RU'));
    expect(CurrentLocationModel.fromJson(location.toJson()).countryCode, 'RU');
  });

  test('normalizes legacy missing country code as null', () {
    final location = CurrentLocationModel.fromJson({
      'location': 'Текущая геолокация',
      'latitude': 55.7558,
      'longitude': 37.6173,
      'source': 'auto',
    });

    expect(location.countryCode, isNull);
  });
}
