import 'dart:ui';

import 'package:asteria_app/app/data/models/article/article_model.dart';

/// Short editorial labels for the current library. The original heading and
/// complete article remain available on the reading screen.
String articleCardTitle(ArticleModel article, Locale locale) {
  final copy = _titles[article.id];
  if (copy == null || !copy.topic.hasMatch(article.title)) return article.title;
  return locale.languageCode == 'ru' ? copy.ru : copy.en;
}

final _titles = <String, _ArticleTitle>{
  'article1': _ArticleTitle(
    r'совместим|compatib',
    'Совместимость знаков',
    'Zodiac compatibility',
  ),
  'article2': _ArticleTitle(
    r'встреч|encounter|meeting',
    'Повторяющиеся встречи',
    'Recurring encounters',
  ),
  'article3': _ArticleTitle(
    r'предназнач|purpose|destin|path',
    'Как найти своё направление',
    'Finding your direction',
  ),
  'article4': _ArticleTitle(
    r'ран[ыа]|wound|choos|похож',
    'Привычные сценарии в отношениях',
    'Familiar relationship patterns',
  ),
  'article5': _ArticleTitle(
    r'деньг|money|abundan',
    'Деньги и внутреннее состояние',
    'Money and your mindset',
  ),
  'article6': _ArticleTitle(
    r'тел[оа]|организм|body',
    'Как услышать своё тело',
    'Listening to your body',
  ),
  'article7': _ArticleTitle(
    r'натальн|birth chart|natal',
    'Возможности натальной карты',
    'Exploring your birth chart',
  ),
  'article8': _ArticleTitle(
    r'транзит|transit',
    'Транзиты и поворотные моменты',
    'Transits and turning points',
  ),
  'article9': _ArticleTitle(
    r'интуиц|intuition|sixth sense',
    'Как распознать интуицию',
    'Recognising your intuition',
  ),
  'article10': _ArticleTitle(
    r'поток|flow',
    'Как войти в творческий поток',
    'Finding your creative flow',
  ),
};

class _ArticleTitle {
  _ArticleTitle(String topic, this.ru, this.en)
    : topic = RegExp(topic, caseSensitive: false);

  final RegExp topic;
  final String ru;
  final String en;
}
