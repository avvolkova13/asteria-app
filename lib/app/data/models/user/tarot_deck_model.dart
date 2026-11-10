class TarotCardInDeckModel {
  final String id;
  final bool isOpened;

  const TarotCardInDeckModel({required this.id, required this.isOpened});

  factory TarotCardInDeckModel.fromJson(Map<String, dynamic> json) {
    return TarotCardInDeckModel(
      id: json['id'] as String? ?? '',
      isOpened: json['is_opened'] as bool? ?? json['isOpened'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'is_opened': isOpened};
  }

  TarotCardInDeckModel copyWith({String? id, bool? isOpened}) {
    return TarotCardInDeckModel(id: id ?? this.id, isOpened: isOpened ?? this.isOpened);
  }
}

class InterpretationModel {
  final String love;
  final String selfRealization;
  final String spirituality;
  final String health;
  final String family;
  final String career;
  final String creativity;
  final String other;

  const InterpretationModel({
    required this.love,
    required this.selfRealization,
    required this.spirituality,
    required this.health,
    required this.family,
    required this.career,
    required this.creativity,
    required this.other,
  });

  factory InterpretationModel.fromJson(Map<String, dynamic> json) {
    return InterpretationModel(
      love: json['love'] as String? ?? '',
      selfRealization: json['selfRealization'] as String? ?? '',
      spirituality: json['spirituality'] as String? ?? '',
      health: json['health'] as String? ?? '',
      family: json['family'] as String? ?? '',
      career: json['career'] as String? ?? '',
      creativity: json['creativity'] as String? ?? '',
      other: json['other'] as String? ?? '',
    );
  }

  factory InterpretationModel.fromApiResponse(Map<String, dynamic> json) {
    return InterpretationModel(
      love: json['interpretation_love'] as String? ?? '',
      selfRealization: json['interpretation_self_realization'] as String? ?? '',
      spirituality: json['interpretation_spirituality'] as String? ?? '',
      health: json['interpretation_health'] as String? ?? '',
      family: json['interpretation_family'] as String? ?? '',
      career: json['interpretation_career'] as String? ?? '',
      creativity: '',
      other: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'love': love,
      'selfRealization': selfRealization,
      'spirituality': spirituality,
      'health': health,
      'family': family,
      'career': career,
      'creativity': creativity,
      'other': other,
    };
  }

  InterpretationModel copyWith({
    String? love,
    String? selfRealization,
    String? spirituality,
    String? health,
    String? family,
    String? career,
    String? creativity,
    String? other,
  }) {
    return InterpretationModel(
      love: love ?? this.love,
      selfRealization: selfRealization ?? this.selfRealization,
      spirituality: spirituality ?? this.spirituality,
      health: health ?? this.health,
      family: family ?? this.family,
      career: career ?? this.career,
      creativity: creativity ?? this.creativity,
      other: other ?? this.other,
    );
  }
}

class TarotDeckModel {
  final List<TarotCardInDeckModel> cards;
  final InterpretationModel? interpretation;

  const TarotDeckModel({required this.cards, this.interpretation});

  factory TarotDeckModel.fromJson(Map<String, dynamic> json) {
    final cardsList = json['cards'] as List<dynamic>?;
    final parsedCards = cardsList != null
        ? cardsList.map((e) => TarotCardInDeckModel.fromJson(e as Map<String, dynamic>)).toList()
        : <TarotCardInDeckModel>[];
    final cards = _ensureLayoutCards(parsedCards);
    return TarotDeckModel(
      cards: cards,
      interpretation: json['interpretation'] != null
          ? InterpretationModel.fromJson(json['interpretation'] as Map<String, dynamic>)
          : null,
    );
  }

  static List<TarotCardInDeckModel> _ensureLayoutCards(List<TarotCardInDeckModel> parsed) {
    const layoutSize = 3;
    if (parsed.length >= layoutSize) {
      return parsed.sublist(0, layoutSize);
    }
    final result = List<TarotCardInDeckModel>.from(parsed);
    while (result.length < layoutSize) {
      result.add(const TarotCardInDeckModel(id: '', isOpened: false));
    }
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((e) => e.toJson()).toList(),
      'interpretation': interpretation?.toJson(),
    };
  }

  TarotDeckModel copyWith({List<TarotCardInDeckModel>? cards, InterpretationModel? interpretation}) {
    return TarotDeckModel(cards: cards ?? this.cards, interpretation: interpretation ?? this.interpretation);
  }
}
