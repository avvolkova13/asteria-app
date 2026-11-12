import 'dart:ui';

import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/features/article/presentation/article_card_title.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ArticleModel article(String id, String title) => ArticleModel(
    id: id,
    title: title,
    category: '',
    intro: '',
    text: '',
    conclusion: '',
    timeToRead: 4,
  );

  test(
    'editorial labels stay short in both locales and preserve the source',
    () {
      const topics = {
        'article1': 'Совместимость по знакам',
        'article2': 'Повторяющиеся встречи',
        'article3': 'Три сигнала, что вы идёте по своему предназначению',
        'article4': 'Почему мы выбираем людей, похожих на наши раны',
        'article5': 'Почему деньги приходят только в состояние расширения',
        'article6': 'Почему тело говорит раньше, чем сознание',
        'article7': 'Почему ваша натальная карта — набор скрытых инструментов',
        'article8': 'Почему большие транзиты запускают точку невозврата',
        'article9': 'Интуиция как шестое чувство',
        'article10': 'Состояние потока: когда идеи приходят сами',
      };
      for (final topic in topics.entries) {
        final source = article(topic.key, topic.value);
        for (final locale in [const Locale('ru'), const Locale('en')]) {
          expect(
            articleCardTitle(source, locale).length,
            lessThanOrEqualTo(34),
          );
        }
        expect(source.title, topic.value);
      }
    },
  );

  test('new or replaced articles keep their own title', () {
    for (final id in ['article2', 'future-article']) {
      final source = article(id, 'Как наблюдать Луну с Земли');
      expect(articleCardTitle(source, const Locale('ru')), source.title);
      expect(articleCardTitle(source, const Locale('en')), source.title);
    }
  });
}
