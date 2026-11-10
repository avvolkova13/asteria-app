import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/location/city_search_service.dart';

// City centres from GeoNames (https://www.geonames.org/), CC BY 4.0.
const _cities = [
  (
    '2122104',
    'Петропавловск-Камчатский',
    'Petropavlovsk-Kamchatsky',
    53.06393,
    158.62751,
  ),
  ('524901', 'Москва', 'Moscow', 55.75204, 37.61781),
  ('1486209', 'Екатеринбург', 'Yekaterinburg', 56.85733, 60.61529),
  ('542420', 'Краснодар', 'Krasnodar', 45.04534, 38.98178),
  ('491422', 'Сочи', 'Sochi', 43.59699, 39.72477),
  ('520555', 'Нижний Новгород', 'Nizhny Novgorod', 56.32867, 44.00205),
  ('499099', 'Самара', 'Samara', 53.20767, 50.13553),
  ('551487', 'Казань', 'Kazan', 55.78874, 49.12214),
  ('1496747', 'Новосибирск', 'Novosibirsk', 55.02259, 82.93175),
  ('479561', 'Уфа', 'Ufa', 54.74306, 55.96779),
  ('1502026', 'Красноярск', 'Krasnoyarsk', 56.03742, 92.93136),
  ('501175', 'Ростов-на-Дону', 'Rostov-on-Don', 47.21997, 39.70769),
  ('1508291', 'Челябинск', 'Chelyabinsk', 55.1611, 61.42877),
];

List<CitySuggestion> suggestedCities(
  CurrentLocationModel current,
  String language,
) {
  final russian = language == 'ru';
  final currentName = current.location.split(',').first.trim().toLowerCase();
  return [
    CitySuggestion(
      placeId: 'current',
      description: current.location,
      knownLocation: current,
    ),
    for (final (id, ru, en, latitude, longitude) in _cities)
      if (!(currentName == ru.toLowerCase() ||
              currentName == en.toLowerCase()) ||
          (current.latitude - latitude).abs() > 0.8 ||
          (current.longitude - longitude).abs() > 0.8)
        CitySuggestion(
          placeId: 'geonames:$id',
          description: russian ? '$ru, Россия' : '$en, Russia',
          knownLocation: CurrentLocationModel(
            location: russian ? '$ru, Россия' : '$en, Russia',
            latitude: latitude,
            longitude: longitude,
            source: CurrentLocationSource.manual,
            countryCode: 'RU',
          ),
        ),
  ];
}
