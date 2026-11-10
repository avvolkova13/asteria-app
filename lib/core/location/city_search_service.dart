import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:dio/dio.dart';

class CitySuggestion {
  final String placeId;
  final String description;

  final CurrentLocationModel? knownLocation;

  const CitySuggestion({
    required this.placeId,
    required this.description,
    this.knownLocation,
  });
}

class CitySearchException implements Exception {
  const CitySearchException(this.message);

  final String message;

  @override
  String toString() => 'CitySearchException: $message';
}

class CitySearchService {
  CitySearchService({required String googleMapsApiKey, Dio? dio})
    : _googleMapsApiKey = googleMapsApiKey,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  final String _googleMapsApiKey;
  final Dio _dio;

  Future<List<CitySuggestion>> searchCities(
    String query, {
    required String language,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.length < 2 || _googleMapsApiKey.isEmpty) {
      return const [];
    }

    final response = await _dio.get<Map<String, dynamic>>(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      queryParameters: {
        'input': normalizedQuery,
        'key': _googleMapsApiKey,
        'language': language,
        'types': '(cities)',
      },
    );

    _validatePlacesStatus(response.data);

    final predictions = response.data?['predictions'];
    if (predictions is! List) return const [];

    return predictions
        .whereType<Map<String, dynamic>>()
        .map(
          (json) => CitySuggestion(
            placeId: (json['place_id'] as String?) ?? '',
            description: (json['description'] as String?) ?? '',
          ),
        )
        .where(
          (suggestion) =>
              suggestion.placeId.isNotEmpty &&
              suggestion.description.isNotEmpty,
        )
        .toList(growable: false);
  }

  Future<CurrentLocationModel?> getLocationForSuggestion(
    CitySuggestion suggestion, {
    required String language,
  }) async {
    if (_googleMapsApiKey.isEmpty) return null;

    final response = await _dio.get<Map<String, dynamic>>(
      'https://maps.googleapis.com/maps/api/place/details/json',
      queryParameters: {
        'placeid': suggestion.placeId,
        'key': _googleMapsApiKey,
        'fields': 'geometry,formatted_address,name,address_components',
        'language': language,
      },
    );

    _validatePlacesStatus(response.data);

    final result = response.data?['result'];
    if (result is! Map<String, dynamic>) return null;

    final geometry = result['geometry'];
    final location = geometry is Map<String, dynamic>
        ? geometry['location']
        : null;
    if (location is! Map<String, dynamic>) return null;

    final lat = (location['lat'] as num?)?.toDouble();
    final lon = (location['lng'] as num?)?.toDouble();
    if (lat == null || lon == null) return null;

    return CurrentLocationModel(
      location:
          (result['formatted_address'] as String?) ??
          (result['name'] as String?) ??
          suggestion.description,
      latitude: lat,
      longitude: lon,
      source: CurrentLocationSource.manual,
      countryCode: _countryCodeFromAddressComponents(
        result['address_components'],
      ),
    );
  }

  String? _countryCodeFromAddressComponents(Object? components) {
    if (components is! List) return null;
    for (final component in components.whereType<Map<String, dynamic>>()) {
      final types = component['types'];
      if (types is! List || !types.contains('country')) continue;
      final code = (component['short_name'] as String?)?.trim().toUpperCase();
      return code == null || code.isEmpty ? null : code;
    }
    return null;
  }

  void _validatePlacesStatus(Map<String, dynamic>? data) {
    final status = data?['status'];
    if (status == null || status == 'OK' || status == 'ZERO_RESULTS') {
      return;
    }

    final errorMessage = data?['error_message'];
    throw CitySearchException(
      errorMessage is String && errorMessage.isNotEmpty
          ? errorMessage
          : 'Google Places request failed with status $status',
    );
  }
}
