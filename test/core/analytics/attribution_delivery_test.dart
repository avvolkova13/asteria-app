import 'dart:io';

import 'package:asteria_app/core/analytics/attribution/attribution_service.dart';
import 'package:asteria_app/core/analytics/durable/analytics_store.dart';
import 'package:asteria_app/core/analytics/durable/durable_analytics.dart';
import 'package:asteria_app/core/services/apps_flyer_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'durable_analytics_test.dart' show FakeTransport;
import 'analytics_recovery_test.dart' show FailingTransitionStore;

void main() {
  test(
    'callback received during failed transition is delivered after recovery',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'attribution-recovery',
      );
      Hive.init(directory.path);
      final original = await AnalyticsStore.open();
      await original.initialize();
      await original.updateContext({
        'platform': 'ios',
        'environment': 'test',
        'first_open_done': true,
      });
      final store = FailingTransitionStore();
      final transport = FakeTransport();
      final analytics = DurableAnalytics(
        store: store,
        transport: transport,
        currentUid: () => null,
        accessToken: (_) async => null,
        platform: 'ios',
        appVersion: '2',
        environment: 'production',
        enabled: true,
      );
      final sdk = AttributionSdk();
      final service = AttributionService(
        sdk,
        analytics: analytics,
        box: await Hive.openBox<Map>('recovery_snapshot'),
      );
      addTearDown(() async {
        await service.dispose();
        analytics.dispose();
        await Hive.close();
        await directory.delete(recursive: true);
      });
      await expectLater(
        analytics.initialize(),
        throwsA(isA<FileSystemException>()),
      );
      await service.initialize();
      await service.refreshUid();
      final raw = {
        'status': 'success',
        'data': {'media_source': 'first-source', 'campaign': 'original'},
      };
      sdk.callback!(raw);
      sdk.callback!({
        'data': {'media_source': 'later-source'},
      });
      await service.pendingWrites;
      expect(transport.attributions, isEmpty);
      expect(store.pendingAttribution, isNull);
      transport.failBootstrap = true;
      await analytics.flush();
      expect(store.pendingAttribution?['raw_payload'], raw);
      expect(transport.attributions, isEmpty);
      transport.failBootstrap = false;
      await analytics.flush();
      expect(transport.attributions.single['raw_payload'], raw);
      expect(transport.attributions.single['appsflyer_id'], 'sdk-uid');
      expect(
        transport.attributions.single['installation_id'],
        store.context['installation_id'],
      );
      await analytics.flush();
      expect(transport.attributions, hasLength(1));
    },
  );

  for (final wrapper in ['payload', 'data', null]) {
    test(
      'callback $wrapper resolves source without campaign and retains raw',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'attribution-envelope',
        );
        Hive.init(directory.path);
        final store = await AnalyticsStore.open();
        final analytics = DurableAnalytics(
          store: store,
          transport: FakeTransport(),
          currentUid: () => null,
          accessToken: (_) async => null,
          platform: 'ios',
          appVersion: '1',
          environment: 'test',
          enabled: true,
        );
        final sdk = AttributionSdk();
        final box = await Hive.openBox<Map>('envelope_snapshot');
        final service = AttributionService(sdk, analytics: analytics, box: box);
        addTearDown(() async {
          await service.dispose();
          analytics.dispose();
          await Hive.close();
          await directory.delete(recursive: true);
        });
        await analytics.initialize();
        await service.initialize();
        await service.refreshUid();
        final conversion = <String, Object?>{
          'af_status': 'Non-organic',
          'media_source': 'mail.ru_int',
          'is_first_launch': false,
        };
        final raw = wrapper == null
            ? conversion
            : <String, Object?>{'status': 'success', wrapper: conversion};
        sdk.callback!(raw);
        await service.pendingWrites;
        expect(service.firstTouchSnapshot?.trafficSource, 'mail.ru_int');
        expect(service.currentSnapshot?.trafficSource, 'mail.ru_int');
        expect(service.firstTouchSnapshot?.campaignId, isNull);
        expect(service.firstTouchSnapshot?.isOrganic, isFalse);
        expect(service.firstTouchSnapshot?.appsflyerId, 'sdk-uid');
        expect(
          box.get('first_touch_snapshot')?['traffic_source'],
          'mail.ru_int',
        );
        expect(store.pendingAttribution?['raw_payload'], raw);
        sdk.openCallback!({
          'status': 'success',
          'payload': {
            'media_source': 'later-network',
            'af_status': 'Non-organic',
          },
        });
        await service.pendingWrites;
        expect(service.firstTouchSnapshot?.trafficSource, 'mail.ru_int');
        expect(store.pendingAttribution?['raw_payload'], raw);
      },
    );
  }
  test(
    'SDK getter without callback is durable; callback retains entire envelope',
    () async {
      final directory = await Directory.systemTemp.createTemp('gmkt22-sdk');
      Hive.init(directory.path);
      final store = await AnalyticsStore.open();
      final analytics = DurableAnalytics(
        store: store,
        transport: FakeTransport(),
        currentUid: () => null,
        accessToken: (_) async => null,
        platform: 'ios',
        appVersion: '1',
        environment: 'test',
        enabled: true,
      );
      await analytics.initialize();
      final sdk = AttributionSdk();
      final service = AttributionService(
        sdk,
        analytics: analytics,
        box: await Hive.openBox<Map>('snapshot_test'),
      );
      await service.initialize();
      await service.refreshUid();
      expect(store.pendingAttribution?['appsflyer_id'], 'sdk-uid');
      sdk.callback!({});
      await service.pendingWrites;
      expect(store.pendingAttribution?.containsKey('raw_payload'), isFalse);
      sdk.openCallback!({
        'data': {'campaign': 'not-install'},
      });
      await service.pendingWrites;
      expect(service.firstTouchSnapshot, isNull);
      final raw = {
        'status': 'success',
        'data': {
          'campaign': 'first',
          'is_first_launch': false,
          'extra': {
            'nested': [1, 2],
          },
        },
      };
      sdk.callback!(raw);
      await service.pendingWrites;
      expect(store.pendingAttribution?['raw_payload'], raw);
      sdk.openCallback!({
        'data': {'campaign': 'later-link'},
      });
      sdk.callback!({
        'status': 'success',
        'data': {'campaign': 'repeat'},
      });
      await service.pendingWrites;
      expect(store.pendingAttribution?['raw_payload'], raw);
      await service.dispose();
      analytics.dispose();
      await Hive.close();
      await directory.delete(recursive: true);
    },
  );
}

class AttributionSdk implements AppsFlyerService {
  void Function(dynamic)? callback;
  void Function(dynamic)? openCallback;
  @override
  Future<String?> getAppsFlyerUid() async => 'sdk-uid';
  @override
  void onInstallConversionData(void Function(dynamic) callback) =>
      this.callback = callback;
  @override
  void onAppOpenAttribution(void Function(dynamic) callback) =>
      openCallback = callback;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
