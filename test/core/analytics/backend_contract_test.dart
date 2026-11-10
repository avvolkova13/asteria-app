import 'dart:convert';
import 'dart:io';

import 'package:asteria_app/core/analytics/durable/analytics_store.dart';
import 'package:asteria_app/core/analytics/durable/analytics_transport.dart';
import 'package:asteria_app/core/analytics/durable/durable_analytics.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:asteria_app/core/payments/api/apple_payments_api.dart';
import 'package:asteria_app/core/payments/api/google_payments_api.dart';
import 'package:asteria_app/core/payments/api/arc_pay_payments_api.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';

void main() {
  final backend = Platform.environment['GMKT22_BACKEND'] ?? '../asteria-back';
  final python = '$backend/.venv/bin/python';
  for (final provider in ['apple', 'google', 'arc_pay']) {
    test(
      'actual $provider payment request retains checkout attempt in backend model',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid/'));
        final requests = <RequestOptions>[];
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (request, handler) {
              requests.add(request);
              handler.resolve(
                Response(
                  requestOptions: request,
                  statusCode: 200,
                  data: {
                    'status': 'pending',
                    'transaction_id': 'transaction',
                    'balance': 0,
                    'attempt_id': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
                    'app_account_token': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaab',
                    'checkout_action': 'continue',
                    'order_id': 'order',
                    'checkout_url': 'https://example.invalid/checkout',
                  },
                ),
              );
            },
          ),
        );
        const attempt = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
        const context = {
          'attempt_id': attempt,
          'installation_id': 'local-only',
          'identity_id': 'local-only',
          'session_id': 'local-only',
        };
        final session = _ContractSession();
        if (provider == 'apple') {
          await ApplePaymentsApi.forDio(dio, session).checkout(
            userId: 'alice',
            attemptId: attempt,
            productId: 'asteria_pro_month',
            analyticsContext: context,
          );
        } else if (provider == 'google') {
          await GooglePaymentsApi.forDio(dio, session).verify(
            userId: 'alice',
            verificationData: 'test-token',
            productId: 'asteria_pro_month',
            analyticsContext: context,
          );
        } else {
          await ArcPayPaymentsApi.forDio(dio, session).createCheckout(
            userId: 'alice',
            productId: 'asteria_pro_month',
            requestId: attempt,
            analyticsContext: context,
          );
        }
        final request = requests.single;
        expect(request.headers['X-Asteria-User-Token'], 'verified-token');
        expect(request.data['attempt_id'], attempt);
        expect(
          request.data.containsKey('analytics_context'),
          provider == 'apple',
        );
        if (provider != 'apple') {
          expect(request.data.toString(), isNot(contains('local-only')));
        }
        final path = provider == 'apple'
            ? '../models/apple_lifecycle.py'
            : provider == 'arc_pay'
            ? 'v2/payments.py'
            : 'v1/payments_$provider.py';
        final model = {
          'apple': 'AppleCheckoutRequest',
          'google': 'GoogleVerifyRequest',
          'arc_pay': 'ArcPayCheckoutRequest',
        }[provider]!;
        final process = await Process.start(python, [
          '-B',
          'test/core/analytics/validate_backend_contract.py',
          '$backend/app/api/$path',
          model,
          'payment',
        ]);
        process.stdin.write(jsonEncode(request.data));
        await process.stdin.close();
        final output = process.stdout.transform(utf8.decoder).join();
        final error = process.stderr.transform(utf8.decoder).join();
        expect(await process.exitCode, 0, reason: await error);
        expect(await output, contains('valid'));
        dio.close();
      },
      skip: !File(python).existsSync()
          ? 'Requires sibling backend venv; set GMKT22_BACKEND'
          : false,
    );
  }
  test(
    'actual mobile HTTP bodies validate against current backend models',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'gmkt22-contract',
      );
      Hive.init(directory.path);
      final store = await AnalyticsStore.open();
      final dio = Dio();
      final requests = <RequestOptions>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) async {
            requests.add(request);
            final endpoint = request.uri.path.split('/analytics/').last;
            final process = await Process.start(python, [
              '-B',
              'test/core/analytics/validate_backend_contract.py',
              '$backend/app/services/analytics/models.py',
              endpoint,
            ]);
            process.stdin.write(jsonEncode(request.data));
            await process.stdin.close();
            final output = process.stdout.transform(utf8.decoder).join();
            final error = process.stderr.transform(utf8.decoder).join();
            final exit = await process.exitCode;
            expect(exit, 0, reason: await error);
            expect(await output, contains('valid'));
            expect(request.headers['Authorization'], 'Bearer api-key');
            expect(
              (request.headers['X-Analytics-Token'] as String).length,
              inInclusiveRange(43, 256),
            );
            if (endpoint == 'identify') {
              expect(request.data.keys, ['installation_id']);
              expect(request.headers['X-Asteria-User-Token'], 'verified-token');
            }
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: {
                  if (endpoint == 'identify') ...{
                    'identity_id': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
                    'user_id': 'alice',
                  },
                  if (endpoint == 'events/batch')
                    'accepted_event_ids': (request.data['events'] as List)
                        .map((e) => e['event_id'])
                        .toList(),
                },
              ),
            );
          },
        ),
      );
      final analytics = DurableAnalytics(
        store: store,
        transport: HttpAnalyticsTransport(
          baseUrl: 'https://example.invalid/',
          apiKey: 'api-key',
          dio: dio,
        ),
        currentUid: () => 'alice',
        accessToken: (_) async => 'verified-token',
        platform: 'ios',
        appVersion: '1.0.5+55',
        environment: 'production',
        enabled: true,
      );
      addTearDown(() async {
        analytics.dispose();
        dio.close();
        await Hive.close();
        await directory.delete(recursive: true);
      });
      await analytics.initialize();
      await analytics.identify();
      for (final event in [
        'screen_viewed',
        'onboarding_step_viewed',
        'auth_result',
        'feature_action_started',
        'feature_result_viewed',
        'feature_action_failed',
        'paywall_viewed',
        'offer_selected',
        'checkout_started',
        'checkout_outcome',
        'restore_started',
        'restore_outcome',
      ]) {
        await analytics.record(event, {
          'feature': 'sonnik',
          'text': 'must be removed',
          'af_revenue': 99,
          if (event == 'offer_selected') ...{
            'plan_id': 'asteria_pro_year',
            'price': 29.99,
            'af_currency': 'USD',
          },
          if (event.startsWith('restore_')) ...{
            'restore_id': 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
            'outcome': 'empty',
            'restored_count': 0,
          },
        });
      }
      await analytics.attribution(
        appsflyerId: 'sdk-uid',
        rawPayload: {
          'status': 'success',
          'data': {'is_first_launch': false, 'campaign': 'original'},
        },
      );
      await store.count('dropped_overflow', 2);
      await analytics.flush();
      expect(requests.first.data, {
        'installation_id': store.context['installation_id'],
        'platform': 'ios',
        'environment': 'production',
        'app_version': '1.0.5+55',
      });
      expect(
        requests.map((r) => r.uri.path),
        containsAll([
          '/api/v2/analytics/installations',
          '/api/v2/analytics/identify',
          '/api/v2/analytics/events/batch',
          '/api/v2/analytics/install-attribution',
        ]),
      );
      final events =
          requests
                  .firstWhere(
                    (r) =>
                        r.uri.path.endsWith('events/batch') &&
                        r.data['events'].first['event_name'] == 'first_open',
                  )
                  .data['events']
              as List;
      final offer = events.firstWhere(
        (e) => e['event_name'] == 'offer_selected',
      );
      expect(offer['payload']['price'], 29.99);
      expect(offer['payload']['currency'], 'USD');
      expect(offer['payload'].containsKey('af_revenue'), isFalse);
      expect(events.first['identity_id'], isNull);
      expect(
        events.last['identity_id'],
        'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      );
      expect(store.diagnostics['queued_events'], 0);
    },
    skip: !File(python).existsSync()
        ? 'Requires sibling backend venv; set GMKT22_BACKEND'
        : false,
  );
}

class _ContractSession implements AuthSessionService {
  @override
  String? get currentUid => 'alice';
  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async =>
      'verified-token';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
