import 'dart:async';

import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/data/models/energy_of_day/energy_of_day_model.dart';
import 'package:asteria_app/app/data/models/moon_phase/moon_phase_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/personalized_lunar_month_model.dart';
import 'package:asteria_app/app/data/repositories/lunar_calendar/personalized_lunar_calendar_repository.dart';
import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/string_extensions.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/location/city_search_service.dart';
import 'package:asteria_app/core/location/device_location_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/compatibility/domain/repositories/compatibility_repository.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_phase_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('ru');
    // The header's one-line layout depends on the actual Cyrillic glyph widths.
    for (final font in ['Lora', 'Onest']) {
      final loader = FontLoader(font)
        ..addFont(
          rootBundle.load(
            'assets/fonts/${font.toLowerCase()}/$font-VariableFont_wght.ttf',
          ),
        );
      await loader.load();
    }
  });

  for (final lunarDay in [1, 30]) {
    testWidgets(
      'renders lunar day $lunarDay with a bold number without overflow',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await di.reset();
        final moonPhase = _moonPhase(lunarDay);
        final userProvider = UserProvider(userRepository: _FakeUserRepository())
          ..applyServerUserSnapshot(
            UserModel.empty().copyWith(
              moonPhase: moonPhase,
              currentLocation: _currentLocation(),
            ),
          );
        final contentProvider = ContentProvider(
          contentRepository: _FakeContentRepository(moonPhase),
          userProvider: userProvider,
          compatibilityRepository: _FakeCompatibilityRepository(),
          personalizedLunarCalendarRepository: _FakePersonalizedRepository(
            _personalizedMonth(moonPhase),
          ),
        );
        di.registerSingleton<UserProvider>(userProvider);
        di.registerSingleton<ContentProvider>(contentProvider);

        addTearDown(() async {
          contentProvider.dispose();
          userProvider.dispose();
          await di.reset();
        });

        await tester.pumpWidget(
          ChangeNotifierProvider<UserProvider>.value(
            value: userProvider,
            child: MaterialApp(
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
                      body: SingleChildScrollView(child: MoonPhaseWidget()),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final label = tester.widget<Text>(
          find.byKey(const ValueKey('moon-phase-lunar-day-label')),
        );
        final rootSpan = label.textSpan! as TextSpan;
        final numberSpan = rootSpan.children!.first as TextSpan;
        final suffixSpan = rootSpan.children!.last as TextSpan;

        expect(rootSpan.toPlainText(), '$lunarDay лунный день');
        expect(label.style?.fontFamily, 'Onest');
        expect(label.style?.fontSize, 12);
        expect(label.style?.fontWeight, FontWeight.w500);
        expect(label.style?.height, 0.9);
        expect(label.style?.letterSpacing, -0.41);
        expect(numberSpan.text, '$lunarDay');
        expect(numberSpan.style?.fontWeight, FontWeight.w700);
        expect(suffixSpan.text, ' лунный день');
        expect(suffixSpan.style, isNull);
        expect(label.maxLines, 1);
        expect(label.overflow, TextOverflow.ellipsis);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('renders primary phase exact local time in moon card', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await di.reset();
    final moonPhase = _moonPhase(
      15,
      moonPhase: 'full_moon',
      moonPhaseRu: 'Полнолуние',
      phaseEvent: const MoonPhaseEventModel(
        phase: 'full_moon',
        phaseRu: 'Полнолуние',
        exactUtc: '2026-05-01T17:23:00Z',
        exactLocal: '2026-05-01T20:23:00+03:00',
        localDate: '2026-05-01',
      ),
    );
    final userProvider = UserProvider(userRepository: _FakeUserRepository())
      ..applyServerUserSnapshot(
        UserModel.empty().copyWith(
          moonPhase: moonPhase,
          currentLocation: _currentLocation(),
        ),
      );
    final contentProvider = ContentProvider(
      contentRepository: _FakeContentRepository(moonPhase),
      userProvider: userProvider,
      compatibilityRepository: _FakeCompatibilityRepository(),
      personalizedLunarCalendarRepository: _FakePersonalizedRepository(
        _personalizedMonth(moonPhase),
      ),
    );
    di.registerSingleton<UserProvider>(userProvider);
    di.registerSingleton<ContentProvider>(contentProvider);

    addTearDown(() async {
      contentProvider.dispose();
      userProvider.dispose();
      await di.reset();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: userProvider,
        child: MaterialApp(
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
                  body: SingleChildScrollView(child: MoonPhaseWidget()),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Полнолуние'), findsOneWidget);
    expect(find.text('Наступает в 20:23 по вашему времени'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'uses primary phase event as moon card title over personalized phase',
    (tester) async {
      final moonPhase = _moonPhase(
        16,
        moonPhase: 'full_moon',
        moonPhaseRu: 'Полнолуние',
        phaseEvent: const MoonPhaseEventModel(
          phase: 'full_moon',
          phaseRu: 'Полнолуние',
          exactUtc: '2027-09-15T23:03:26Z',
          exactLocal: '2027-09-16T02:03:26+03:00',
          localDate: '2027-09-16',
        ),
      );
      await _pumpMoonPhaseWidget(
        tester,
        moonPhase: moonPhase,
        personalizedMonth: _personalizedMonth(
          moonPhase,
          phase: 'waning_gibbous',
          backgroundSummary: 'Backend summary for selected day.',
        ),
      );

      expect(find.text('Полнолуние'), findsOneWidget);
      expect(find.text('Убывающая Луна'), findsNothing);
      expect(find.text('Наступает в 02:03 по вашему времени'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'keeps backend summary without inventing status when spheres are missing',
    (tester) async {
      await _pumpMoonPhaseWidget(
        tester,
        moonPhase: _moonPhase(15),
        personalizedMonth: _personalizedMonth(
          _moonPhase(22),
          backgroundTitle: 'Доработка',
          backgroundSummary: 'Backend summary for selected day.',
        ),
      );

      expect(
        _assetImagesAtSize('assets/icons/day_status_favorable_star.png', 14),
        findsNothing,
      );
      expect(
        _assetImagesAtSize('assets/icons/day_status_neutral_star.png', 14),
        findsNothing,
      );
      expect(
        _assetImagesAtSize('assets/icons/day_status_unfavorable_star.png', 14),
        findsNothing,
      );
      expect(find.text('Backend summary for selected day.'), findsOneWidget);
      expect(find.text('Доработка'), findsNothing);
      expect(
        find.byKey(const ValueKey('moon-phase-background-tone-chip')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('moon-phase-lunar-day-chip')),
        findsOneWidget,
      );
      expect(find.text('22 лунный день'), findsOneWidget);
      expect(find.text('Нейтральный день'), findsNothing);
      expect(
        _assetImagesAtSize('assets/icons/day_status_neutral_star.png', 25),
        findsNothing,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              (widget.properties.label ?? '').contains('Благоприятный день'),
        ),
        findsNothing,
      );
      expect(
        tester
            .widgetList<Image>(find.byType(Image))
            .map(_assetName)
            .whereType<String>()
            .any((assetName) => assetName.endsWith('_day_icon.png')),
        isFalse,
      );
    },
  );

  for (final entry in {
    RecommendationStatus.favorable: 'Благоприятный день',
    RecommendationStatus.neutral: 'Нейтральный день',
    RecommendationStatus.unfavorable: 'Неблагоприятный день',
  }.entries) {
    testWidgets(
      'shows the aggregate ${entry.key.name} day status in the strip and card',
      (tester) async {
        final moonPhase = _moonPhase(15);
        final selected = moonPhase.date.fromRussianShortDate();
        const neutral = SphereRecommendationModel(
          status: RecommendationStatus.neutral,
          tasks: {},
        );
        final selectedSpheres = {
          'beauty': const SphereRecommendationModel(
            status: RecommendationStatus.favorable,
            tasks: {},
          ),
          'gardening': const SphereRecommendationModel(
            status: RecommendationStatus.unfavorable,
            tasks: {},
          ),
          'health': SphereRecommendationModel(
            status: entry.key,
            tasks: const {},
          ),
          'work_and_rest': neutral,
          'relationships': neutral,
        };
        await _pumpMoonPhaseWidget(
          tester,
          moonPhase: moonPhase,
          personalizedMonth: _personalizedMonth(
            moonPhase,
            spheresForDate: (date) => date.day == selected.day
                ? selectedSpheres
                : {'work_and_rest': neutral},
          ),
        );
        final icon = 'assets/icons/day_status_${entry.key.name}_star.png';
        expect(_assetImagesAtSize(icon, 14), findsOneWidget);
        expect(_assetImagesAtSize(icon, 16), findsOneWidget);
        expect(find.text(entry.value), findsOneWidget);
        final calendar = tester.getCenter(find.text('Выбрать день'));
        expect(
          calendar.dy,
          closeTo(tester.getCenter(find.text('Фаза луны')).dy, 2),
        );
        expect(
          tester.getTopLeft(find.text(_currentLocation().location)).dy,
          lessThan(tester.getTopLeft(find.text('Backend summary.')).dy),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('shows the full location note on one line on compact phones', (
    tester,
  ) async {
    await _pumpMoonPhaseWidget(tester, moonPhase: _moonPhase(15));
    const label = 'Учитываем твою локацию и время';
    for (final width in [320.0, 390.0]) {
      tester.view.physicalSize = Size(width, 844);
      await tester.pumpAndSettle();
      final note = find.text(label);
      final paragraph = tester.renderObject<RenderParagraph>(note);
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: label.length),
      );
      expect(boxes.map((box) => box.top).toSet(), hasLength(1));
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(tester.getTopRight(note).dx, closeTo(width - 16, 1));
      expect(
        tester.getTopLeft(note).dx,
        greaterThan(
          tester.getTopRight(find.text(_currentLocation().location)).dx,
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('large text gives the city and location note their own lines', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _pumpMoonPhaseWidget(tester, moonPhase: _moonPhase(15));
    final city = tester.getRect(find.text(_currentLocation().location));
    final note = tester.getRect(find.text('Учитываем твою локацию и время'));
    expect(note.top, greaterThanOrEqualTo(city.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens current city, confirms it, or changes it from the list', (
    tester,
  ) async {
    final user = await _pumpMoonPhaseWidget(tester, moonPhase: _moonPhase(15));
    final city = user.currentUser!.currentLocation!;
    await tester.tap(find.text(city.location));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('это ваш город?', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.text('Верно'));
    await tester.pumpAndSettle();
    expect(identical(user.currentUser!.currentLocation, city), isTrue);
    await tester.tap(find.text(city.location));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сменить'));
    await tester.pumpAndSettle();
    expect(find.text('Выберите город'), findsOneWidget);
    const next = 'Петропавловск-Камчатский, Россия';
    await tester.tap(find.text(next));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(
        'Петропавловск-Камчатский,\nэто ваш город?',
        findRichText: true,
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Верно'));
    await tester.pumpAndSettle();
    expect(user.currentUser!.currentLocation!.location, next);
    expect(
      user.currentUser!.currentLocation!.source,
      CurrentLocationSource.manual,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'pages the date strip and day card together and reverses mid-flight',
    (tester) async {
      final currentMoonPhase = _moonPhase(15);
      final selectedDate = currentMoonPhase.date.fromRussianShortDate();
      final lastDayOfMonth = DateTime(
        selectedDate.year,
        selectedDate.month + 1,
        0,
      ).day;
      final targetOffset = selectedDate.day == lastDayOfMonth ? -1 : 1;
      final targetDate = selectedDate.add(Duration(days: targetOffset));
      await _pumpMoonPhaseWidget(
        tester,
        moonPhase: currentMoonPhase,
        contentRepository: _FakeContentRepository.byDate({
          _dateKey(selectedDate): currentMoonPhase,
          _dateKey(targetDate): _moonPhase(
            16,
            moonPhase: 'full_moon',
            moonPhaseRu: 'Полнолуние',
          ),
        }),
      );

      final nextDayLabel = LocaleFormatters.dayMonth(
        targetDate,
        const Locale('ru'),
      ).replaceAll('.', '');
      final todayLabel = LocaleFormatters.dayMonth(
        selectedDate,
        const Locale('ru'),
      ).replaceAll('.', '');
      final today = find.text(todayLabel);
      final next = find.text(nextDayLabel);
      final chip = find
          .ancestor(of: today, matching: find.byType(AnimatedContainer))
          .first;
      expect(tester.getSize(chip), const Size(58, 114));
      expect(tester.widget<Text>(today).style?.fontSize, 12);
      final lunarChip = find.byKey(const ValueKey('moon-phase-lunar-day-chip'));
      final cardTop = tester.getTopLeft(lunarChip).dy;
      final selectedX = tester.getCenter(today).dx;
      final initialDistance = (tester.getCenter(next).dx - selectedX).abs();
      await tester.tap(next);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 190));

      final distance = (tester.getCenter(next).dx - selectedX).abs();
      expect(distance, inExclusiveRange(1, initialDistance - 1));
      expect(lunarChip, findsNWidgets(2));
      for (final chip in [lunarChip.first, lunarChip.last]) {
        expect(tester.getTopLeft(chip).dy, closeTo(cardTop, .01));
      }
      final shifts = <double>[];
      for (final chip in [lunarChip.first, lunarChip.last]) {
        final slide = tester.widget<SlideTransition>(
          find.ancestor(of: chip, matching: find.byType(SlideTransition)).first,
        );
        expect(slide.position.value.dy, 0);
        expect(slide.child, isA<HomeGlassSurface>());
        expect((slide.child! as HomeGlassSurface).animateEntrance, isFalse);
        shifts.add(slide.position.value.dx);
      }
      expect(shifts.any((dx) => dx < -.05), isTrue);
      expect(shifts.any((dx) => dx > .05), isTrue);
      await tester.tap(today);
      await tester.pumpAndSettle();
      expect(tester.getCenter(today).dx, closeTo(selectedX, .5));
      expect(
        find.byKey(const ValueKey('moon-phase-lunar-day-label')),
        findsOneWidget,
      );

      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pump();
      await tester.tap(next);
      await tester.pump();
      await tester.pump();
      expect(tester.getCenter(next).dx, closeTo(selectedX, .5));
    },
  );

  testWidgets('keeps loading state until backend day is loaded', (
    tester,
  ) async {
    final moonPhase = _moonPhase(15);
    await _pumpMoonPhaseWidget(
      tester,
      moonPhase: moonPhase,
      personalizedMonth: _emptyPersonalizedMonth(moonPhase),
      settle: false,
    );
    await tester.pump();

    expect(find.text('Загружаем фазу луны'), findsOneWidget);
    expect(find.text('Выбрать день').hitTestable(), findsOneWidget);
    expect(
      _assetImagesAtSize('assets/icons/day_status_neutral_star.png', 25),
      findsNothing,
    );
  });

  testWidgets(
    'shows location setup instead of birth place when current location is missing',
    (tester) async {
      final userProvider = await _pumpMoonPhaseWidget(
        tester,
        moonPhase: _moonPhase(13),
        user: UserModel.empty().copyWith(
          moonPhase: _moonPhase(13),
          personalInfo: const PersonalInfoModel(
            birthPlace: BirthPlaceModel(
              location: 'Шымкент, Казахстан',
              latitude: 42.3417,
              longitude: 69.5901,
            ),
          ),
        ),
      );
      di.registerSingleton<CitySearchService>(
        _FakeCitySearchService(
          suggestion: const CitySuggestion(
            placeId: 'almaty',
            description: 'Алматы, Казахстан',
          ),
          location: const CurrentLocationModel(
            location: 'Алматы, Казахстан',
            latitude: 43.2389,
            longitude: 76.8897,
            source: CurrentLocationSource.manual,
          ),
        ),
      );

      expect(find.text('Укажи текущую геолокацию'), findsOneWidget);
      expect(find.text('Шымкент, Казахстан'), findsNothing);
      expect(find.text('Разрешить геолокацию'), findsOneWidget);
      expect(find.text('Выбрать город вручную'), findsOneWidget);
      expect(find.text('Город'), findsNothing);

      await tester.tap(find.text('Выбрать город вручную'));
      await tester.pumpAndSettle();

      expect(find.text('Выберите город'), findsOneWidget);
      expect(find.text('Город'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Ал');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Алматы, Казахстан'), findsOneWidget);

      await tester.tap(find.text('Алматы, Казахстан'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Укажи текущую геолокацию'), findsOneWidget);
      expect(find.text('Верно'), findsOneWidget);
      expect(find.text('Сменить'), findsOneWidget);
      expect(
        tester
            .getTopLeft(find.byKey(const ValueKey('city-confirmation-sheet')))
            .dy,
        103,
      );

      await tester.tap(find.text('Сменить'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Выберите город'), findsOneWidget);
      expect(find.text('Алматы, Казахстан'), findsOneWidget);
      expect(tester.testTextInput.isVisible, isFalse);

      await tester.tap(find.text('Алматы, Казахстан'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Верно'), findsOneWidget);
      expect(find.text('Сменить'), findsOneWidget);

      await tester.tap(find.text('Верно'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Укажи текущую геолокацию'), findsNothing);
      expect(find.text('Разрешить геолокацию'), findsNothing);
      expect(find.text('Выбрать город вручную'), findsNothing);
      expect(find.text('Растущая Луна'), findsOneWidget);
      expect(
        userProvider.currentUser?.currentLocation?.location,
        'Алматы, Казахстан',
      );
      expect(
        userProvider.currentUser?.currentLocation?.source,
        CurrentLocationSource.manual,
      );
    },
  );

  testWidgets(
    'shows an explicit moon loading state after auto location grant',
    (tester) async {
      final moonPhaseCompleter = Completer<MoonPhaseModel>();
      final contentRepository = _FakeContentRepository.pendingMoonPhase(
        moonPhaseCompleter.future,
      );
      await _pumpMoonPhaseWidget(
        tester,
        moonPhase: _moonPhase(12),
        contentRepository: contentRepository,
        deviceLocationService: const _FakeDeviceLocationService(
          CurrentLocationModel(
            location: 'Амстердам, Нидерланды',
            latitude: 52.3676,
            longitude: 4.9041,
            source: CurrentLocationSource.auto,
          ),
          availableOnlyWhenRequested: true,
        ),
        user: UserModel.empty(),
      );

      await tester.tap(find.text('Разрешить геолокацию'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Загружаем фазу луны'), findsOneWidget);
      expect(find.text('Укажи текущую геолокацию').hitTestable(), findsNothing);
      await tester.pump(const Duration(milliseconds: 370));
      expect(find.text('Укажи текущую геолокацию'), findsNothing);

      moonPhaseCompleter.complete(_moonPhase(12));
      await tester.pumpAndSettle();

      expect(find.text('Растущая Луна'), findsOneWidget);
      expect(contentRepository.todayMoonPhaseCallCount, 1);
    },
  );

  testWidgets(
    'refreshes an existing automatic location when permission exists',
    (tester) async {
      final contentRepository = _FakeContentRepository(_moonPhase(12));
      final userProvider = await _pumpMoonPhaseWidget(
        tester,
        moonPhase: _moonPhase(12),
        contentRepository: contentRepository,
        deviceLocationService: const _FakeDeviceLocationService(
          CurrentLocationModel(
            location: 'Амстердам, Нидерланды',
            latitude: 52.3676,
            longitude: 4.9041,
            source: CurrentLocationSource.auto,
          ),
        ),
        user: UserModel.empty().copyWith(
          currentLocation: const CurrentLocationModel(
            location: 'Сан-Франциско, Соединённые Штаты Америки',
            latitude: 37.7749,
            longitude: -122.4194,
            source: CurrentLocationSource.auto,
          ),
          clearMoonPhase: true,
        ),
      );

      await tester.pumpAndSettle();

      expect(
        userProvider.currentUser?.currentLocation?.location,
        'Амстердам, Нидерланды',
      );
      expect(contentRepository.lastMoonPhaseLat, 52.3676);
      expect(contentRepository.lastMoonPhaseLon, 4.9041);
      expect(contentRepository.todayMoonPhaseCallCount, 1);
    },
  );

  testWidgets(
    'does not render or prefetch with a stale automatic location before refresh',
    (tester) async {
      final contentRepository = _FakeContentRepository(_moonPhase(12));
      final userProvider = await _pumpMoonPhaseWidget(
        tester,
        moonPhase: _moonPhase(12),
        contentRepository: contentRepository,
        deviceLocationService: const _FakeDeviceLocationService(
          CurrentLocationModel(
            location: 'Амстердам, Нидерланды',
            latitude: 52.3676,
            longitude: 4.9041,
            source: CurrentLocationSource.auto,
          ),
        ),
        user: UserModel.empty().copyWith(
          moonPhase: _moonPhase(12),
          currentLocation: const CurrentLocationModel(
            location: 'Сан-Франциско, Соединённые Штаты Америки',
            latitude: 37.7749,
            longitude: -122.4194,
            source: CurrentLocationSource.auto,
          ),
        ),
      );

      expect(
        find.text('Сан-Франциско, Соединённые Штаты Америки'),
        findsNothing,
      );

      await tester.pumpAndSettle();

      expect(
        userProvider.currentUser?.currentLocation?.location,
        'Амстердам, Нидерланды',
      );
      expect(
        contentRepository.requestedMoonPhaseCoordinates,
        isNot(contains('37.7749:-122.4194')),
      );
      expect(
        contentRepository.requestedMoonPhaseCoordinates,
        everyElement('52.3676:4.9041'),
      );
    },
  );
}

Future<UserProvider> _pumpMoonPhaseWidget(
  WidgetTester tester, {
  required MoonPhaseModel moonPhase,
  UserModel? user,
  ContentRepository? contentRepository,
  DeviceLocationService? deviceLocationService,
  PersonalizedLunarMonthModel? personalizedMonth,
  bool settle = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await di.reset();
  final userProvider = UserProvider(userRepository: _FakeUserRepository())
    ..applyServerUserSnapshot(
      user ??
          UserModel.empty().copyWith(
            moonPhase: moonPhase,
            currentLocation: _currentLocation(),
          ),
    );
  final contentProvider = ContentProvider(
    contentRepository: contentRepository ?? _FakeContentRepository(moonPhase),
    userProvider: userProvider,
    compatibilityRepository: _FakeCompatibilityRepository(),
    personalizedLunarCalendarRepository: _FakePersonalizedRepository(
      personalizedMonth ?? _personalizedMonth(moonPhase),
    ),
  );
  await contentProvider.initialize();
  di.registerSingleton<UserProvider>(userProvider);
  di.registerSingleton<ContentProvider>(contentProvider);
  if (deviceLocationService != null) {
    di.registerSingleton<DeviceLocationService>(deviceLocationService);
  }

  addTearDown(() async {
    contentProvider.dispose();
    userProvider.dispose();
    await di.reset();
  });

  await tester.pumpWidget(
    ChangeNotifierProvider<UserProvider>.value(
      value: userProvider,
      child: MaterialApp(
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
              body: SingleChildScrollView(child: MoonPhaseWidget()),
            ),
          ),
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
  return userProvider;
}

Finder _assetImagesAtSize(String assetPath, double size) =>
    find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          _assetName(widget) == assetPath &&
          widget.width == size &&
          widget.height == size,
      description: 'Image.asset($assetPath, ${size}x$size)',
    );

String? _assetName(Image image) {
  final provider = image.image;
  if (provider is AssetImage) return provider.assetName;
  if (provider is ResizeImage && provider.imageProvider is AssetImage) {
    return (provider.imageProvider as AssetImage).assetName;
  }
  return null;
}

CurrentLocationModel _currentLocation() {
  return const CurrentLocationModel(
    location: 'Алматы, Казахстан',
    latitude: 43.2389,
    longitude: 76.8897,
    source: CurrentLocationSource.manual,
  );
}

MoonPhaseModel _moonPhase(
  int lunarDay, {
  String moonPhase = 'waxing_gibbous',
  String moonPhaseRu = 'Растущая луна',
  MoonPhaseEventModel? phaseEvent,
}) {
  final now = DateTime.now();
  return MoonPhaseModel(
    date: _formatDate(now),
    lunarDay: lunarDay,
    moonSign: 'aries',
    moonPhase: moonPhase,
    moonPhaseRu: moonPhaseRu,
    moonriseLocal: '12:00',
    phaseEvent: phaseEvent,
  );
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

String _dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class _FakeContentRepository implements ContentRepository {
  _FakeContentRepository(this.moonPhase)
    : pendingMoonPhase = null,
      moonPhasesByDate = const {};

  _FakeContentRepository.pendingMoonPhase(this.pendingMoonPhase)
    : moonPhase = null,
      moonPhasesByDate = const {};

  _FakeContentRepository.byDate(this.moonPhasesByDate)
    : moonPhase = null,
      pendingMoonPhase = null;

  final MoonPhaseModel? moonPhase;
  final Future<MoonPhaseModel>? pendingMoonPhase;
  final Map<String, MoonPhaseModel> moonPhasesByDate;
  double? lastMoonPhaseLat;
  double? lastMoonPhaseLon;
  int getMoonPhaseCallCount = 0;
  int todayMoonPhaseCallCount = 0;
  final List<String> requestedMoonPhaseCoordinates = [];

  @override
  Future<void> refreshContentVersions() async {}

  @override
  Future<List<TarotCardModel>> getTarotCards() async => const [];

  @override
  Future<List<TarotCardModel>> getTarotCardsFromCache() async => const [];

  @override
  Future<void> saveTarotCardsToCache(List<TarotCardModel> tarotCards) async {}

  @override
  Future<List<RuneOfDayModel>> getRunes() async => const [];

  @override
  Future<List<RuneOfDayModel>> getRunesFromCache() async => const [];

  @override
  Future<void> saveRunesToCache(List<RuneOfDayModel> runes) async {}

  @override
  Future<List<ArticleModel>> getArticles() async => const [];

  @override
  Future<List<ArticleModel>> getArticlesFromCache() async => const [];

  @override
  Future<void> saveArticlesToCache(List<ArticleModel> articles) async {}

  @override
  Future<List<AffirmationModel>> getAffirmations() async => const [];

  @override
  Future<List<AffirmationModel>> getAffirmationsFromCache() async => const [];

  @override
  Future<void> saveAffirmationsToCache(
    List<AffirmationModel> affirmations,
  ) async {}

  @override
  Future<List<EnergyOfDayModel>> getEnergyOfDay() async => const [];

  @override
  Future<List<EnergyOfDayModel>> getEnergyOfDayFromCache() async => const [];

  @override
  Future<void> saveEnergyOfDayToCache(
    List<EnergyOfDayModel> energyOfDay,
  ) async {}

  @override
  Future<bool> shouldReloadEnergyOfDay() async => false;

  @override
  Future<MoonPhaseModel> getMoonPhase(
    int year,
    int month,
    int day,
    int hour,
    int minute,
    int timezoneOffsetMinutes,
    double lat,
    double lon,
  ) async {
    getMoonPhaseCallCount += 1;
    final now = DateTime.now();
    if (year == now.year && month == now.month && day == now.day) {
      todayMoonPhaseCallCount += 1;
    }
    lastMoonPhaseLat = lat;
    lastMoonPhaseLon = lon;
    requestedMoonPhaseCoordinates.add(
      '${lat.toStringAsFixed(4)}:${lon.toStringAsFixed(4)}',
    );
    final requestedDate = DateTime(year, month, day);
    final resolvedMoonPhase = pendingMoonPhase != null
        ? await pendingMoonPhase!
        : moonPhasesByDate[_dateKey(requestedDate)] ??
              moonPhase ??
              moonPhasesByDate.values.first;
    return resolvedMoonPhase.copyWith(date: _formatDate(requestedDate));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePersonalizedRepository
    implements PersonalizedLunarCalendarRepository {
  const _FakePersonalizedRepository(this.month);

  final PersonalizedLunarMonthModel month;

  @override
  Future<PersonalizedLunarMonthModel> loadMonth({
    required DateTime month,
    required CurrentLocationModel location,
  }) async {
    return this.month;
  }
}

class _FakeDeviceLocationService extends DeviceLocationService {
  const _FakeDeviceLocationService(
    this.location, {
    this.availableOnlyWhenRequested = false,
  });

  final CurrentLocationModel location;
  final bool availableOnlyWhenRequested;

  @override
  Future<DeviceLocationResult> detectCurrentLocation({
    required bool requestPermission,
  }) async {
    if (availableOnlyWhenRequested && !requestPermission) {
      return const DeviceLocationResult.permissionDenied();
    }
    return DeviceLocationResult.available(location);
  }
}

PersonalizedLunarMonthModel _personalizedMonth(
  MoonPhaseModel moonPhase, {
  String? phase,
  String backgroundTitle = 'Восстановление',
  String backgroundSummary = 'Backend summary.',
  Map<String, SphereRecommendationModel> Function(DateTime)? spheresForDate,
}) {
  final selectedDate = moonPhase.date.fromRussianShortDate();
  final monthStart = DateTime(selectedDate.year, selectedDate.month);
  final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

  return PersonalizedLunarMonthModel(
    year: selectedDate.year,
    month: selectedDate.month,
    timezone: 'Asia/Almaty',
    anchorLocalTime: '12:00',
    days: [
      for (var day = 1; day <= lastDay; day++)
        _personalizedDay(
          DateTime(monthStart.year, monthStart.month, day),
          lunarDay: day == selectedDate.day ? moonPhase.lunarDay : day,
          phase: day == selectedDate.day
              ? phase ?? moonPhase.moonPhase
              : 'waxing_gibbous',
          backgroundTitle: backgroundTitle,
          backgroundSummary: backgroundSummary,
          spheres:
              spheresForDate?.call(
                DateTime(monthStart.year, monthStart.month, day),
              ) ??
              const {},
        ),
    ],
  );
}

PersonalizedLunarMonthModel _emptyPersonalizedMonth(MoonPhaseModel moonPhase) {
  final selectedDate = moonPhase.date.fromRussianShortDate();
  return PersonalizedLunarMonthModel(
    year: selectedDate.year,
    month: selectedDate.month,
    timezone: 'Asia/Almaty',
    anchorLocalTime: '12:00',
    days: const [],
  );
}

PersonalizedLunarDayModel _personalizedDay(
  DateTime date, {
  required int lunarDay,
  required String phase,
  required String backgroundTitle,
  required String backgroundSummary,
  required Map<String, SphereRecommendationModel> spheres,
}) {
  return PersonalizedLunarDayModel(
    date: DateTime(date.year, date.month, date.day),
    lunarContext: PersonalizedLunarContextModel(
      lunarDayNumber: lunarDay,
      moonAgeDays: (lunarDay - 1).toDouble(),
      moonAgeDayIndex: lunarDay == 30 ? 29 : lunarDay - 1,
      moonPhaseCode: phase,
      moonPhaseName: 'Фаза',
      moonSignCode: 'aries',
      moonSignName: 'Овен',
      phaseEvent: null,
    ),
    dailyBackground: DailyBackgroundModel(
      tone: PhaseTone.recovery,
      title: backgroundTitle,
      summary: backgroundSummary,
    ),
    spheres: spheres,
  );
}

class _FakeUserRepository implements UserRepository {
  UserModel? updatedUser;

  @override
  Future<void> updateCurrentUser(UserModel user) async {
    updatedUser = user;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCitySearchService extends CitySearchService {
  _FakeCitySearchService({required this.suggestion, required this.location})
    : super(googleMapsApiKey: 'test');

  final CitySuggestion suggestion;
  final CurrentLocationModel location;

  @override
  Future<List<CitySuggestion>> searchCities(
    String query, {
    required String language,
  }) async {
    return [suggestion];
  }

  @override
  Future<CurrentLocationModel?> getLocationForSuggestion(
    CitySuggestion suggestion, {
    required String language,
  }) async {
    return location;
  }
}

class _FakeCompatibilityRepository implements CompatibilityRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
