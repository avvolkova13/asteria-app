import 'package:asteria_app/features/achievements/presentation/widgets/achievement_card.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/achievements/presentation/achievements_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final font in [
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
      ('PlayfairDisplay', 'assets/fonts/playfair/PlayfairDisplay-SemiBold.ttf'),
    ]) {
      await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
    }
  });

  testWidgets('remaining counts agree with completed progress and rune lock', (
    tester,
  ) async {
    await pumpAchievements(tester);
    expect(find.text('Осталось 3 из 5'), findsOneWidget);
    expect(find.text('Осталось 1 из 3'), findsOneWidget);
    expect(find.text('Осталось 3 из 3'), findsOneWidget);
    final semantics = tester.ensureSemantics();
    try {
      expect(find.bySemanticsLabel('Открыть руны. Закрыто'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
    for (final entry in [('tarot', 2), ('horoscope', 2), ('runes', 0)]) {
      final segments = tester.widgetList<DecoratedBox>(
        find.descendant(
          of: find.byKey(ValueKey('achievement-progress-${entry.$1}')),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(
        segments.where(
          (box) => (box.decoration as BoxDecoration).gradient != null,
        ),
        hasLength(entry.$2),
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('progress follows server snapshots and account changes', (
    tester,
  ) async {
    await pumpAchievements(tester);
    final provider = di.get<UserProvider>();
    provider.applyServerUserSnapshot(
      achievementUser(tarot: 4, horoscope: 3, runes: 2),
    );
    await tester.pumpAndSettle();
    expect(find.text('Осталось 1 из 5'), findsOneWidget);
    expect(find.text('Осталось 0 из 3'), findsOneWidget);
    expect(
      tester
          .widget<AchievementCard>(
            find.byKey(const ValueKey('achievement-runes')),
          )
          .isLocked,
      isFalse,
    );
    expect(find.text('Осталось 1 из 3'), findsOneWidget);

    provider.applyServerUserSnapshot(
      achievementUser(id: 'another-account', tarot: 0, horoscope: 0, runes: 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Осталось 5 из 5'), findsOneWidget);
    expect(find.text('Осталось 3 из 3'), findsNWidgets(2));
    expect(
      tester
          .widget<AchievementCard>(
            find.byKey(const ValueKey('achievement-runes')),
          )
          .isLocked,
      isTrue,
    );

    provider.applyServerUserSnapshot(
      achievementUser(tarot: 12, horoscope: 9, runes: 7),
    );
    await tester.pumpAndSettle();
    expect(find.text('Осталось 0 из 5'), findsOneWidget);
    expect(find.text('Осталось 0 из 3'), findsNWidgets(2));
  });

  testWidgets('each achievement unlocks independently after its first action', (
    tester,
  ) async {
    await pumpAchievements(tester);
    final semantics = tester.ensureSemantics();
    try {
      final provider = di.get<UserProvider>();
      const titles = [
        'Раскинуть карты Таро',
        'Открыть гороскоп',
        'Открыть руны',
      ];
      const ids = ['tarot', 'horoscope', 'runes'];
      const totals = [5, 3, 3];
      for (final counts in [
        [0, 0, 0],
        [1, 0, 0],
        [1, 1, 0],
        [1, 1, 1],
      ]) {
        provider.applyServerUserSnapshot(
          achievementUser(
            id: 'lock-transition-account',
            tarot: counts[0],
            horoscope: counts[1],
            runes: counts[2],
          ),
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < ids.length; i++) {
          final card = find.byKey(ValueKey('achievement-${ids[i]}'));
          final locked = counts[i] == 0;
          expect(
            find.descendant(of: card, matching: find.byType(BackdropFilter)),
            locked ? findsOneWidget : findsNothing,
            reason: '${ids[i]}: ${counts[i]}',
          );
          expect(
            find.bySemanticsLabel(locked ? '${titles[i]}. Закрыто' : titles[i]),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: card,
              matching: find.text(
                'Осталось ${totals[i] - counts[i]} из ${totals[i]}',
              ),
            ),
            findsOneWidget,
          );
        }
      }
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('reference cards are 358 by 128 with 16 point spacing', (
    tester,
  ) async {
    await pumpAchievements(tester);
    final cards = [
      'tarot',
      'horoscope',
      'runes',
    ].map((id) => find.byKey(ValueKey('achievement-$id'))).toList();
    for (final card in cards) {
      expect(tester.getSize(card), const Size(358, 128));
    }
    expect(tester.getTopLeft(cards.first).dy, 182);
    expect(
      tester.getTopLeft(cards[1]).dy - tester.getBottomLeft(cards[0]).dy,
      16,
    );
    expect(
      tester.getTopLeft(cards[2]).dy - tester.getBottomLeft(cards[1]).dy,
      16,
    );
  });

  for (final locale in ['ru', 'en']) {
    testWidgets(
      '$locale titles remain readable on compact screens and large text',
      (tester) async {
        await pumpAchievements(
          tester,
          width: 320,
          textScale: 2,
          locale: locale,
        );
        for (final text in tester.widgetList<Text>(find.byType(Text))) {
          if (text.data == null) continue;
          final paragraph = tester.renderObject<RenderParagraph>(
            find.byWidget(text),
          );
          expect(paragraph.didExceedMaxLines, isFalse, reason: text.data);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> pumpAchievements(
  WidgetTester tester, {
  double width = 390,
  double textScale = 1,
  String locale = 'ru',
}) async {
  final provider = UserProvider(userRepository: _UnusedRepository());
  provider.applyServerUserSnapshot(achievementUser());
  di.registerSingleton<UserProvider>(provider);
  addTearDown(() async {
    await di.unregister<UserProvider>();
    provider.dispose();
  });
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocaleService.supportedLocales,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: const RepaintBoundary(
              key: ValueKey('achievements-capture'),
              child: AchievementsScreen(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

UserModel achievementUser({
  String id = 'achievement-account',
  int tarot = 2,
  int horoscope = 2,
  int runes = 0,
}) => UserModel.fromJson({
  ...UserModel.empty().copyWith(id: id).toJson(),
  'statistics': {
    'tarot_cards_opened': tarot,
    'horoscope_opened': horoscope,
    'runes_opened': runes,
  },
});

class _UnusedRepository extends Fake implements UserRepository {}
