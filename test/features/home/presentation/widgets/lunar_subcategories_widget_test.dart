import 'dart:ui' as ui;

import 'package:asteria_app/app/data/models/lunar_calendar/beauty_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/content_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/gardening_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/health_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/relationships_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/work_and_rest_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/features/home/presentation/widgets/lunar_subcategories_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/sphere_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'renders the pre-cropped haircut icon inside its allocated area',
    (tester) async {
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
                child: const Scaffold(
                  body: LunarSubcategoriesWidget(
                    content: _content,
                    sphere: Sphere.beauty,
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      final haircutImageFinder = find.byWidgetPredicate((widget) {
        return widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/prediction_images/'
                    'moon_card_beauty_haircut.webp';
      });

      expect(haircutImageFinder, findsOneWidget);

      final haircutImage = tester.widget<Image>(haircutImageFinder);
      expect(haircutImage.image, isA<AssetImage>());
      expect(haircutImage.fit, BoxFit.fill);
      expect(haircutImage.width, 83);
      expect(haircutImage.height, 44);

      await tester.runAsync(() async {
        final assetData = await rootBundle.load(
          'assets/images/prediction_images/moon_card_beauty_haircut.webp',
        );
        final codec = await ui.instantiateImageCodec(
          assetData.buffer.asUint8List(
            assetData.offsetInBytes,
            assetData.lengthInBytes,
          ),
        );
        final frame = await codec.getNextFrame();
        final rgba = await frame.image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        expect(frame.image.width, 249);
        expect(frame.image.height, 132);
        expect(rgba, isNotNull);
        expect(rgba!.getUint8(3), 0);
        frame.image.dispose();
        codec.dispose();
      });

      final imageRect = tester.getRect(haircutImageFinder);
      expect(imageRect.width, 83);
      expect(imageRect.height, 44);
      final descriptionRect = tester.getRect(find.text(_haircutDescription));
      expect(imageRect.bottom, lessThanOrEqualTo(descriptionRect.top));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('renders lunar subcategory display names from English ARB', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
        home: Builder(
          builder: (context) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: const Scaffold(
              body: LunarSubcategoriesWidget(
                content: _content,
                sphere: Sphere.beauty,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Haircuts'), findsOneWidget);
    expect(find.text('Hair coloring'), findsOneWidget);
    expect(find.text('Стрижки'), findsNothing);
    expect(find.text('Окрашивание волос'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('grows beauty subcategory cards to fit long descriptions', (
    tester,
  ) async {
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
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: const Scaffold(
                body: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: LunarSubcategoriesWidget(
                        content: _contentWithLongBeautyCard,
                        sphere: Sphere.beauty,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text(_longDescription), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('matches subcategory card heights to the tallest card', (
    tester,
  ) async {
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
            child: const Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: LunarSubcategoriesWidget(
                      content: _contentWithLongBeautyCard,
                      sphere: Sphere.beauty,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    final cards = _lunarCardContainers();
    expect(cards, findsWidgets);
    final firstCardHeight = tester.getSize(cards.at(0)).height;
    final secondCardHeight = tester.getSize(cards.at(1)).height;
    expect(firstCardHeight, greaterThan(182));
    expect(secondCardHeight, firstCardHeight);
    expect(tester.takeException(), isNull);
  });
}

const _haircutDescription =
    'Подровнять кончики и освежить форму без резкой смены образа.';

const _content = ContentModel(
  beauty: BeautyModel(
    status: 1,
    haircut: _haircutDescription,
    hairColoring: 'Для окрашивания лучше выбрать знакомый оттенок.',
    skinCare: 'Подойдёт мягкий повседневный уход.',
    manicurePedicure: 'Поддерживающие процедуры пройдут комфортно.',
    cosmetology: 'Отложите агрессивные процедуры.',
    epilationDepilation: 'Выбирайте привычный способ ухода.',
    spaAndRelaxation: 'Спокойный отдых поможет восстановиться.',
    fragrancesAndMagnetism: 'Подойдут лёгкие знакомые ароматы.',
  ),
  gardening: GardeningModel(
    status: 0,
    sowingAndPlanting: '',
    transplantingAndPricking: '',
    wateringAndFertilizing: '',
    pestControl: '',
    harvestingAndPreserving: '',
    houseplants: '',
    garden: '',
  ),
  health: HealthModel(
    status: 0,
    healthAndImmunity: '',
    dailyDiet: '',
    weightLossAndFastingDays: '',
    sleepAndRecovery: '',
    physicalActivityAndSports: '',
    medicalProcedures: '',
    meditations: '',
  ),
  workAndRest: WorkAndRestModel(
    status: 0,
    jobChange: '',
    careerGrowth: '',
    work: '',
    travel: '',
    importantDecisions: '',
  ),
  relationships: RelationshipsModel(
    status: 0,
    family: '',
    couple: '',
    friends: '',
    sex: '',
    forThoseAlone: '',
  ),
);

const _longDescription =
    'Хорошо заходят длительные программы релакса: спа-день, массаж всего тела, '
    'флоатинг, соляные и травяные ванны. Удобно делать очищающие и '
    'детокс-процедуры: скрабы, обёртывания, баню в умеренном режиме, без '
    'лишнего напряжения. Важно не перегружать сердце и не перегреваться: '
    'умеренная температура в бане, короткие заходы, чай и расслабляющий массаж.';

const _contentWithLongBeautyCard = ContentModel(
  beauty: BeautyModel(
    status: 1,
    haircut: _longDescription,
    hairColoring: 'Для окрашивания лучше выбрать знакомый оттенок.',
    skinCare: 'Подойдёт мягкий повседневный уход.',
    manicurePedicure: 'Поддерживающие процедуры пройдут комфортно.',
    cosmetology: 'Отложите агрессивные процедуры.',
    epilationDepilation: 'Выбирайте привычный способ ухода.',
    spaAndRelaxation: 'Спокойный отдых поможет восстановиться.',
    fragrancesAndMagnetism: 'Подойдут лёгкие знакомые ароматы.',
  ),
  gardening: GardeningModel(
    status: 0,
    sowingAndPlanting: '',
    transplantingAndPricking: '',
    wateringAndFertilizing: '',
    pestControl: '',
    harvestingAndPreserving: '',
    houseplants: '',
    garden: '',
  ),
  health: HealthModel(
    status: 0,
    healthAndImmunity: '',
    dailyDiet: '',
    weightLossAndFastingDays: '',
    sleepAndRecovery: '',
    physicalActivityAndSports: '',
    medicalProcedures: '',
    meditations: '',
  ),
  workAndRest: WorkAndRestModel(
    status: 0,
    jobChange: '',
    careerGrowth: '',
    work: '',
    travel: '',
    importantDecisions: '',
  ),
  relationships: RelationshipsModel(
    status: 0,
    family: '',
    couple: '',
    friends: '',
    sex: '',
    forThoseAlone: '',
  ),
);

Finder _lunarCardContainers() {
  return find.byWidgetPredicate((widget) {
    if (widget is! Container) return false;
    final constraints = widget.constraints;
    return constraints?.minWidth == 304 &&
        constraints?.maxWidth == 304 &&
        constraints?.minHeight == 182;
  });
}
