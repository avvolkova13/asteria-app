import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/daily_symbol_of_the_day_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/tarot_card_of_the_day_widget.dart';
import 'package:asteria_app/features/taro_cards/widgets/card_description_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cases = <String, Widget>{
    'daily symbol': DailySymbolOfTheDayWidget(
      tarotCard: _card,
      isTarotOpened: true,
      onTarotRefresh: () {},
      onRuneRefresh: () {},
    ),
    'card of the day': TarotCardOfTheDayWidget(
      tarotCard: _card,
      isOpened: true,
      isDarkLayout: true,
      showMoreButton: false,
      onRefresh: () {},
    ),
    'card description': const TarotLayoutCardDescriptionModal(
      card: _card,
      positionInDeck: 0,
    ),
  };

  for (final entry in cases.entries) {
    testWidgets(
      '${entry.key} follows the UI locale without changing the card',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final locale = ValueNotifier(const Locale('ru'));
        addTearDown(locale.dispose);

        await tester.pumpWidget(_testApp(locale, entry.value));
        await tester.pumpAndSettle();
        expect(
          find.image(const AssetImage('assets/images/cards/the_strength.webp')),
          findsOneWidget,
        );
        final originalElement = tester.element(find.byWidget(entry.value));

        for (final englishLocale in AppLocaleService.supportedLocales.where(
          (locale) => locale.languageCode == 'en',
        )) {
          locale.value = englishLocale;
          await tester.pumpAndSettle();
          expect(
            find.image(
              const AssetImage('assets/images/cards/en/the_strength.webp'),
            ),
            findsOneWidget,
            reason: englishLocale.toLanguageTag(),
          );
          expect(
            find.image(
              const AssetImage('assets/images/cards/the_strength.webp'),
            ),
            findsNothing,
          );
          expect(
            tester.element(find.byWidget(entry.value)),
            same(originalElement),
          );
          expect(tester.takeException(), isNull);
        }

        locale.value = const Locale('ru');
        await tester.pumpAndSettle();
        expect(
          find.image(const AssetImage('assets/images/cards/the_strength.webp')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Widget _testApp(ValueNotifier<Locale> locale, Widget child) {
  return ValueListenableBuilder<Locale>(
    valueListenable: locale,
    child: child,
    builder: (context, locale, child) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocaleService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: Builder(
        builder: (context) => Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    ),
  );
}

const _card = TarotCardModel(
  id: 'strength',
  title: 'Strength',
  imageName: 'the_strength',
  sort: 8,
  keywords: ['Courage'],
  cardOfDayDescription: 'Trust your inner strength.',
  generalDescription: 'Inner strength.',
  shortDescription: 'Courage.',
  textInDecks: ['Inner strength.'],
  keltDeck: ['Inner strength.'],
  keltDeckImpact: ['Courage.'],
  loveDeck: ['Patience.'],
);
