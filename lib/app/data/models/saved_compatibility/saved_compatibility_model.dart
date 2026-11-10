import 'package:asteria_app/app/data/models/prompt_response.dart';

class SavedCompatibilityModel {
  final String id;
  final CompatibilityData compatibilityData;
  final DateTime firstBirthdate;
  final DateTime secondBirthdate;
  final String generalPercentage;
  final DateTime createdAt;
  final String locale;

  const SavedCompatibilityModel({
    required this.id,
    required this.compatibilityData,
    required this.firstBirthdate,
    required this.secondBirthdate,
    required this.generalPercentage,
    required this.createdAt,
    this.locale = 'ru',
  });

  factory SavedCompatibilityModel.fromJson(Map<String, dynamic> json) {
    return SavedCompatibilityModel(
      id: json['id'] as String,
      compatibilityData: CompatibilityData.fromJson(
        json['compatibility_data'] as Map<String, dynamic>,
      ),
      firstBirthdate: DateTime.parse(json['first_birthdate'] as String),
      secondBirthdate: DateTime.parse(json['second_birthdate'] as String),
      generalPercentage: json['general_percentage'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      locale: (json['locale'] as String?) ?? 'ru',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'compatibility_data': compatibilityData.toJson(),
      'first_birthdate': firstBirthdate.toIso8601String(),
      'second_birthdate': secondBirthdate.toIso8601String(),
      'general_percentage': generalPercentage,
      'created_at': createdAt.toIso8601String(),
      'locale': locale,
    };
  }

  SavedCompatibilityModel copyWith({
    String? id,
    CompatibilityData? compatibilityData,
    DateTime? firstBirthdate,
    DateTime? secondBirthdate,
    String? generalPercentage,
    DateTime? createdAt,
    String? locale,
  }) {
    return SavedCompatibilityModel(
      id: id ?? this.id,
      compatibilityData: compatibilityData ?? this.compatibilityData,
      firstBirthdate: firstBirthdate ?? this.firstBirthdate,
      secondBirthdate: secondBirthdate ?? this.secondBirthdate,
      generalPercentage: generalPercentage ?? this.generalPercentage,
      createdAt: createdAt ?? this.createdAt,
      locale: locale ?? this.locale,
    );
  }
}
