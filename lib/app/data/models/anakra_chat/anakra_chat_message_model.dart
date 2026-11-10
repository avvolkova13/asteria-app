class AnakraChatMessageModel {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String locale;

  const AnakraChatMessageModel({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.locale = 'ru',
  });

  factory AnakraChatMessageModel.fromJson(Map<String, dynamic> json) {
    return AnakraChatMessageModel(
      text: json['text'] as String,
      isUser: json['is_user'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      locale: (json['locale'] as String?) ?? 'ru',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'is_user': isUser,
      'timestamp': timestamp.toIso8601String(),
      'locale': locale,
    };
  }

  AnakraChatMessageModel copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? locale,
  }) {
    return AnakraChatMessageModel(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      locale: locale ?? this.locale,
    );
  }
}
