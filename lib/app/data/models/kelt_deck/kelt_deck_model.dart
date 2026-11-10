class KeltDeckModel {
  final Map<String, bool> keltDeckCards;
  final String? interpretation;
  final String? executionId;

  const KeltDeckModel({
    required this.keltDeckCards,
    this.interpretation,
    this.executionId,
  });

  factory KeltDeckModel.fromJson(Map<String, dynamic> json) {
    return KeltDeckModel(
      keltDeckCards: Map<String, bool>.from(json['kelt_deck_cards'] as Map),
      interpretation: json['interpretation'] as String?,
      executionId: json['execution_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kelt_deck_cards': keltDeckCards,
      'interpretation': interpretation,
      if (executionId != null) 'execution_id': executionId,
    };
  }

  KeltDeckModel copyWith({
    Map<String, bool>? keltDeckCards,
    String? interpretation,
    String? executionId,
  }) {
    return KeltDeckModel(
      keltDeckCards: keltDeckCards ?? this.keltDeckCards,
      interpretation: interpretation ?? this.interpretation,
      executionId: executionId ?? this.executionId,
    );
  }
}
