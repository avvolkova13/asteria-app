class TarotCardOfDayItemModel {
  final String cardId;
  final String date;
  final bool isOpened;

  const TarotCardOfDayItemModel({required this.cardId, required this.date, required this.isOpened});

  factory TarotCardOfDayItemModel.fromJson(Map<String, dynamic> json) {
    return TarotCardOfDayItemModel(
      cardId: json['card_id'] as String? ?? json['cardId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      isOpened: json['is_opened'] as bool? ?? json['isOpened'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'card_id': cardId, 'date': date, 'is_opened': isOpened};
  }

  TarotCardOfDayItemModel copyWith({String? cardId, String? date, bool? isOpened}) {
    return TarotCardOfDayItemModel(cardId: cardId ?? this.cardId, date: date ?? this.date, isOpened: isOpened ?? this.isOpened);
  }
}
