import 'dart:io';
import 'package:asteria_app/core/analytics/durable/analytics_store.dart';
import 'package:asteria_app/core/analytics/durable/durable_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'durable_analytics_test.dart' show FakeTransport;

void main() {
  test('failed transition cannot send old data and retries on flush', () async {
    final directory = await Directory.systemTemp.createTemp(
      'analytics-transition',
    );
    Hive.init(directory.path);
    final original = await AnalyticsStore.open();
    await original.initialize();
    await original.updateContext({
      'platform': 'ios',
      'environment': 'test',
      'first_open_done': true,
    });
    final oldId = original.context['installation_id'];
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
    addTearDown(() async {
      analytics.dispose();
      await Hive.close();
      await directory.delete(recursive: true);
    });
    await expectLater(
      analytics.initialize(),
      throwsA(isA<FileSystemException>()),
    );
    final newId = store.context['installation_id'];
    expect(newId, isNot(oldId));
    await analytics.record('screen_viewed', {});
    await analytics.identify();
    expect(transport.calls, isEmpty);
    expect(await store.batch(DateTime.now()), isEmpty);
    await analytics.flush();
    expect(store.context['installation_id'], newId);
    expect(
      transport.events.where((e) => e['event_name'] == 'session_started'),
      hasLength(1),
    );
    expect(
      transport.events.every((e) => e['environment'] == 'production'),
      true,
    );
    await analytics.record('screen_viewed', {});
    await analytics.flush();
    expect(transport.events.last['event_name'], 'screen_viewed');
  });

  test(
    'disabled does not open Hive; enabled failure degrades then recovers',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'gmkt22-recovery',
      );
      Hive.init(directory.path);
      var failed = true;
      var opens = 0;
      final store = AnalyticsStore.deferred(
        openStore: () async {
          opens++;
          if (failed) throw const FileSystemException('test unavailable');
          return AnalyticsStore.open();
        },
      );
      final transport = FakeTransport();
      DurableAnalytics create(bool enabled) => DurableAnalytics(
        store: store,
        transport: transport,
        currentUid: () => null,
        accessToken: (_) async => null,
        platform: 'ios',
        appVersion: '1+2',
        environment: 'test',
        enabled: enabled,
      );
      final disabled = create(false);
      await disabled.initialize();
      await disabled.flush();
      expect(opens, 0);
      disabled.dispose();
      final analytics = create(true);
      addTearDown(() async {
        analytics.dispose();
        await Hive.close();
        await directory.delete(recursive: true);
      });
      await analytics.initialize();
      expect(store.isAvailable, false);
      expect(store.diagnostics['storage_open_failures'], 1);
      await analytics.record('screen_viewed', {'screen': '/home'});
      expect(store.diagnostics['degraded_dropped_events'], 1);
      failed = false;
      await analytics.flush();
      expect(store.isAvailable, true);
      expect(store.diagnostics['storage_recoveries'], 1);
      expect(store.diagnostics['storage_open_failures'], 1);
      expect(
        transport.events.where((e) => e['event_name'] == 'first_open'),
        hasLength(1),
      );
    },
  );
}

class FailingTransitionStore extends AnalyticsStore {
  FailingTransitionStore() : super.deferred();

  bool fail = true;

  @override
  Future<bool> prepareContext(String platform, String environment) async {
    final result = await super.prepareContext(platform, environment);
    if (fail) {
      fail = false;
      throw const FileSystemException('transition write failed');
    }
    return result;
  }
}
