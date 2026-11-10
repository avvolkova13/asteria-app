import 'package:flutter/services.dart';

class AnalyticsDeviceContext {
  static const _channel = MethodChannel('asteria/analytics-device');

  static Future<Map<String, Object?>?> read() async {
    final result = await _channel.invokeMapMethod<String, Object?>('read');
    return result == null ? null : Map<String, Object?>.from(result);
  }
}
