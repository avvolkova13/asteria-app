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

    testWidgets('a swipe changes the card and a tap opens the shared player', (
      tester,
    ) async {
      final cards = [
        _affirmation(id: 'first', text: 'Первая'),
        _affirmation(id: 'second', text: 'Вторая'),
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
          GoRoute(
            path: AffirmationPlayerRoute.routeName,
            name: AffirmationPlayerRoute.routeName,
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () => context.pop(),
                child: const Text('Закрыть плеер'),
              ),
            ),
          ),
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
      await tester.tap(stack);
      await tester.pumpAndSettle();
      expect(find.text('Закрыть плеер'), findsOneWidget);
      await tester.tap(find.text('Закрыть плеер'));
      await tester.pumpAndSettle();
      await tester.drag(stack, const Offset(0, -145));
      await tester.pumpAndSettle();
      expect(_frontImageAssetPath(tester), endsWith('category_love_2.webp'));
      await tester.tap(stack);
      await tester.pumpAndSettle();
      expect(find.text('Закрыть плеер'), findsOneWidget);
      await tester.tap(find.text('Закрыть плеер'));
      await tester.pumpAndSettle();
      expect(_frontImageAssetPath(tester), endsWith('category_love_2.webp'));
    });

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
                      data: MediaQuery.of(
                        context,
                      ).copyWith(disableAnimations: reduced.value),
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
        final artwork = find.byWidgetPredicate(
          (widget) =>
              widget is GestureDetector && widget.onVerticalDragEnd != null,
        );
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

        final swipeDetector = find.byWidgetPredicate(
          (widget) =>
              widget is GestureDetector && widget.onVerticalDragEnd != null,
        );
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
