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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('deduplicates concurrent loads for the same context month', () async {
    final repository = _FakePersonalizedRepository();
    final provider = _provider(repository: repository);

    final first = provider.loadPersonalizedLunarMonth(DateTime(2026, 8));
    final second = provider.loadPersonalizedLunarMonth(DateTime(2026, 8));
    await Future.wait([first, second]);

    expect(repository.loadCount, 1);
    expect(
      provider.getPersonalizedLunarDayByDate(DateTime(2026, 8, 11)),
      isNotNull,
    );
    provider.dispose();
  });

  test('location change prevents old active month lookup', () async {
    final userProvider = _userProvider(_userWithLocation(_saratov));
    final repository = _FakePersonalizedRepository();
    final provider = _provider(
      repository: repository,
      userProvider: userProvider,
    );

    await provider.loadPersonalizedLunarMonth(DateTime(2026, 8));
    userProvider.applyServerUserSnapshot(_userWithLocation(_amsterdam));

    expect(
      provider.getPersonalizedLunarDayByDate(DateTime(2026, 8, 11)),
      isNull,
    );
    provider.dispose();
    userProvider.dispose();
  });
}

ContentProvider _provider({
  required _FakePersonalizedRepository repository,
  UserProvider? userProvider,
}) {
  return ContentProvider(
    contentRepository: _FakeContentRepository(),
    personalizedLunarCalendarRepository: repository,
    userProvider: userProvider ?? _userProvider(_userWithLocation(_saratov)),
    compatibilityRepository: _FakeCompatibilityRepository(),
    localeService: AppLocaleService(
      platformLocales: const <Locale>[Locale('ru')],
    ),
  );
}

UserProvider _userProvider(UserModel user) {
  return UserProvider(userRepository: _FakeUserRepository())
    ..applyServerUserSnapshot(user);
}

UserModel _userWithLocation(CurrentLocationModel location) {
  return UserModel.empty().copyWith(currentLocation: location);
}

const _saratov = CurrentLocationModel(
  location: 'Саратов',
  latitude: 51.5336,
  longitude: 46.0343,
  source: CurrentLocationSource.manual,
);

const _amsterdam = CurrentLocationModel(
  location: 'Amsterdam',
  latitude: 52.3676,
  longitude: 4.9041,
  source: CurrentLocationSource.manual,
);

class _FakePersonalizedRepository
    implements PersonalizedLunarCalendarRepository {
  int loadCount = 0;

  @override
  Future<PersonalizedLunarMonthModel> loadMonth({
    required DateTime month,
    required CurrentLocationModel location,
  }) async {
    loadCount += 1;
    await Future<void>.delayed(Duration.zero);
    return _month(location);
  }
}

PersonalizedLunarMonthModel _month(CurrentLocationModel location) {
  return PersonalizedLunarMonthModel(
    year: 2026,
    month: 8,
    timezone: 'Europe/Saratov',
    anchorLocalTime: '12:00',
    days: [
      PersonalizedLunarDayModel(
        date: DateTime(2026, 8, 11),
        lunarContext: const PersonalizedLunarContextModel(
          lunarDayNumber: 28,
          moonAgeDays: 27.4,
          moonAgeDayIndex: 27,
          moonPhaseCode: 'waning_crescent',
          moonPhaseName: 'Убывающий серп',
          moonSignCode: 'cancer',
          moonSignName: 'Рак',
          phaseEvent: null,
        ),
        dailyBackground: const DailyBackgroundModel(
          tone: PhaseTone.recovery,
          title: 'Восстановление',
          summary: 'Время восстановления.',
        ),
        spheres: const {},
      ),
    ],
  );
}

class _FakeContentRepository implements ContentRepository {
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
