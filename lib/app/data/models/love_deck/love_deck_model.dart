class LoveDeckModel {
  final Map<String, bool> loveDeckCards;
  final String? interpretation;
  final String? executionId;

  const LoveDeckModel({
    required this.loveDeckCards,
    this.interpretation,
    this.executionId,
  });

  factory LoveDeckModel.fromJson(Map<String, dynamic> json) {
    return LoveDeckModel(
      loveDeckCards: Map<String, bool>.from(json['love_deck_cards'] as Map),
      interpretation: json['interpretation'] as String?,
      executionId: json['execution_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'love_deck_cards': loveDeckCards,
      'interpretation': interpretation,
      if (executionId != null) 'execution_id': executionId,
    };
  }

  LoveDeckModel copyWith({
    Map<String, bool>? loveDeckCards,
    String? interpretation,
    String? executionId,
  }) {
    return LoveDeckModel(
      loveDeckCards: loveDeckCards ?? this.loveDeckCards,
      interpretation: interpretation ?? this.interpretation,
      executionId: executionId ?? this.executionId,
    );
  }
}
