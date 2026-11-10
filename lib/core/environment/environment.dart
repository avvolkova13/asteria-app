import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final class Environment {
  const Environment._();

  static const _openAiApiKey = 'OPEN_AI_API_KEY';
  static const _openAiBaseUrl = 'OPEN_AI_BASE_URL';

  static const _moonApiBaseUrl = 'MOON_API_URL';
  static const _moonApiKey = 'MOON_API_KEY';

  // Google Maps API Key
  static const _googleMapsApiKey = 'GOOGLE_MAPS_API_KEY';

  // AppsFlyer API Key
  static const _appsflyerApiKey = 'APPSFLYER_API_KEY';
  static const _appsflyerIosAppIdKey = 'APPSFLYER_IOS_APP_ID';

  // Asteria Backend (StoreKit verify, etc.)
  static const _asteriaBackendUrlKey = 'ASTERIA_BACKEND_URL';
  static const _apiKeyKey = 'API_KEY';

  String get googleMapsApiKey => dotenv.env[_googleMapsApiKey] ?? '';

  String get appsflyerApiKey {
    final apiKey = dotenv.env[_appsflyerApiKey];
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw Exception(
        'APPSFLYER_API_KEY not configured. Please check .env file',
      );
    }
    return apiKey.trim();
  }

  /// Apple App ID for iOS AppsFlyer init. Returns `null` if not set —
  /// AppsFlyerService treats that as "disable AppsFlyer for this session"
  /// rather than crashing the app. Format validation (digits-only) is
  /// done in AppsFlyerService against the same regex the SDK uses.
  String? get appsflyerIosAppId {
    final raw = dotenv.env[_appsflyerIosAppIdKey];
    if (raw == null) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String get openAiApiKey => dotenv.env[_openAiApiKey] ?? '';
  String get openAiBaseUrl => dotenv.env[_openAiBaseUrl] ?? '';

  String get moonApiBaseUrl => dotenv.env[_moonApiBaseUrl] ?? '';
  String get moonApiKey => dotenv.env[_moonApiKey] ?? '';

  String get asteriaBackendUrl {
    final url = dotenv.env[_asteriaBackendUrlKey];
    if (url == null || url.trim().isEmpty) {
      throw Exception(
        'ASTERIA_BACKEND_URL not configured. Please check .env file',
      );
    }
    // Ensure trailing slash for predictable concatenation with paths.
    final trimmed = url.trim();
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }

  String get asteriaApiKey {
    final key = dotenv.env[_apiKeyKey];
    if (key == null || key.trim().isEmpty) {
      throw Exception('API_KEY not configured. Please check .env file');
    }
    return key.trim();
  }

  static Future<Environment> initialize() async {
    try {
      // Load env variables from .env file
      await dotenv.load(fileName: '.env');
      return const Environment._();
    } catch (e) {
      // Fallback to default values if .env file is not found
      debugPrint('Error: .env file not found!');
      return const Environment._();
    }
  }
}
