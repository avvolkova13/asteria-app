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
      LogInterceptor(
        requestBody: false,
        responseBody: true,
        requestHeader: false,
        responseHeader: true,
        error: true,
        logPrint: (object) => debugPrint('[BackendAPI] $object'),
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
      debugPrint(
        '[BackendAPI] Calling moon_phase/calculate with params: $params',
      );

      final response = await _dio.post(
        url,
        data: params,
        options: Options(headers: _localizedHeaders),
      );

      return response;
    } catch (e, stackTrace) {
      debugPrint('[BackendAPI] calculate-moon-data error: $e');
      debugPrint('[BackendAPI] Stack trace: $stackTrace');
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
      debugPrint(
        '[BackendAPI] Calling get-planets-houses-position-http with params: $params',
      );

      final response = await _dio.post(
        url,
        data: params,
        options: Options(headers: _localizedHeaders),
      );

      debugPrint('[BackendAPI] get-planets-houses-position-http success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('[BackendAPI] get-planets-houses-position-http error: $e');
      debugPrint('[BackendAPI] Stack trace: $stackTrace');
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
      debugPrint(
        '[BackendAPI] Calling get_solar_data_http with params: $params',
      );

      final response = await _dio.post(
        url,
        data: params,
        options: Options(headers: _localizedHeaders),
      );

      debugPrint('[BackendAPI] get_solar_data_http success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('[BackendAPI] get_solar_data_http error: $e');
      debugPrint('[BackendAPI] Stack trace: $stackTrace');
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
      debugPrint(
        '[BackendAPI] Calling openai-generate-response with data: $data',
      );

      final response = await _dio.post(
        url,
        data: data,
        options: Options(headers: _localizedHeaders),
      );

      debugPrint('[BackendAPI] openai-generate-response success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('[BackendAPI] openai-generate-response error: $e');
      debugPrint('[BackendAPI] Stack trace: $stackTrace');
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
      debugPrint(
        '[BackendAPI] Calling openai-post with url: $url, data: $data',
      );

      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: _localizedHeaders),
      );

      debugPrint('[BackendAPI] openai-post success');
      return response;
    } catch (e, stackTrace) {
      debugPrint('[BackendAPI] openai-post error: $e');
      debugPrint('[BackendAPI] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
