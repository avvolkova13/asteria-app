part of 'user_model.dart';

class BirthDateModel {
  final DateTime birthDate;
  final DateTime? birthTime;

  const BirthDateModel({required this.birthDate, this.birthTime});

  factory BirthDateModel.fromJson(Map<String, dynamic> json) {
    return BirthDateModel(
      birthDate: DateTime.parse(json['birth_date'] as String),
      birthTime: json['birth_time'] != null ? DateTime.parse(json['birth_time'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'birth_date': birthDate.toIso8601String(), 'birth_time': birthTime?.toIso8601String()};
  }

  BirthDateModel copyWith({DateTime? birthDate, DateTime? birthTime}) {
    return BirthDateModel(birthDate: birthDate ?? this.birthDate, birthTime: birthTime ?? this.birthTime);
  }
}
