import 'dart:typed_data';

import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final fails in [false, true]) {
    test(
      'backend logging excludes request response and error PII (failure: $fails)',
      () async {
        const sentinel = 'private-sentinel-person@example.test';
        final logs = <String>[];
        final previousDebugPrint = debugPrint;
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) logs.add(message);
        };
        addTearDown(() => debugPrint = previousDebugPrint);
        final adapter = _RecordingAdapter()
          ..statusCode = fails ? 500 : 200
          ..responseData = '{"detail":"$sentinel"}'
          ..privateHeader = sentinel;
        final api = BackendApi.forTesting(
          dio: Dio()..httpClientAdapter = adapter,
          asteriaBackendUrl: 'https://backend.example.com',
          asteriaApiKey: sentinel,
        );
        final result = api.openaiPost(
          path: 'v1/$sentinel',
          data: {'input': sentinel},
          queryParameters: {'name': sentinel},
        );
        if (fails) {
          await expectLater(result, throwsA(isA<DioException>()));
        } else {
          expect((await result).data, {'detail': sentinel});
        }
        final sent = adapter.requests.single;
        expect(sent.data, {'input': sentinel});
        expect(sent.queryParameters, {'name': sentinel});
        expect(sent.headers['Authorization'], 'Bearer $sentinel');
        expect(logs, isNotEmpty);
        final output = logs.join('\n');
        expect(output, isNot(contains(sentinel)));
        expect(output, isNot(contains('backend.example.com')));
      },
    );
  }

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

  test(
    'compatibility uses the captured request locale over the later UI locale',
    () async {
      final adapter = _RecordingAdapter();
      final localeService = AppLocaleService(
        platformLocales: const [Locale('ru')],
      );
      addTearDown(localeService.dispose);
      final api = BackendApi.forTesting(
        dio: Dio()..httpClientAdapter = adapter,
        asteriaBackendUrl: 'https://backend.example.com',
        asteriaApiKey: 'test-api-key',
        localeService: localeService,
      );

      await api.calculateCompatibility(
        herName: 'Alice',
        hisName: 'Bob',
        herBirthdate: '1990-01-02',
        hisBirthdate: '1991-03-04',
        localeTag: 'en-GB',
      );

      expect(adapter.requests.single.headers['Accept-Language'], 'en-GB');
      expect(adapter.requests.single.data, isNot(contains('locale')));
    },
  );

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
  int statusCode = 200;
  String? responseData;
  String? privateHeader;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final headers = {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      if (privateHeader != null) 'x-private-test': [privateHeader!],
    };
    return ResponseBody.fromString(
      responseData ??
          '{"success":true,"data":"Солнце - Козерог - 3","elements":{"fire":"1","earth":"1","air":"1","water":"1"},"positions":[],"calculation":{},"prompt_context":""}',
      statusCode,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}
}
