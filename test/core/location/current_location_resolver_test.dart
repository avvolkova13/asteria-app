import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/location/current_location_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrentLocationResolver', () {
    test('uses manual current location before auto and birth place', () {
      final user = UserModel.empty().copyWith(
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
      );

      final result = const CurrentLocationResolver().resolve(user);

      expect(result.status, CurrentLocationResolutionStatus.available);
      expect(result.location?.location, 'Алматы, Казахстан');
      expect(result.location?.latitude, 43.2389);
      expect(result.location?.longitude, 76.8897);
      expect(result.location?.source, CurrentLocationSource.manual);
    });

    test(
      'does not fall back to birth place when current location is missing',
      () {
        final user = UserModel.empty().copyWith(
          personalInfo: const PersonalInfoModel(
            birthPlace: BirthPlaceModel(
              location: 'Шымкент, Казахстан',
              latitude: 42.3417,
              longitude: 69.5901,
            ),
          ),
        );

        final result = const CurrentLocationResolver().resolve(user);

        expect(result.status, CurrentLocationResolutionStatus.needsSetup);
        expect(result.location, isNull);
      },
    );
  });
}
