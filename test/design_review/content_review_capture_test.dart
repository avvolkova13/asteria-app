import 'package:asteria_app/app/data/models/user/tarot_deck_model.dart';
import 'package:asteria_app/app/data/models/love_deck/love_deck_model.dart';
import 'package:asteria_app/app/data/models/kelt_deck/kelt_deck_model.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/features/kelt_deck/widgets/celtic_cross_layout.dart';
import 'package:asteria_app/features/love_deck/widgets/love_layout.dart';
import 'package:asteria_app/features/taro_cards/widgets/tarot_layout.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/app/data/models/natal_card/natal_card_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/natal_card/natal_card_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/compatibility_history_screen.dart';
import 'package:asteria_app/features/affirmation/player/affirmation_player_screen.dart';
import 'package:asteria_app/features/affirmation/player/practice_playback_controller.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/app/data/models/prompt_response.dart';
import 'package:asteria_app/app/data/models/anakra_chat/anakra_chat_message_model.dart';
import 'package:asteria_app/features/affirmation/affirmation_detail_screen.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_category_widget.dart';
import 'package:asteria_app/features/taro_cards/widgets/card_description_modal.dart';
import 'package:asteria_app/features/taro_cards/widgets/how_to_use_taro_cards.dart';
import 'package:asteria_app/features/runes/widgets/how_to_use_runes.dart';
import 'package:asteria_app/features/runes/widgets/runes_block.dart';
import 'package:asteria_app/features/love_deck/widgets/card_description_modal.dart';
import 'package:asteria_app/features/love_deck/widgets/how_to_use_love_deck.dart';
import 'package:asteria_app/features/kelt_deck/widgets/card_description_modal.dart'
    as kelt;
import 'package:asteria_app/features/home/presentation/widgets/rune_of_the_day_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/tarot_card_of_the_day_widget.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_results.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_card_loading_overlay.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_card_empty_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compability_results.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_chat_message.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_composer.dart';

bool reviewOpened = false;
String reviewLanguage = 'ru';
const out = '/private/tmp/asteria-design-review/content';
String get paragraph => reviewLanguage == 'en'
    ? 'This day invites you to notice your feelings, keep a sense of calm, and choose what matters most to you. '
    : 'Этот день помогает заметить собственные чувства, сохранить спокойствие и выбрать то, что действительно важно для вас. ';
String get longText => List.filled(10, paragraph).join();
TarotCardModel get card => TarotCardModel(
  id: 'review',
  title: reviewLanguage == 'en' ? 'Queen of Pentacles' : 'Королева пентаклей',
  imageName: 'queen_of_pentacles',
  sort: 1,
  keywords: ['Забота', 'Устойчивость'],
  cardOfDayDescription: paragraph,
  generalDescription: longText,
  shortDescription: paragraph,
  textInDecks: [longText],
  keltDeck: List.filled(10, longText),
  keltDeckImpact: List.filled(10, paragraph),
  loveDeck: List.filled(6, longText),
);
RuneOfDayModel get rune => RuneOfDayModel(
  id: 'review',
  title: reviewLanguage == 'en' ? 'Fehu' : 'Феху',
  imageName: 'fehu',
  sort: 1,
  cardOfDayDescription: paragraph,
  generalDescription: longText,
  pastDeck: longText,
  presentDeck: longText,
  futureDeck: longText,
  keywords: ['Благополучие'],
  definitions: [longText],
);
AffirmationModel get affirmation => AffirmationModel(
  id: 'review',
  categoryId: 'love',
  category: 'Любовь',
  text: longText,
  sort: 1,
);
Widget scroll(Widget child) => SingleChildScrollView(
  child: Padding(padding: const EdgeInsets.all(16), child: child),
);
Widget sheet(Widget child) =>
    Align(alignment: Alignment.bottomCenter, child: child);
Widget buildCase(String name) => switch (name) {
  'tarot-spread-closed' || 'tarot-spread-open' => scroll(const TarotLayout()),
  'love-spread-closed' || 'love-spread-open' => scroll(const LoveLayout()),
  'kelt-spread-closed' ||
  'kelt-spread-open' => scroll(const CelticCrossLayout()),
  'tarot-help' => sheet(const HowToUseTaroCards()),
  'runes-help' => sheet(const HowToUseRunes()),
  'love-help' => sheet(const HowToUseLoveDeck()),
  'tarot-detail' => sheet(
    TarotLayoutCardDescriptionModal(card: card, positionInDeck: 0),
  ),
  'love-detail' => sheet(
    LoveDeckCardDescriptionModal(card: card, cardNumber: 1),
  ),
  'kelt-detail' => sheet(kelt.CardDescriptionModal(card: card, cardNumber: 1)),
  'affirmation-detail' => AffirmationDetailScreen(
    selection: AffirmationSelection(affirmation: affirmation),
  ),
  'affirmation-open' => scroll(
    AffirmationCategoryWidget(category: 'love', affirmations: [affirmation]),
  ),
  'affirmation-locked' => scroll(
    AffirmationCategoryWidget(
      category: 'strength',
      affirmations: [affirmation],
      showAffirmations: false,
    ),
  ),
  'affirmation-empty' => scroll(
    const AffirmationCategoryWidget(category: 'love', affirmations: []),
  ),
  'rune-day-closed' => scroll(
    RuneOfTheDayWidget(
      isDarkLayout: true,
      margin: EdgeInsets.zero,
      rune: rune,
      onRefresh: () {},
    ),
  ),
  'rune-day-open' => scroll(
    RuneOfTheDayWidget(
      isDarkLayout: true,
      margin: EdgeInsets.zero,
      rune: rune,
      isOpened: true,
      onRefresh: () {},
    ),
  ),
  'rune-day-loading' => scroll(
    RuneOfTheDayWidget(
      isDarkLayout: true,
      margin: EdgeInsets.zero,
      isLoading: true,
      onRefresh: () {},
    ),
  ),
  'rune-day-error' => scroll(
    RuneOfTheDayWidget(
      isDarkLayout: true,
      margin: EdgeInsets.zero,
      onRefresh: () {},
    ),
  ),
  'tarot-day-closed' => scroll(
    TarotCardOfTheDayWidget(
      isDarkLayout: true,
      margin: EdgeInsets.zero,
      tarotCard: card,
      onRefresh: () {},
    ),
  ),
  'tarot-day-open' => scroll(
    TarotCardOfTheDayWidget(
      isDarkLayout: true,
      margin: EdgeInsets.zero,
      tarotCard: card,
      isOpened: true,
      onRefresh: () {},
    ),
  ),
  'tarot-day-error' => scroll(
    TarotCardOfTheDayWidget(
      isDarkLayout: true,
      margin: EdgeInsets.zero,
      onRefresh: () {},
    ),
  ),
  'rune-spread-open' => scroll(
    RunesBlock(
      rune1: rune,
      rune2: rune,
      rune3: rune,
      isRuneLeftOpened: true,
      isRuneCenterOpened: true,
      isRuneRightOpened: true,
    ),
  ),
  'rune-spread-closed' => scroll(
    RunesBlock(
      rune1: rune,
      rune2: rune,
      rune3: rune,
      isRuneLeftOpened: false,
      isRuneCenterOpened: false,
      isRuneRightOpened: false,
    ),
  ),
  'sonnik-result' => scroll(
    SonnikResults(
      sonnik: SonnikModel(
        id: 'review',
        dateGenerated: DateTime(2026, 9, 9),
        title: 'Сон про море и возвращение домой',
        interpretation: longText,
      ),
      onDecodeAgainPressed: () {},
    ),
  ),
  'compatibility-result' => scroll(
    CompabilityResults(
      compatibilityData: CompatibilityData(
        generalCompatibility: longText,
        loveCompatibility: paragraph,
        loveCompatibilityPercentage: '82%',
        familyCompatibility: paragraph,
        familyCompatibilityPercentage: '80%',
        conflicts: paragraph,
        conflictsPercentage: '30%',
        percentage: '69%',
        phrase: 'Стабильность встречает переменчивость.',
        introduction: paragraph,
      ),
      hisBirthdate: '17-04-1992',
      herBirthdate: '22-05-1994',
      onHistoryPressed: () {},
    ),
  ),
  'natal-locked' => scroll(NatalCardEmptyScreen(onBuyPressed: () {})),
  'natal-loading' => const NatalCardLoadingOverlay(),
  'compatibility-history-empty' => scroll(
    CompatibilityHistoryScreen(onItemTap: (_) {}, onNewPairPressed: () {}),
  ),
  'natal-open' => ChangeNotifierProvider<UserProvider>.value(
    value: di.get<UserProvider>(),
    child: const NatalCardScreen(),
  ),
  'player' => AffirmationPlayerScreen(controller: ReviewAudio()),
  'chat' => Column(
    children: [
      Expanded(
        child: scroll(
          Column(
            children: [
              AnakraChatMessage(
                message: AnakraChatMessageModel(
                  text: paragraph,
                  isUser: true,
                  timestamp: DateTime(2026),
                ),
              ),
              AnakraChatMessage(
                message: AnakraChatMessageModel(
                  text: longText,
                  isUser: false,
                  timestamp: DateTime(2026),
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: AnakraComposer(
          controller: TextEditingController(text: paragraph),
          busy: false,
          hasInput: true,
          onSend: () {},
        ),
      ),
    ],
  ),
  _ => const SizedBox(),
};
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    Hive.init('/private/tmp/asteria-design-review/content/hive');
    await Hive.openBox<bool>('affirmation_player_favorites');
  });
  tearDownAll(() async => Hive.close());
  for (final variant in ['390-ru', '320-en-2x', '320-ru-2x']) {
    final compact = variant != '390-ru';
    final language = variant == '320-en-2x' ? 'en' : 'ru';
    for (final name in [
      'tarot-help',
      'runes-help',
      'love-help',
      'tarot-detail',
      'love-detail',
      'kelt-detail',
      'affirmation-detail',
      'affirmation-open',
      'affirmation-locked',
      'affirmation-empty',
      'rune-day-closed',
      'rune-day-open',
      'rune-day-loading',
      'rune-day-error',
      'tarot-day-closed',
      'tarot-day-open',
      'tarot-day-error',
      'rune-spread-open',
      'rune-spread-closed',
      'sonnik-result',
      'compatibility-result',
      'natal-locked',
      'natal-loading',
      'chat',
      'compatibility-history-empty',
      'natal-open',
      'player',
      'tarot-spread-closed',
      'tarot-spread-open',
      'love-spread-closed',
      'love-spread-open',
      'kelt-spread-closed',
      'kelt-spread-open',
    ]) {
      testWidgets('$name $variant', (tester) async {
        tester.view.physicalSize = compact
            ? const Size(320, 568)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
        addTearDown(tester.view.reset);
        await tester.runAsync(() async {
          for (final f in [
            ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
            ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
            ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
          ]) {
            await (FontLoader(f.$1)..addFont(rootBundle.load(f.$2))).load();
          }
        });
        reviewLanguage = language;
        reviewOpened = name.endsWith('-open');
        final analytics = _TestAnalytics();
        di.registerSingleton<AnalyticsFacade>(analytics);
        di.registerSingleton<ProductAnalyticsService>(
          ProductAnalyticsService(analytics),
        );
        di.registerSingleton<AppLocaleService>(
          AppLocaleService(platformLocales: [Locale(language)]),
        );
        di.registerSingleton<UserProvider>(
          _TestUserProvider(
            _user(longText, language, true).copyWith(
              tarotDeck: TarotDeckModel(
                cards: List.generate(
                  3,
                  (i) => TarotCardInDeckModel(
                    id: 'review-$i',
                    isOpened: reviewOpened,
                  ),
                ),
              ),
              keltDeck: KeltDeckModel(
                keltDeckCards: {
                  for (var i = 0; i < 10; i++) 'review-$i': reviewOpened,
                },
              ),
              loveDeck: LoveDeckModel(
                loveDeckCards: {
                  for (var i = 0; i < 6; i++) 'review-$i': reviewOpened,
                },
              ),
            ),
          ),
        );
        di.registerSingleton<ContentProvider>(_TestContent());
        addTearDown(() async => di.reset());
        await tester.pumpWidget(
          RepaintBoundary(
            key: const Key('capture'),
            child: MaterialApp(
              locale: Locale(language),
              supportedLocales: AppLocaleService.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              builder: (context, child) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(compact ? 2 : 1),
                    disableAnimations: true,
                  ),
                  child: child!,
                ),
              ),
              home: Scaffold(
                backgroundColor: const Color(0xFF130923),
                body: Builder(builder: (_) => buildCase(name)),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 350)),
        );
        await tester.pump(const Duration(milliseconds: 200));
        final issues = <String>[];
        Object? error;
        while ((error = tester.takeException()) != null) {
          issues.add(error.toString());
        }
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('capture')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory(out).create(recursive: true);
          await File(
            '$out/$name-$variant.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          await File(
            '$out/$name-$variant.txt',
          ).writeAsString(issues.join('\n'));
          image.dispose();
        });
        if ([
          'tarot-help',
          'runes-help',
          'love-help',
          'tarot-detail',
          'love-detail',
          'kelt-detail',
          'affirmation-detail',
          'affirmation-open',
          'sonnik-result',
          'compatibility-result',
          'natal-locked',
          'natal-loading',
          'natal-open',
          'player',
          'chat',
        ].contains(name)) {
          final scrolling = find.byType(Scrollable);
          if (scrolling.evaluate().isNotEmpty) {
            await tester.drag(scrolling.first, const Offset(0, -12000));
            await tester.pump(const Duration(seconds: 2));
            await tester.runAsync(() async {
              final img = await boundary.toImage(pixelRatio: 1);
              final data = await img.toByteData(format: ui.ImageByteFormat.png);
              await File(
                '$out/$name-$variant-bottom.png',
              ).writeAsBytes(data!.buffer.asUint8List());
              img.dispose();
            });
            final bottomIssues = <String>[];
            while ((error = tester.takeException()) != null) {
              bottomIssues.add(error.toString());
            }
            issues.addAll(bottomIssues);
            await tester.runAsync(
              () => File(
                '$out/$name-$variant-bottom.txt',
              ).writeAsString(bottomIssues.join('\n')),
            );
          }
        }
        expect(
          issues,
          isEmpty,
          reason: '$name $variant capture must render without framework errors',
        );
      }, timeout: const Timeout(Duration(seconds: 20)));
    }
  }
}

UserModel _user(String description, String language, bool exactTime) =>
    UserModel(
      id: 'layout-test',
      balance: 0,
      userGroup: UserGroup.user,
      subscriptionType: SubscriptionType.free,
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
      sonnikHistory: const [],
      solarData: const SolarDataModel(data: ''),
      personalInfo: PersonalInfoModel(
        birthDate: BirthDateModel(
          birthDate: DateTime(1992, 4, 17),
          birthTimeKnown: exactTime,
          birthTime: DateTime(1992, 4, 17, 14, 58),
        ),
        birthPlace: const BirthPlaceModel(
          location: 'Петропавловск-Камчатский, Россия',
          latitude: 55,
          longitude: 37,
        ),
      ),
      planetsHousesData: const PlanetsHousesDataModel(
        data: '',
        elements: Elements(fire: '3', earth: '6', air: '2', water: '4'),
        positions: [
          PlanetHousePositionModel(
            code: 'sun',
            name: 'Солнце',
            signCode: 'taurus',
            sign: 'Телец',
            house: 10,
            longitude: 40,
          ),
          PlanetHousePositionModel(
            code: 'venus',
            name: 'Венера',
            signCode: 'gemini',
            sign: 'Близнецы',
            house: 7,
            longitude: 65,
          ),
        ],
        houseSummary: HouseSummaryModel(
          strongHouse: HouseSummaryEntryModel(houseNumber: 10),
          weakHouse: HouseSummaryEntryModel(houseNumber: 3),
          accentHouse: HouseSummaryEntryModel(houseNumber: 7),
        ),
      ),
      natalCard: NatalCardModel.fromJson({
        'source_language': language,
        'interpretations': {
          language: {
            'planet_interpretations': {
              'sun': description,
              'venus': 'Описание Венеры.',
            },
            'house_interpretations': {
              'strong_house': 'Персональное описание сильного дома.',
              'weak_house': 'Описание слабого дома.',
              'accent_house': 'Описание акцента.',
            },
          },
        },
      }),
    );

class _TestUserProvider extends ChangeNotifier implements UserProvider {
  _TestUserProvider(this.currentUser);
  @override
  final UserModel currentUser;
  @override
  bool isDeckCardOpened(DeckType type, String id) => reviewOpened;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestContent extends ChangeNotifier implements ContentProvider {
  @override
  List<TarotCardModel> get tarotCards =>
      List.generate(10, (i) => card.copyWith(id: 'review-$i'));
  @override
  Future<void> ensureTarotDeckLayoutReady() async {}
  @override
  bool isTarotCardInDeckOpened(String key) => reviewOpened;
  @override
  Future<PlanetsHousesDataModel?> loadPurchasedNatalGeometry() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAnalytics implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ReviewAudio extends PracticePlaybackController {
  @override
  Future<void> initialize() async {}
  @override
  Future<void> toggle() async {}
}
