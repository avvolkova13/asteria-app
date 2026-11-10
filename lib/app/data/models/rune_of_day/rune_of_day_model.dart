class RuneOfDayModel {
  final String id;
  final String title;
  final String imageName;
  final int sort;
  final String cardOfDayDescription;
  final String generalDescription;
  final String pastDeck;
  final String presentDeck;
  final String futureDeck;
  final List<String> keywords;
  final List<String> definitions;

  const RuneOfDayModel({
    required this.id,
    required this.title,
    required this.imageName,
    required this.sort,
    required this.cardOfDayDescription,
    required this.generalDescription,
    required this.pastDeck,
    required this.presentDeck,
    required this.futureDeck,
    required this.keywords,
    required this.definitions,
  });

  factory RuneOfDayModel.fromJson(Map<String, dynamic> json) {
    return RuneOfDayModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageName: json['image_name'] as String,
      sort: json['sort'] as int,
      cardOfDayDescription: json['card_of_day_description'] as String,
      generalDescription: json['general_description'] as String,
      pastDeck: json['past_deck'] as String,
      presentDeck: json['present_deck'] as String,
      futureDeck: json['future_deck'] as String,
      keywords: (json['keywords'] as List).map((e) => e as String).toList(),
      definitions: (json['definitions'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_name': imageName,
      'sort': sort,
      'card_of_day_description': cardOfDayDescription,
      'general_description': generalDescription,
      'past_deck': pastDeck,
      'present_deck': presentDeck,
      'future_deck': futureDeck,
      'keywords': keywords,
      'definitions': definitions,
    };
  }

  RuneOfDayModel copyWith({
    String? id,
    String? title,
    String? imageName,
    int? sort,
    String? cardOfDayDescription,
    String? generalDescription,
    String? pastDeck,
    String? presentDeck,
    String? futureDeck,
    List<String>? keywords,
    List<String>? definitions,
  }) {
    return RuneOfDayModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageName: imageName ?? this.imageName,
      sort: sort ?? this.sort,
      cardOfDayDescription: cardOfDayDescription ?? this.cardOfDayDescription,
      generalDescription: generalDescription ?? this.generalDescription,
      pastDeck: pastDeck ?? this.pastDeck,
      presentDeck: presentDeck ?? this.presentDeck,
      futureDeck: futureDeck ?? this.futureDeck,
      keywords: keywords ?? this.keywords,
      definitions: definitions ?? this.definitions,
    );
  }
}
