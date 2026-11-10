part of 'user_model.dart';

/// Persisted achievement counters returned by the user profile API.
class UserStatisticsModel {
  final int tarotCardsOpened;
  final int horoscopeOpened;
  final int runesOpened;

  const UserStatisticsModel({
    this.tarotCardsOpened = 0,
    this.horoscopeOpened = 0,
    this.runesOpened = 0,
  });

  factory UserStatisticsModel.fromJson(Map<String, dynamic> json) {
    int count(String key) {
      final value = json[key];
      return value is num && value.isFinite && value >= 0 ? value.toInt() : 0;
    }

    return UserStatisticsModel(
      tarotCardsOpened: count('tarot_cards_opened'),
      horoscopeOpened: count('horoscope_opened'),
      runesOpened: count('runes_opened'),
    );
  }

  Map<String, dynamic> toJson() => {
    'tarot_cards_opened': tarotCardsOpened,
    'horoscope_opened': horoscopeOpened,
    'runes_opened': runesOpened,
  };
}
