import '../../../compatibility/support/selection_test_support.dart';

import 'dart:async';

import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/data/models/energy_of_day/energy_of_day_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_day_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_shared_model.dart';
import 'package:asteria_app/app/data/models/prompt_response.dart';
import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/compatibility/domain/repositories/compatibility_repository.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asteria_app/features/home/presentation/screens/personal_screen.dart';
import 'package:asteria_app/features/home/presentation/widgets/card_advertisement_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/energy_of_the_day_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('energy updates a const widget when loading completes', (
    tester,
  ) async {
    final repository = _DelayedEnergyRepository();
    final content = await _registerEnergyProvider(repository);
    final loading = content.loadContent();
    await tester.pumpWidget(_testApp(const EnergyOfTheDayWidget(), width: 390));
    await tester.pumpAndSettle();

    expect(find.text('Загрузка…'), findsNWidgets(2));
    expect(find.text('—'), findsNWidgets(2));
    expect(find.text('0%'), findsNothing);

    repository.response.complete([
      _energyOfDay().copyWith(focus: 'Фокус', risk: 'Риски', phrase: 'Сегодня'),
    ]);
    await loading;
    await tester.pumpAndSettle();

    expect(find.text('23%'), findsOneWidget);
    expect(find.text('94%'), findsOneWidget);
    expect(find.text('Загрузка…'), findsNothing);
    expect(find.text('—'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final scenario in ['missing today', 'load failure']) {
    testWidgets('energy shows unavailable rather than zero on $scenario', (
      tester,
    ) async {
      final repository = _DelayedEnergyRepository();
      final content = await _registerEnergyProvider(repository);
      final loading = content.loadContent();
      await tester.pumpWidget(
        _testApp(const EnergyOfTheDayWidget(), width: 390),
      );
      await tester.pumpAndSettle();

      if (scenario == 'load failure') {
        repository.response.completeError(StateError('Content unavailable'));
      } else {
        repository.response.complete([
          _energyOfDay().copyWith(
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ]);
      }
      await loading;
      await tester.pumpAndSettle();

      expect(find.text('Пока недоступно'), findsNWidgets(2));
      expect(find.text('—'), findsNWidgets(2));
      expect(find.text('0%'), findsNothing);
      expect(find.text('Загрузка…'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('energy distinguishes a real zero from a malformed percentage', (
    tester,
  ) async {
    final content = await _registerEnergyProvider(
      _FakeContentRepository(
        energyOfDay: [
          _energyOfDay().copyWith(
            focusPercentage: '0%',
            riskPercentage: 'unknown',
            focus: 'Фокус',
            risk: 'Риски',
            phrase: 'Сегодня',
          ),
        ],
      ),
    );
    await content.loadContent();
    await tester.pumpWidget(_testApp(const EnergyOfTheDayWidget(), width: 390));
    await tester.pumpAndSettle();

    expect(find.text('0%'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('natal card banner grows to show a long description', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _testApp(
        CardAdvertisementWidget(
          horizontalMargin: 0,
          variant: CardAdvertisementVariant.natalCardBanner,
          title: 'Натальная\nкарта',
          description: _longNatalDescription,
          buttonText: 'Открыть карту',
          onPressed: () {},
        ),
        width: 320,
        textScaler: const TextScaler.linear(1.3),
      ),
    );
    await tester.pump();

    final description = tester.widget<Text>(find.text(_longNatalDescription));
    expect(description.maxLines, isNull);
    expect(description.overflow, isNull);
    expect(
      tester.getSize(find.byKey(const ValueKey('natal-card-banner'))).height,
      greaterThan(240),
    );
    expect(
      tester.getTopLeft(find.text('Открыть карту')).dy,
      greaterThan(tester.getBottomLeft(find.text(_longNatalDescription)).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'energy cards show full descriptions and share the tallest height',
    (tester) async {
      await di.reset();
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final userProvider = UserProvider(userRepository: _FakeUserRepository());
      final contentProvider = ContentProvider(
        contentRepository: _FakeContentRepository(
          energyOfDay: [_energyOfDay()],
        ),
        userProvider: userProvider,
        compatibilityRepository: _FakeCompatibilityRepository(),
      );
      await contentProvider.loadContent();
      di.registerSingleton<ContentProvider>(contentProvider);
      addTearDown(() async {
        contentProvider.dispose();
        userProvider.dispose();
        await di.reset();
      });

      await tester.pumpWidget(
        _testApp(const EnergyOfTheDayWidget(), width: 320),
      );
      await tester.pump();

      final focusText = tester.widget<Text>(find.text(_longFocusDescription));
      final riskText = tester.widget<Text>(find.text(_longRiskDescription));
      expect(focusText.maxLines, isNull);
      expect(focusText.overflow, isNull);
      expect(riskText.maxLines, isNull);
      expect(riskText.overflow, isNull);

      final focusSize = tester.getSize(
        find.byKey(const ValueKey('energy-card-focus')),
      );
      final riskSize = tester.getSize(
        find.byKey(const ValueKey('energy-card-risk')),
      );
      expect(focusSize.height, riskSize.height);
      expect(focusSize.height, greaterThan(259));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'compatibility card grows beyond its old height for a long description',
    (tester) async {
      await di.reset();
      await tester.binding.setSurfaceSize(const Size(390, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final userProvider = UserProvider(userRepository: _FakeUserRepository());
      userProvider.applyServerUserSnapshot(
        UserModel.empty().copyWith(
          personalInfo: PersonalInfoModel(
            birthDate: BirthDateModel(birthDate: DateTime(1991, 5, 13)),
          ),
          compatibilityHistory: [_savedCompatibility()],
        ),
      );
      final contentProvider = ContentProvider(
        contentRepository: _FakeContentRepository(),
        userProvider: userProvider,
        compatibilityRepository: _FakeCompatibilityRepository(),
      );
      final homeCubit = HomeCubit(
        userRepository: _FakeUserRepository(),
        contentProvider: contentProvider,
        userProvider: userProvider,
      );
      di.registerSingleton<UserProvider>(userProvider);
      registerTestCompatibilityProvider(userProvider);
      addTearDown(() async {
        await homeCubit.close();
        contentProvider.dispose();
        userProvider.dispose();
        await di.reset();
      });

      for (final family in ['Lora', 'Onest']) {
        final loader = FontLoader(family)
          ..addFont(
            rootBundle.load(
              'assets/fonts/${family.toLowerCase()}/$family-VariableFont_wght.ttf',
            ),
          );
        await loader.load();
      }
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
                child: ChangeNotifierProvider<UserProvider>.value(
                  value: userProvider,
                  child: BlocProvider<HomeCubit>.value(
                    value: homeCubit,
                    child: const PersonalScreen(),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      final description = tester.widget<Text>(
        find.text(_longCompatibilityDescription),
      );
      expect(description.maxLines, isNull);
      expect(description.overflow, isNull);

      final cardFinder = find.byKey(
        const ValueKey('personal-compatibility-card'),
      );
      final detailsFinder = find.descendant(
        of: cardFinder,
        matching: find.text('Подробнее'),
      );
      expect(tester.getSize(cardFinder).height, greaterThan(315));
      expect(
        tester.getTopLeft(detailsFinder).dy,
        greaterThan(
          tester.getBottomLeft(find.text(_longCompatibilityDescription)).dy,
        ),
      );

      final background = tester.widget<Image>(
        find.byKey(const ValueKey('personal-compatibility-background')),
      );
      expect(
        (background.image as AssetImage).assetName,
        'assets/images/home/compatibility_background.webp',
      );
      expect(background.fit, BoxFit.cover);
      expect(background.alignment, const Alignment(0, 0.08));
      expect(background.opacity?.value, 0.5);

      for (final assetName in ['kozerog', 'lev']) {
        final zodiac = tester.widget<Image>(
          find.byKey(ValueKey('personal-compatibility-zodiac-$assetName')),
        );
        expect(
          (zodiac.image as AssetImage).assetName,
          'assets/images/zodiacs/compatibility_round/$assetName.webp',
        );
      }

      await tester.binding.setSurfaceSize(const Size(320, 2000));
      await tester.pump();
      expect(tester.getSize(cardFinder).height, greaterThan(315));
      expect(tester.takeException(), isNull);

      await tester.binding.setSurfaceSize(const Size(390, 2000));
      await tester.pumpAndSettle();
      final elementY = tester.getCenter(find.text('Стихия')).dy;
      expect(tester.getCenter(find.text('Планета')).dy, closeTo(elementY, 1));
      expect(tester.getCenter(find.text('Характер')).dy, closeTo(elementY, 1));

      final date = find.textContaining('1991');
      final dateHeight = tester.getSize(date).height;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.binding.setSurfaceSize(const Size(320, 2000));
      await tester.pumpAndSettle();
      expect(tester.getSize(date).height, greaterThan(dateHeight));
      expect(tester.widget<Text>(date).maxLines, isNull);

      for (final label in [
        'Стихия',
        'Планета',
        'Характер',
        'Земля',
        'Венера',
        'Устойчивый',
        'На сегодня',
        'На неделю',
        'На месяц',
      ]) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(label),
        );
        final lastLetter = paragraph
            .getBoxesForSelection(
              TextSelection(
                baseOffset: label.length - 1,
                extentOffset: label.length,
              ),
            )
            .single;
        final firstLetter = paragraph
            .getBoxesForSelection(
              const TextSelection(baseOffset: 0, extentOffset: 1),
            )
            .single;
        expect(lastLetter.top, firstLetter.top, reason: label);
        expect(
          lastLetter.right,
          lessThanOrEqualTo(paragraph.size.width + 0.1),
          reason: label,
        );
      }
      for (final period in ['неделю', 'месяц']) {
        final tab = find.text('На $period');
        await tester.ensureVisible(tab);
        await tester.tap(tab);
        await tester.pumpAndSettle();
        expect(
          find.textContaining('гороскоп на $period доступен'),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'personal horoscope uses Figma background, impact rings, and free day content',
    (tester) async {
      await di.reset();
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final userProvider = UserProvider(userRepository: _FakeUserRepository());
      userProvider.applyServerUserSnapshot(
        UserModel.empty().copyWith(horoscopeDay: _horoscopeDay()),
      );
      final contentProvider = ContentProvider(
        contentRepository: _FakeContentRepository(),
        userProvider: userProvider,
        compatibilityRepository: _FakeCompatibilityRepository(),
      );
      final homeCubit = HomeCubit(
        userRepository: _FakeUserRepository(),
        contentProvider: contentProvider,
        userProvider: userProvider,
      );
      di.registerSingleton<UserProvider>(userProvider);
      registerTestCompatibilityProvider(userProvider);
      addTearDown(() async {
        await homeCubit.close();
        contentProvider.dispose();
        userProvider.dispose();
        await di.reset();
      });

      for (final width in [390.0, 320.0]) {
        await tester.binding.setSurfaceSize(Size(width, 1200));
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
                  child: ChangeNotifierProvider<UserProvider>.value(
                    value: userProvider,
                    child: BlocProvider<HomeCubit>.value(
                      value: homeCubit,
                      child: PersonalScreen(
                        key: ValueKey('personal-screen-$width'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pump();

        final backgroundFinder = find.byKey(
          const ValueKey('personal-horoscope-background-art'),
        );
        expect(backgroundFinder, findsOneWidget);
        final backgroundImage = tester.widget<Image>(backgroundFinder);
        expect(
          (backgroundImage.image as AssetImage).assetName,
          'assets/images/home/personal_horoscope_background.webp',
        );
        expect(
          find.byKey(
            const ValueKey('personal-horoscope-background-top-gradient'),
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(
            const ValueKey('personal-horoscope-background-bottom-gradient'),
          ),
          findsOneWidget,
        );

        expect(find.text('Влияние на сферы'), findsOneWidget);
        expect(find.text('Совет на день'), findsOneWidget);

        for (final metricId in ['love', 'finances', 'energy']) {
          final ringFinder = find.byKey(
            ValueKey('personal-impact-ring-$metricId'),
          );
          expect(ringFinder, findsOneWidget);
          expect(tester.getSize(ringFinder), const Size.square(71));
        }

        expect(find.text('Тема отношений'), findsNothing);
        expect(find.text('Глубокое описание отношений'), findsOneWidget);
        expect(find.text('Любовь\nи отношения'), findsOneWidget);
        expect(find.text('Слабые места'), findsOneWidget);
        expect(find.text('Слабые места\nи что проработать'), findsNothing);
        expect(find.textContaining('Слабое место энергии'), findsOneWidget);
        expect(find.text('Разблокировать'), findsNothing);

        expect(tester.takeException(), isNull);

        final backgroundTop = tester.getTopLeft(backgroundFinder).dy;
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(backgroundFinder).dy,
          lessThan(backgroundTop - 250),
        );
      }
    },
  );

  testWidgets('personal horoscope uses Figma daily add-on card layout', (
    tester,
  ) async {
    await di.reset();
    await tester.binding.setSurfaceSize(const Size(390, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final userProvider = UserProvider(userRepository: _FakeUserRepository());
    userProvider.applyServerUserSnapshot(
      UserModel.empty().copyWith(
        horoscopeDay: _horoscopeDay(
          isKeyThemeOpened: true,
          isWeaknessOpened: true,
        ),
      ),
    );
    final contentProvider = ContentProvider(
      contentRepository: _FakeContentRepository(),
      userProvider: userProvider,
      compatibilityRepository: _FakeCompatibilityRepository(),
    );
    final homeCubit = HomeCubit(
      userRepository: _FakeUserRepository(),
      contentProvider: contentProvider,
      userProvider: userProvider,
    );
    di.registerSingleton<UserProvider>(userProvider);
    registerTestCompatibilityProvider(userProvider);
    addTearDown(() async {
      await homeCubit.close();
      contentProvider.dispose();
      userProvider.dispose();
      await di.reset();
    });

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
            child: ChangeNotifierProvider<UserProvider>.value(
              value: userProvider,
              child: BlocProvider<HomeCubit>.value(
                value: homeCubit,
                child: const PersonalScreen(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Тема отношений'), findsNothing);
    expect(find.text('Глубокое описание отношений'), findsOneWidget);
    expect(find.text('Любовь\nи отношения'), findsOneWidget);
    expect(find.text('Слабые места'), findsOneWidget);
    expect(find.text('Слабые места\nи что проработать'), findsNothing);
    expect(find.textContaining('Слабое место энергии'), findsOneWidget);

    final lovePanelFinder = find.byKey(
      const ValueKey('personal-day-love-panel'),
    );
    final weaknessPanelFinder = find.byKey(
      const ValueKey('personal-day-weakness-panel'),
    );
    expect(lovePanelFinder, findsOneWidget);
    expect(weaknessPanelFinder, findsOneWidget);
    expect(tester.getSize(lovePanelFinder).width, 112);
    expect(tester.getSize(weaknessPanelFinder), const Size(112, 112));

    final loveImage = tester.widget<Image>(
      find.byKey(const ValueKey('personal-day-love-image')),
    );
    final weaknessImage = tester.widget<Image>(
      find.byKey(const ValueKey('personal-day-weakness-image')),
    );
    expect(
      (loveImage.image as AssetImage).assetName,
      'assets/images/home/personal_day_love_relationships.webp',
    );
    expect(
      (weaknessImage.image as AssetImage).assetName,
      'assets/images/home/personal_day_weakness.webp',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'personal horoscope shows unlock prompt for an expired daily forecast',
    (tester) async {
      await di.reset();
      await tester.binding.setSurfaceSize(const Size(390, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final userProvider = UserProvider(userRepository: _FakeUserRepository());
      userProvider.applyServerUserSnapshot(
        UserModel.empty().copyWith(
          horoscopeDay: _horoscopeDay(
            dateUntil: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
        ),
      );
      final contentProvider = ContentProvider(
        contentRepository: _FakeContentRepository(),
        userProvider: userProvider,
        compatibilityRepository: _FakeCompatibilityRepository(),
      );
      final homeCubit = HomeCubit(
        userRepository: _FakeUserRepository(),
        contentProvider: contentProvider,
        userProvider: userProvider,
      );
      di.registerSingleton<UserProvider>(userProvider);
      registerTestCompatibilityProvider(userProvider);
      addTearDown(() async {
        await homeCubit.close();
        contentProvider.dispose();
        userProvider.dispose();
        await di.reset();
      });

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
              child: ChangeNotifierProvider<UserProvider>.value(
                value: userProvider,
                child: BlocProvider<HomeCubit>.value(
                  value: homeCubit,
                  child: const PersonalScreen(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Открой прогноз'), findsOneWidget);
      expect(find.text('Открыть бесплатно'), findsOneWidget);
      expect(find.text('Влияние на сферы'), findsNothing);
      expect(find.text('Совет на день'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _testApp(
  Widget child, {
  required double width,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    locale: const Locale('ru'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocaleService.supportedLocales,
    home: Builder(
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(width: width, child: child),
              ),
            ),
          ),
        );
      },
    ),
  );
}

EnergyOfDayModel _energyOfDay() {
  final now = DateTime.now();
  return EnergyOfDayModel(
    id: 'energy-today',
    date: DateTime(now.year, now.month, now.day),
    focusPercentage: '23%',
    riskPercentage: '94%',
    focus: _longFocusDescription,
    risk: _longRiskDescription,
    phrase: 'Осторожность и уединение',
  );
}

SavedCompatibilityModel _savedCompatibility() {
  return SavedCompatibilityModel(
    id: 'compatibility-id',
    firstBirthdate: DateTime(2000, 12, 23),
    secondBirthdate: DateTime(1997, 7, 31),
    generalPercentage: '75%',
    createdAt: DateTime(2026, 8, 12),
    compatibilityData: const CompatibilityData(
      generalCompatibility: '',
      loveCompatibility: '',
      loveCompatibilityPercentage: '',
      familyCompatibility: '',
      familyCompatibilityPercentage: '',
      conflicts: '',
      conflictsPercentage: '',
      percentage: '75%',
      phrase: 'Гармония преодолевает различия',
      introduction: _longCompatibilityDescription,
    ),
  );
}

HoroscopeDayModel _horoscopeDay({
  DateTime? dateUntil,
  bool isKeyThemeOpened = false,
  bool isWeaknessOpened = false,
}) {
  const loveArea = HoroscopeAreaModel(
    keyTheme: 'Отношения',
    themeTitle: 'Тема отношений',
    description: 'Глубокое описание отношений',
  );
  const area = HoroscopeAreaModel(
    keyTheme: 'Баланс',
    themeTitle: 'Тема баланса',
    description: 'Описание баланса',
  );
  return HoroscopeDayModel(
    dateUntil: dateUntil ?? DateTime.now().add(const Duration(days: 1)),
    isKeyThemeOpened: isKeyThemeOpened,
    isWeaknessOpened: isWeaknessOpened,
    focus: 'Общение и укрепление связей.',
    risk: 'Избегайте поспешных решений.',
    personalArea: area,
    personalWeakPoints: const [
      HoroscopeWeakPointModel(
        title: 'Слабое место энергии',
        description: 'Описание слабого места энергии.',
      ),
    ],
    personalAreaPercentage: '71%',
    loveArea: loveArea,
    loveWeakPoints: const [
      HoroscopeWeakPointModel(
        title: 'Слабое место отношений',
        description: 'Описание слабого места отношений.',
      ),
    ],
    loveAreaPercentage: '89%',
    financeArea: area,
    financeWeakPoints: const [
      HoroscopeWeakPointModel(
        title: 'Слабое место финансов',
        description: 'Описание слабого места финансов.',
      ),
    ],
    financeAreaPercentage: '64%',
    spotlight: 'В центре внимания — отношения',
  );
}

const _longNatalDescription =
    'Ты родился(ась) под знаком стабильности и глубокой чувствительности. '
    'У тебя сильная связь с эмоциями и интуицией. Этот дополнительный текст '
    'проверяет, что карточка увеличивает высоту и ничего не скрывает.';

const _longFocusDescription =
    'В этот день рекомендуется проявлять осторожность в любых начинаниях и '
    'по возможности не торопиться с важными решениями. Сохраняй спокойствие '
    'и оставляй достаточно времени для отдыха и восстановления.';

const _longRiskDescription =
    'Сегодня крайне не рекомендуется вступать в конфликты, начинать новые '
    'проекты или заниматься финансовыми вопросами без тщательной проверки.';

const _longCompatibilityDescription =
    'Эта пара обладает потенциалом для глубокого взаимопонимания, но требует '
    'внимания к чувствам друг друга, терпения, гибкости и готовности спокойно '
    'обсуждать любые разногласия без обесценивания партнёра.';

Future<ContentProvider> _registerEnergyProvider(
  ContentRepository repository,
) async {
  await di.reset();
  final user = UserProvider(userRepository: _FakeUserRepository());
  final content = ContentProvider(
    contentRepository: repository,
    userProvider: user,
    compatibilityRepository: _FakeCompatibilityRepository(),
  );
  di.registerSingleton<ContentProvider>(content);
  addTearDown(() async {
    content.dispose();
    user.dispose();
    await di.reset();
  });
  return content;
}

class _DelayedEnergyRepository extends _FakeContentRepository {
  final response = Completer<List<EnergyOfDayModel>>();

  @override
  Future<List<EnergyOfDayModel>> getEnergyOfDayFromCache() => response.future;
}

class _FakeContentRepository implements ContentRepository {
  _FakeContentRepository({this.energyOfDay = const []});

  final List<EnergyOfDayModel> energyOfDay;

  @override
  Future<void> refreshContentVersions() async {}

  @override
  Future<List<TarotCardModel>> getTarotCards() async => [];

  @override
  Future<List<RuneOfDayModel>> getRunes() async => [];

  @override
  Future<List<ArticleModel>> getArticles() async => [];

  @override
  Future<List<AffirmationModel>> getAffirmations() async => [];

  @override
  Future<bool> shouldReloadEnergyOfDay() async => false;

  @override
  Future<List<EnergyOfDayModel>> getEnergyOfDayFromCache() async => energyOfDay;

  @override
  Future<List<EnergyOfDayModel>> getEnergyOfDay() async => energyOfDay;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCompatibilityRepository implements CompatibilityRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
