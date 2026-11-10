import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/personalized_lunar_month_model.dart';
import 'package:asteria_app/app/data/models/moon_phase/moon_phase_model.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/app/data/repositories/lunar_calendar/personalized_lunar_calendar_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/features/compatibility/domain/repositories/compatibility_repository.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_cubit.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/sphere_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/analytics_route_observer.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/screens/moon_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Urbanist')..addFont(
          rootBundle.load('assets/fonts/urbanist/Urbanist-Regular.ttf'),
        ))
        .load();
  });

  testWidgets(
    'preloaded Moon tracks the loaded day only when its tab becomes visible',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final events = _MoonEvents();
      final observer = AnalyticsRouteObserver(onScreen: (_, __) {});
      final user = UserProvider(userRepository: _FakeUserRepository());
      di.registerSingleton<AnalyticsFacade>(events);
      di.registerSingleton<ProductAnalyticsService>(
        ProductAnalyticsService(events),
      );
      di.registerSingleton<AnalyticsRouteObserver>(observer);
      di.registerSingleton<ContentProvider>(_MoonContent());
      di.registerFactory<MoonScreenCubit>(() => _createCubit(_month()));
      final tab = ValueNotifier<int>(0);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            name: '/home',
            builder: (_, __) => ValueListenableBuilder<int>(
              valueListenable: tab,
              builder: (context, index, _) => Theme(
                data: AppThemeLight.instance.getThemeData(context),
                child: IndexedStack(
                  index: index,
                  children: const [SizedBox(), MoonScreen()],
                ),
              ),
            ),
          ),
        ],
      );
      observer.attach(router);
      addTearDown(() async {
        observer.detach();
        router.dispose();
        tab.dispose();
        user.dispose();
        await di.reset();
      });
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: user,
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('ru'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocaleService.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(events.names.where((name) => name == 'moon_day_view'), isEmpty);
      tab.value = 1;
      observer.homeTab(2);
      await tester.pumpAndSettle();
      expect(
        events.names.where((name) => name == 'moon_day_view'),
        hasLength(1),
      );
      observer.homeTab(0);
      tab.value = 0;
      await tester.pumpAndSettle();
      tab.value = 1;
      observer.homeTab(2);
      await tester.pumpAndSettle();
      expect(
        events.names.where((name) => name == 'moon_day_view'),
        hasLength(1),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  test('starts in phase mode without a selected sphere', () async {
    final cubit = _createCubit(_month());

    await cubit.loadData();

    expect(cubit.state.selectedSphere, isNull);
    expect(
      cubit.state.selectedPersonalizedDayData?.dailyBackground.tone,
      PhaseTone.recovery,
    );
    expect(cubit.state.dayStatuses, isEmpty);
    expect(cubit.state.selectedDayStatus, DayStatus.neutral);

    await cubit.close();
  });

  test('sphere selection changes only backend sphere statuses', () async {
    final cubit = _createCubit(_month());

    await cubit.loadData();
    final background = cubit.state.selectedPersonalizedDayData?.dailyBackground;
    cubit.selectSphere(Sphere.garden);

    expect(cubit.state.selectedDayStatus, DayStatus.favorable);
    expect(
      cubit.state.selectedPersonalizedDayData?.dailyBackground,
      same(background),
    );

    await cubit.close();
  });

  test(
    'loadMonth tracks primary phase days from personalized phase events',
    () async {
      final cubit = _createCubit(
        _month(
          days: [
            _day(DateTime(2026, 8, 1), hasPhaseEvent: true),
            _day(DateTime(2026, 8, 2)),
          ],
        ),
      );

      await cubit.loadMonth(DateTime(2026, 8));

      expect(cubit.state.primaryPhaseDates, contains(DateTime(2026, 8, 1)));
      expect(
        cubit.state.primaryPhaseDates,
        isNot(contains(DateTime(2026, 8, 2))),
      );

      await cubit.close();
    },
  );

  test('loadMonth moves selected day into the newly focused month', () async {
    final cubit = _createCubitWithRepository(
      _MonthByRequestRepository({
        '2026-8': _month(
          days: [_day(DateTime(2026, 8, 13)), _day(DateTime(2026, 8, 25))],
        ),
        '2026-9': _month(
          year: 2026,
          month: 9,
          days: [_day(DateTime(2026, 9, 13)), _day(DateTime(2026, 9, 25))],
        ),
      }),
    );

    await cubit.loadMonth(DateTime(2026, 8));
    cubit.selectDate(DateTime(2026, 8, 13));

    await cubit.loadMonth(DateTime(2026, 9));

    expect(cubit.state.selectedDate, DateTime(2026, 9, 13));
    expect(
      cubit.state.selectedPersonalizedDayData?.date,
      DateTime(2026, 9, 13),
    );
    expect(cubit.state.selectedPersonalizedDayData, isNotNull);

    await cubit.close();
  });
}

class _MoonEvents implements AnalyticsFacade {
  final names = <String>[];
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    names.add(name);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MoonContent implements ContentProvider {
  @override
  PersonalizedLunarMonthModel? get activeLunarMonth => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MoonScreenCubit _createCubit(PersonalizedLunarMonthModel month) {
  return _createCubitWithRepository(_FakePersonalizedRepository(month));
}

MoonScreenCubit _createCubitWithRepository(
  PersonalizedLunarCalendarRepository repository,
) {
  final userProvider = UserProvider(userRepository: _FakeUserRepository())
    ..applyServerUserSnapshot(
      UserModel.empty().copyWith(currentLocation: _saratov),
    );
  final contentProvider = ContentProvider(
    contentRepository: _FakeContentRepository(),
    personalizedLunarCalendarRepository: repository,
    userProvider: userProvider,
    compatibilityRepository: _FakeCompatibilityRepository(),
    localeService: AppLocaleService(
      platformLocales: const <Locale>[Locale('ru')],
    ),
  );
  return MoonScreenCubit(contentProvider: contentProvider);
}

const _saratov = CurrentLocationModel(
  location: 'Саратов',
  latitude: 51.5336,
  longitude: 46.0343,
  source: CurrentLocationSource.manual,
);

class _FakePersonalizedRepository
    implements PersonalizedLunarCalendarRepository {
  _FakePersonalizedRepository(this.month);

  final PersonalizedLunarMonthModel month;

  @override
  Future<PersonalizedLunarMonthModel> loadMonth({
    required DateTime month,
    required CurrentLocationModel location,
  }) async {
    return this.month;
  }
}

class _MonthByRequestRepository implements PersonalizedLunarCalendarRepository {
  const _MonthByRequestRepository(this.months);

  final Map<String, PersonalizedLunarMonthModel> months;

  @override
  Future<PersonalizedLunarMonthModel> loadMonth({
    required DateTime month,
    required CurrentLocationModel location,
  }) async {
    return months['${month.year}-${month.month}']!;
  }
}

PersonalizedLunarMonthModel _month({
  int year = 2026,
  int month = 8,
  List<PersonalizedLunarDayModel>? days,
}) {
  return PersonalizedLunarMonthModel(
    year: year,
    month: month,
    timezone: 'Europe/Saratov',
    anchorLocalTime: '12:00',
    days: days ?? [_day(DateTime.now())],
  );
}

PersonalizedLunarDayModel _day(
  DateTime date, {
  String phase = 'waning_crescent',
  bool hasPhaseEvent = false,
}) {
  return PersonalizedLunarDayModel(
    date: DateTime(date.year, date.month, date.day),
    lunarContext: PersonalizedLunarContextModel(
      lunarDayNumber: 28,
      moonAgeDays: 27.4,
      moonAgeDayIndex: 27,
      moonPhaseCode: phase,
      moonPhaseName: 'Убывающий серп',
      moonSignCode: 'cancer',
      moonSignName: 'Рак',
      phaseEvent: hasPhaseEvent
          ? LunarPhaseEventModel(
              phase: 'full_moon',
              phaseName: 'Полнолуние',
              exactUtc: '2026-08-01T00:00:00Z',
              exactLocal: '2026-08-01T03:00:00+03:00',
            )
          : null,
    ),
    dailyBackground: const DailyBackgroundModel(
      tone: PhaseTone.recovery,
      title: 'Восстановление',
      summary: 'Время восстановления.',
    ),
    spheres: {
      'gardening': const SphereRecommendationModel(
        status: RecommendationStatus.favorable,
        tasks: {},
      ),
    },
  );
}

class _FakeContentRepository implements ContentRepository {
  @override
  Future<void> refreshContentVersions() async {}

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
    return MoonPhaseModel(
      date: '$day.$month.$year',
      lunarDay: 28,
      moonSign: 'Рак',
      moonPhase: 'waning_crescent',
      moonPhaseRu: 'Убывающий серп',
      moonriseLocal: '',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<void> updateCurrentUser(UserModel user) async {}

  @override
  Future<void> updateUserShopItems(
    String userId,
    List<ShopItemModel> shopItems,
  ) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCompatibilityRepository implements CompatibilityRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
