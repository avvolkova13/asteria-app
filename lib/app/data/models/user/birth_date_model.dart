part of 'user_model.dart';

class BirthDateModel {
  final DateTime birthDate;
  final DateTime? birthTime;
  final bool? birthTimeKnown;

  const BirthDateModel({
    required this.birthDate,
    this.birthTime,
    this.birthTimeKnown,
  });

  bool get hasExactBirthTime {
    final time = birthTime;
    if (time == null) return false;
    // Legacy registration used noon or midnight for its approximate choices.
    return birthTimeKnown ??
        !(time.minute == 0 && (time.hour == 0 || time.hour == 12));
  }

  factory BirthDateModel.fromJson(Map<String, dynamic> json) {
    return BirthDateModel(
      birthDate: DateTime.parse(json['birth_date'] as String),
      birthTime: json['birth_time'] != null
          ? DateTime.parse(json['birth_time'] as String)
          : null,
      birthTimeKnown: json['birth_time_known'] is bool
          ? json['birth_time_known'] as bool
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'birth_date': birthDate.toIso8601String(),
      'birth_time': birthTime?.toIso8601String(),
      if (birthTimeKnown != null) 'birth_time_known': birthTimeKnown,
    };
  }

  BirthDateModel copyWith({
    DateTime? birthDate,
    DateTime? birthTime,
    bool? birthTimeKnown,
  }) {
    return BirthDateModel(
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthTimeKnown: birthTimeKnown ?? this.birthTimeKnown,
    );
  }
}
