class NatalCardModel {
  final String sourceLanguage;
  final Map<String, NatalCardInterpretationModel> interpretations;

  const NatalCardModel({
    required this.sourceLanguage,
    required this.interpretations,
  });

  factory NatalCardModel.fromJson(Map<String, dynamic> json) {
    final rawInterpretations = Map<String, dynamic>.from(
      json['interpretations'] as Map? ?? const {},
    );
    final interpretations = rawInterpretations.map(
      (language, value) => MapEntry(
        _baseLanguage(language),
        NatalCardInterpretationModel.fromJson(
          Map<String, dynamic>.from(value as Map? ?? const {}),
        ),
      ),
    );
    final sourceLanguage = _baseLanguage(
      json['source_language']?.toString() ??
          (interpretations.isNotEmpty ? interpretations.keys.first : 'ru'),
    );

    return NatalCardModel(
      sourceLanguage: sourceLanguage,
      interpretations: Map.unmodifiable(interpretations),
    );
  }

  bool hasLanguage(String language) {
    return interpretations.containsKey(_baseLanguage(language));
  }

  bool get hasAnyInterpretation => interpretations.isNotEmpty;

  NatalCardInterpretationModel? tryInterpretationFor(String language) {
    final baseLanguage = _baseLanguage(language);
    return interpretations[baseLanguage] ?? interpretations[sourceLanguage];
  }

  NatalCardInterpretationModel interpretationFor(String language) {
    return tryInterpretationFor(language) ?? interpretations.values.first;
  }

  Map<String, dynamic> toJson() {
    return {
      'source_language': sourceLanguage,
      'interpretations': interpretations.map(
        (language, interpretation) =>
            MapEntry(language, interpretation.toJson()),
      ),
    };
  }

  NatalCardModel copyWith({
    String? sourceLanguage,
    Map<String, NatalCardInterpretationModel>? interpretations,
  }) {
    return NatalCardModel(
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      interpretations: interpretations ?? this.interpretations,
    );
  }

  NatalCardModel copyWithInterpretation({
    required String language,
    required NatalCardInterpretationModel interpretation,
  }) {
    return NatalCardModel(
      sourceLanguage: sourceLanguage,
      interpretations: Map.unmodifiable({
        ...interpretations,
        _baseLanguage(language): interpretation,
      }),
    );
  }
}

class NatalCardInterpretationModel {
  final String personality;
  final String intellectualArea;
  final String loveArea;
  final String talentArea;
  final String energyArea;
  final String insideArea;
  final String finalConclusion;
  final String elementsInterpretation;
  final Map<String, String> planetInterpretations;
  final Map<String, String> houseInterpretations;

  const NatalCardInterpretationModel({
    required this.personality,
    required this.intellectualArea,
    required this.loveArea,
    required this.talentArea,
    required this.energyArea,
    required this.insideArea,
    required this.finalConclusion,
    this.elementsInterpretation = '',
    this.planetInterpretations = const {},
    this.houseInterpretations = const {},
  });

  factory NatalCardInterpretationModel.fromJson(Map<String, dynamic> json) {
    return NatalCardInterpretationModel(
      personality: json['personality']?.toString() ?? '',
      intellectualArea: json['intellectual_area']?.toString() ?? '',
      loveArea: json['love_area']?.toString() ?? '',
      talentArea: json['talent_area']?.toString() ?? '',
      energyArea: json['energy_area']?.toString() ?? '',
      insideArea: json['inside_area']?.toString() ?? '',
      finalConclusion: json['final_conclusion']?.toString() ?? '',
      elementsInterpretation: json['elements_interpretation']?.toString() ?? '',
      planetInterpretations: Map.unmodifiable(
        _stringMap(json['planet_interpretations']),
      ),
      houseInterpretations: Map.unmodifiable(
        _stringMap(json['house_interpretations']),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personality': personality,
      'intellectual_area': intellectualArea,
      'love_area': loveArea,
      'talent_area': talentArea,
      'energy_area': energyArea,
      'inside_area': insideArea,
      'final_conclusion': finalConclusion,
      'elements_interpretation': elementsInterpretation,
      'planet_interpretations': planetInterpretations,
      'house_interpretations': houseInterpretations,
    };
  }
}

class NatalCardPlanetDisplayModel {
  final String code;
  final String description;

  const NatalCardPlanetDisplayModel({
    required this.code,
    required this.description,
  });
}

class NatalCardHouseDisplayModel {
  final int houseNumber;
  final String description;

  const NatalCardHouseDisplayModel({
    required this.houseNumber,
    required this.description,
  });
}

String _baseLanguage(String language) {
  final normalized = language.toLowerCase().replaceAll('_', '-');
  return normalized.startsWith('en') ? 'en' : 'ru';
}

Map<String, String> _stringMap(Object? value) {
  final map = value is Map ? value : const {};
  return {
    for (final entry in map.entries)
      entry.key.toString(): entry.value.toString(),
  };
}
