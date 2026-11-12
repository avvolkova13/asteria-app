import 'package:asteria_app/app/data/models/natal_card/natal_card_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/natal_card/natal_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Lora')..addFont(
          rootBundle.load('assets/fonts/lora/Lora-VariableFont_wght.ttf'),
        ))
        .load();
    await (FontLoader('Onest')..addFont(
          rootBundle.load('assets/fonts/onest/Onest-VariableFont_wght.ttf'),
        ))
        .load();
  });
  tearDown(() async => di.reset());

  for (final use24Hour in [false, true]) {
    testWidgets('US birth time uses AM/PM with system 24h=$use24Hour', (
      tester,
    ) async {
      await _pumpChart(
        tester,
        320,
        'Planet description.',
        locale: const Locale('en', 'US'),
        use24Hour: use24Hour,
      );
      expect(find.text('2:58 PM'), findsOneWidget);
      expect(find.text('14:58'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final exact in [true, false]) {
    testWidgets(
      'wheel selects, replaces and dismisses the matching detail card with exact time $exact',
      (tester) async {
        await _pumpChart(
          tester,
          320,
          'Описание Солнца.',
          exactTime: exact,
          textScale: 1.4,
        );
        Finder card(String code) =>
            find.byKey(ValueKey('selected-planet-card-$code'));
        Future<void> choose(String code) async {
          final target = find.byKey(ValueKey('natal-wheel-$code'));
          await tester.tapAt(tester.getCenter(target));
          await tester.pumpAndSettle();
        }

        await choose('sun');
        expect(
          find.descendant(of: card('sun'), matching: find.text('Солнце')),
          findsOneWidget,
        );
        await choose('venus');
        expect(card('sun'), findsNothing);
        expect(
          find.descendant(of: card('venus'), matching: find.text('Венера')),
          findsOneWidget,
        );
        final body = find.descendant(
          of: card('venus'),
          matching: find.textContaining('Близнецы'),
        );
        expect(body, findsOneWidget);
        final text = tester.widget<Text>(body).data!;
        expect(text.contains('Описание Венеры.'), exact);
        expect(text.contains('7 дом'), exact);
        expect(text.contains('°'), exact);
        await choose('venus');
        expect(card('venus'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('long birth city is ellipsized on one line', (tester) async {
    await _pumpChart(tester, 390, 'Описание позиции.');
    final city = tester.renderObject<RenderParagraph>(
      find.text('Петропавловск-Камчатский'),
    );
    expect(city.maxLines, 1);
    expect(city.overflow, TextOverflow.ellipsis);
    expect(city.didExceedMaxLines, isTrue);
  });

  testWidgets(
    'approximate birth time omits exact houses in the purchased report',
    (tester) async {
      await _pumpChart(
        tester,
        390,
        'Сохранённый текст о десятом доме.',
        exactTime: false,
      );
      expect(find.text('Не указано'), findsOneWidget);
      expect(
        find.textContaining('Сохранённый текст о десятом доме.'),
        findsNothing,
      );
      final houses = find.textContaining('Дома и');
      await tester.ensureVisible(houses);
      await tester.tap(houses);
      await tester.pumpAndSettle();
      expect(
        find.text('Для расчёта домов нужно точное время рождения.'),
        findsOneWidget,
      );
      expect(find.text('Сильный 10 дом'), findsNothing);
    },
  );

  testWidgets('birth labels keep whole words on each line', (tester) async {
    await _pumpChart(tester, 390, 'Описание позиции.');
    final paragraph = tester.renderObject<RenderParagraph>(
      find.text('Дата рождения'),
    );
    expect(
      paragraph.getBoxesForSelection(
        const TextSelection(baseOffset: 5, extentOffset: 13),
      ),
      hasLength(1),
    );
  });

  for (final width in [320.0, 390.0]) {
    testWidgets('long position text remains readable at width $width', (
      tester,
    ) async {
      final description = List.filled(
        12,
        'Полное описание позиции планеты.',
      ).join(' ');
      await _pumpChart(
        tester,
        width,
        description,
        textScale: width == 320 ? 1.6 : 1,
      );
      final text = find.textContaining(description);
      expect(text, findsOneWidget);
      final paragraph = tester.renderObject<RenderParagraph>(text);
      expect(paragraph.didExceedMaxLines, isFalse);
      Finder cardFor(Finder text) => find
          .ancestor(
            of: text,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container && widget.clipBehavior == Clip.antiAlias,
            ),
          )
          .first;
      final tallest = tester.getRect(cardFor(text));
      final venus = tester.getRect(
        cardFor(find.textContaining('Описание Венеры.')),
      );
      expect(venus.height, tallest.height);
      expect(
        tester.getBottomLeft(text).dy,
        lessThanOrEqualTo(tallest.bottom - 16),
      );
      final nextGroup = find.text('Отношения и проявление');
      expect(
        tester.getBottomLeft(text).dy,
        lessThan(tester.getTopLeft(nextGroup).dy),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'house tab preserves calculated house numbers and full descriptions',
    (tester) async {
      await _pumpChart(tester, 390, 'Описание позиции.');
      // The accessible label remains usable independently of visual styling.
      await tester.tap(find.textContaining('Дома и'));
      await tester.pumpAndSettle();
      expect(find.text('Сильный 10 дом'), findsOneWidget);
      expect(find.text('Слабый 3 дом'), findsOneWidget);
      expect(find.text('Акцент на 7 доме'), findsOneWidget);
      expect(find.text('Персональное описание сильного дома.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _pumpChart(
  WidgetTester tester,
  double width,
  String description, {
  Locale locale = const Locale('ru'),
  bool use24Hour = false,
  bool exactTime = true,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final user = _TestUserProvider(
    _user(description, locale.languageCode, exactTime),
  );
  final analytics = _TestAnalytics();
  di.registerSingleton<UserProvider>(user);
  di.registerSingleton<ContentProvider>(_TestContent());
  di.registerSingleton<AnalyticsFacade>(analytics);
  di.registerSingleton<ProductAnalyticsService>(
    ProductAnalyticsService(analytics),
  );
  di.registerSingleton<AppLocaleService>(
    AppLocaleService(platformLocales: [locale]),
  );
  await tester.pumpWidget(
    ChangeNotifierProvider<UserProvider>.value(
      value: user,
      child: MaterialApp(
        locale: locale,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: use24Hour,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
        home: Builder(
          builder: (context) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: const NatalCardScreen(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

UserModel _user(String description, String language, bool exactTime) =>
    UserModel(
      id: 'layout-test',
      balance: 0,
      userGroup: UserGroup.user,
      subscriptionType: SubscriptionType.free,
      createdAt: DateTime(2020),
      updatedAt: DateTime(2020),
      sonnikHistory: const [],
      solarData: const SolarDataModel(data: ''),
      personalInfo: PersonalInfoModel(
        birthDate: BirthDateModel(
          birthDate: DateTime(1995, 5, 13),
          birthTimeKnown: exactTime,
          birthTime: DateTime(1995, 5, 13, 14, 58),
        ),
        birthPlace: const BirthPlaceModel(
          location: 'Петропавловск-Камчатский, Россия',
          latitude: 55,
          longitude: 37,
        ),
      ),
      planetsHousesData: const PlanetsHousesDataModel(
        data: '',
        elements: Elements(fire: '3', earth: '6', air: '2', water: '4'),
        positions: [
          PlanetHousePositionModel(
            code: 'sun',
            name: 'Солнце',
            signCode: 'taurus',
            sign: 'Телец',
            house: 10,
            longitude: 40,
          ),
          PlanetHousePositionModel(
            code: 'venus',
            name: 'Венера',
            signCode: 'gemini',
            sign: 'Близнецы',
            house: 7,
            longitude: 65,
          ),
        ],
        houseSummary: HouseSummaryModel(
          strongHouse: HouseSummaryEntryModel(houseNumber: 10),
          weakHouse: HouseSummaryEntryModel(houseNumber: 3),
          accentHouse: HouseSummaryEntryModel(houseNumber: 7),
        ),
      ),
      natalCard: NatalCardModel.fromJson({
        'source_language': language,
        'interpretations': {
          language: {
            'planet_interpretations': {
              'sun': description,
              'venus': 'Описание Венеры.',
            },
            'house_interpretations': {
              'strong_house': 'Персональное описание сильного дома.',
              'weak_house': 'Описание слабого дома.',
              'accent_house': 'Описание акцента.',
            },
          },
        },
      }),
    );

class _TestUserProvider extends ChangeNotifier implements UserProvider {
  _TestUserProvider(this.currentUser);
  @override
  final UserModel currentUser;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestContent implements ContentProvider {
  @override
  Future<PlanetsHousesDataModel?> loadPurchasedNatalGeometry() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAnalytics implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
