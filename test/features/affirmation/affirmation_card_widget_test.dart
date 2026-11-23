import 'package:asteria_app/core/ui_kit/widgets/swipe_card_stack.dart';
import 'package:asteria_app/features/affirmation/player/affirmation_player_screen.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/dictionaries/entry_surface.dart';
import 'package:asteria_app/features/affirmation/affirmation_screen.dart';
import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_card_widget.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  const categoryImageNames = <String, String>{
    'Любовь': 'love',
    'Изобилие': 'izobilie',
    'Сила': 'power',
    'Творчество': 'creative',
    'Лунные': 'moon',
    'Спокойствие': 'calm',
  };

  test('resolves three unique image assets for every category', () {
    for (final categoryEntry in categoryImageNames.entries) {
      final paths = <String>{
        for (var imageIndex = 0; imageIndex < 3; imageIndex++)
          AffirmationCardWidget(
            affirmation: _affirmation(category: categoryEntry.key),
            imageIndex: imageIndex,
          ).imageAssetPath,
      };

      expect(paths, <String>{
        'assets/images/affirmation/category_${categoryEntry.value}.webp',
        'assets/images/affirmation/category_${categoryEntry.value}_2.webp',
        'assets/images/affirmation/category_${categoryEntry.value}_3.webp',
      });
    }
  });

  test('adjacent cards have distinct covers across the deck boundary', () {
    for (final category in categoryImageNames.keys) {
      for (final length in [2, 3, 4, 7, 10, 11]) {
        final deck = List.generate(
          length,
          (_) => _affirmation(category: category),
        );
        final covers = List.generate(
          length,
          (index) => AffirmationCardWidget(
            affirmation: deck[index],
            imageIndex: index,
            deck: deck,
          ).imageAssetPath,
        );
        for (var index = 0; index < length; index++) {
          expect(covers[index], isNot(covers[(index + 1) % length]));
        }
      }
    }
  });

  test('falls back to love images and cycles variants', () {
    final unknownCategoryAffirmation = _affirmation(category: 'Неизвестная');

    expect(
      AffirmationCardWidget(
        affirmation: unknownCategoryAffirmation,
        imageIndex: 3,
      ).imageAssetPath,
      'assets/images/affirmation/category_love.webp',
    );
    expect(
      AffirmationCardWidget(
        affirmation: unknownCategoryAffirmation,
        imageIndex: 4,
      ).imageAssetPath,
      'assets/images/affirmation/category_love_2.webp',
    );
  });

  group('AffirmationCardStack', () {
    setUp(() {
      di.registerSingleton<ProductAnalyticsService>(
        _FakeProductAnalyticsService(),
      );
    });

    tearDown(() {
      di.unregister<ProductAnalyticsService>();
    });

    testWidgets(
      'a late collection appears while the user remains on the same screen',
      (tester) async {
        final content = _DelayedContent();
        final account = _Account();
        di.registerSingleton<ContentProvider>(content);
        di.registerSingleton<UserProvider>(account);
        addTearDown(() {
          di.unregister<ContentProvider>();
          di.unregister<UserProvider>();
          content.dispose();
          account.dispose();
        });
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ru'),
            supportedLocales: AppLocaleService.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            home: Builder(
              builder: (context) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: const AffirmationScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AffirmationCardStack), findsNothing);
        content.deliver(
          _affirmation(id: 'delivered', text: 'Текст из коллекции'),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AffirmationCardStack), findsOneWidget);
        expect(find.text('Текст из коллекции'), findsWidgets);
      },
    );

    testWidgets(
      'a swipe changes selected content passed to the real destination',
      (tester) async {
        final cards = [
          _affirmation(id: 'first', text: 'Первая'),
          _affirmation(id: 'second', text: 'Вторая'),
          for (var i = 3; i <= 10; i++)
            _affirmation(id: 'love-$i', text: 'Карточка $i'),
        ];
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, _) => Scaffold(
                body: Column(
                  children: [
                    AffirmationCategoryWidget(
                      category: 'love',
                      affirmations: cards,
                      showSwipeHint: true,
                    ),
                    AffirmationCategoryWidget(
                      category: 'calm',
                      affirmations: cards,
                      showAffirmations: false,
                    ),
                  ],
                ),
              ),
            ),
            AffirmationPlayerRoute(),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            builder: (context, child) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: child!,
            ),
            locale: const Locale('ru'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocaleService.supportedLocales,
          ),
        );
        await tester.pumpAndSettle();

        final stack = find.byType(AffirmationCardStack);
        expect(stack, findsOneWidget);
        final art = find.descendant(
          of: stack,
          matching: find.byKey(SwipeCardStack.artworkGestureKey),
        );
        // A slow first gesture must work even while the hand hint is on screen.
        await tester.timedDrag(
          art,
          const Offset(0, 48),
          const Duration(milliseconds: 480),
        );
        await tester.pumpAndSettle();
        expect(find.text('Карточка 10'), findsOneWidget);
        expect(_frontImageAssetPath(tester), endsWith('category_love_2.webp'));
        await tester.tap(art);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        final selected = tester.widget<AffirmationPlayerScreen>(
          find.byType(AffirmationPlayerScreen),
        );
        expect(
          selected.session!.portraitAsset,
          endsWith('category_love_2.webp'),
        );
        expect(find.text('Карточка 10'), findsOneWidget);
        router.pop();
        await tester.pumpAndSettle();
        await tester.timedDrag(
          art,
          const Offset(0, -48),
          const Duration(milliseconds: 480),
        );
        await tester.pumpAndSettle();
        expect(_frontImageAssetPath(tester), endsWith('category_love.webp'));
        await tester.tap(stack);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.byType(AffirmationPlayerScreen), findsOneWidget);
        expect(find.text('Первая'), findsOneWidget);
        expect(find.text('Любовь'), findsOneWidget);
        await tester.tap(
          find.byTooltip(
            MaterialLocalizations.of(
              tester.element(find.byType(AffirmationPlayerScreen)),
            ).backButtonTooltip,
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(stack, const Offset(0, -145));
        // Even a tap before the release animation finishes opens card two.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 30));
        await tester.tap(stack);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.byType(AffirmationPlayerScreen), findsOneWidget);
        expect(find.text('Вторая'), findsOneWidget);
        expect(find.text('Первая'), findsNothing);
        await tester.tap(
          find.byTooltip(
            MaterialLocalizations.of(
              tester.element(find.byType(AffirmationPlayerScreen)),
            ).backButtonTooltip,
          ),
        );
        await tester.pumpAndSettle();
        expect(_frontImageAssetPath(tester), endsWith('category_love_2.webp'));
      },
    );

    testWidgets(
      'every affirmation deck accepts rapid swipes and a gesture held across handoff',
      (tester) async {
        for (final category in categoryImageNames.entries) {
          final items = [
            for (var i = 0; i < 4; i++)
              _affirmation(
                id: '${category.value}-$i',
                category: category.key,
                text: '${category.key} $i',
              ),
          ];
          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('ru'),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: AppLocaleService.supportedLocales,
              home: Builder(
                builder: (context) => Theme(
                  data: AppThemeDark.instance.getThemeData(context),
                  child: Scaffold(
                    body: ListView(
                      children: [
                        AffirmationCardStack(
                          affirmations: items,
                          showSwipeHint: true,
                        ),
                        const SizedBox(height: 800),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          final art = find.byKey(SwipeCardStack.artworkGestureKey);
          final center = tester.getCenter(art);
          // Two releases inside the same 220 ms animation used to lose #2.
          await tester.dragFrom(center, const Offset(0, -84));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 35));
          await tester.dragFrom(center, const Offset(0, -84));
          await tester.pumpAndSettle();
          expect(find.text('${category.key} 2'), findsOneWidget);
          expect(
            _frontImageAssetPath(tester),
            endsWith('category_${category.value}_3.webp'),
          );

          // Begin the new gesture while the previous face is still leaving,
          // hold through the handoff, then release and wrap to the first card.
          await tester.dragFrom(center, const Offset(-90, 0));
          await tester.pump();
          final held = await tester.startGesture(center);
          await tester.pump(const Duration(milliseconds: 260));
          await held.moveBy(const Offset(-24, 0));
          await held.moveBy(const Offset(-50, 0));
          await held.up();
          await tester.pumpAndSettle();
          expect(find.text('${category.key} 0'), findsOneWidget);
          expect(
            _frontImageAssetPath(tester),
            endsWith('category_${category.value}.webp'),
          );

          await tester.drag(
            find.text('${category.key} 0'),
            const Offset(65, 0),
          );
          await tester.pump();
          await tester.dragFrom(center, const Offset(0, -67));
          await tester.pumpAndSettle();
          expect(find.text('${category.key} 0'), findsOneWidget);
        }
      },
    );

    testWidgets(
      'diagonal swipes follow net travel, including the exposed stack edge',
      (tester) async {
        final cards = List.generate(
          4,
          (i) => _affirmation(id: 'id-$i', text: 'Card $i'),
        );
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ru'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocaleService.supportedLocales,
            home: Builder(
              builder: (context) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: Scaffold(
                  body: ListView(
                    children: [
                      AffirmationCardStack(affirmations: cards),
                      const SizedBox(height: 1000),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final stack = find.byType(AffirmationCardStack);
        final top = tester.getTopLeft(stack);
        final x = tester.getCenter(stack).dx;
        final art = Offset(x, top.dy + 110);
        final edge = Offset(x, top.dy + 8);
        Future<void> swipe(Offset from, List<Offset> steps, int want) async {
          final touch = await tester.startGesture(from);
          for (final step in steps) {
            await touch.moveBy(step);
            await tester.pump(const Duration(milliseconds: 12));
          }
          await touch.up();
          await tester.pumpAndSettle();
          expect(find.text('Card $want').hitTestable(), findsOneWidget);
        }

        // A thumb can initially drift downward before sweeping to the left.
        await swipe(art, [const Offset(-8, 21), const Offset(-78, 4)], 1);
        await swipe(art, [const Offset(65, -22)], 0);
        await swipe(edge, [const Offset(-56, 0)], 1);
        await swipe(edge, [const Offset(0, -50)], 2);
      },
    );

    testWidgets(
      'a replaced deck discards the old swipe; Reduce Motion advances immediately',
      (tester) async {
        final deck = ValueNotifier([
          _affirmation(id: 'old-a'),
          _affirmation(id: 'old-b'),
        ]);
        final reduced = ValueNotifier(false);
        addTearDown(deck.dispose);
        addTearDown(reduced.dispose);
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ru'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocaleService.supportedLocales,
            home: Builder(
              builder: (context) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: Scaffold(
                  body: ListenableBuilder(
                    listenable: Listenable.merge([deck, reduced]),
                    builder: (context, _) => MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(disableAnimations: reduced.value),
                      child: SizedBox(
                        width: 358,
                        child: AffirmationCardStack(affirmations: deck.value),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final stack = find.byType(AffirmationCardStack);
        await tester.drag(stack, const Offset(0, -145));
        deck.value = [_affirmation(id: 'new-a'), _affirmation(id: 'new-b')];
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expect(_frontImageAssetPath(tester), endsWith('category_love.webp'));
        reduced.value = true;
        await tester.pump();
        await tester.drag(stack, const Offset(0, -145));
        await tester.pump();
        expect(_frontImageAssetPath(tester), endsWith('category_love_2.webp'));
      },
    );

    testWidgets(
      'art swipes change the card and caption swipes scroll categories',
      (tester) async {
        final longCaption = List.filled(
          4,
          'Сегодня я могу замедлиться.',
        ).join(' ');
        final scroll = ScrollController();
        addTearDown(scroll.dispose);
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ru'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocaleService.supportedLocales,
            home: Builder(
              builder: (context) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: Scaffold(
                  body: ListView(
                    controller: scroll,
                    children: [
                      AffirmationCardStack(
                        affirmations: [
                          _affirmation(id: 'one', text: 'Первая'),
                          _affirmation(id: 'two', text: longCaption),
                        ],
                      ),
                      const SizedBox(height: 900),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final artwork = find.byKey(SwipeCardStack.artworkGestureKey);
        final firstCaption = find.text('Первая');
        final imageGesture = find.descendant(
          of: find.byType(AffirmationCardStack),
          matching: artwork,
        );
        expect(
          tester.getBottomLeft(imageGesture).dy,
          lessThanOrEqualTo(tester.getTopLeft(firstCaption).dy),
        );
        final deckHeight = tester
            .getSize(find.byType(AffirmationCardStack))
            .height;
        await tester.drag(imageGesture, const Offset(0, -135));
        await tester.pumpAndSettle();
        expect(find.text('Первая'), findsNothing);
        expect(find.text(longCaption), findsOneWidget);
        expect(
          tester.getSize(find.byType(AffirmationCardStack)).height,
          deckHeight,
        );
        expect(tester.getSize(find.text(longCaption)).height, greaterThan(30));
        expect(scroll.offset, 0);
        await tester.drag(find.text(longCaption), const Offset(0, -160));
        await tester.pumpAndSettle();
        expect(scroll.offset, greaterThan(0));
      },
    );

    testWidgets(
      'promotes the visible card behind without duplicating adjacent images',
      (tester) async {
        final affirmations = <AffirmationModel>[
          _affirmation(id: 'love-1', text: 'Первая'),
          _affirmation(id: 'love-2', text: 'Вторая'),
          _affirmation(id: 'love-3', text: 'Третья'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ru'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocaleService.supportedLocales,
            home: Builder(
              builder: (context) {
                return Theme(
                  data: AppThemeDark.instance.getThemeData(context),
                  child: Scaffold(
                    body: SizedBox(
                      width: 358,
                      child: AffirmationCardStack(
                        affirmations: affirmations,
                        showSwipeHint: true,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pump();

        _expectThreeUniqueLoveImages(tester);
        expect(_frontImageAssetPath(tester), endsWith('category_love.webp'));

        final swipeDetector = find.byKey(SwipeCardStack.artworkGestureKey);
        final hand = find.image(
          const AssetImage('assets/icons/clay/swipe_hand.webp'),
        );
        await tester.pump(const Duration(milliseconds: 430));
        final start = tester.getCenter(hand);
        final center = tester.getCenter(swipeDetector);
        expect(start.dx, closeTo(center.dx, 1));
        expect(start.dy, greaterThan(center.dy + 35));
        await tester.pump(const Duration(milliseconds: 950));
        final end = tester.getCenter(hand);
        expect(end.dx, closeTo(start.dx, 1));
        expect(end.dy, lessThan(start.dy - 75));
        final visibleBehindBeforeLeftSwipe = _visibleBehindImageAssetPath(
          tester,
        );
        await tester.drag(swipeDetector, const Offset(0, -120));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 219));
        final incoming = find.byWidgetPredicate(
          (widget) => widget is AffirmationCardWidget && widget.imageIndex == 1,
        );
        expect(
          find.descendant(of: incoming, matching: find.text('Вторая')),
          findsOneWidget,
        );
        final beforeHandoff = tester.getRect(incoming);
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pump();
        final afterHandoff = tester.getRect(incoming);
        expect(afterHandoff.bottom, closeTo(beforeHandoff.bottom, 1));
        expect(afterHandoff.width, closeTo(beforeHandoff.width, 1));
        await tester.pumpAndSettle();

        _expectThreeUniqueLoveImages(tester);
        expect(_frontImageAssetPath(tester), visibleBehindBeforeLeftSwipe);
        expect(hand, findsNothing);

        await tester.drag(swipeDetector, const Offset(0, 120));
        await tester.pumpAndSettle();

        _expectThreeUniqueLoveImages(tester);
        expect(_frontImageAssetPath(tester), endsWith('category_love.webp'));
        expect(find.text('Первая'), findsOneWidget);
        expect(find.text('Вторая'), findsNothing);
        expect(find.text('Третья'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

AffirmationModel _affirmation({
  String id = 'affirmation-id',
  String category = 'Любовь',
  String text = 'Текст аффирмации',
}) {
  return AffirmationModel(id: id, category: category, text: text, sort: 0);
}

List<String> _imageAssetPaths(WidgetTester tester) {
  return tester
      .widgetList<Image>(find.byType(Image))
      .map((widget) => widget.image)
      .whereType<AssetImage>()
      .map((image) => image.assetName)
      .where((path) => path.startsWith('assets/images/affirmation/category_'))
      .toList();
}

String _frontImageAssetPath(WidgetTester tester) {
  return _imageAssetPaths(tester).last;
}

String _visibleBehindImageAssetPath(WidgetTester tester) {
  final paths = _imageAssetPaths(tester);
  return paths[paths.length - 2];
}

void _expectThreeUniqueLoveImages(WidgetTester tester) {
  final paths = _imageAssetPaths(tester);
  expect(paths, hasLength(3));
  expect(paths.toSet(), <String>{
    'assets/images/affirmation/category_love.webp',
    'assets/images/affirmation/category_love_2.webp',
    'assets/images/affirmation/category_love_3.webp',
  });
}

class _FakeProductAnalyticsService implements ProductAnalyticsService {
  @override
  Future<void> trackAffirmationsStart({
    EntrySurface entrySurface = EntrySurface.unknown,
  }) async {}

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

class _DelayedContent extends ChangeNotifier implements ContentProvider {
  final _cards = <AffirmationModel>[];
  void deliver(AffirmationModel item) {
    _cards.add(item);
    notifyListeners();
  }

  @override
  List<String> get affirmationCategories => const ['love'];
  @override
  List<AffirmationModel> getAffirmationsByCategory(String category) => [
    ..._cards,
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Account extends ChangeNotifier implements UserProvider {
  @override
  UserModel? get currentUser => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
