class HoroscopeApiException implements Exception {
  final String message;
  final int? statusCode;

  HoroscopeApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
