class ArticleModel {
  final String id;
  final String title;
  final String category;
  final String intro;
  final String text;
  final String conclusion;
  final int timeToRead;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.category,
    required this.intro,
    required this.text,
    required this.conclusion,
    required this.timeToRead,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      intro: json['intro'] as String,
      text: json['text'] as String,
      conclusion: json['conclusion'] as String,
      timeToRead: json['time_to_read'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'intro': intro,
      'text': text,
      'conclusion': conclusion,
      'time_to_read': timeToRead,
    };
  }

  ArticleModel copyWith({
    String? id,
    String? title,
    String? category,
    String? intro,
    String? text,
    String? conclusion,
    int? timeToRead,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      intro: intro ?? this.intro,
      text: text ?? this.text,
      conclusion: conclusion ?? this.conclusion,
      timeToRead: timeToRead ?? this.timeToRead,
    );
  }
}
