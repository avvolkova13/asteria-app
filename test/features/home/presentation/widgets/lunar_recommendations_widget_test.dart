import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/lunar_card_image.dart';
import 'package:asteria_app/features/home/presentation/widgets/lunar_recommendations_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders backend task recommendations with localized titles', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const LunarRecommendationsWidget(
          recommendation: SphereRecommendationModel(
            status: RecommendationStatus.favorable,
            tasks: {
              'houseplants': TaskRecommendationModel(
                status: RecommendationStatus.favorable,
                description: 'Можно пересаживать комнатные растения.',
              ),
              'watering_fertilizing': TaskRecommendationModel(
                status: RecommendationStatus.unfavorable,
                description: 'Полив лучше перенести.',
              ),
            },
          ),
        ),
      ),
    );

    expect(find.text('Комнатные растения'), findsOneWidget);
    expect(find.text('Полив и подкормка'), findsOneWidget);
    expect(find.text('Можно пересаживать комнатные растения.'), findsOneWidget);
    expect(find.text('Полив лучше перенести.'), findsOneWidget);
    expect(
      _assetImage(
        'assets/images/prediction_images/moon_card_gardening_houseplants.webp',
      ),
      findsOneWidget,
    );
    expect(
      _assetImage(
        'assets/images/prediction_images/moon_card_gardening_watering_fertilizing.webp',
      ),
      findsOneWidget,
    );
    expect(find.byType(LunarCardImage), findsNWidgets(2));
    final firstImageFinder = find.byType(LunarCardImage).first;
    expect(tester.getSize(firstImageFinder), const Size(83, 44));
    final titleCenter = tester.getCenter(find.text('Комнатные растения'));
    final imageCenter = tester.getCenter(firstImageFinder);
    expect((titleCenter.dy - imageCenter.dy).abs(), lessThan(1));
    final headerRow = tester.widget<Row>(
      find.ancestor(of: firstImageFinder, matching: find.byType(Row)).first,
    );
    expect(headerRow.crossAxisAlignment, CrossAxisAlignment.center);
    expect(_dayStatusImages(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders English titles for current backend task keys', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const LunarRecommendationsWidget(
          recommendation: SphereRecommendationModel(
            status: RecommendationStatus.favorable,
            tasks: {
              'spa_and_relaxation': TaskRecommendationModel(
                status: RecommendationStatus.favorable,
                description: 'Choose a calm spa ritual.',
              ),
              'sowing_and_planting': TaskRecommendationModel(
                status: RecommendationStatus.neutral,
                description: 'Keep planting work moderate.',
              ),
              'health_and_immunity': TaskRecommendationModel(
                status: RecommendationStatus.unfavorable,
                description: 'Do not overload recovery.',
              ),
            },
          ),
        ),
        locale: const Locale('en', 'US'),
      ),
    );

    expect(find.text('Spa and relaxation'), findsOneWidget);
    expect(find.text('Sowing and planting'), findsOneWidget);
    expect(find.text('Health and immunity'), findsOneWidget);
    expect(find.text('Choose a calm spa ritual.'), findsOneWidget);
    expect(find.text('Keep planting work moderate.'), findsOneWidget);
    expect(find.text('Do not overload recovery.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'grows to fit long localized card descriptions without overflow',
    (tester) async {
      await tester.pumpWidget(
        _app(
          const LunarRecommendationsWidget(
            recommendation: SphereRecommendationModel(
              status: RecommendationStatus.unfavorable,
              tasks: {
                'haircut': TaskRecommendationModel(
                  status: RecommendationStatus.unfavorable,
                  description:
                      'Лучше избегать кардинальной стрижки: при необходимости '
                      'ограничиться лёгким подравниванием. Удобно делать '
                      'поддерживающую стрижку и убирать лишнюю длину, если не '
                      'хочешь быстрого отрастания. Лучше делать аккуратные, '
                      'продуманные стрижки, выравнивать форму и кончики.',
                ),
                'hair_coloring': TaskRecommendationModel(
                  status: RecommendationStatus.unfavorable,
                  description:
                      'Окрашивание стоит сделать максимально мягким: без '
                      'сильного осветления и радикального изменения цвета, '
                      'можно ограничиться лёгким оттеночным средством. Лучше '
                      'избегать агрессивного окрашивания и обесцвечивания, '
                      'ограничиться тонированием и мягкими средствами. Хорошо '
                      'делать аккуратное окрашивание, выравнивание тона и '
                      'поддержание середины.',
                ),
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('grows to fit long spa recommendation descriptions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const LunarRecommendationsWidget(
          recommendation: SphereRecommendationModel(
            status: RecommendationStatus.favorable,
            tasks: {
              'spa_and_relaxation': TaskRecommendationModel(
                status: RecommendationStatus.favorable,
                description:
                    'Хорошо заходят длительные программы релакса: спа-день, '
                    'массаж всего тела, флоатинг, соляные и травяные ванны. '
                    'Удобно делать очищающие и детокс-процедуры: скрабы, '
                    'обёртывания, баню в умеренном режиме, без лишнего '
                    'напряжения. Важно не перегружать сердце и не '
                    'перегреваться: умеренная температура в бане, короткие '
                    'заходы, чай и расслабляющий массаж.',
              ),
            },
          ),
        ),
      ),
    );

    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders hair coloring icon as a full card image', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const LunarRecommendationsWidget(
          recommendation: SphereRecommendationModel(
            status: RecommendationStatus.neutral,
            tasks: {
              'hair_coloring': TaskRecommendationModel(
                status: RecommendationStatus.neutral,
                description: 'Цвет ляжет нормально.',
              ),
            },
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(
      _assetImage(
        'assets/images/prediction_images/moon_card_beauty_hair_coloring.webp',
      ),
    );

    expect(image.width, 83);
    expect(image.height, 44);
    expect(image.fit, BoxFit.fill);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses Figma typography for lunar recommendation cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const LunarRecommendationsWidget(
          recommendation: SphereRecommendationModel(
            status: RecommendationStatus.neutral,
            tasks: {
              'hair_coloring': TaskRecommendationModel(
                status: RecommendationStatus.neutral,
                description: 'Цвет ляжет нормально.',
              ),
            },
          ),
        ),
      ),
    );

    final title = tester.widget<Text>(find.text('Окрашивание волос'));
    final description = tester.widget<Text>(find.text('Цвет ляжет нормально.'));

    expect(title.style?.fontFamily, 'Lora');
    expect(title.style?.fontWeight, FontWeight.w500);
    expect(title.style?.fontSize, 20);
    expect(title.style?.height, 1.1);
    expect(description.style?.fontFamily, 'Onest');
    expect(description.style?.fontWeight, FontWeight.w400);
    expect(description.style?.fontSize, 16);
    expect(description.style?.height, 1.2);
    expect(description.style?.letterSpacing, closeTo(-0.408, 0.001));
  });
}

Finder _assetImage(String assetName) {
  return find.byWidgetPredicate((widget) {
    final imageProvider = widget is Image ? widget.image : null;
    final assetImage = switch (imageProvider) {
      AssetImage image => image,
      ResizeImage(:final imageProvider) when imageProvider is AssetImage =>
        imageProvider,
      _ => null,
    };
    return widget is Image &&
        assetImage != null &&
        assetImage.assetName == assetName;
  });
}

Finder _dayStatusImages() {
  return find.byWidgetPredicate((widget) {
    return widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName.startsWith(
          'assets/icons/day_status_',
        );
  });
}

Widget _app(Widget child, {Locale locale = const Locale('ru')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocaleService.supportedLocales,
    home: Builder(
      builder: (context) => Theme(
        data: AppThemeDark.instance.getThemeData(context),
        child: Scaffold(body: child),
      ),
    ),
  );
}
