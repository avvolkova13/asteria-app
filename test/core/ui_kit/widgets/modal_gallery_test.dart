import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/features/kelt_deck/widgets/card_description_modal.dart';
import 'package:asteria_app/features/kelt_deck/widgets/how_to_use_kelt_deck.dart';
import 'package:asteria_app/features/love_deck/widgets/card_description_modal.dart';
import 'package:asteria_app/features/love_deck/widgets/how_to_use_love_deck.dart';
import 'package:asteria_app/features/runes/widgets/all_runes_tab.dart';
import 'package:asteria_app/features/runes/widgets/how_to_use_runes.dart';
import 'package:asteria_app/features/runes/widgets/runes_block.dart';
import 'package:asteria_app/features/taro_cards/widgets/all_cards_tab.dart';
import 'package:asteria_app/features/taro_cards/widgets/card_description_modal.dart';
import 'package:asteria_app/features/taro_cards/widgets/how_to_use_taro_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const _reading =
    'Спокойствие и терпение помогают найти выход из трудной ситуации.';
const _card = TarotCardModel(
  id: 'strength',
  title: 'Сила',
  imageName: 'the_strength',
  sort: 8,
  keywords: ['Смелость'],
  cardOfDayDescription: _reading,
  generalDescription: _reading,
  shortDescription: 'Смелость.',
  textInDecks: [_reading],
  keltDeck: [_reading],
  keltDeckImpact: [_reading],
  loveDeck: [_reading],
);
const _rune = RuneOfDayModel(
  id: 'algiz',
  title: 'Альгиз',
  imageName: 'algiz',
  sort: 15,
  cardOfDayDescription: _reading,
  generalDescription: _reading,
  pastDeck: _reading,
  presentDeck: '',
  futureDeck: '',
  keywords: ['Защита'],
  definitions: [_reading],
);

class _Collection extends ChangeNotifier implements ContentProvider {
  @override
  List<TarotCardModel> get tarotCards => [_card];
  @override
  List<RuneOfDayModel> get runes => [_rune];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Reader extends ChangeNotifier implements UserProvider {
  @override
  bool isContentViewed(String contentId) => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final font in [
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
    ]) {
      await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
    }
  });
  setUp(() {
    di.registerSingleton<ContentProvider>(_Collection());
    di.registerSingleton<UserProvider>(_Reader());
  });
  tearDown(di.reset);

  final cases =
      <({String name, Widget content, String Function(AppLocalizations) last})>[
        (
          name: 'tarot instructions',
          content: const HowToUseTaroCards(),
          last: (l) => l.tarotHowToReminder,
        ),
        (
          name: 'rune instructions',
          content: const HowToUseRunes(),
          last: (l) => l.runesHowToReminder,
        ),
        (
          name: 'love instructions',
          content: const HowToUseLoveDeck(),
          last: (l) => l.loveDeckHowToClosing,
        ),
        (
          name: 'kelt instructions',
          content: const HowToUseKeltDeck(),
          last: (l) => l.keltDeckHowToClosing,
        ),
        (
          name: 'tarot reading',
          content: const TarotLayoutCardDescriptionModal(
            card: _card,
            positionInDeck: 0,
          ),
          last: (_) => _reading,
        ),
        (
          name: 'love reading',
          content: const LoveDeckCardDescriptionModal(
            card: _card,
            cardNumber: 1,
          ),
          last: (_) => _reading,
        ),
        (
          name: 'kelt reading',
          content: const CardDescriptionModal(card: _card, cardNumber: 1),
          last: (_) => _reading,
        ),
        (
          name: 'tarot collection',
          content: const AllCardsTab(),
          last: (_) => '— $_reading',
        ),
        (
          name: 'rune reading',
          content: const RunesBlock(
            rune1: _rune,
            rune2: _rune,
            rune3: _rune,
            isRuneLeftOpened: true,
            isRuneCenterOpened: true,
            isRuneRightOpened: true,
          ),
          last: (_) => _reading,
        ),
        (
          name: 'rune collection',
          content: const AllRunesTab(),
          last: (_) => _reading,
        ),
      ];
  for (final entry in cases) {
    final screenSizes = [
      (const Size(390, 844), 1.0),
      (const Size(320, 568), 2.0),
      if (entry.content is AllCardsTab) (const Size(844, 390), 1.0),
      if (entry.content is CardDescriptionModal) (const Size(768, 1024), 1.0),
    ];
    for (final screen in screenSizes) {
      testWidgets(
        '${entry.name} at ${screen.$1.width} with text scale ${screen.$2} presents the full reading',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = screen.$1;
          tester.view.padding = const FakeViewPadding(top: 24, bottom: 20);
          addTearDown(tester.view.reset);
          final opensFromImage =
              entry.content is AllCardsTab ||
              entry.content is AllRunesTab ||
              entry.content is RunesBlock;
          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('ru'),
              supportedLocales: AppLocaleService.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              builder: (context, child) => Theme(
                data: AppThemeLight.instance.getThemeData(context),
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(screen.$2)),
                  child: child!,
                ),
              ),
              home: Scaffold(
                backgroundColor: AppColorsDark.homeCanvas,
                body: Builder(
                  builder: (context) => opensFromImage
                      ? entry.content
                      : TextButton(
                          onPressed: () => showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => entry.content,
                          ),
                          child: const Text('Open'),
                        ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            opensFromImage ? find.byType(Image).first : find.text('Open'),
          );
          await tester.pumpAndSettle();
          final surface = find.byType(ModalGlassSurface);
          expect(
            tester.widget<ModalGlassSurface>(surface).color,
            ModalGlassTokens.surface,
          );
          final l10n = AppLocalizations.of(tester.element(surface));
          final last = find
              .descendant(of: surface, matching: find.text(entry.last(l10n)))
              .last;
          final scroll = find.descendant(
            of: surface,
            matching: find.byType(Scrollable),
          );
          final position = tester.state<ScrollableState>(scroll).position;
          if (position.maxScrollExtent > 0) {
            await tester.drag(scroll, const Offset(0, -140));
            await tester.pumpAndSettle();
            expect(position.pixels, greaterThan(0));
            position.jumpTo(position.maxScrollExtent);
            await tester.pumpAndSettle();
          }
          expect(
            tester.getRect(last).bottom,
            lessThanOrEqualTo(tester.getRect(scroll).bottom),
          );
          for (final rich
              in find
                  .descendant(of: surface, matching: find.byType(RichText))
                  .evaluate()) {
            final paragraph = rich.renderObject! as RenderParagraph;
            expect(
              paragraph.didExceedMaxLines,
              isFalse,
              reason: paragraph.text.toPlainText(),
            );
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
