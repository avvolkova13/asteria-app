part of 'user_model.dart';

enum CurrentLocationSource { auto, manual }

class CurrentLocationModel {
  final String location;
  final double latitude;
  final double longitude;
  final CurrentLocationSource source;
  final String? countryCode;
  final DateTime? updatedAt;

  const CurrentLocationModel({
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.source,
    this.countryCode,
    this.updatedAt,
  });

  factory CurrentLocationModel.fromJson(Map<String, dynamic> json) {
    return CurrentLocationModel(
      location: (json['location'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      source: CurrentLocationSource.values.firstWhere(
        (value) => value.name == json['source'],
        orElse: () => CurrentLocationSource.auto,
      ),
      countryCode: _normalizeCountryCode(json['country_code'] as String?),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'source': source.name,
      'country_code': countryCode,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CurrentLocationModel copyWith({
    String? location,
    double? latitude,
    double? longitude,
    CurrentLocationSource? source,
    String? countryCode,
    DateTime? updatedAt,
    bool clearCountryCode = false,
    bool clearUpdatedAt = false,
  }) {
    return CurrentLocationModel(
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      source: source ?? this.source,
      countryCode: clearCountryCode ? null : (countryCode ?? this.countryCode),
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
    );
  }

  static String? _normalizeCountryCode(String? value) {
    final normalized = value?.trim().toUpperCase();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
