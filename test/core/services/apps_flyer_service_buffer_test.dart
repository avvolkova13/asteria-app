import 'dart:async';
import 'dart:convert';

import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/services/apps_flyer_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

const _testEnvironment =
    'APPSFLYER_API_KEY=unit-test-key\n'
    'APPSFLYER_IOS_APP_ID=1234567890\n';
const _deniedEvents = [
  'unknown_event',
  'af_purchase',
  'ast_coin_purchase_success',
  'ast_subscription_purchase_success',
  'ast_payment_refunded',
  'ast_subscription_trial_started',
  'ast_coin_spend_success',
  'ast_coin_spend_refunded',
];

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = binding.defaultBinaryMessenger;
  const channel = MethodChannel('af-api');
  late Environment environment;
  late DebugPrintCallback originalDebugPrint;
  late String environmentAsset;
  late List<MethodCall> nativeCalls;
  late List<String> diagnostics;

  void testBuffer(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      try {
        await body(tester);
      } finally {
        debugDefaultTargetPlatformOverride = null;
        debugPrint = originalDebugPrint;
      }
    });
  }

  Future<Environment> loadEnvironment(String asset) async {
    environmentAsset = asset;
    rootBundle.evict('.env');
    return Environment.initialize();
  }

  Future<void> initializeSdk(
    WidgetTester tester,
    AppsFlyerService service,
  ) async {
    final initialized = service.initialize();
    // appsflyer_sdk.initSdk schedules a zero-duration timer.
    await tester.pump(Duration.zero);
    await initialized;
  }

  setUp(() async {
    nativeCalls = [];
    diagnostics = [];
    originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null) diagnostics.add(message);
    };
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      expect(const StringCodec().decodeMessage(message), '.env');
      return ByteData.sublistView(
        Uint8List.fromList(utf8.encode(environmentAsset)),
      );
    });
    messenger.setMockMethodCallHandler(channel, (call) async {
      nativeCalls.add(call);
      return call.method == 'logEvent' ? true : null;
    });
    environment = await loadEnvironment(_testEnvironment);
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMessageHandler('flutter/assets', null);
    channel.setMethodCallHandler(null);
    rootBundle.evict('.env');
    dotenv.clean();
    debugDefaultTargetPlatformOverride = null;
    debugPrint = originalDebugPrint;
  });

  testBuffer('unknown and server money events never enter the early queue', (
    tester,
  ) async {
    final service = AppsFlyerService(environment);
    for (final name in _deniedEvents) {
      expect(await service.logEvent(name, {'af_revenue': 9}), isFalse);
    }
    await tester.pump(const Duration(seconds: 60));
    expect(nativeCalls, isEmpty);
    expect(diagnostics, isEmpty);
    expect(service.isInitialized, isFalse);
  });

  for (final scenario in {
    'missing API key': 'APPSFLYER_IOS_APP_ID=1234567890\n',
    'missing Apple ID': 'APPSFLYER_API_KEY=unit-test-key\n',
    'invalid Apple ID':
        'APPSFLYER_API_KEY=unit-test-key\n'
        'APPSFLYER_IOS_APP_ID=com.example.invalid\n',
  }.entries) {
    testBuffer('${scenario.key} disables SDK and clears pre-initialize events', (
      tester,
    ) async {
      environment = await loadEnvironment(scenario.value);
      final service = AppsFlyerService(environment);
      expect(await service.logEvent('ast_first_open', null), isFalse);
      await service.initialize();
      expect(
        diagnostics,
        contains('[AppsFlyer] dropping 1 pending events (SDK disabled)'),
      );
      diagnostics.clear();
      await loadEnvironment(_testEnvironment);
      await service.initialize();
      service.startSDK();
      expect(await service.logEvent('ast_app_open', null), isFalse);
      expect(service.isInitialized, isFalse);
      expect(nativeCalls, isEmpty);
      expect(diagnostics, isEmpty);
      // testWidgets also fails if disabling leaves the watchdog timer pending.
    });
  }

  testBuffer(
    'native init failure disables SDK and cancels the early watchdog',
    (tester) async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        nativeCalls.add(call);
        throw PlatformException(code: 'test_init_failure');
      });
      final service = AppsFlyerService(environment);
      await service.logEvent('ast_first_open', null);
      await initializeSdk(tester, service);
      expect(
        diagnostics,
        contains('[AppsFlyer] dropping 1 pending events (SDK disabled)'),
      );
      await service.initialize();
      service.startSDK();
      expect(await service.logEvent('ast_app_open', null), isFalse);
      expect(nativeCalls.map((call) => call.method), ['initSdk']);
      expect(service.isInitialized, isFalse);
    },
  );

  testBuffer(
    '60-second watchdog starts before initialize and is not extended',
    (tester) async {
      final service = AppsFlyerService(environment);
      await service.logEvent('ast_first_open', null);
      await tester.pump(const Duration(seconds: 59));
      await service.logEvent('ast_app_open', null);
      await initializeSdk(tester, service);
      await tester.pump(const Duration(milliseconds: 999));
      expect(diagnostics.where((line) => line.contains('watchdog:')), isEmpty);
      await tester.pump(const Duration(milliseconds: 1));
      expect(
        diagnostics,
        contains(
          '[AppsFlyer] watchdog: SDK did not start within 60s, '
          'dropping 2 pending events',
        ),
      );
      diagnostics.clear();
      expect(await service.logEvent('ast_home_view', null), isFalse);
      expect(diagnostics, ['AppsFlyer: Cannot log event - SDK not started']);
      expect(nativeCalls.map((call) => call.method), ['initSdk']);
      expect(service.isInitialized, isFalse);
    },
  );

  testBuffer('initialize watchdog expires even when no event was queued', (
    tester,
  ) async {
    final service = AppsFlyerService(environment);
    await initializeSdk(tester, service);
    await tester.pump(const Duration(seconds: 60));
    expect(await service.logEvent('ast_first_open', null), isFalse);
    expect(diagnostics, ['AppsFlyer: Cannot log event - SDK not started']);
    expect(nativeCalls.map((call) => call.method), ['initSdk']);
  });

  // The package factory retains _isSdkStarted across service instances.
  // Keep the only successful start here; other tests never start the SDK.
  testBuffer(
    'early FIFO keeps newest 100, sanitizes and isolates flush errors',
    (tester) async {
      final initResponse = Completer<Object?>();
      final failedFlush = Completer<bool>();
      final logged = <Map<String, dynamic>>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        nativeCalls.add(call);
        if (call.method == 'initSdk') return initResponse.future;
        if (call.method != 'logEvent') return null;
        final event = Map<String, dynamic>.from(call.arguments as Map);
        logged.add(event);
        final position = (event['eventValues'] as Map)['position'];
        if (position == 2) return failedFlush.future;
        if (position == 103) {
          throw PlatformException(code: 'test_direct_log_failure');
        }
        return true;
      });
      final service = AppsFlyerService(environment);
      const eventId = '12345678-1234-4234-8234-123456789012';

      Future<void> queue(int position) async {
        final params = <String, dynamic>{
          'position': position,
          'screen': '/home',
          'event_id': eventId,
          'email': 'private@example.test',
          'birth_date': '2000-01-01',
          'dream_text': 'test-only private text',
          'raw_payload': {'receipt': 'test-only'},
          'af_revenue': 99,
          'af_currency': 'USD',
        };
        expect(await service.logEvent('ast_home_view', params), isFalse);
        params['position'] = 999;
        params['screen'] = '/settings';
      }

      for (var position = 0; position < 4; position++) {
        await queue(position);
      }
      expect(nativeCalls, isEmpty);
      service.startSDK();
      expect(nativeCalls, isEmpty);
      final initialized = service.initialize();
      await tester.pump(Duration.zero);
      final options = nativeCalls.single.arguments as Map;
      expect(options['manualStart'], isTrue);
      expect(options['isDebug'], isFalse);
      expect(options['GCD'], isTrue);
      expect(options['UDL'], isTrue);
      await queue(4);
      initResponse.complete();
      await tester.pump();
      await initialized;
      await service.initialize();
      for (var position = 5; position <= 100; position++) {
        await queue(position);
      }
      service.startSDK();
      service.startSDK();
      await tester.pump();
      await queue(101);
      expect(service.isInitialized, isFalse);
      expect(logged, isEmpty);
      expect(nativeCalls.map((call) => call.method), [
        'initSdk',
        'startSDKwithHandler',
      ]);

      binding.channelBuffers.push(
        'af-api',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('onSuccess'),
        ),
        (_) {},
      );
      await tester.pump();
      expect(service.isInitialized, isTrue);
      // The first native response is still pending; it cannot block the rest.
      expect(logged, hasLength(100));
      for (var offset = 0; offset < logged.length; offset++) {
        expect(logged[offset], {
          'eventName': 'ast_home_view',
          'eventValues': {
            'position': offset + 2,
            'screen': '/home',
            'event_id': eventId,
          },
        });
      }
      debugPrint = originalDebugPrint;
      failedFlush.completeError(PlatformException(code: 'test_flush_failure'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        await service.logEvent('ast_home_view', {'position': 102}),
        isTrue,
      );
      expect(
        await service.logEvent('ast_home_view', {'position': 103}),
        isNull,
      );
      for (final name in _deniedEvents) {
        expect(await service.logEvent(name, {'af_revenue': 9}), isFalse);
      }
      service.startSDK();
      await tester.pump(const Duration(seconds: 61));
      expect(logged, hasLength(102));
      expect(
        nativeCalls.where((call) => call.method == 'startSDKwithHandler'),
        hasLength(1),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
