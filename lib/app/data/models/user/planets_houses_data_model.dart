part of 'user_model.dart';

class PlanetsHousesDataModel {
  final String data;
  final Elements elements;
  final List<PlanetHousePositionModel> positions;
  final List<HouseCuspModel> houseCusps;
  final HouseSummaryModel? houseSummary;
  final PlanetsHousesCalculationModel? calculation;
  final String? promptContext;

  const PlanetsHousesDataModel({
    required this.data,
    required this.elements,
    this.positions = const [],
    this.houseCusps = const [],
    this.houseSummary,
    this.calculation,
    this.promptContext,
  });

  factory PlanetsHousesDataModel.fromJson(Map<String, dynamic> json) {
    return PlanetsHousesDataModel(
      data: json['data'] as String,
      elements: Elements.fromJson(json['elements'] as Map<String, dynamic>),
      positions: PlanetHousePositionModel.parseAvailable(json['positions']),
      houseCusps: HouseCuspModel.parseCycle(json['house_cusps']),
      houseSummary: json['house_summary'] != null
          ? HouseSummaryModel.fromJson(
              json['house_summary'] as Map<String, dynamic>,
            )
          : null,
      calculation: json['calculation'] != null
          ? PlanetsHousesCalculationModel.fromJson(
              json['calculation'] as Map<String, dynamic>,
            )
          : null,
      promptContext: json['prompt_context'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'elements': elements.toJson(),
      if (positions.isNotEmpty)
        'positions': positions.map((position) => position.toJson()).toList(),
      if (houseCusps.isNotEmpty)
        'house_cusps': houseCusps.map((cusp) => cusp.toJson()).toList(),
      if (houseSummary != null) 'house_summary': houseSummary!.toJson(),
      if (calculation != null) 'calculation': calculation!.toJson(),
      if (promptContext != null) 'prompt_context': promptContext,
    };
  }

  static const _planetCodes = {
    'sun',
    'moon',
    'mercury',
    'venus',
    'mars',
    'jupiter',
    'saturn',
    'uranus',
    'neptune',
    'pluto',
  };

  bool get hasPlanetCoordinates => positions.any(
    (p) =>
        _planetCodes.contains(p.code) &&
        p.longitude.isFinite &&
        p.longitude >= 0 &&
        p.longitude < 360,
  );

  /// Old canonical prose includes exact houses and angles. For approximate
  /// times pass only planetary positions, never that prose or inferred houses.
  String toApproximateTimePromptContext() {
    return [
      'Точное время рождения неизвестно. Положения планет приблизительны; не делай выводов о домах, асценденте, MC и других углах карты.',
      for (final p in positions)
        if (_planetCodes.contains(p.code))
          '${p.name} | ${p.sign} | ориентировочная долгота ${p.longitude.toStringAsFixed(6)}°',
    ].join('\n');
  }

  String toPromptContext({
    String? name,
    String? birthdate,
    String? birthtime,
    String? city,
    double? latitude,
    double? longitude,
  }) {
    final lines = <String>[];
    if (name != null && name.isNotEmpty) {
      lines.add('Имя: $name');
    }
    if (birthdate != null && birthdate.isNotEmpty) {
      lines.add('Дата рождения: $birthdate');
    }
    if (birthtime != null && birthtime.isNotEmpty) {
      lines.add('Время рождения: $birthtime');
    }
    if (city != null && city.isNotEmpty) {
      lines.add('Место рождения: $city');
    }
    if (latitude != null && longitude != null) {
      lines.add(
        'Координаты рождения: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
      );
    }

    lines.add(
      'Канонические расчетные позиции натальной карты. '
      'Формат: объект - знак - дом. Эти значения нельзя менять в ответе:',
    );
    lines.add(data);

    if (promptContext != null && promptContext!.trim().isNotEmpty) {
      lines.add('');
      lines.add(promptContext!.trim());
    } else {
      if (positions.isNotEmpty) {
        lines.add('');
        lines.add('Структурированные позиции:');
        for (final position in positions) {
          lines.add(
            '- ${position.name} | ${position.sign} | дом ${position.house} | долгота ${position.longitude.toStringAsFixed(6)}°',
          );
        }
      }
      if (calculation != null) {
        lines.add('');
        lines.add('Контекст расчета:');
        lines.add('Локальное время: ${calculation!.localDateTime}');
        lines.add('Часовой пояс: ${calculation!.timezone}');
        lines.add(
          'UTC offset: ${calculation!.timezoneOffsetHours.toStringAsFixed(1)}',
        );
        lines.add('UTC-момент: ${calculation!.utcDateTime}');
        lines.add('Система домов: ${calculation!.houseSystem}');
        lines.add('Зодиак: ${calculation!.zodiac}');
      }
    }

    lines.add('');
    lines.add('Баланс стихий:');
    lines.add('- Огонь: ${elements.fire}');
    lines.add('- Земля: ${elements.earth}');
    lines.add('- Воздух: ${elements.air}');
    lines.add('- Вода: ${elements.water}');

    return lines.join('\n');
  }

  PlanetsHousesDataModel copyWith({
    String? data,
    Elements? elements,
    List<PlanetHousePositionModel>? positions,
    List<HouseCuspModel>? houseCusps,
    HouseSummaryModel? houseSummary,
    PlanetsHousesCalculationModel? calculation,
    String? promptContext,
  }) {
    return PlanetsHousesDataModel(
      data: data ?? this.data,
      elements: elements ?? this.elements,
      positions: positions ?? this.positions,
      houseCusps: houseCusps ?? this.houseCusps,
      houseSummary: houseSummary ?? this.houseSummary,
      calculation: calculation ?? this.calculation,
      promptContext: promptContext ?? this.promptContext,
    );
  }
}

class HouseCuspModel {
  final int house;
  final double longitude;

  const HouseCuspModel({required this.house, required this.longitude});

  /// A partial or noncyclic set cannot describe a house wheel. Never invent
  /// missing boundaries or turn an absent longitude into zero degrees Aries.
  static List<HouseCuspModel> parseCycle(Object? raw) {
    if (raw is! List || raw.length != 12) return const [];
    final byHouse = <int, HouseCuspModel>{};
    final longitudes = <double>{};
    for (final item in raw) {
      if (item is! Map) return const [];
      final house = item['house'];
      final longitude = item['longitude'];
      if (house is! int ||
          house < 1 ||
          house > 12 ||
          byHouse.containsKey(house) ||
          longitude is! num ||
          !longitude.isFinite ||
          longitude < 0 ||
          longitude >= 360 ||
          !longitudes.add(longitude.toDouble())) {
        return const [];
      }
      byHouse[house] = HouseCuspModel(
        house: house,
        longitude: longitude.toDouble(),
      );
    }
    final ordered = List.generate(12, (i) => byHouse[i + 1]!);
    var wraps = 0;
    for (var i = 0; i < 12; i++) {
      if (ordered[(i + 1) % 12].longitude < ordered[i].longitude) wraps++;
    }
    return wraps == 1 ? List.unmodifiable(ordered) : const [];
  }

  Map<String, dynamic> toJson() => {'house': house, 'longitude': longitude};
}

class HouseSummaryModel {
  final HouseSummaryEntryModel strongHouse;
  final HouseSummaryEntryModel weakHouse;
  final HouseSummaryEntryModel accentHouse;

  const HouseSummaryModel({
    required this.strongHouse,
    required this.weakHouse,
    required this.accentHouse,
  });

  factory HouseSummaryModel.fromJson(Map<String, dynamic> json) {
    return HouseSummaryModel(
      strongHouse: HouseSummaryEntryModel.fromJson(
        json['strong_house'] as Map<String, dynamic>,
      ),
      weakHouse: HouseSummaryEntryModel.fromJson(
        json['weak_house'] as Map<String, dynamic>,
      ),
      accentHouse: HouseSummaryEntryModel.fromJson(
        json['accent_house'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strong_house': strongHouse.toJson(),
      'weak_house': weakHouse.toJson(),
      'accent_house': accentHouse.toJson(),
    };
  }
}

class HouseSummaryEntryModel {
  final int houseNumber;
  final int? objectCount;
  final String? source;

  const HouseSummaryEntryModel({
    required this.houseNumber,
    this.objectCount,
    this.source,
  });

  factory HouseSummaryEntryModel.fromJson(Map<String, dynamic> json) {
    return HouseSummaryEntryModel(
      houseNumber: (json['house_number'] as num).toInt(),
      objectCount: (json['object_count'] as num?)?.toInt(),
      source: json['source']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'house_number': houseNumber,
      if (objectCount != null) 'object_count': objectCount,
      if (source != null) 'source': source,
    };
  }
}

class Elements {
  final String fire;
  final String earth;
  final String air;
  final String water;

  const Elements({
    required this.fire,
    required this.earth,
    required this.air,
    required this.water,
  });

  factory Elements.fromJson(Map<String, dynamic> json) {
    return Elements(
      fire: json['fire'] as String,
      earth: json['earth'] as String,
      air: json['air'] as String,
      water: json['water'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'fire': fire, 'earth': earth, 'air': air, 'water': water};
  }

  Elements copyWith({String? fire, String? earth, String? air, String? water}) {
    return Elements(
      fire: fire ?? this.fire,
      earth: earth ?? this.earth,
      air: air ?? this.air,
      water: water ?? this.water,
    );
  }
}

class PlanetHousePositionModel {
  final String code;
  final String name;
  final String signCode;
  final String sign;
  final int house;
  final double longitude;

  const PlanetHousePositionModel({
    required this.code,
    required this.name,
    required this.signCode,
    required this.sign,
    required this.house,
    required this.longitude,
  });

  static List<PlanetHousePositionModel> parseAvailable(Object? raw) {
    if (raw is! List) return const [];
    return [
      for (final item in raw)
        if (item is Map<String, dynamic> &&
            item['code'] is String &&
            item['name'] is String &&
            item['sign'] is String &&
            item['house'] is num &&
            (item['house'] as num).isFinite &&
            item['longitude'] is num &&
            (item['longitude'] as num).isFinite &&
            (item['longitude'] as num) >= 0 &&
            (item['longitude'] as num) < 360)
          PlanetHousePositionModel.fromJson(item),
    ];
  }

  factory PlanetHousePositionModel.fromJson(Map<String, dynamic> json) {
    return PlanetHousePositionModel(
      code: json['code'] as String,
      name: json['name'] as String,
      signCode: json['sign_code']?.toString() ?? '',
      sign: json['sign'] as String,
      house: (json['house'] as num).toInt(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'sign_code': signCode,
      'sign': sign,
      'house': house,
      'longitude': longitude,
    };
  }
}

class PlanetsHousesCalculationModel {
  final String localDateTime;
  final String timezone;
  final double timezoneOffsetHours;
  final String utcDateTime;
  final String houseSystem;
  final String zodiac;

  const PlanetsHousesCalculationModel({
    required this.localDateTime,
    required this.timezone,
    required this.timezoneOffsetHours,
    required this.utcDateTime,
    required this.houseSystem,
    required this.zodiac,
  });

  factory PlanetsHousesCalculationModel.fromJson(Map<String, dynamic> json) {
    return PlanetsHousesCalculationModel(
      localDateTime: json['local_datetime'] as String,
      timezone: json['timezone'] as String,
      timezoneOffsetHours: (json['timezone_offset_hours'] as num).toDouble(),
      utcDateTime: json['utc_datetime'] as String,
      houseSystem: json['house_system'] as String,
      zodiac: json['zodiac'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'local_datetime': localDateTime,
      'timezone': timezone,
      'timezone_offset_hours': timezoneOffsetHours,
      'utc_datetime': utcDateTime,
      'house_system': houseSystem,
      'zodiac': zodiac,
    };
  }
}
