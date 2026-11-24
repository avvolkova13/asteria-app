import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/runes/widgets/all_runes_tab.dart';
import 'package:asteria_app/features/taro_cards/widgets/all_cards_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

const _card = TarotCardModel(
  id: 'fresh',
  title: 'Fresh',
  imageName: 'the_strength',
  sort: 8,
  keywords: ['Courage'],
  cardOfDayDescription: 'Day',
  generalDescription: 'Premium reading',
  shortDescription: 'Courage',
  textInDecks: [],
  keltDeck: [],
  keltDeckImpact: [],
  loveDeck: [],
);
const _rune = RuneOfDayModel(
  id: 'fresh',
  title: 'Fresh',
  imageName: 'algiz',
  sort: 15,
  cardOfDayDescription: 'Day',
  generalDescription: 'Premium reading',
  pastDeck: '',
  presentDeck: '',
  futureDeck: '',
  keywords: [],
  definitions: [],
);

class _Content extends ChangeNotifier implements ContentProvider {
  @override
  List<TarotCardModel> get tarotCards => [
    _card.copyWith(id: 'seen', title: 'Seen'),
    _card,
  ];
  @override
  List<RuneOfDayModel> get runes => [
    _rune.copyWith(id: 'seen', title: 'Seen'),
    _rune,
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _User extends ChangeNotifier implements UserProvider {
  final viewed = <String>{'seen'};
  @override
  bool isContentViewed(String id) => viewed.contains(id);
  void view(String id) {
    viewed.add(id);
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Pro extends ChangeNotifier implements MonetizationProvider {
  bool active = false;
  @override
  bool get effectivePro => active;
  void subscription(bool value) {
    active = value;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final runes in [false, true]) {
    for (final diOnly in [false, true]) {
      testWidgets(
        'subscription unlocks the ${runes ? 'rune' : 'tarot'} collection live, DI=$diOnly',
        (tester) async {
          await di.reset();
          addTearDown(di.reset);
          final user = _User();
          final pro = _Pro();
          final content = _Content();
          addTearDown(user.dispose);
          addTearDown(pro.dispose);
          addTearDown(content.dispose);
          di.registerSingleton<UserProvider>(user);
          di.registerSingleton<ContentProvider>(content);
          di.registerSingleton<MonetizationProvider>(pro);
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final page = MaterialApp(
            locale: const Locale('en'),
            supportedLocales: AppLocaleService.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            builder: (context, child) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              ),
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: runes ? const AllRunesTab() : const AllCardsTab(),
              ),
            ),
          );
          await tester.pumpWidget(
            diOnly
                ? page
                : ChangeNotifierProvider<MonetizationProvider>.value(
                    value: pro,
                    child: page,
                  ),
          );
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final images = tester
                .widgetList<Image>(find.byType(Image))
                .map((image) => image.image)
                .toSet();
            await Future.wait(
              images.map(
                (image) => precacheImage(
                  image,
                  tester.element(find.byType(Scaffold).first),
                ),
              ),
            );
          });
          await tester.pumpAndSettle();
          final l = AppLocalizations.current;
          final lockedLabel = runes
              ? l.runeLockedLabel('Fresh')
              : l.tarotLockedCardLabel('Fresh');
          final openLabel = runes
              ? l.runeOpenLabel('Fresh')
              : l.tarotOpenCardLabel('Fresh');
          Finder label(String value) => find.byWidgetPredicate(
            (widget) => widget is Semantics && widget.properties.label == value,
          );
          expect(label(lockedLabel), findsOneWidget);
          pro.subscription(true);
          await tester.pumpAndSettle();
          expect(label(lockedLabel), findsNothing);
          expect(label(openLabel), findsOneWidget);
          await tester.tap(
            find
                .descendant(of: label(openLabel), matching: find.byType(Image))
                .first,
          );
          await tester.pumpAndSettle();
          expect(find.text('Premium reading'), findsOneWidget);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          pro.subscription(false);
          await tester.pumpAndSettle();
          expect(label(lockedLabel), findsOneWidget);
          expect(
            label(
              runes ? l.runeOpenLabel('Seen') : l.tarotOpenCardLabel('Seen'),
            ),
            findsOneWidget,
          );
          user.view('fresh');
          await tester.pumpAndSettle();
          expect(label(openLabel), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
