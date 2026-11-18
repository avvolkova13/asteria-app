import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/models/moon_phase/moon_phase_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/personalized_lunar_month_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/data/models/energy_of_day/energy_of_day_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/screens/main_screen.dart';
import 'package:asteria_app/features/home/presentation/screens/home_screen.dart';
import 'package:asteria_app/features/home/presentation/screens/moon_screen.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_state.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_state.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/models/year_animal_asset.dart';
import 'package:asteria_app/features/home/presentation/widgets/bottom_tab_bar_widget.dart';
import 'package:asteria_app/features/home/localization/home_localization_contract.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/anakra_chat/presentation/provider/anakra_chat_provider.dart';
import 'content_review_capture_test.dart' as fixtures;

const out = '/private/tmp/asteria-design-review/home';
// Run the loaded MainScreen coverage with Reduced Motion enabled.
const mainReducedMotion = bool.fromEnvironment('ASTERIA_REVIEW_HOME_REDUCED');
String language = 'ru';
String get summary => language == 'ru'
    ? 'День подходит для спокойного темпа. Завершите начатое и оставьте время для себя.'
    : 'Keep a calm pace today. Finish what you have started and leave some time for yourself.';
DateTime get today {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

String dateText(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
MoonPhaseModel moon(DateTime d) => MoonPhaseModel(
  date: dateText(d),
  lunarDay: 12,
  moonSign: 'aries',
  moonPhase: 'waxing_gibbous',
  moonPhaseRu: 'Растущая луна',
  moonriseLocal: '12:00',
);
PersonalizedLunarDayModel day(DateTime d) => PersonalizedLunarDayModel(
  date: d,
  lunarContext: PersonalizedLunarContextModel(
    lunarDayNumber: 12,
    moonAgeDays: 11,
    moonAgeDayIndex: 11,
    moonPhaseCode: 'waxing_gibbous',
    moonPhaseName: language == 'ru' ? 'Растущая луна' : 'Waxing gibbous',
    moonSignCode: 'aries',
    moonSignName: language == 'ru' ? 'Овен' : 'Aries',
    phaseEvent: null,
  ),
  dailyBackground: DailyBackgroundModel(
    tone: PhaseTone.recovery,
    title: language == 'ru' ? 'Восстановление' : 'Recovery',
    summary: summary,
  ),
  spheres: const {},
);
PersonalizedLunarMonthModel get month => PersonalizedLunarMonthModel(
  year: today.year,
  month: today.month,
  timezone: 'Asia/Yekaterinburg',
  anchorLocalTime: '12:00',
  days: [
    for (var n = 1; n <= DateTime(today.year, today.month + 1, 0).day; n++)
      day(DateTime(today.year, today.month, n)),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await initializeDateFormatting('ru');
    await initializeDateFormatting('en');
    for (final f in [
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
    ]) {
      await (FontLoader(f.$1)..addFont(rootBundle.load(f.$2))).load();
    }
  });
  for (final variant in ['390-ru', '320-ru-2x', '320-en-2x']) {
    for (final surface in [
      'main-loaded',
      'moon-loaded',
      'moon-loading',
      'moon-error',
      'home-loading',
      'home-error',
    ]) {
      testWidgets('$surface $variant', (tester) async {
        language = variant.contains('-en-') ? 'en' : 'ru';
        fixtures.reviewLanguage = language;
        tester.view.physicalSize = variant.startsWith('390')
            ? const Size(390, 844)
            : const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
        addTearDown(tester.view.reset);
        final user = _User();
        final content = _Content();
        final monetization = _Monetization();
        final analytics = _Analytics();
        final home = _Home(
          surface == 'home-loading'
              ? const HomeLoading()
              : surface == 'home-error'
              ? const HomeError(failure: HomeFailure.load)
              : HomeLoaded(tarotCard: fixtures.card, runeOfDay: fixtures.rune),
        );
        di.registerSingleton<UserProvider>(user);
        di.registerSingleton<ContentProvider>(content);
        di.registerSingleton<MonetizationProvider>(monetization);
        di.registerSingleton<AnalyticsFacade>(analytics);
        di.registerSingleton<ProductAnalyticsService>(
          ProductAnalyticsService(analytics),
        );
        di.registerSingleton<AppLocaleService>(
          AppLocaleService(platformLocales: [Locale(language)]),
        );
        di.registerSingleton<AnakraChatProvider>(_Anakra());
        final moonCubit = _Moon(
          MoonScreenState(
            focusedDay: today,
            selectedDate: today,
            isLoading: surface == 'moon-loading',
            error: surface == 'moon-error'
                ? MoonScreenErrorCode.loadData
                : null,
            selectedPersonalizedDayData: surface == 'moon-loaded'
                ? day(today)
                : null,
            selectedDayStatus: DayStatus.neutral,
          ),
        );
        di.registerFactory<MoonScreenCubit>(() => moonCubit);
        addTearDown(() async {
          await home.close();
          if (!moonCubit.isClosed) await moonCubit.close();
          user.dispose();
          content.dispose();
          monetization.dispose();
          await di.reset();
        });
        Widget screen;
        if (surface.startsWith('home-')) {
          screen = HomeScreen(homeLocalization: HomeLocalization());
        } else {
          screen = Scaffold(
            body: surface.startsWith('main-')
                ? const MainScreen()
                : const MoonScreen(),
            bottomNavigationBar: BottomTabBarWidget(
              currentIndex: surface.startsWith('main-') ? 0 : 1,
              onTabChanged: (_) {},
              onAiAstrologerPressed: () {},
              aiAstrologerAsset: YearAnimalAsset.forYear(DateTime.now().year),
            ),
          );
        }
        await tester.pumpWidget(
          RepaintBoundary(
            key: const Key('capture'),
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<UserProvider>.value(value: user),
                ChangeNotifierProvider<MonetizationProvider>.value(
                  value: monetization,
                ),
                BlocProvider<HomeCubit>.value(value: home),
              ],
              child: MaterialApp(
                locale: Locale(language),
                supportedLocales: AppLocaleService.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  ...GlobalMaterialLocalizations.delegates,
                ],
                builder: (context, child) => Theme(
                  data: AppThemeDark.instance.getThemeData(context),
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(
                        variant.startsWith('320') ? 2 : 1,
                      ),
                      disableAnimations:
                          surface != 'main-loaded' || mainReducedMotion,
                    ),
                    child: child!,
                  ),
                ),
                home: screen,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 400)),
        );
        await tester.pump(const Duration(milliseconds: 500));
        final issues = <String>[];
        Object? error;
        while ((error = tester.takeException()) != null) {
          issues.add(error.toString());
        }
        Future<void> capture(String suffix) async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const Key('capture')),
          );
          await tester.runAsync(() async {
            final img = await boundary.toImage(pixelRatio: 1);
            final data = await img.toByteData(format: ui.ImageByteFormat.png);
            await Directory(out).create(recursive: true);
            await File(
              '$out/${surface == 'main-loaded' && mainReducedMotion ? 'main-reduced' : surface}-$variant-$suffix.png',
            ).writeAsBytes(data!.buffer.asUint8List());
            img.dispose();
          });
        }

        await capture('first');
        if (surface == 'main-loaded') {
          final phase = find.text(
            AppLocalizations.current.moonPhaseWaxingGibbous,
          );
          final label = tester.renderObject<RenderParagraph>(
            find.descendant(of: phase, matching: find.byType(RichText)),
          );
          if (label.didExceedMaxLines) {
            issues.add('Phase name is visually truncated');
          }
          final weekdayLabels = find.descendant(
            of: find.byType(MainScreen),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is Text &&
                  w.data != null &&
                  RegExp(r'^[A-ZА-Я]{2,3}$').hasMatch(w.data!),
            ),
          );
          var checkedWeekdays = 0;
          for (final element in weekdayLabels.evaluate()) {
            final paragraph = tester.renderObject<RenderParagraph>(
              find.descendant(
                of: find.byWidget(element.widget),
                matching: find.byType(RichText),
              ),
            );
            final natural = TextPainter(
              text: paragraph.text,
              textDirection: paragraph.textDirection,
              textScaler: paragraph.textScaler,
            )..layout(maxWidth: paragraph.size.width);
            final slot = find.ancestor(
              of: find.byWidget(element.widget),
              matching: find.byWidgetPredicate(
                (w) => w is SizedBox && w.height == 14,
              ),
            );
            if (slot.evaluate().isEmpty) {
              natural.dispose();
              continue;
            }
            checkedWeekdays++;
            final bounds = tester.getRect(slot.first);
            final top = paragraph.localToGlobal(Offset.zero).dy;
            final bottom = paragraph
                .localToGlobal(Offset(0, natural.height))
                .dy;
            if (top < bounds.top - 1 || bottom > bounds.bottom + 1) {
              issues.add(
                'Weekday ${(element.widget as Text).data} is clipped by its compact slot',
              );
            }
            natural.dispose();
          }
          if (checkedWeekdays < 5) {
            issues.add(
              'Expected at least five real weekday labels, got $checkedWeekdays',
            );
          }
        }
        final scrolls = find.byType(Scrollable);
        if (scrolls.evaluate().isNotEmpty) {
          if (surface == 'main-loaded' && variant == '320-ru-2x') {
            await tester.drag(scrolls.first, const Offset(0, -200));
            await tester.pump(const Duration(seconds: 1));
            await tester.pump(const Duration(seconds: 1));
            await capture('strip');
            await tester.drag(scrolls.first, const Offset(0, -300));
          } else {
            await tester.drag(scrolls.first, const Offset(0, -500));
          }
          await tester.pump(const Duration(seconds: 1));
          await tester.pump(const Duration(seconds: 1));
          await capture('middle');
          await tester.drag(scrolls.first, const Offset(0, -12000));
          await tester.pump(const Duration(seconds: 1));
          await tester.pump(const Duration(seconds: 1));
          await capture('bottom');
        }
        while ((error = tester.takeException()) != null) {
          issues.add(error.toString());
        }
        await tester.runAsync(
          () => File(
            '$out/${surface == 'main-loaded' && mainReducedMotion ? 'main-reduced' : surface}-$variant.txt',
          ).writeAsString(issues.join('\n')),
        );
        expect(issues, isEmpty);
      });
    }
  }
}

class _Analytics implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _User extends ChangeNotifier implements UserProvider {
  @override
  final currentUser = UserModel.empty().copyWith(
    id: 'design-review',
    moonPhase: moon(today),
    currentLocation: const CurrentLocationModel(
      location: 'Екатеринбург, Россия',
      latitude: 56.84,
      longitude: 60.61,
      source: CurrentLocationSource.manual,
    ),
  );
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Content extends ChangeNotifier implements ContentProvider {
  @override
  List<AffirmationModel> get affirmations => [fixtures.affirmation];
  @override
  List<ArticleModel> get articles => [];
  @override
  bool get isLoadingContent => false;
  @override
  EnergyOfDayModel? getTodayEnergyOfDay() => null;
  @override
  void resetTarotAndRuneOpenState() {}
  @override
  bool isDailySymbolTarotOpened() => false;
  @override
  bool isDailySymbolRuneOpened() => false;
  @override
  TarotCardModel getTodayTarotCard() => fixtures.card;
  @override
  RuneOfDayModel getTodayRune() => fixtures.rune;
  @override
  PersonalizedLunarMonthModel? get activeLunarMonth => month;
  @override
  PersonalizedLunarDayModel? getPersonalizedLunarDayByDate(DateTime d) =>
      day(DateTime(d.year, d.month, d.day));
  @override
  Future<PersonalizedLunarMonthModel> loadPersonalizedLunarMonth(
    DateTime d, {
    bool forceRefresh = false,
  }) async => month;
  @override
  Future<MoonPhaseModel> getMoonPhaseForDate(DateTime d) async => moon(d);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Monetization extends ChangeNotifier implements MonetizationProvider {
  @override
  int get balance => 42;
  @override
  bool get effectivePro => false;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Home extends Cubit<HomeState> implements HomeCubit {
  _Home(super.state);
  @override
  Future<void> start() async {}
  @override
  Future<void> loadDailySelection() async {}
  @override
  void resetTarotAndRuneOpenState() {}
  @override
  void syncTarotCard() {}
  @override
  void syncRune() {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Moon extends Cubit<MoonScreenState> implements MoonScreenCubit {
  _Moon(super.state);
  @override
  Future<void> loadData() async {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Anakra extends ChangeNotifier implements AnakraChatProvider {
  @override
  Future<void> initialize() async {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
