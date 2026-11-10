class RuneInDeckModel {
  final String id;
  final bool isOpened;

  const RuneInDeckModel({required this.id, required this.isOpened});

  factory RuneInDeckModel.fromJson(Map<String, dynamic> json) {
    return RuneInDeckModel(
      id: json['id'] as String? ?? '',
      isOpened: json['is_opened'] as bool? ?? json['isOpened'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'is_opened': isOpened};
  }

  RuneInDeckModel copyWith({String? id, bool? isOpened}) {
    return RuneInDeckModel(id: id ?? this.id, isOpened: isOpened ?? this.isOpened);
  }
}

class RuneDeckModel {
  final List<RuneInDeckModel> cards;
  final String? interpretation;

  const RuneDeckModel({required this.cards, this.interpretation});

  factory RuneDeckModel.fromJson(Map<String, dynamic> json) {
    final cardsList = json['cards'] as List<dynamic>?;
    final parsedCards = cardsList != null
        ? cardsList.map((e) => RuneInDeckModel.fromJson(e as Map<String, dynamic>)).toList()
        : <RuneInDeckModel>[];
    final cards = _ensureLayoutCards(parsedCards);
    return RuneDeckModel(
      cards: cards,
      interpretation: json['interpretation'] as String?,
    );
  }

  static List<RuneInDeckModel> _ensureLayoutCards(List<RuneInDeckModel> parsed) {
    const layoutSize = 3;
    if (parsed.length >= layoutSize) {
      return parsed.sublist(0, layoutSize);
    }
    final result = List<RuneInDeckModel>.from(parsed);
    while (result.length < layoutSize) {
      result.add(const RuneInDeckModel(id: '', isOpened: false));
    }
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((e) => e.toJson()).toList(),
      'interpretation': interpretation,
    };
  }

  RuneDeckModel copyWith({List<RuneInDeckModel>? cards, String? interpretation}) {
    return RuneDeckModel(
      cards: cards ?? this.cards,
      interpretation: interpretation ?? this.interpretation,
    );
  }
}
