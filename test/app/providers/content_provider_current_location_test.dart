import 'package:asteria_app/app/data/models/moon_phase/moon_phase_model.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/location/current_location_resolver.dart';
import 'package:asteria_app/features/compatibility/domain/repositories/compatibility_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loadMoonPhase uses current location coordinates instead of birth place',
    () async {
      final repository = _RecordingContentRepository();
      final userProvider = UserProvider(userRepository: _FakeUserRepository())
        ..applyServerUserSnapshot(
          UserModel.empty().copyWith(
            currentLocation: const CurrentLocationModel(
              location: 'Алматы, Казахстан',
              latitude: 43.2389,
              longitude: 76.8897,
              source: CurrentLocationSource.manual,
            ),
            personalInfo: const PersonalInfoModel(
              birthPlace: BirthPlaceModel(
                location: 'Шымкент, Казахстан',
                latitude: 42.3417,
                longitude: 69.5901,
              ),
            ),
          ),
        );
      final provider = ContentProvider(
        contentRepository: repository,
        userProvider: userProvider,
        compatibilityRepository: _FakeCompatibilityRepository(),
        currentLocationResolver: const CurrentLocationResolver(),
      );

      addTearDown(() {
        provider.dispose();
        userProvider.dispose();
      });

      await provider.loadMoonPhase();

      expect(repository.lastLat, 43.2389);
      expect(repository.lastLon, 76.8897);
    },
  );
}

class _RecordingContentRepository implements ContentRepository {
  double? lastLat;
  double? lastLon;

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
    lastLat = lat;
    lastLon = lon;
    return MoonPhaseModel(
      date:
          '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year',
      lunarDay: 13,
      moonSign: 'aquarius',
      moonPhase: 'waxing_gibbous',
      moonPhaseRu: 'Растущая луна',
      moonriseLocal: '18:00',
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
