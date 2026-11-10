import 'dart:convert';

import 'package:asteria_app/core/environment/environment.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _backendUrlOverride = String.fromEnvironment(
  'DYNAMIC_CONTENT_BACKEND_URL',
);
const _contentEndpoints = <String>[
  'tarot_cards',
  'rune_of_day',
  'articles',
  'affirmation',
  'energy_of_day',
  'shop_items',
  'lunar_calendar',
];
final _cyrillic = RegExp(r'[А-Яа-яЁё]');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Dio dio;

  setUpAll(() async {
    final environment = await Environment.initialize();
    final baseUrl = _backendUrlOverride.isEmpty
        ? environment.asteriaBackendUrl
        : _backendUrlOverride;
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
        headers: <String, String>{
          'Authorization': 'Bearer ${environment.asteriaApiKey}',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 3),
      ),
    );
  });

  testWidgets(
    'all required English regional APIs contain no Cyrillic',
    (_) async {
      for (final locale in const <String>['en-US', 'en-CA', 'en-GB', 'en-AU']) {
        for (final endpoint in _contentEndpoints) {
          final response = await dio.get<dynamic>(
            'api/v1/$endpoint',
            options: Options(
              headers: <String, String>{'Accept-Language': locale},
            ),
          );
          expect(response.statusCode, 200, reason: '$locale $endpoint');
          expect(
            response.data,
            isA<List<dynamic>>(),
            reason: '$locale $endpoint',
          );
          final items = response.data! as List<dynamic>;
          expect(items, isNotEmpty, reason: '$locale $endpoint');
          final encoded = jsonEncode(items);
          expect(
            _cyrillic.hasMatch(encoded),
            isFalse,
            reason: '$locale $endpoint contains Cyrillic',
          );
          expect(
            encoded,
            isNot(contains('"i18n"')),
            reason: '$locale $endpoint',
          );
        }
      }
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );

  testWidgets(
    'legacy requests still receive Russian content',
    (_) async {
      for (final endpoint in _contentEndpoints) {
        final response = await dio.get<dynamic>('api/v1/$endpoint');
        expect(response.statusCode, 200, reason: endpoint);
        expect(response.data, isA<List<dynamic>>(), reason: endpoint);
        final encoded = jsonEncode(response.data);
        expect(
          _cyrillic.hasMatch(encoded),
          isTrue,
          reason: '$endpoint must preserve the legacy Russian response',
        );
      }
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );

  testWidgets(
    'compatibility result follows Accept-Language',
    (_) async {
      for (final locale in const <String>['en-US', 'ru-RU']) {
        final response = await dio.post<dynamic>(
          'api/v1/compatibility/calculate',
          data: const <String, String>{
            'her_name': 'Alice',
            'his_name': 'Bob',
            'her_birthdate': '1990-01-02',
            'his_birthdate': '1991-03-04',
          },
          options: Options(
            headers: <String, String>{'Accept-Language': locale},
          ),
        );
        expect(response.statusCode, 200, reason: locale);
        final payload = Map<String, dynamic>.from(response.data! as Map);
        expect(
          payload.keys,
          containsAll(const <String>[
            'phrase',
            'introduction',
            'percentage',
            'general_compatibility',
            'love_compatibility',
            'family_compatibility',
            'conflicts',
          ]),
        );
        final hasCyrillic = _cyrillic.hasMatch(jsonEncode(payload));
        expect(hasCyrillic, locale == 'ru-RU', reason: locale);
      }
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
