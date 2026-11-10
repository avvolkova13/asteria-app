import 'package:dio/dio.dart';

abstract interface class AnalyticsTransport {
  Future<Map<String, Object?>> post(
    String path,
    Map<String, Object?> body, {
    required String token,
    String? accessToken,
  });
}

class AnalyticsDeliveryException implements Exception {
  const AnalyticsDeliveryException(this.status);
  final int status;
  @override
  String toString() => 'Analytics delivery failed ($status)';
}

/// Uses a dedicated Dio without payload/header logging interceptors.
class HttpAnalyticsTransport implements AnalyticsTransport {
  HttpAnalyticsTransport({
    required String baseUrl,
    required this.apiKey,
    Dio? dio,
  }) : _baseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 15),
               sendTimeout: const Duration(seconds: 15),
             ),
           );
  final String _baseUrl;
  final String apiKey;
  final Dio _dio;

  @override
  Future<Map<String, Object?>> post(
    String path,
    Map<String, Object?> body, {
    required String token,
    String? accessToken,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '${_baseUrl}api/v2/analytics/$path',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'X-Analytics-Token': token,
            if (accessToken != null) 'X-Asteria-User-Token': accessToken,
            'Content-Type': 'application/json',
          },
          validateStatus: (_) => true,
        ),
      );
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw AnalyticsDeliveryException(status);
      }
      final data = response.data;
      if (data is! Map) throw const AnalyticsDeliveryException(0);
      return Map<String, Object?>.from(data);
    } on DioException catch (error) {
      throw AnalyticsDeliveryException(error.response?.statusCode ?? 0);
    }
  }
}
