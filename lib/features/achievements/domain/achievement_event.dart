import 'dart:convert';
import 'package:crypto/crypto.dart';

enum AchievementEventKind {
  tarotDay('tarot_day'),
  runeDay('rune_day'),
  horoscope('horoscope');

  const AchievementEventKind(this.wireValue);
  final String wireValue;
}

class AchievementEvent {
  const AchievementEvent({
    required this.userId,
    required this.kind,
    required this.reference,
  });

  final String userId;
  final AchievementEventKind kind;
  // Day of the revealed symbol, or horoscope type + expiry calendar date.
  final String reference;

  String get key =>
      sha256.convert(utf8.encode(jsonEncode(toJson()))).toString();

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'kind': kind.wireValue,
    'reference': reference,
  };

  factory AchievementEvent.fromJson(Map<String, dynamic> json) =>
      AchievementEvent(
        userId: json['user_id'] as String,
        kind: AchievementEventKind.values.firstWhere(
          (value) => value.wireValue == json['kind'],
        ),
        reference: json['reference'] as String,
      );
}
