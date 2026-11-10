class HealthModel {
  final int status;
  final String healthAndImmunity;
  final String dailyDiet;
  final String weightLossAndFastingDays;
  final String sleepAndRecovery;
  final String physicalActivityAndSports;
  final String medicalProcedures;
  final String meditations;

  const HealthModel({
    required this.status,
    required this.healthAndImmunity,
    required this.dailyDiet,
    required this.weightLossAndFastingDays,
    required this.sleepAndRecovery,
    required this.physicalActivityAndSports,
    required this.medicalProcedures,
    required this.meditations,
  });

  factory HealthModel.fromJson(Map<String, dynamic> json) {
    return HealthModel(
      status: json['status'] as int,
      healthAndImmunity: json['health_and_immunity'] as String,
      dailyDiet: json['daily_diet'] as String,
      weightLossAndFastingDays: json['weight_loss_and_fasting_days'] as String,
      sleepAndRecovery: json['sleep_and_recovery'] as String,
      physicalActivityAndSports: json['physical_activity_and_sports'] as String,
      medicalProcedures: json['medical_procedures'] as String,
      meditations: json['meditations'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'health_and_immunity': healthAndImmunity,
      'daily_diet': dailyDiet,
      'weight_loss_and_fasting_days': weightLossAndFastingDays,
      'sleep_and_recovery': sleepAndRecovery,
      'physical_activity_and_sports': physicalActivityAndSports,
      'medical_procedures': medicalProcedures,
      'meditations': meditations,
    };
  }

  HealthModel copyWith({
    int? status,
    String? healthAndImmunity,
    String? dailyDiet,
    String? weightLossAndFastingDays,
    String? sleepAndRecovery,
    String? physicalActivityAndSports,
    String? medicalProcedures,
    String? meditations,
  }) {
    return HealthModel(
      status: status ?? this.status,
      healthAndImmunity: healthAndImmunity ?? this.healthAndImmunity,
      dailyDiet: dailyDiet ?? this.dailyDiet,
      weightLossAndFastingDays:
          weightLossAndFastingDays ?? this.weightLossAndFastingDays,
      sleepAndRecovery: sleepAndRecovery ?? this.sleepAndRecovery,
      physicalActivityAndSports:
          physicalActivityAndSports ?? this.physicalActivityAndSports,
      medicalProcedures: medicalProcedures ?? this.medicalProcedures,
      meditations: meditations ?? this.meditations,
    );
  }
}
