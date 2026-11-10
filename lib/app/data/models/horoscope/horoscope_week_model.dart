import 'package:asteria_app/app/data/models/horoscope/horoscope_shared_model.dart';

class HoroscopeWeekModel {
  final DateTime dateUntil;
  final HoroscopeAreaModel personalArea;
  final String personalAreaPercentage;
  final HoroscopeAreaModel loveArea;
  final String loveAreaPercentage;
  final HoroscopeAreaModel financeArea;
  final String financeAreaPercentage;
  final String advice;

  const HoroscopeWeekModel({
    required this.dateUntil,
    required this.personalArea,
    required this.personalAreaPercentage,
    required this.loveArea,
    required this.loveAreaPercentage,
    required this.financeArea,
    required this.financeAreaPercentage,
    required this.advice,
  });

  factory HoroscopeWeekModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeWeekModel(
      dateUntil: DateTime.parse(json['date_until'] as String),
      personalArea: HoroscopeAreaModel.fromJson(json['personal_area'] as Map<String, dynamic>),
      personalAreaPercentage: json['personal_area_persentage'] as String,
      loveArea: HoroscopeAreaModel.fromJson(json['love_area'] as Map<String, dynamic>),
      loveAreaPercentage: json['love_area_persentage'] as String,
      financeArea: HoroscopeAreaModel.fromJson(json['finance_area'] as Map<String, dynamic>),
      financeAreaPercentage: json['finance_area_persentage'] as String,
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
      'advice': advice,
    };
  }

  HoroscopeWeekModel copyWith({
    DateTime? dateUntil,
    HoroscopeAreaModel? personalArea,
    String? personalAreaPercentage,
    HoroscopeAreaModel? loveArea,
    String? loveAreaPercentage,
    HoroscopeAreaModel? financeArea,
    String? financeAreaPercentage,
    String? advice,
  }) {
    return HoroscopeWeekModel(
      dateUntil: dateUntil ?? this.dateUntil,
      personalArea: personalArea ?? this.personalArea,
      personalAreaPercentage: personalAreaPercentage ?? this.personalAreaPercentage,
      loveArea: loveArea ?? this.loveArea,
      loveAreaPercentage: loveAreaPercentage ?? this.loveAreaPercentage,
      financeArea: financeArea ?? this.financeArea,
      financeAreaPercentage: financeAreaPercentage ?? this.financeAreaPercentage,
      advice: advice ?? this.advice,
    );
  }
}
