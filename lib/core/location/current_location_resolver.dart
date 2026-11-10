import 'package:asteria_app/app/data/models/user/user_model.dart';

enum CurrentLocationResolutionStatus { available, needsSetup }

class CurrentLocationResolution {
  final CurrentLocationResolutionStatus status;
  final CurrentLocationModel? location;

  const CurrentLocationResolution._({
    required this.status,
    required this.location,
  });

  const CurrentLocationResolution.available(CurrentLocationModel location)
    : this._(
        status: CurrentLocationResolutionStatus.available,
        location: location,
      );

  const CurrentLocationResolution.needsSetup()
    : this._(
        status: CurrentLocationResolutionStatus.needsSetup,
        location: null,
      );

  bool get hasLocation =>
      status == CurrentLocationResolutionStatus.available && location != null;
}

class CurrentLocationRequiredException implements Exception {
  const CurrentLocationRequiredException();

  @override
  String toString() => 'Current location is required for moon calculations';
}

class CurrentLocationResolver {
  const CurrentLocationResolver();

  CurrentLocationResolution resolve(UserModel? user) {
    final location = user?.currentLocation;
    if (location == null || !_isUsable(location)) {
      return const CurrentLocationResolution.needsSetup();
    }
    return CurrentLocationResolution.available(location);
  }

  CurrentLocationModel requireLocation(UserModel? user) {
    final resolution = resolve(user);
    final location = resolution.location;
    if (location == null) throw const CurrentLocationRequiredException();
    return location;
  }

  bool _isUsable(CurrentLocationModel location) {
    return location.location.trim().isNotEmpty &&
        location.latitude.isFinite &&
        location.longitude.isFinite &&
        location.latitude >= -90 &&
        location.latitude <= 90 &&
        location.longitude >= -180 &&
        location.longitude <= 180;
  }
}
