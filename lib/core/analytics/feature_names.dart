/// Stable, snake_case feature identifiers attached to product events as
/// `feature_name`. Used to group funnels in dashboards regardless of
/// which screen / cubit emitted the event.
enum FeatureName {
  compatibility,
  natalChart,
  sonnik,
  anakraChat,
  tarot,
  runes,
  loveDeck,
  keltDeck,
  horoscope,
  moonCalendar,
  shop,
  coins,
  subscription;

  String get eventValue {
    switch (this) {
      case FeatureName.compatibility:
        return 'compatibility';
      case FeatureName.natalChart:
        return 'natal_chart';
      case FeatureName.sonnik:
        return 'sonnik';
      case FeatureName.anakraChat:
        return 'anakra_chat';
      case FeatureName.tarot:
        return 'tarot';
      case FeatureName.runes:
        return 'runes';
      case FeatureName.loveDeck:
        return 'love_deck';
      case FeatureName.keltDeck:
        return 'kelt_deck';
      case FeatureName.horoscope:
        return 'horoscope';
      case FeatureName.moonCalendar:
        return 'moon_calendar';
      case FeatureName.shop:
        return 'shop';
      case FeatureName.coins:
        return 'coins';
      case FeatureName.subscription:
        return 'subscription';
    }
  }
}
