import 'dart:ui' show PointerDeviceKind;

import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/swipe_card_stack.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_card_widget.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_category_widget.dart';
import 'package:asteria_app/features/practices/practice_catalog_screen.dart';
import 'package:asteria_app/features/scenarios/scenario_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Face = ({String text, String art});

const _categories = [
  'love',
  'abundance',
  'strength',
  'creativity',
  'lunar',
  'calm',
];

List<AffirmationModel> _cards(String category) => [
  for (var i = 0; i < 10; i++)
    AffirmationModel(
      id: '$category-$i',
      categoryId: category,
      category: category,
      text: '$category • $i',
      sort: i,
    ),
];

void main() {
  for (final category in _categories) {
    testWidgets('every card can be reached in either direction: $category', (
      tester,
    ) async {
      di.registerSingleton<ProductAnalyticsService>(_Analytics());
      addTearDown(() => di.unregister<ProductAnalyticsService>());
      final cards = _cards(category);
      await _pump(
        tester,
        ListView(
          children: [
            AffirmationCategoryWidget(
              category: category,
              affirmations: cards,
              showSwipeHint: true,
            ),
            const SizedBox(height: 850),
          ],
        ),
      );
      final faces = [
        for (var i = 0; i < cards.length; i++)
          (
            text: cards[i].text,
            art: AffirmationCardWidget.artworkFor(
              category,
              AffirmationCardWidget.coverIndex(i, cards.length),
            ),
          ),
      ];
      await _exercise(tester, _stacks.first, faces);
    });
  }

  testWidgets(
    'a swipe during catalog momentum selects immediately; a tap just stops scrolling',
    (tester) async {
      await _pump(
        tester,
        Builder(
          builder: (c) => TextButton(
            onPressed: () => openPracticeCatalog(c, PracticeCategory.body),
            child: const Text('Open'),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final deck = _stacks.first;
      final position = Scrollable.of(tester.element(deck)).position;

      Future<Offset> coast() async {
        position.jumpTo(0);
        final drag = position.drag(
          DragStartDetails(kind: PointerDeviceKind.touch),
          () {},
        );
        drag.update(
          DragUpdateDetails(
            delta: const Offset(0, -45),
            primaryDelta: -45,
            globalPosition: const Offset(180, 340),
          ),
        );
        drag.end(
          DragEndDetails(
            velocity: const Velocity(pixelsPerSecond: Offset(0, -520)),
            primaryVelocity: -520,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 30));
        expect(position.isScrollingNotifier.value, isTrue);
        return tester.getRect(deck).topCenter + const Offset(0, 135);
      }

      final start = await coast();
      await tester.dragFrom(start, const Offset(-70, 3));
      await tester.pumpAndSettle();
      expect(find.text('Мягкий выдох').hitTestable(), findsOneWidget);
      final stop = await coast();
      await tester.tapAt(stop);
      await tester.pumpAndSettle();
      expect(_stacks, findsNWidgets(4));
      expect(find.byKey(const ValueKey('open-practice-player')), findsNothing);
      await tester.tapAt(stop);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.byKey(const ValueKey('open-practice-player')),
        findsOneWidget,
      );
    },
  );

  const practiceSections = [
    [
      ('Утро без спешки', 'home/hand_with_star'),
      ('Рабочий день закончился', 'practices/workday-is-over'),
      ('Когда пора спать', 'practices/time-for-sleep'),
    ],
    [
      ('Ровное дыхание', 'practices/easy-breathing-rhythm'),
      ('Мягкий выдох', 'practices/gentle-exhale'),
    ],
    [
      ('Стряхнуть день', 'practices/shake-off-the-day'),
      ('Облачные руки', 'practices/cloud-hands'),
    ],
    [('Почувствуй разницу', 'practices/feel-the-difference')],
    [('Гвоздестояние', 'practices/sadhu-board')],
  ];

  for (final category in PracticeCategory.values) {
    testWidgets('every ${category.name} deck opens its selected practice', (
      tester,
    ) async {
      await _pump(
        tester,
        Builder(
          builder: (c) => TextButton(
            onPressed: () => openPracticeCatalog(c, category),
            child: Text(category.name),
          ),
        ),
      );
      await tester.tap(find.text(category.name));
      await tester.pumpAndSettle();
      final sections = category == PracticeCategory.meditation
          ? practiceSections.take(1)
          : practiceSections.skip(1);
      expect(_stacks, findsNWidgets(sections.length));
      for (final (i, section) in sections.indexed) {
        final faces = [
          for (final (title, art) in section)
            (text: title, art: 'assets/images/$art.webp'),
        ];
        final deck = _stacks.at(i);
        await _exercise(tester, deck, faces);
        final start = tester.getRect(deck).topCenter + const Offset(0, 105);
        final gesture = await tester.startGesture(start);
        await gesture.moveBy(const Offset(-70, 2));
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 16));
        await tester.tapAt(start);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        final opened = faces[1 % faces.length];
        expect(
          find.byKey(const ValueKey('open-practice-player')),
          findsOneWidget,
        );
        final detail = find.ancestor(
          of: find.byKey(const ValueKey('open-practice-player')),
          matching: find.byType(ScenarioPage),
        );
        expect(
          find.descendant(of: detail, matching: find.text(opened.text)),
          findsWidgets,
        );
        expect(
          find.descendant(
            of: detail,
            matching: find.byWidgetPredicate(
              (w) => w is Image && w.image == AssetImage(opened.art),
            ),
          ),
          findsOneWidget,
        );
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }
    });
  }
}

Finder get _stacks => find.byWidgetPredicate((w) => w is SwipeCardStack);

Future<void> _pump(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ru'),
      supportedLocales: AppLocaleService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      builder: (context, child) => Theme(
        data: AppThemeDark.instance.getThemeData(context),
        child: child!,
      ),
      home: Scaffold(body: page),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _exercise(
  WidgetTester tester,
  Finder deck,
  List<_Face> faces,
) async {
  await Scrollable.ensureVisible(tester.element(deck), alignment: .30);
  await tester.pumpAndSettle();
  final front = find.descendant(
    of: deck,
    matching: find.byWidgetPredicate((w) => w is PracticeDeckCard && w.isFront),
  );
  String? lastArt;
  void check(int index) {
    final face = faces[index];
    expect(front, findsOneWidget);
    final visibleText = tester
        .widgetList<Text>(
          find.descendant(of: front, matching: find.byType(Text)),
        )
        .map((w) => w.data)
        .toList();
    expect(visibleText, contains(face.text));
    expect(
      find.descendant(
        of: front,
        matching: find.byWidgetPredicate(
          (w) => w is Image && w.image == AssetImage(face.art),
        ),
      ),
      findsOneWidget,
      reason: face.text,
    );
    if (lastArt != null && faces.length > 1) expect(face.art, isNot(lastArt));
    lastArt = face.art;
  }

  check(0);
  for (final direction in [1, -1]) {
    for (var step = 1; step <= faces.length; step++) {
      final bounds = tester.getRect(front);
      // Real platforms may coalesce the first drag samples into one diagonal
      // event. Direction follows its dominant axis, even with opposite signs.
      final footer = step % 3 == 0;
      final start = footer
          ? bounds.bottomCenter - const Offset(0, 25)
          : bounds.topCenter + const Offset(0, 105);
      final delta = footer
          ? const Offset(-65, 5)
          : step.isOdd
          ? const Offset(-67, 26)
          : const Offset(24, -65);
      final gesture = await tester.startGesture(start);
      await gesture.moveBy(delta * direction.toDouble());
      await gesture.up();
      await tester.pumpAndSettle();
      check(direction * step % faces.length);
    }
  }
}

class _Analytics implements ProductAnalyticsService {
  @override
  Future<void> trackAffirmationCardView({String? contentId}) async {}
  @override
  Future<void> trackAffirmationEngagement({
    required String actionType,
    String? contentId,
  }) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
