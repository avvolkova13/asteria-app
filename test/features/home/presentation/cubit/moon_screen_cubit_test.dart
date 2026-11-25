import 'dart:async';

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
import 'package:asteria_app/features/home/presentation/widgets/moon_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    await (FontLoader('Onest')..addFont(
          rootBundle.load('assets/fonts/onest/Onest-VariableFont_wght.ttf'),
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
      observer.homeTab(1);
      await tester.pumpAndSettle();
      expect(
        events.names.where((name) => name == 'moon_day_view'),
        hasLength(1),
      );
      observer.homeTab(0);
      tab.value = 0;
      await tester.pumpAndSettle();
      tab.value = 1;
      observer.homeTab(1);
      await tester.pumpAndSettle();
      expect(
        events.names.where((name) => name == 'moon_day_view'),
        hasLength(1),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('arrows and a swipe navigate while earlier months are loading', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _PendingMonths();
    final cubit = _createCubitWithRepository(repository);
    addTearDown(cubit.close);
    final august = cubit.loadMonth(DateTime(2026, 8));
    repository.finish(DateTime(2026, 8));
    await august;
    await tester.pumpWidget(
      BlocProvider<MoonScreenCubit>.value(
        value: cubit,
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocaleService.supportedLocales,
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeLight.instance.getThemeData(context),
              child: const Scaffold(body: MoonCalendarWidget()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final next = find.byTooltip('Следующий месяц');
    await tester.tap(next);
    await tester.pump();
    expect(find.textContaining('Сентябрь 2026'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 64));
    await tester.tap(next);
    await tester.pumpAndSettle();
    expect(find.textContaining('Октябрь 2026'), findsOneWidget);

    await tester.fling(find.text('15'), const Offset(-280, 0), 1400);
    await tester.pumpAndSettle();
    expect(find.textContaining('Ноябрь 2026'), findsOneWidget);
    await tester.tap(find.text('19'));
    await tester.pump();
    repository.finish(DateTime(2026, 11));
    repository.finish(DateTime(2026, 10));
    repository.finish(DateTime(2026, 9));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ноябрь 2026'), findsOneWidget);
    expect(cubit.state.selectedDate?.day, 19);
    expect(tester.takeException(), isNull);
  });

  test(
    'late responses preserve the selected day and its sphere data',
    () async {
      final repository = _PendingMonths();
      final cubit = _createCubitWithRepository(repository);
      addTearDown(cubit.close);
      final september = cubit.loadMonth(DateTime(2026, 9));
      final october = cubit.loadMonth(DateTime(2026, 10));
      final picked = DateTime(2026, 10, 21);
      cubit.selectDate(picked);
      repository.finish(picked);
      await october;
      repository.finish(DateTime(2026, 9));
      await september;

      cubit.selectSphere(Sphere.garden);
      expect(cubit.state.selectedDate, picked);
      expect(cubit.state.selectedPersonalizedDayData?.date, picked);
      expect(cubit.state.selectedDayStatus, DayStatus.favorable);
    },
  );

  test('a failed month stays visible for day selection and retry', () async {
    final repository = _PendingMonths();
    final cubit = _createCubitWithRepository(repository);
    addTearDown(cubit.close);
    final picked = DateTime(2026, 9, 19);
    final load = cubit.loadMonth(DateTime(2026, 9));
    repository.requests[DateTime(2026, 9)]!.completeError(
      StateError('offline'),
    );
    await load;
    expect(cubit.state.focusedDay.month, 9);
    expect(cubit.state.error, isNotNull);
    cubit.selectDate(picked);

    final retry = cubit.loadMonth(cubit.state.focusedDay, forceRefresh: true);
    repository.finish(picked);
    await retry;
    expect(cubit.state.selectedDate, picked);
    expect(cubit.state.selectedPersonalizedDayData?.date, picked);
    expect(cubit.state.error, isNull);
  });

  for (final changeDuringLoad in [true, false]) {
    test(
      'changing city ${changeDuringLoad ? 'during' : 'after'} a request excludes the previous city',
      () async {
        final user = UserProvider(userRepository: _FakeUserRepository());
        addTearDown(user.dispose);
        final repository = _PendingMonths();
        final cubit = _createCubitWithRepository(repository, user: user);
        addTearDown(cubit.close);
        final date = DateTime(2026, 9, 19);
        final load = cubit.loadMonth(date);
        cubit.selectDate(date);
        void changeCity() => user.applyServerUserSnapshot(
          user.currentUser!.copyWith(
            currentLocation: _saratov.copyWith(
              location: 'Москва',
              latitude: 55.75,
              longitude: 37.62,
            ),
          ),
        );

        if (changeDuringLoad) changeCity();
        repository.finish(date);
        await load;
        if (changeDuringLoad) {
          expect(cubit.state.selectedPersonalizedDayData, isNull);
        } else {
          expect(cubit.state.selectedPersonalizedDayData?.date, date);
          changeCity();
        }
        cubit.selectSphere(Sphere.garden);
        expect(cubit.state.selectedPersonalizedDayData, isNull);
        expect(cubit.state.dayStatuses, isEmpty);
        cubit.selectDate(date);
        expect(cubit.state.selectedPersonalizedDayData, isNull);

        final refresh = cubit.loadMonth(date, forceRefresh: true);
        repository.finish(date);
        await refresh;
        expect(cubit.state.selectedPersonalizedDayData?.date, date);
        expect(cubit.state.selectedDayStatus, DayStatus.favorable);
      },
    );
  }

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
  PersonalizedLunarCalendarRepository repository, {
  UserProvider? user,
}) {
  final userProvider =
      (user ?? UserProvider(userRepository: _FakeUserRepository()))
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

class _PendingMonths implements PersonalizedLunarCalendarRepository {
  final requests = <DateTime, Completer<PersonalizedLunarMonthModel>>{};

  @override
  Future<PersonalizedLunarMonthModel> loadMonth({
    required DateTime month,
    required CurrentLocationModel location,
  }) {
    final request = Completer<PersonalizedLunarMonthModel>();
    requests[month] = request;
    return request.future;
  }

  void finish(DateTime day) {
    requests[DateTime(day.year, day.month)]!.complete(
      _month(year: day.year, month: day.month, days: [_day(day)]),
    );
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
