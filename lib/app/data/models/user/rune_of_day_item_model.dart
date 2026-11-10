class RuneOfDayItemModel {
  final String runeId;
  final String date;
  final bool isOpened;

  const RuneOfDayItemModel({required this.runeId, required this.date, required this.isOpened});

  factory RuneOfDayItemModel.fromJson(Map<String, dynamic> json) {
    return RuneOfDayItemModel(
      runeId: json['rune_id'] as String? ?? json['runeId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      isOpened: json['is_opened'] as bool? ?? json['isOpened'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'rune_id': runeId, 'date': date, 'is_opened': isOpened};
  }

  RuneOfDayItemModel copyWith({String? runeId, String? date, bool? isOpened}) {
    return RuneOfDayItemModel(runeId: runeId ?? this.runeId, date: date ?? this.date, isOpened: isOpened ?? this.isOpened);
  }
}
