import 'package:asteria_app/core/analytics/durable/analytics_transport.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'exact API prefix, installation secret and verified user header',
    () async {
      final dio = Dio();
      final requests = <RequestOptions>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            requests.add(request);
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: {'identity_id': 'immutable', 'user_id': 'server-user'},
              ),
            );
          },
        ),
      );
      final transport = HttpAnalyticsTransport(
        baseUrl: 'https://example.invalid/',
        apiKey: 'api-key',
        dio: dio,
      );
      final body = <String, Object?>{'installation_id': 'installation-uuid'};
      await transport.post('installations', body, token: 'installation-secret');
      final response = await transport.post(
        'identify',
        body,
        token: 'installation-secret',
        accessToken: 'verified-session',
      );
      expect(response['identity_id'], 'immutable');
      expect(requests.first.uri.path, '/api/v2/analytics/installations');
      expect(requests.last.uri.path, '/api/v2/analytics/identify');
      expect(requests.last.data, body);
      expect(requests.last.headers['X-Analytics-Token'], 'installation-secret');
      expect(requests.last.headers['X-Asteria-User-Token'], 'verified-session');
      expect(
        requests.first.headers.containsKey('X-Asteria-User-Token'),
        isFalse,
      );
    },
  );

  test(
    '503 containing accepted IDs is still failure; no raw body in exception',
    () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 503,
                data: {
                  'accepted_event_ids': ['event'],
                  'detail': 'private data',
                },
              ),
            );
          },
        ),
      );
      final transport = HttpAnalyticsTransport(
        baseUrl: 'https://example.invalid',
        apiKey: 'api-key',
        dio: dio,
      );
      await expectLater(
        transport.post('events/batch', {}, token: 'secret'),
        throwsA(
          isA<AnalyticsDeliveryException>()
              .having((e) => e.status, 'status', 503)
              .having(
                (e) => e.toString(),
                'redacted error',
                isNot(contains('private')),
              ),
        ),
      );
    },
  );
}
