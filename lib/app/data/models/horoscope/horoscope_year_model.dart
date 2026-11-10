import 'package:asteria_app/app/data/models/horoscope/horoscope_shared_model.dart';

class HoroscopeYearModel {
  final DateTime dateUntil;
  final HoroscopeCoreDescriptionModel coreDescription;
  final String emotionalWorld;
  final List<HoroscopeWeakPointModel> weakPoints;
  final List<String> recommendations;
  final String astroMetaphor;
  final HoroscopeLoveModel love;
  final HoroscopeWorkModel work;
  final HoroscopeFinanceModel finance;
  final HoroscopeTransformationModel transformation;

  const HoroscopeYearModel({
    required this.dateUntil,
    required this.coreDescription,
    required this.emotionalWorld,
    required this.weakPoints,
    required this.recommendations,
    required this.astroMetaphor,
    required this.love,
    required this.work,
    required this.finance,
    required this.transformation,
  });

  factory HoroscopeYearModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeYearModel(
      dateUntil: DateTime.parse(json['date_until'] as String),
      coreDescription: HoroscopeCoreDescriptionModel.fromJson(json['core_description'] as Map<String, dynamic>),
      emotionalWorld: json['emotional_world'] as String,
      weakPoints: (json['weak_points'] as List)
          .map((e) => HoroscopeWeakPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List).map((e) => e as String).toList(),
      astroMetaphor: json['astro_metaphor'] as String,
      love: HoroscopeLoveModel.fromJson(json['love'] as Map<String, dynamic>),
      work: HoroscopeWorkModel.fromJson(json['work'] as Map<String, dynamic>),
      finance: HoroscopeFinanceModel.fromJson(json['finance'] as Map<String, dynamic>),
      transformation: HoroscopeTransformationModel.fromJson(json['transformation'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_until': dateUntil.toIso8601String(),
      'core_description': coreDescription.toJson(),
      'emotional_world': emotionalWorld,
      'weak_points': weakPoints.map((e) => e.toJson()).toList(),
      'recommendations': recommendations,
      'astro_metaphor': astroMetaphor,
      'love': love.toJson(),
      'work': work.toJson(),
      'finance': finance.toJson(),
      'transformation': transformation.toJson(),
    };
  }

  HoroscopeYearModel copyWith({
    DateTime? dateUntil,
    HoroscopeCoreDescriptionModel? coreDescription,
    String? emotionalWorld,
    List<HoroscopeWeakPointModel>? weakPoints,
    List<String>? recommendations,
    String? astroMetaphor,
    HoroscopeLoveModel? love,
    HoroscopeWorkModel? work,
    HoroscopeFinanceModel? finance,
    HoroscopeTransformationModel? transformation,
  }) {
    return HoroscopeYearModel(
      dateUntil: dateUntil ?? this.dateUntil,
      coreDescription: coreDescription ?? this.coreDescription,
      emotionalWorld: emotionalWorld ?? this.emotionalWorld,
      weakPoints: weakPoints ?? this.weakPoints,
      recommendations: recommendations ?? this.recommendations,
      astroMetaphor: astroMetaphor ?? this.astroMetaphor,
      love: love ?? this.love,
      work: work ?? this.work,
      finance: finance ?? this.finance,
      transformation: transformation ?? this.transformation,
    );
  }
}
