class TarotCardModel {
  final String id;
  final String title;
  final String imageName;
  final int sort;
  final List<String> keywords;
  final String cardOfDayDescription;
  final String generalDescription;
  final String shortDescription;
  final List<String> textInDecks;
  final List<String> keltDeck;
  final List<String> keltDeckImpact;
  final List<String> loveDeck;

  const TarotCardModel({
    required this.id,
    required this.title,
    required this.imageName,
    required this.sort,
    required this.keywords,
    required this.cardOfDayDescription,
    required this.generalDescription,
    required this.shortDescription,
    required this.textInDecks,
    required this.keltDeck,
    required this.keltDeckImpact,
    required this.loveDeck,
  });

  factory TarotCardModel.fromJson(Map<String, dynamic> json) {
    return TarotCardModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageName: json['image_name'] as String,
      sort: json['sort'] as int,
      keywords: (json['keywords'] as List).map((e) => e as String).toList(),
      cardOfDayDescription: json['card_of_day_description'] as String,
      generalDescription: json['general_description'] as String,
      shortDescription: json['short_description'] as String,
      textInDecks: (json['text_in_decks'] as List).map((e) => e as String).toList(),
      keltDeck: (json['kelt_deck'] as List).map((e) => e as String).toList(),
      keltDeckImpact: (json['kelt_deck_impact'] as List).map((e) => e as String).toList(),
      loveDeck: (json['love_deck'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_name': imageName,
      'sort': sort,
      'keywords': keywords,
      'card_of_day_description': cardOfDayDescription,
      'general_description': generalDescription,
      'short_description': shortDescription,
      'text_in_decks': textInDecks,
      'kelt_deck': keltDeck,
      'kelt_deck_impact': keltDeckImpact,
      'love_deck': loveDeck,
    };
  }

  TarotCardModel copyWith({
    String? id,
    String? title,
    String? imageName,
    int? sort,
    List<String>? keywords,
    String? cardOfDayDescription,
    String? generalDescription,
    String? shortDescription,
    List<String>? textInDecks,
    List<String>? keltDeck,
    List<String>? keltDeckImpact,
    List<String>? loveDeck,
  }) {
    return TarotCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageName: imageName ?? this.imageName,
      sort: sort ?? this.sort,
      keywords: keywords ?? this.keywords,
      cardOfDayDescription: cardOfDayDescription ?? this.cardOfDayDescription,
      generalDescription: generalDescription ?? this.generalDescription,
      shortDescription: shortDescription ?? this.shortDescription,
      textInDecks: textInDecks ?? this.textInDecks,
      keltDeck: keltDeck ?? this.keltDeck,
      keltDeckImpact: keltDeckImpact ?? this.keltDeckImpact,
      loveDeck: loveDeck ?? this.loveDeck,
    );
  }
}
