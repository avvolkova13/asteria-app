import 'dart:io';

import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/scenarios/pair_conversation_tarot.dart';
import 'package:asteria_app/features/scenarios/pair_tarot_questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every bundled daily card has its own question in both languages', () {
    final images = Directory('assets/images/cards')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((name) => name.endsWith('.webp'))
        .map((name) => name.substring(0, name.length - '.webp'.length));
    expect(images.length, 78);
    expect(pairTarotQuestions.keys, unorderedEquals(images));
    expect(pairTarotQuestions.values.map((q) => q.ru).toSet(), hasLength(78));
    expect(pairTarotQuestions.values.map((q) => q.en).toSet(), hasLength(78));
  });

  testWidgets('manual reveal and revisiting use the same free daily card', (
    tester,
  ) async {
    final content = _Content();
    di.registerSingleton<ContentProvider>(content);
    addTearDown(() async {
      content.dispose();
      await di.reset();
    });
    final app = MaterialApp(
      locale: const Locale('ru'),
      supportedLocales: AppLocaleService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: child!,
        ),
      ),
      home: const PairConversationTarot(),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    final question = find.text(pairTarotQuestions['six_of_pentacles']!.ru);
    expect(question, findsNothing);
    expect(content.reveals, 0);
    final back = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == 'Перевернуть карту Таро дня',
    );
    await tester.ensureVisible(back);
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(question, findsOneWidget);
    expect(find.text(_card.cardOfDayDescription), findsOneWidget);
    expect(content.reveals, 1);
    expect(content.symbolOpened, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    expect(question, findsOneWidget);
    expect(back, findsNothing);
    expect(content.reveals, 1);
    expect(tester.takeException(), isNull);
  });
}

const _card = TarotCardModel(
  id: 'six',
  title: 'Шестёрка Пентаклей',
  imageName: 'six_of_pentacles',
  sort: 0,
  keywords: [],
  cardOfDayDescription: 'Сегодняшнее значение',
  generalDescription: '',
  shortDescription: '',
  textInDecks: [],
  keltDeck: [],
  keltDeckImpact: [],
  loveDeck: [],
);

class _Content extends Fake with ChangeNotifier implements ContentProvider {
  int reveals = 0;
  bool symbolOpened = false;
  @override
  List<TarotCardModel> get tarotCards => const [_card];
  @override
  TarotCardModel getTodayTarotCard() => _card;
  @override
  bool isTodayTarotCardOpened() => reveals > 0;
  @override
  Future<void> setTodayTarotCardOpened() async {
    reveals++;
    notifyListeners();
  }

  @override
  void setDailySymbolTarotOpened() {
    symbolOpened = true;
    notifyListeners();
  }
}
