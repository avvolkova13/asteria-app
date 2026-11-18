import 'dart:ui';

import 'package:asteria_app/app/data/models/article/article_model.dart';

/// Shared editorial titles for cards, accessibility labels and the reader.
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
    'Неслучайные встречи',
    'Meaningful encounters',
  ),
  'article3': _ArticleTitle(
    r'предназнач|purpose|destin|path',
    'Три признака своего пути',
    'Three signs of your path',
  ),
  'article4': _ArticleTitle(
    r'ран[ыа]|wound|choos|похож',
    'Кого мы выбираем',
    'Who we choose',
  ),
  'article5': _ArticleTitle(
    r'деньг|money|abundan',
    'Деньги и самоощущение',
    'Money and mindset',
  ),
  'article6': _ArticleTitle(
    r'тел[оа]|организм|body',
    'Сигналы тела',
    'Body signals',
  ),
  'article7': _ArticleTitle(
    r'натальн|birth chart|natal',
    'Что даёт натальная карта',
    'What your birth chart shows',
  ),
  'article8': _ArticleTitle(
    r'транзит|transit',
    'Транзиты и перемены',
    'Transits and change',
  ),
  'article9': _ArticleTitle(
    r'интуиц|intuition|sixth sense',
    'Как работает интуиция',
    'How intuition works',
  ),
  'article10': _ArticleTitle(
    r'поток|flow',
    'Творческий поток',
    'Creative flow',
  ),
};

class _ArticleTitle {
  _ArticleTitle(String topic, this.ru, this.en)
    : topic = RegExp(topic, caseSensitive: false);

  final RegExp topic;
  final String ru;
  final String en;
}
