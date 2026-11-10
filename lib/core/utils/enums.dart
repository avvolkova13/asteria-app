import 'package:asteria_app/core/const/pricing_catalog.dart';

enum HoroscopeTypeEnum {
  day,
  week,
  month,
  year;

  int get price => switch (this) {
    HoroscopeTypeEnum.day => 0,
    HoroscopeTypeEnum.week => PricingCatalog.weeklyHoroscope,
    HoroscopeTypeEnum.month => PricingCatalog.monthlyHoroscope,
    HoroscopeTypeEnum.year => PricingCatalog.yearlyHoroscope,
  };

  String get russianPurchaseTitle => switch (this) {
    HoroscopeTypeEnum.day => 'Гороскоп на сегодня',
    HoroscopeTypeEnum.week => 'Гороскоп на неделю',
    HoroscopeTypeEnum.month => 'Гороскоп на месяц',
    HoroscopeTypeEnum.year => 'Гороскоп на год',
  };
}

enum DayHoroscopeOpenEnum {
  keyTheme,
  weaknesses;

  int get price => switch (this) {
    DayHoroscopeOpenEnum.keyTheme => 1,
    DayHoroscopeOpenEnum.weaknesses => 3,
  };
}

enum DeckType {
  kelt,
  love;

  int get cardCount => switch (this) {
    DeckType.kelt => 10,
    DeckType.love => 6,
  };

  String get key => switch (this) {
    DeckType.kelt => 'kelt_deck',
    DeckType.love => 'love_deck',
  };
}
