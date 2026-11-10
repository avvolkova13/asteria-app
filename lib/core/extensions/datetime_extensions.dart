import 'package:asteria_app/core/localization/locale_formatters.dart';
import 'package:flutter/widgets.dart';

/// Знаки зодиака
enum ZodiacSign {
  aries('aries', 'oven'),
  taurus('taurus', 'telec'),
  gemini('gemini', 'bliznecy'),
  cancer('cancer', 'rak'),
  leo('leo', 'lev'),
  virgo('virgo', 'deva'),
  libra('libra', 'vesy'),
  scorpio('scorpio', 'skorpion'),
  sagittarius('sagittarius', 'strelec'),
  capricorn('capricorn', 'kozerog'),
  aquarius('aquarius', 'vodoley'),
  pisces('pisces', 'ryby');

  const ZodiacSign(this.id, this.assetName);

  final String id;

  /// Название ассета для изображения знака
  final String assetName;
}

extension DateTimeExtensions on DateTime {
  String toLocalizedDate(Locale locale) =>
      LocaleFormatters.longDate(this, locale);

  String toLocalizedDateDayMonth(Locale locale) =>
      LocaleFormatters.dayMonth(this, locale);

  String toLocalizedShortDate(Locale locale) =>
      LocaleFormatters.shortDate(this, locale);

  /// Canonical date value for API payloads, cache keys, and persistence.
  String toIsoDate() {
    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }

  /// Legacy data format retained for parsing existing records only.
  String toShortDate() {
    return '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
  }

  /// Stable 24-hour value for API payloads and persistence, never for UI.
  String getBirthTime() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Возвращает знак зодиака по дате рождения
  ZodiacSign getZodiacSign() {
    final month = this.month;
    final day = this.day;

    switch (month) {
      case 1: // Январь
        return day <= 19 ? ZodiacSign.capricorn : ZodiacSign.aquarius;
      case 2: // Февраль
        return day <= 18 ? ZodiacSign.aquarius : ZodiacSign.pisces;
      case 3: // Март
        return day <= 20 ? ZodiacSign.pisces : ZodiacSign.aries;
      case 4: // Апрель
        return day <= 19 ? ZodiacSign.aries : ZodiacSign.taurus;
      case 5: // Май
        return day <= 20 ? ZodiacSign.taurus : ZodiacSign.gemini;
      case 6: // Июнь
        return day <= 20 ? ZodiacSign.gemini : ZodiacSign.cancer;
      case 7: // Июль
        return day <= 22 ? ZodiacSign.cancer : ZodiacSign.leo;
      case 8: // Август
        return day <= 22 ? ZodiacSign.leo : ZodiacSign.virgo;
      case 9: // Сентябрь
        return day <= 22 ? ZodiacSign.virgo : ZodiacSign.libra;
      case 10: // Октябрь
        return day <= 22 ? ZodiacSign.libra : ZodiacSign.scorpio;
      case 11: // Ноябрь
        return day <= 21 ? ZodiacSign.scorpio : ZodiacSign.sagittarius;
      case 12: // Декабрь
        return day <= 21 ? ZodiacSign.sagittarius : ZodiacSign.capricorn;
      default:
        throw ArgumentError('Некорректная дата');
    }
  }

  String getZodiacSignName({String languageCode = 'ru'}) {
    return _zodiacNames[languageCode]?[getZodiacSign()] ??
        _zodiacNames['en']![getZodiacSign()]!;
  }

  /// Возвращает название ассета для знака зодиака
  String getZodiacSignAsset() {
    return getZodiacSign().assetName;
  }

  /// Возвращает стихию по дате рождения
  String getElement({String languageCode = 'ru'}) {
    final zodiac = getZodiacSign();
    final isRussian = languageCode == 'ru';
    switch (zodiac) {
      case ZodiacSign.aries:
      case ZodiacSign.leo:
      case ZodiacSign.sagittarius:
        return isRussian ? 'Огонь' : 'Fire';
      case ZodiacSign.taurus:
      case ZodiacSign.virgo:
      case ZodiacSign.capricorn:
        return isRussian ? 'Земля' : 'Earth';
      case ZodiacSign.gemini:
      case ZodiacSign.libra:
      case ZodiacSign.aquarius:
        return isRussian ? 'Воздух' : 'Air';
      case ZodiacSign.cancer:
      case ZodiacSign.scorpio:
      case ZodiacSign.pisces:
        return isRussian ? 'Вода' : 'Water';
    }
  }

  /// Возвращает планету-управителя по дате рождения
  String getPlanet({String languageCode = 'ru'}) {
    final zodiac = getZodiacSign();
    final isRussian = languageCode == 'ru';
    switch (zodiac) {
      case ZodiacSign.aries:
        return isRussian ? 'Марс' : 'Mars';
      case ZodiacSign.taurus:
        return isRussian ? 'Венера' : 'Venus';
      case ZodiacSign.gemini:
        return isRussian ? 'Меркурий' : 'Mercury';
      case ZodiacSign.cancer:
        return isRussian ? 'Луна' : 'Moon';
      case ZodiacSign.leo:
        return isRussian ? 'Солнце' : 'Sun';
      case ZodiacSign.virgo:
        return isRussian ? 'Меркурий' : 'Mercury';
      case ZodiacSign.libra:
        return isRussian ? 'Венера' : 'Venus';
      case ZodiacSign.scorpio:
        return isRussian ? 'Марс' : 'Mars';
      case ZodiacSign.sagittarius:
        return isRussian ? 'Юпитер' : 'Jupiter';
      case ZodiacSign.capricorn:
        return isRussian ? 'Сатурн' : 'Saturn';
      case ZodiacSign.aquarius:
        return isRussian ? 'Уран' : 'Uranus';
      case ZodiacSign.pisces:
        return isRussian ? 'Нептун' : 'Neptune';
    }
  }

  /// Возвращает характер по дате рождения
  String getCharacter({String languageCode = 'ru'}) {
    final element = getElement(languageCode: 'en');
    final isRussian = languageCode == 'ru';
    switch (element) {
      case 'Fire':
        return isRussian ? 'Страстный' : 'Passionate';
      case 'Earth':
        return isRussian ? 'Устойчивый' : 'Grounded';
      case 'Air':
        return isRussian ? 'Изменчивый' : 'Adaptable';
      case 'Water':
        return isRussian ? 'Эмоциональный' : 'Emotional';
      default:
        return isRussian ? 'Неизвестный' : 'Unknown';
    }
  }
}

const Map<String, Map<ZodiacSign, String>> _zodiacNames = {
  'ru': {
    ZodiacSign.aries: 'Овен',
    ZodiacSign.taurus: 'Телец',
    ZodiacSign.gemini: 'Близнецы',
    ZodiacSign.cancer: 'Рак',
    ZodiacSign.leo: 'Лев',
    ZodiacSign.virgo: 'Дева',
    ZodiacSign.libra: 'Весы',
    ZodiacSign.scorpio: 'Скорпион',
    ZodiacSign.sagittarius: 'Стрелец',
    ZodiacSign.capricorn: 'Козерог',
    ZodiacSign.aquarius: 'Водолей',
    ZodiacSign.pisces: 'Рыбы',
  },
  'en': {
    ZodiacSign.aries: 'Aries',
    ZodiacSign.taurus: 'Taurus',
    ZodiacSign.gemini: 'Gemini',
    ZodiacSign.cancer: 'Cancer',
    ZodiacSign.leo: 'Leo',
    ZodiacSign.virgo: 'Virgo',
    ZodiacSign.libra: 'Libra',
    ZodiacSign.scorpio: 'Scorpio',
    ZodiacSign.sagittarius: 'Sagittarius',
    ZodiacSign.capricorn: 'Capricorn',
    ZodiacSign.aquarius: 'Aquarius',
    ZodiacSign.pisces: 'Pisces',
  },
};

extension StringToDateTimeExtension on String {
  /// Парсит дату из формата "dd-MM-yyyy" в DateTime
  DateTime parseShortDate() {
    final parts = split('-');
    if (parts.length != 3) {
      throw FormatException(
        'Неверный формат даты. Ожидается: dd-MM-yyyy, получено: $this',
      );
    }

    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    return DateTime(year, month, day);
  }
}
