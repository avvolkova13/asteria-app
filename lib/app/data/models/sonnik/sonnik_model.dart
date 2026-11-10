import 'package:uuid/uuid.dart';

class SonnikModel {
  final String id;
  final DateTime dateGenerated;
  final String title;
  final String interpretation;
  final String locale;

  const SonnikModel({
    required this.id,
    required this.dateGenerated,
    required this.title,
    required this.interpretation,
    this.locale = 'ru',
  });

  factory SonnikModel.fromJson(Map<String, dynamic> json) {
    return SonnikModel(
      id: json['id'] as String? ?? const Uuid().v4(),
      dateGenerated:
          DateTime.tryParse(json['date_generated'] as String? ?? '') ??
          DateTime.now(),
      title: json['title'] as String,
      interpretation: json['interpretation'] as String,
      locale: (json['locale'] as String?) ?? 'ru',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_generated': dateGenerated.toIso8601String(),
      'title': title,
      'interpretation': interpretation,
      'locale': locale,
    };
  }

  SonnikModel copyWith({
    String? id,
    DateTime? dateGenerated,
    String? title,
    String? interpretation,
    String? locale,
  }) {
    return SonnikModel(
      id: id ?? this.id,
      dateGenerated: dateGenerated ?? this.dateGenerated,
      title: title ?? this.title,
      interpretation: interpretation ?? this.interpretation,
      locale: locale ?? this.locale,
    );
  }
}
