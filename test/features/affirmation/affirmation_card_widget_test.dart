import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_card_widget.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

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
                      child: AffirmationCardStack(affirmations: affirmations),
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
              widget is GestureDetector && widget.onHorizontalDragEnd != null,
        );
        final visibleBehindBeforeLeftSwipe = _visibleBehindImageAssetPath(
          tester,
        );
        await tester.drag(swipeDetector, const Offset(-120, 0));
        await tester.pumpAndSettle();

        _expectThreeUniqueLoveImages(tester);
        expect(_frontImageAssetPath(tester), visibleBehindBeforeLeftSwipe);

        final visibleBehindBeforeRightSwipe = _visibleBehindImageAssetPath(
          tester,
        );
        await tester.drag(swipeDetector, const Offset(120, 0));
        await tester.pumpAndSettle();

        _expectThreeUniqueLoveImages(tester);
        expect(_frontImageAssetPath(tester), visibleBehindBeforeRightSwipe);
        expect(find.text('Первая'), findsOneWidget);
        expect(find.text('Вторая'), findsOneWidget);
        expect(find.text('Третья'), findsOneWidget);
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
      .map((image) => (image.image as AssetImage).assetName)
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
  Future<void> trackAffirmationCardView({String? contentId}) async {}

  @override
  Future<void> trackAffirmationEngagement({
    required String actionType,
    String? contentId,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
