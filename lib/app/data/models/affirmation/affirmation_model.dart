class AffirmationModel {
  final String id;
  final String categoryId;
  final String category;
  final String text;
  final int sort;

  const AffirmationModel({
    required this.id,
    this.categoryId = '',
    required this.category,
    required this.text,
    required this.sort,
  });

  String get effectiveCategoryId => categoryId.isNotEmpty
      ? categoryId
      : affirmationCategoryIdFromLegacy(category);

  factory AffirmationModel.fromJson(Map<String, dynamic> json) {
    return AffirmationModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String? ?? '',
      category: json['category'] as String,
      text: json['text'] as String,
      sort: json['sort'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': effectiveCategoryId,
      'category': category,
      'text': text,
      'sort': sort,
    };
  }

  AffirmationModel copyWith({
    String? id,
    String? categoryId,
    String? category,
    String? text,
    int? sort,
  }) {
    return AffirmationModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      text: text ?? this.text,
      sort: sort ?? this.sort,
    );
  }
}

String affirmationCategoryIdFromLegacy(String category) {
  return switch (category.trim().toLowerCase()) {
    'любовь' || 'love' => 'love',
    'изобилие' || 'abundance' => 'abundance',
    'сила' || 'strength' => 'strength',
    'творчество' || 'creativity' => 'creativity',
    'лунные' || 'lunar' => 'lunar',
    'спокойствие' || 'calm' => 'calm',
    _ => category.trim().toLowerCase(),
  };
}
