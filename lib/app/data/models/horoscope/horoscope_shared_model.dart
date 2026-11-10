class HoroscopeAreaModel {
  final String keyTheme;
  final String themeTitle;
  final String description;

  const HoroscopeAreaModel({
    required this.keyTheme,
    required this.themeTitle,
    required this.description,
  });

  factory HoroscopeAreaModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeAreaModel(
      keyTheme: json['key_theme'] as String,
      themeTitle: json['theme_title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key_theme': keyTheme,
      'theme_title': themeTitle,
      'description': description,
    };
  }

  HoroscopeAreaModel copyWith({
    String? keyTheme,
    String? themeTitle,
    String? description,
  }) {
    return HoroscopeAreaModel(
      keyTheme: keyTheme ?? this.keyTheme,
      themeTitle: themeTitle ?? this.themeTitle,
      description: description ?? this.description,
    );
  }
}

class HoroscopeWeakPointModel {
  final String title;
  final String description;

  const HoroscopeWeakPointModel({
    required this.title,
    required this.description,
  });

  factory HoroscopeWeakPointModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeWeakPointModel(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }

  HoroscopeWeakPointModel copyWith({
    String? title,
    String? description,
  }) {
    return HoroscopeWeakPointModel(
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}

class HoroscopePeriodDetailsModel {
  final String dates;
  final String text;

  const HoroscopePeriodDetailsModel({
    required this.dates,
    required this.text,
  });

  factory HoroscopePeriodDetailsModel.fromJson(Map<String, dynamic> json) {
    return HoroscopePeriodDetailsModel(
      dates: json['dates'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dates': dates,
      'text': text,
    };
  }

  HoroscopePeriodDetailsModel copyWith({
    String? dates,
    String? text,
  }) {
    return HoroscopePeriodDetailsModel(
      dates: dates ?? this.dates,
      text: text ?? this.text,
    );
  }
}

class HoroscopePeriodsModel {
  final HoroscopePeriodDetailsModel bestDaysForWork;
  final HoroscopePeriodDetailsModel bestDaysForSelfFocus;
  final HoroscopePeriodDetailsModel bestDaysForRelationships;

  const HoroscopePeriodsModel({
    required this.bestDaysForWork,
    required this.bestDaysForSelfFocus,
    required this.bestDaysForRelationships,
  });

  factory HoroscopePeriodsModel.fromJson(Map<String, dynamic> json) {
    return HoroscopePeriodsModel(
      bestDaysForWork: HoroscopePeriodDetailsModel.fromJson(json['best_days_for_work'] as Map<String, dynamic>),
      bestDaysForSelfFocus: HoroscopePeriodDetailsModel.fromJson(json['best_days_for_self_focus'] as Map<String, dynamic>),
      bestDaysForRelationships: HoroscopePeriodDetailsModel.fromJson(json['best_days_for_relationships'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'best_days_for_work': bestDaysForWork.toJson(),
      'best_days_for_self_focus': bestDaysForSelfFocus.toJson(),
      'best_days_for_relationships': bestDaysForRelationships.toJson(),
    };
  }

  HoroscopePeriodsModel copyWith({
    HoroscopePeriodDetailsModel? bestDaysForWork,
    HoroscopePeriodDetailsModel? bestDaysForSelfFocus,
    HoroscopePeriodDetailsModel? bestDaysForRelationships,
  }) {
    return HoroscopePeriodsModel(
      bestDaysForWork: bestDaysForWork ?? this.bestDaysForWork,
      bestDaysForSelfFocus: bestDaysForSelfFocus ?? this.bestDaysForSelfFocus,
      bestDaysForRelationships: bestDaysForRelationships ?? this.bestDaysForRelationships,
    );
  }
}


class HoroscopePlanetInSignModel {
  final String planetInSign;
  final String description;

  const HoroscopePlanetInSignModel({
    required this.planetInSign,
    required this.description,
  });

  factory HoroscopePlanetInSignModel.fromJson(Map<String, dynamic> json) {
    return HoroscopePlanetInSignModel(
      planetInSign: json['planet_in_sign'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planet_in_sign': planetInSign,
      'description': description,
    };
  }

  HoroscopePlanetInSignModel copyWith({
    String? planetInSign,
    String? description,
  }) {
    return HoroscopePlanetInSignModel(
      planetInSign: planetInSign ?? this.planetInSign,
      description: description ?? this.description,
    );
  }
}

class HoroscopeCoreDescriptionModel {
  final HoroscopePlanetInSignModel sunInSign;
  final HoroscopePlanetInSignModel moonInSign;
  final HoroscopePlanetInSignModel ascendantInSign;

  const HoroscopeCoreDescriptionModel({
    required this.sunInSign,
    required this.moonInSign,
    required this.ascendantInSign,
  });

  factory HoroscopeCoreDescriptionModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeCoreDescriptionModel(
      sunInSign: HoroscopePlanetInSignModel.fromJson(json['sun_in_sign'] as Map<String, dynamic>),
      moonInSign: HoroscopePlanetInSignModel.fromJson(json['moon_in_sign'] as Map<String, dynamic>),
      ascendantInSign: HoroscopePlanetInSignModel.fromJson(json['ascendant_in_sign'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sun_in_sign': sunInSign.toJson(),
      'moon_in_sign': moonInSign.toJson(),
      'ascendant_in_sign': ascendantInSign.toJson(),
    };
  }

  HoroscopeCoreDescriptionModel copyWith({
    HoroscopePlanetInSignModel? sunInSign,
    HoroscopePlanetInSignModel? moonInSign,
    HoroscopePlanetInSignModel? ascendantInSign,
  }) {
    return HoroscopeCoreDescriptionModel(
      sunInSign: sunInSign ?? this.sunInSign,
      moonInSign: moonInSign ?? this.moonInSign,
      ascendantInSign: ascendantInSign ?? this.ascendantInSign,
    );
  }
}

class HoroscopeLoveModel {
  final String general;
  final String lesson;
  final List<String> compatibility;

  const HoroscopeLoveModel({
    required this.general,
    required this.lesson,
    required this.compatibility,
  });

  factory HoroscopeLoveModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeLoveModel(
      general: json['general'] as String,
      lesson: json['lesson'] as String,
      compatibility: (json['compatibility'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'general': general,
      'lesson': lesson,
      'compatibility': compatibility,
    };
  }

  HoroscopeLoveModel copyWith({
    String? general,
    String? lesson,
    List<String>? compatibility,
  }) {
    return HoroscopeLoveModel(
      general: general ?? this.general,
      lesson: lesson ?? this.lesson,
      compatibility: compatibility ?? this.compatibility,
    );
  }
}

class HoroscopeWorkModel {
  final String general;
  final String important;
  final List<String> successExamples;

  const HoroscopeWorkModel({
    required this.general,
    required this.important,
    required this.successExamples,
  });

  factory HoroscopeWorkModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeWorkModel(
      general: json['general'] as String,
      important: json['important'] as String,
      successExamples: (json['success_examples'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'general': general,
      'important': important,
      'success_examples': successExamples,
    };
  }

  HoroscopeWorkModel copyWith({
    String? general,
    String? important,
    List<String>? successExamples,
  }) {
    return HoroscopeWorkModel(
      general: general ?? this.general,
      important: important ?? this.important,
      successExamples: successExamples ?? this.successExamples,
    );
  }
}

class HoroscopeFinanceModel {
  final String general;
  final String risk;
  final String advice;

  const HoroscopeFinanceModel({
    required this.general,
    required this.risk,
    required this.advice,
  });

  factory HoroscopeFinanceModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeFinanceModel(
      general: json['general'] as String,
      risk: json['risk'] as String,
      advice: json['advice'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'general': general,
      'risk': risk,
      'advice': advice,
    };
  }

  HoroscopeFinanceModel copyWith({
    String? general,
    String? risk,
    String? advice,
  }) {
    return HoroscopeFinanceModel(
      general: general ?? this.general,
      risk: risk ?? this.risk,
      advice: advice ?? this.advice,
    );
  }
}

class HoroscopeTransitModel {
  final String planet;
  final String description;

  const HoroscopeTransitModel({
    required this.planet,
    required this.description,
  });

  factory HoroscopeTransitModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeTransitModel(
      planet: json['planet'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planet': planet,
      'description': description,
    };
  }

  HoroscopeTransitModel copyWith({
    String? planet,
    String? description,
  }) {
    return HoroscopeTransitModel(
      planet: planet ?? this.planet,
      description: description ?? this.description,
    );
  }
}

class HoroscopeTransformationModel {
  final String general;
  final List<HoroscopeTransitModel> transits;

  const HoroscopeTransformationModel({
    required this.general,
    required this.transits,
  });

  factory HoroscopeTransformationModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeTransformationModel(
      general: json['general'] as String,
      transits: (json['transits'] as List).map((e) => HoroscopeTransitModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'general': general,
      'transits': transits.map((e) => e.toJson()).toList(),
    };
  }

  HoroscopeTransformationModel copyWith({
    String? general,
    List<HoroscopeTransitModel>? transits,
  }) {
    return HoroscopeTransformationModel(
      general: general ?? this.general,
      transits: transits ?? this.transits,
    );
  }
}
