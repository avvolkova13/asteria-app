import 'package:asteria_app/app/data/models/horoscope/horoscope_shared_model.dart';

class HoroscopeMonthModel {
  final DateTime dateUntil;
  final HoroscopeAreaModel personalArea;
  final String personalAreaPercentage;
  final HoroscopeAreaModel loveArea;
  final String loveAreaPercentage;
  final HoroscopeAreaModel financeArea;
  final String financeAreaPercentage;
  final HoroscopePeriodsModel periods;
  final String keyTopic;
  final String advice;

  const HoroscopeMonthModel({
    required this.dateUntil,
    required this.personalArea,
    required this.personalAreaPercentage,
    required this.loveArea,
    required this.loveAreaPercentage,
    required this.financeArea,
    required this.financeAreaPercentage,
    required this.periods,
    required this.keyTopic,
    required this.advice,
  });

  factory HoroscopeMonthModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeMonthModel(
      dateUntil: DateTime.parse(json['date_until'] as String),
      personalArea: HoroscopeAreaModel.fromJson(json['personal_area'] as Map<String, dynamic>),
      personalAreaPercentage: json['personal_area_persentage'] as String,
      loveArea: HoroscopeAreaModel.fromJson(json['love_area'] as Map<String, dynamic>),
      loveAreaPercentage: json['love_area_persentage'] as String,
      financeArea: HoroscopeAreaModel.fromJson(json['finance_area'] as Map<String, dynamic>),
      financeAreaPercentage: json['finance_area_persentage'] as String,
      periods: HoroscopePeriodsModel.fromJson(json['periods'] as Map<String, dynamic>),
      keyTopic: json['key_topic'] as String,
      advice: json['advice'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_until': dateUntil.toIso8601String(),
      'personal_area': personalArea.toJson(),
      'personal_area_persentage': personalAreaPercentage,
      'love_area': loveArea.toJson(),
      'love_area_persentage': loveAreaPercentage,
      'finance_area': financeArea.toJson(),
      'finance_area_persentage': financeAreaPercentage,
      'periods': periods.toJson(),
      'key_topic': keyTopic,
      'advice': advice,
    };
  }

  HoroscopeMonthModel copyWith({
    DateTime? dateUntil,
    HoroscopeAreaModel? personalArea,
    String? personalAreaPercentage,
    HoroscopeAreaModel? loveArea,
    String? loveAreaPercentage,
    HoroscopeAreaModel? financeArea,
    String? financeAreaPercentage,
    HoroscopePeriodsModel? periods,
    String? keyTopic,
    String? advice,
  }) {
    return HoroscopeMonthModel(
      dateUntil: dateUntil ?? this.dateUntil,
      personalArea: personalArea ?? this.personalArea,
      personalAreaPercentage: personalAreaPercentage ?? this.personalAreaPercentage,
      loveArea: loveArea ?? this.loveArea,
      loveAreaPercentage: loveAreaPercentage ?? this.loveAreaPercentage,
      financeArea: financeArea ?? this.financeArea,
      financeAreaPercentage: financeAreaPercentage ?? this.financeAreaPercentage,
      periods: periods ?? this.periods,
      keyTopic: keyTopic ?? this.keyTopic,
      advice: advice ?? this.advice,
    );
  }
}
