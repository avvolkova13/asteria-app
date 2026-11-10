import 'package:asteria_app/app/data/models/horoscope/horoscope_shared_model.dart';

class HoroscopeDayModel {
  final DateTime dateUntil;
  final bool isKeyThemeOpened;
  final bool isWeaknessOpened;
  final String focus;
  final String risk;
  final HoroscopeAreaModel personalArea;
  final List<HoroscopeWeakPointModel> personalWeakPoints;
  final String personalAreaPercentage;
  final HoroscopeAreaModel loveArea;
  final List<HoroscopeWeakPointModel> loveWeakPoints;
  final String loveAreaPercentage;
  final HoroscopeAreaModel financeArea;
  final List<HoroscopeWeakPointModel> financeWeakPoints;
  final String financeAreaPercentage;
  final String spotlight;

  const HoroscopeDayModel({
    required this.dateUntil,
    this.isKeyThemeOpened = true,
    this.isWeaknessOpened = true,
    required this.focus,
    required this.risk,
    required this.personalArea,
    required this.personalWeakPoints,
    required this.personalAreaPercentage,
    required this.loveArea,
    required this.loveWeakPoints,
    required this.loveAreaPercentage,
    required this.financeArea,
    required this.financeWeakPoints,
    required this.financeAreaPercentage,
    required this.spotlight,
  });

  factory HoroscopeDayModel.fromJson(Map<String, dynamic> json) {
    return HoroscopeDayModel(
      dateUntil: DateTime.parse(json['date_until'] as String),
      isKeyThemeOpened: true,
      isWeaknessOpened: true,
      focus: json['focus'] as String,
      risk: json['risk'] as String,
      personalArea: HoroscopeAreaModel.fromJson(json['personal_area'] as Map<String, dynamic>),
      personalWeakPoints: (json['personal_weak_points'] as List)
          .map((e) => HoroscopeWeakPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      personalAreaPercentage: json['personal_area_persentage'] as String,
      loveArea: HoroscopeAreaModel.fromJson(json['love_area'] as Map<String, dynamic>),
      loveWeakPoints: (json['love_weak_points'] as List)
          .map((e) => HoroscopeWeakPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      loveAreaPercentage: json['love_area_persentage'] as String,
      financeArea: HoroscopeAreaModel.fromJson(json['finance_area'] as Map<String, dynamic>),
      financeWeakPoints: (json['finance_weak_points'] as List)
          .map((e) => HoroscopeWeakPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      financeAreaPercentage: json['finance_area_persentage'] as String,
      spotlight: json['spotlight'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_until': dateUntil.toIso8601String(),
      'is_key_theme_opened': isKeyThemeOpened,
      'is_weakness_opened': isWeaknessOpened,
      'focus': focus,
      'risk': risk,
      'personal_area': personalArea.toJson(),
      'personal_weak_points': personalWeakPoints.map((e) => e.toJson()).toList(),
      'personal_area_persentage': personalAreaPercentage,
      'love_area': loveArea.toJson(),
      'love_weak_points': loveWeakPoints.map((e) => e.toJson()).toList(),
      'love_area_persentage': loveAreaPercentage,
      'finance_area': financeArea.toJson(),
      'finance_weak_points': financeWeakPoints.map((e) => e.toJson()).toList(),
      'finance_area_persentage': financeAreaPercentage,
      'spotlight': spotlight,
    };
  }

  HoroscopeDayModel copyWith({
    DateTime? dateUntil,
    bool? isKeyThemeOpened,
    bool? isWeaknessOpened,
    String? focus,
    String? risk,
    HoroscopeAreaModel? personalArea,
    List<HoroscopeWeakPointModel>? personalWeakPoints,
    String? personalAreaPercentage,
    HoroscopeAreaModel? loveArea,
    List<HoroscopeWeakPointModel>? loveWeakPoints,
    String? loveAreaPercentage,
    HoroscopeAreaModel? financeArea,
    List<HoroscopeWeakPointModel>? financeWeakPoints,
    String? financeAreaPercentage,
    String? spotlight,
  }) {
    return HoroscopeDayModel(
      dateUntil: dateUntil ?? this.dateUntil,
      isKeyThemeOpened: isKeyThemeOpened ?? this.isKeyThemeOpened,
      isWeaknessOpened: isWeaknessOpened ?? this.isWeaknessOpened,
      focus: focus ?? this.focus,
      risk: risk ?? this.risk,
      personalArea: personalArea ?? this.personalArea,
      personalWeakPoints: personalWeakPoints ?? this.personalWeakPoints,
      personalAreaPercentage: personalAreaPercentage ?? this.personalAreaPercentage,
      loveArea: loveArea ?? this.loveArea,
      loveWeakPoints: loveWeakPoints ?? this.loveWeakPoints,
      loveAreaPercentage: loveAreaPercentage ?? this.loveAreaPercentage,
      financeArea: financeArea ?? this.financeArea,
      financeWeakPoints: financeWeakPoints ?? this.financeWeakPoints,
      financeAreaPercentage: financeAreaPercentage ?? this.financeAreaPercentage,
      spotlight: spotlight ?? this.spotlight,
    );
  }
}
