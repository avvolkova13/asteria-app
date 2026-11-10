import 'dart:async';

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum DeviceLocationStatus {
  available,
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  unavailable,
}

class DeviceLocationResult {
  final DeviceLocationStatus status;
  final CurrentLocationModel? location;

  const DeviceLocationResult._({required this.status, this.location});

  const DeviceLocationResult.available(CurrentLocationModel location)
    : this._(status: DeviceLocationStatus.available, location: location);

  const DeviceLocationResult.permissionDenied()
    : this._(status: DeviceLocationStatus.permissionDenied);

  const DeviceLocationResult.permissionDeniedForever()
    : this._(status: DeviceLocationStatus.permissionDeniedForever);

  const DeviceLocationResult.serviceDisabled()
    : this._(status: DeviceLocationStatus.serviceDisabled);

  const DeviceLocationResult.unavailable()
    : this._(status: DeviceLocationStatus.unavailable);
}

class DeviceLocationService {
  const DeviceLocationService();

  Future<DeviceLocationResult> detectCurrentLocation({
    required bool requestPermission,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const DeviceLocationResult.serviceDisabled();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestPermission) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const DeviceLocationResult.permissionDenied();
    }
    if (permission == LocationPermission.deniedForever) {
      return const DeviceLocationResult.permissionDeniedForever();
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      final resolved = await _resolvePlacemark(position);

      return DeviceLocationResult.available(
        CurrentLocationModel(
          location: resolved.label,
          latitude: position.latitude,
          longitude: position.longitude,
          source: CurrentLocationSource.auto,
          countryCode: resolved.countryCode,
        ),
      );
    } on TimeoutException {
      return const DeviceLocationResult.unavailable();
    } catch (_) {
      return const DeviceLocationResult.unavailable();
    }
  }

  Future<_ResolvedPlacemark> _resolvePlacemark(Position position) async {
    try {
      final placemarks = await Geocoding()
          .placemarkFromCoordinates(position.latitude, position.longitude)
          .timeout(const Duration(seconds: 8));
      if (placemarks.isEmpty) {
        return const _ResolvedPlacemark(label: 'Текущая геолокация');
      }

      final placemark = placemarks.first;
      final city = _firstNotEmpty([
        placemark.locality,
        placemark.subAdministrativeArea,
        placemark.administrativeArea,
      ]);
      final country = placemark.country?.trim();
      final countryCode = _normalizeCountryCode(placemark.isoCountryCode);

      if (city != null && country != null && country.isNotEmpty) {
        return _ResolvedPlacemark(
          label: '$city, $country',
          countryCode: countryCode,
        );
      }
      if (city != null) {
        return _ResolvedPlacemark(label: city, countryCode: countryCode);
      }
      if (country != null && country.isNotEmpty) {
        return _ResolvedPlacemark(label: country, countryCode: countryCode);
      }
      return _ResolvedPlacemark(
        label: 'Текущая геолокация',
        countryCode: countryCode,
      );
    } catch (_) {
      return const _ResolvedPlacemark(label: 'Текущая геолокация');
    }
  }

  String? _firstNotEmpty(List<String?> values) {
    for (final value in values) {
      final normalized = value?.trim();
      if (normalized != null && normalized.isNotEmpty) return normalized;
    }
    return null;
  }

  String? _normalizeCountryCode(String? value) {
    final normalized = value?.trim().toUpperCase();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

class _ResolvedPlacemark {
  final String label;
  final String? countryCode;

  const _ResolvedPlacemark({required this.label, this.countryCode});
}
