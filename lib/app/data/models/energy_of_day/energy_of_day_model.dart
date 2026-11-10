class EnergyOfDayModel {
  final String id;
  final DateTime date;
  final String focusPercentage;
  final String riskPercentage;
  final String focus;
  final String risk;
  final String phrase;

  const EnergyOfDayModel({
    required this.focusPercentage,
    required this.riskPercentage,
    required this.focus,
    required this.risk,
    required this.date,
    required this.phrase,
    required this.id,
  });

  factory EnergyOfDayModel.fromJson(Map<String, dynamic> json) {
    return EnergyOfDayModel(
      id: json['id'] as String,
      focusPercentage: json['focus_percentage'] as String,
      riskPercentage: json['risk_percentage'] as String,
      focus: json['focus'] as String,
      risk: json['risk'] as String,
      date: DateTime.parse(json['date'] as String),
      phrase: json['phrase'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'focus_percentage': focusPercentage,
      'risk_percentage': riskPercentage,
      'focus': focus,
      'risk': risk,
      'date': date.toIso8601String(),
      'phrase': phrase,
    };
  }

  EnergyOfDayModel copyWith({
    String? id,
    String? focusPercentage,
    String? riskPercentage,
    String? focus,
    String? risk,
    DateTime? date,
    String? phrase,
  }) {
    return EnergyOfDayModel(
      id: id ?? this.id,
      focusPercentage: focusPercentage ?? this.focusPercentage,
      riskPercentage: riskPercentage ?? this.riskPercentage,
      focus: focus ?? this.focus,
      risk: risk ?? this.risk,
      date: date ?? this.date,
      phrase: phrase ?? this.phrase,
    );
  }
}
