import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cycle = List.generate(
    12,
    (i) => {'house': i + 1, 'longitude': (340.5 + i * 30) % 360},
  );
  final payload = {
    'data': 'legacy text',
    'elements': {'fire': '1', 'earth': '2', 'air': '3', 'water': '4'},
  };
  test(
    'precise cusp cycle survives profile serialization, independently of ordering',
    () {
      final model = PlanetsHousesDataModel.fromJson({
        ...payload,
        'house_cusps': cycle.reversed.toList(),
      });
      expect(
        model.houseCusps.map((c) => c.house),
        List.generate(12, (i) => i + 1),
      );
      expect(model.copyWith().toJson()['house_cusps'], cycle);
      expect(
        PlanetsHousesDataModel.fromJson(
          model.toJson(),
        ).houseCusps.first.longitude,
        340.5,
      );
    },
  );
  test(
    'invalid house cycle never breaks a legacy chart or invents boundaries',
    () {
      for (final raw in [
        null,
        {},
        cycle.take(11).toList(),
        [...cycle.take(11), cycle.first],
        [
          ...cycle.take(11),
          {'house': 12, 'longitude': -1},
        ],
        [
          ...cycle.take(11),
          {'house': 12, 'longitude': 360},
        ],
        [
          ...cycle.take(11),
          {'house': 12, 'longitude': double.nan},
        ],
        [
          ...cycle.take(11),
          {'house': 12, 'longitude': 10.5},
        ],
        [
          ...cycle.take(11),
          {'house': 12, 'longitude': 2},
        ],
        [
          ...cycle.take(11),
          {'house': 12},
        ],
      ]) {
        final model = PlanetsHousesDataModel.fromJson({
          ...payload,
          'house_cusps': raw,
        });
        expect(model.houseCusps, isEmpty, reason: raw.toString());
        expect(model.toJson(), payload);
      }
    },
  );
  test(
    'unknown longitude is not plotted at Aries zero; actual zero remains valid',
    () {
      final sun = {'code': 'sun', 'name': 'Sun', 'sign': 'Aries', 'house': 1};
      final model = PlanetsHousesDataModel.fromJson({
        ...payload,
        'positions': [
          sun,
          {...sun, 'longitude': 0},
        ],
      });
      expect(model.positions.map((p) => p.longitude), [0.0]);
    },
  );
  test(
    'explicit time precision round trips, legacy placeholders remain ambiguous',
    () {
      final birth = DateTime(2000, 8, 19);
      for (final hour in [0, 12]) {
        final old = BirthDateModel(
          birthDate: birth,
          birthTime: DateTime(2000, 8, 19, hour),
        );
        expect(
          BirthDateModel.fromJson(old.toJson()).hasExactBirthTime,
          isFalse,
        );
        expect(
          BirthDateModel.fromJson(
            old.copyWith(birthTimeKnown: true).toJson(),
          ).hasExactBirthTime,
          isTrue,
        );
      }
      final known = BirthDateModel(
        birthDate: birth,
        birthTime: DateTime(2000, 8, 19, 11),
      );
      expect(known.hasExactBirthTime, isTrue);
      expect(
        BirthDateModel.fromJson(
          known.copyWith(birthTimeKnown: false).toJson(),
        ).hasExactBirthTime,
        isFalse,
      );
      expect(
        BirthDateModel(
          birthDate: birth,
          birthTimeKnown: true,
        ).hasExactBirthTime,
        isFalse,
      );
    },
  );
  test(
    'approximate-time interpretation never includes canonical houses or angle coordinates',
    () {
      final model = PlanetsHousesDataModel.fromJson({
        ...payload,
        'data': 'Солнце - Козерог - 3',
        'prompt_context': 'секретный старый текст о домах',
        'positions': [
          {
            'code': 'sun',
            'name': 'Солнце',
            'sign': 'Козерог',
            'longitude': 272,
            'house': 3,
          },
          {
            'code': 'asc',
            'name': 'Ascendant',
            'sign': 'Лев',
            'longitude': 111,
            'house': 1,
          },
        ],
      });
      final prompt = model.toApproximateTimePromptContext();
      expect(prompt, contains('время рождения неизвестно'));
      expect(prompt, contains('Солнце | Козерог'));
      for (final forbidden in [
        'Ascendant',
        '111.000000',
        'Солнце - Козерог - 3',
        'секретный старый текст',
      ]) {
        expect(prompt, isNot(contains(forbidden)));
      }
      expect(
        model.copyWith(positions: [model.positions.last]).hasPlanetCoordinates,
        isFalse,
      );
    },
  );

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
