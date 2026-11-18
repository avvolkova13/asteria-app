import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BackendApi {
  final Environment? _environment;
  final AppLocaleService? _localeService;
  final String? _asteriaBackendUrlOverride;
  final String? _asteriaApiKeyOverride;
  late final Dio _dio;

  BackendApi(this._environment, {AppLocaleService? localeService})
    : _localeService = localeService,
      _asteriaBackendUrlOverride = null,
      _asteriaApiKeyOverride = null {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 3000),
        receiveTimeout: const Duration(seconds: 3000),
        sendTimeout: const Duration(seconds: 3000),
      ),
    );

    _setupInterceptors();
  }

  @visibleForTesting
  BackendApi.forTesting({
    required Dio dio,
    required String asteriaBackendUrl,
    required String asteriaApiKey,
    AppLocaleService? localeService,
  }) : _environment = null,
       _localeService = localeService,
       _asteriaBackendUrlOverride = asteriaBackendUrl.endsWith('/')
           ? asteriaBackendUrl
           : '$asteriaBackendUrl/',
       _asteriaApiKeyOverride = asteriaApiKey {
    _dio = dio;
    _setupInterceptors();
  }

  String get _asteriaBackendUrl =>
      _asteriaBackendUrlOverride ?? _environment!.asteriaBackendUrl;

  String get _asteriaApiKey =>
      _asteriaApiKeyOverride ?? _environment!.asteriaApiKey;

  Map<String, String> get _localizedHeaders => <String, String>{
    'Authorization': 'Bearer $_asteriaApiKey',
    'Content-Type': 'application/json',
    if (_localeService != null) 'Accept-Language': _localeService.languageTag,
  };

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('backend_api_request_started');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('backend_api_response_received');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('backend_api_request_failed');
          handler.next(error);
        },
      ),
    );
  }

  /// Вызывает функцию calculate-moon-data
  ///
  /// [year] - год
  /// [month] - месяц
  /// [day] - день
  /// [hour] - час
  /// [minute] - минута
  /// [timezoneOffsetMinutes] - смещение часового пояса устройства от UTC в минутах
  /// [lat] - широта
  /// [lon] - долгота
  Future<Response> calculateMoonData({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required int timezoneOffsetMinutes,
    required double lat,
    required double lon,
  }) async {
    try {
      final url = '${_asteriaBackendUrl}api/v1/moon_phase/calculate';
      final params = <String, dynamic>{
        'year': year,
        'month': month,
        'day': day,
        'hour': hour,
        'minute': minute,
        'timezone_offset_minutes': timezoneOffsetMinutes,
        'lat': lat,
        'lon': lon,
      };
      debugPrint('backend_api_moon_calculation_started');

      final response = await _dio.post(
        url,
        data: params,
        options: Options(headers: _localizedHeaders),
      );

      return response;
    } catch (_) {
      debugPrint('backend_api_moon_calculation_failed');
      rethrow;
    }
  }

  Future<Response<dynamic>> getPersonalizedLunarMonth({
    required int year,
    required int month,
    required double latitude,
    required double longitude,
  }) async {
    final url = '${_asteriaBackendUrl}api/v1/lunar_calendar/month';
    return _dio.post<dynamic>(
      url,
      data: <String, dynamic>{
        'year': year,
        'month': month,
        'lat': latitude,
        'lon': longitude,
      },
      options: Options(headers: _localizedHeaders),
    );
  }

  Future<Response> getContentVersions() async {
    final url = '${_asteriaBackendUrl}api/v1/content/versions';
    return _dio.get(url, options: Options(headers: _localizedHeaders));
  }

  Future<Response<dynamic>> getContentCollection(String collection) {
    final url = '${_asteriaBackendUrl}api/v1/$collection';
    return _dio.get<dynamic>(url, options: Options(headers: _localizedHeaders));
  }

  Future<Response<dynamic>> calculateCompatibility({
    required String herName,
    required String hisName,
    required String herBirthdate,
    required String hisBirthdate,
  }) {
    final url = '${_asteriaBackendUrl}api/v1/compatibility/calculate';
    return _dio.post<dynamic>(
      url,
      data: <String, dynamic>{
        'her_name': herName,
        'his_name': hisName,
        'her_birthdate': herBirthdate,
        'his_birthdate': hisBirthdate,
      },
      options: Options(headers: _localizedHeaders),
    );
  }

  /// Вызывает функцию get-planets-houses-position-http
  ///
  /// [year] - год
  /// [month] - месяц
  /// [day] - день
  /// [hour] - час рождения
  /// [minute] - минута рождения
  /// [lat] - широта
  /// [lon] - долгота
  Future<Response> getPlanetsHousesPosition({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = '${_asteriaBackendUrl}api/v1/planets_houses_position';
      final params = <String, dynamic>{
        'year': year,
        'month': month,
        'day': day,
        'hour': hour,
        'minute': minute,
        'latitude': latitude,
        'longitude': longitude,
      };
      debugPrint('backend_api_planets_calculation_started');

      final response = await _dio.post(
        url,
        data: params,
        options: Options(headers: _localizedHeaders),
      );

      debugPrint('backend_api_planets_calculation_completed');
      return response;
    } catch (_) {
      debugPrint('backend_api_planets_calculation_failed');
      rethrow;
    }
  }

  /// Запрашивает расчет солярной карты через backend.
  ///
  /// [year] - год
  /// [month] - месяц
  /// [day] - день
  /// [lat] - широта
  /// [lon] - долгота
  Future<Response> getSolarData({
    required int birthYear,
    required int birthMonth,
    required int birthDay,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = '${_asteriaBackendUrl}api/v1/solar_data';
      final params = <String, dynamic>{
        'birth_year': birthYear,
        'birth_month': birthMonth,
        'birth_day': birthDay,
        'latitude': latitude,
        'longitude': longitude,
      };
      debugPrint('backend_api_solar_calculation_started');

      final response = await _dio.post(
        url,
        data: params,
        options: Options(headers: _localizedHeaders),
      );

      debugPrint('backend_api_solar_calculation_completed');
      return response;
    } catch (_) {
      debugPrint('backend_api_solar_calculation_failed');
      rethrow;
    }
  }

  /// Выполняет Responses API запрос через backend proxy.
  ///
  /// [data] - данные запроса (обычно PromptRequest.toJson())
  Future<Response> openaiGenerateResponse({
    required Map<String, dynamic> data,
  }) async {
    try {
      final url = '${_asteriaBackendUrl}api/v1/openai_generate_response';
      debugPrint('backend_api_generation_started');

      final response = await _dio.post(
        url,
        data: data,
        options: Options(headers: _localizedHeaders),
      );

      debugPrint('backend_api_generation_completed');
      return response;
    } catch (_) {
      debugPrint('backend_api_generation_failed');
      rethrow;
    }
  }

  /// Выполняет разрешенный OpenAI POST через backend proxy.
  ///
  /// [path] - путь к эндпоинту OpenAI API (например, 'v1/responses', 'v1/chat/completions')
  /// [data] - данные запроса
  /// [queryParameters] - опциональные query параметры
  Future<Response> openaiPost({
    required String path,
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final normalizedPath = path.replaceFirst(RegExp(r'^/+'), '');
      final url = '${_asteriaBackendUrl}api/v1/openai_post/$normalizedPath';
      debugPrint('backend_api_proxy_request_started');

      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: _localizedHeaders),
      );

      debugPrint('backend_api_proxy_request_completed');
      return response;
    } catch (_) {
      debugPrint('backend_api_proxy_request_failed');
      rethrow;
    }
  }
}
