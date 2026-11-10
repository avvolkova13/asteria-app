import 'dart:typed_data';

import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BackendApi buildApi(_RecordingAdapter adapter) {
    final dio = Dio()..httpClientAdapter = adapter;
    return BackendApi.forTesting(
      dio: dio,
      asteriaBackendUrl: 'https://backend.example.com',
      asteriaApiKey: 'test-api-key',
    );
  }

  test(
    'getPlanetsHousesPosition calls backend endpoint with birth time',
    () async {
      final adapter = _RecordingAdapter();
      final api = buildApi(adapter);

      await api.getPlanetsHousesPosition(
        year: 2000,
        month: 12,
        day: 23,
        hour: 2,
        minute: 0,
        latitude: 42.3417,
        longitude: 69.5901,
      );

      expect(adapter.requests, hasLength(1));
      final request = adapter.requests.single;
      expect(
        request.uri.toString(),
        'https://backend.example.com/api/v1/planets_houses_position',
      );
      expect(request.headers['Authorization'], 'Bearer test-api-key');
      expect(request.headers['Content-Type'], 'application/json');
      expect(request.data, {
        'year': 2000,
        'month': 12,
        'day': 23,
        'hour': 2,
        'minute': 0,
        'latitude': 42.3417,
        'longitude': 69.5901,
      });
    },
  );

  test('getSolarData calls backend endpoint', () async {
    final adapter = _RecordingAdapter();
    final api = buildApi(adapter);

    await api.getSolarData(
      birthYear: 1990,
      birthMonth: 5,
      birthDay: 6,
      latitude: 42.3417,
      longitude: 69.5901,
    );

    expect(adapter.requests, hasLength(1));
    final request = adapter.requests.single;
    expect(
      request.uri.toString(),
      'https://backend.example.com/api/v1/solar_data',
    );
    expect(request.headers['Authorization'], 'Bearer test-api-key');
    expect(request.data, {
      'birth_year': 1990,
      'birth_month': 5,
      'birth_day': 6,
      'latitude': 42.3417,
      'longitude': 69.5901,
    });
  });

  test('openaiGenerateResponse calls backend endpoint', () async {
    final adapter = _RecordingAdapter();
    final api = buildApi(adapter);

    await api.openaiGenerateResponse(data: {'input': 'hello'});

    expect(adapter.requests, hasLength(1));
    final request = adapter.requests.single;
    expect(
      request.uri.toString(),
      'https://backend.example.com/api/v1/openai_generate_response',
    );
    expect(request.headers['Authorization'], 'Bearer test-api-key');
    expect(request.data, {'input': 'hello'});
  });

  test('openaiPost calls backend endpoint with normalized path', () async {
    final adapter = _RecordingAdapter();
    final api = buildApi(adapter);

    await api.openaiPost(
      path: '/v1/chat/completions',
      data: {
        'messages': [
          {'role': 'user', 'content': 'hello'},
        ],
      },
      queryParameters: {'timeout': 30},
    );

    expect(adapter.requests, hasLength(1));
    final request = adapter.requests.single;
    expect(
      request.uri.toString(),
      'https://backend.example.com/api/v1/openai_post/v1/chat/completions?timeout=30',
    );
    expect(request.headers['Authorization'], 'Bearer test-api-key');
    expect(request.data, {
      'messages': [
        {'role': 'user', 'content': 'hello'},
      ],
    });
  });

  test('getContentCollection sends effective Accept-Language', () async {
    final adapter = _RecordingAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final api = BackendApi.forTesting(
      dio: dio,
      asteriaBackendUrl: 'https://backend.example.com',
      asteriaApiKey: 'test-api-key',
      localeService: AppLocaleService(
        platformLocales: const <Locale>[Locale('en', 'GB')],
      ),
    );

    await api.getContentCollection('shop_items');

    expect(adapter.requests, hasLength(1));
    final request = adapter.requests.single;
    expect(
      request.uri.toString(),
      'https://backend.example.com/api/v1/shop_items',
    );
    expect(request.headers['Authorization'], 'Bearer test-api-key');
    expect(request.headers['Content-Type'], 'application/json');
    expect(request.headers['Accept-Language'], 'en-GB');
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    const headers = {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    };
    return ResponseBody.fromString(
      '{"success":true,"data":"Солнце - Козерог - 3","elements":{"fire":"1","earth":"1","air":"1","water":"1"},"positions":[],"calculation":{},"prompt_context":""}',
      200,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}
}
