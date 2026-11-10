import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:asteria_app/core/analytics/durable/analytics_store.dart';
import 'package:asteria_app/core/analytics/durable/analytics_transport.dart';
import 'package:asteria_app/core/analytics/durable/durable_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory directory;
  late AnalyticsStore store;
  late FakeTransport transport;
  late DateTime now;
  String? uid;
  late DurableAnalytics analytics;

  Future<void> open({
    int maxEvents = 10000,
    int maxBytes = 20 * 1024 * 1024,
    Future<Map<String, Object?>?> Function()? deviceContext,
  }) async {
    store = await AnalyticsStore.open(maxEvents: maxEvents, maxBytes: maxBytes);
    analytics = DurableAnalytics(
      store: store,
      transport: transport,
      currentUid: () => uid,
      accessToken: (expected) async =>
          uid == expected ? 'verified-token' : null,
      platform: 'ios',
      appVersion: '1.0.5+55',
      environment: 'test',
      enabled: true,
      deviceContext: deviceContext,
      clock: () => now,
    );
    await analytics.initialize();
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('gmkt22');
    Hive.init(directory.path);
    now = DateTime.utc(2026, 9, 10);
    uid = null;
    transport = FakeTransport();
    await open();
  });
  tearDown(() async {
    analytics.dispose();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'device metadata is separate, retried, and refreshed after ATT revocation',
    () async {
      analytics.dispose();
      await Hive.close();
      var context = <String, Object?>{
        'os': '26.6.1',
        'att': 3,
        'idfa': 'device-id',
      };
      await open(deviceContext: () async => context);
      transport.failDeviceContext = true;
      await analytics.flush();
      expect(transport.events, isNotEmpty);
      transport.failDeviceContext = false;
      await analytics.flush();
      expect(transport.deviceContexts.last['device_context'], context);
      expect(jsonEncode(transport.events), isNot(contains('device-id')));
      final count = transport.deviceContexts.length;
      await analytics.flush();
      expect(transport.deviceContexts.length, count);
      context = {'os': '26.6.1', 'att': 2, 'idfa': null};
      await analytics.resume();
      await analytics.flush();
      expect(transport.deviceContexts.last['device_context'], context);
      expect(transport.deviceContexts.length, count + 1);
    },
  );

  test('device plugin failure does not block product event delivery', () async {
    analytics.dispose();
    await Hive.close();
    await open(
      deviceContext: () async => throw StateError('native unavailable'),
    );
    await analytics.flush();
    expect(transport.events, isNotEmpty);
    expect(transport.deviceContexts, isEmpty);
  });

  for (final terminal in ['feature_action_failed', 'feature_result_viewed']) {
    test(
      '$terminal closes the attempt before an old result is viewed',
      () async {
        await analytics.record('feature_action_started', {'feature': 'sonnik'});
        final start = (await store.batch(now)).last['payload'] as Map;
        await analytics.record(terminal, {'feature': 'sonnik'});
        expect(
          ((await store.batch(now)).last['payload'] as Map)['attempt_id'],
          start['attempt_id'],
        );

        analytics.dispose();
        await Hive.close();
        await open();
        await analytics.record('feature_result_viewed', {'feature': 'sonnik'});
        expect(
          (await store.batch(now)).last['payload'] as Map,
          isNot(contains('attempt_id')),
        );

        await analytics.record('feature_action_started', {'feature': 'sonnik'});
        final retry = (await store.batch(now)).last['payload'] as Map;
        expect(retry['attempt_id'], isNot(start['attempt_id']));
        await analytics.record('feature_result_viewed', {'feature': 'sonnik'});
        expect(
          ((await store.batch(now)).last['payload'] as Map)['attempt_id'],
          retry['attempt_id'],
        );
      },
    );
  }

  test(
    'loss snapshot is durable, bounded, deduplicated and cannot evict product events',
    () async {
      await store.count('dropped_overflow', 7);
      await store.count('dropped_expired', 2);
      transport.failEvents = true;
      await analytics.flush();
      final first = transport.events
          .where((e) => e['event_name'] == 'analytics_queue_dropped')
          .single;
      expect(first['identity_id'], isNull);
      expect((first['payload'] as Map)['dropped_overflow'], 7);
      expect(jsonEncode(first).length, lessThan(2048));
      expect(store.diagnostics['queued_events'], 2);
      analytics.dispose();
      await Hive.close();
      await open(maxEvents: 2);
      uid = 'bob';
      await store.count('dropped_overflow', 3);
      transport.failEvents = false;
      await analytics.flush();
      var snapshots = transport.events
          .where((e) => e['event_name'] == 'analytics_queue_dropped')
          .toList();
      expect(snapshots.last, first);
      await analytics.flush();
      snapshots = transport.events
          .where((e) => e['event_name'] == 'analytics_queue_dropped')
          .toList();
      expect(snapshots.last['event_id'], isNot(first['event_id']));
      expect((snapshots.last['payload'] as Map)['dropped_overflow'], 10);
      final count = snapshots.length;
      await analytics.flush();
      expect(
        transport.events.where(
          (e) => e['event_name'] == 'analytics_queue_dropped',
        ),
        hasLength(count),
      );
      expect(store.diagnostics['dropped_overflow'], 10);
      expect(store.diagnostics['queued_events'], 0);
    },
  );

  test(
    'first open and installation secret survive restart and lost ACK',
    () async {
      final installation = store.context['installation_id'];
      final secret = store.context['token'] as String;
      expect(base64Url.decode(secret), hasLength(32));
      expect(secret.length, inInclusiveRange(43, 256));
      final first = (await store.batch(now)).first;
      expect(first['event_name'], 'first_open');
      transport.failEvents = true;
      await analytics.flush();
      expect((await store.batch(now)).first, first);
      analytics.dispose();
      await Hive.close();
      await open();
      expect(store.context['installation_id'], installation);
      expect(store.context['token'], secret);
      expect(
        (await store.batch(now)).where((e) => e['event_name'] == 'first_open'),
        hasLength(1),
      );
      transport.failEvents = false;
      await analytics.flush();
      expect(await store.batch(now), isEmpty);
      expect(transport.events.first['event_id'], first['event_id']);
    },
  );

  test(
    'anonymous and account contexts stay immutable through logout and switch',
    () async {
      await analytics.record('screen_viewed', {'screen': 'home'});
      uid = 'alice';
      await analytics.identify();
      await analytics.record('feature_action_started', {'feature': 'sonnik'});
      uid = null;
      await analytics.record('screen_viewed', {'screen': 'login'});
      uid = 'bob';
      await analytics.identify();
      await analytics.record('feature_action_started', {'feature': 'tarot'});
      final events = await store.batch(now);
      expect(events[2]['identity_id'], isNull);
      expect(events[3]['identity_id'], 'identity-alice');
      expect(events[4]['identity_id'], isNull);
      expect(events[5]['identity_id'], 'identity-bob');
      expect(events.every((e) => !e.containsKey('user_id')), isTrue);
      expect(events.last.keys.toSet(), {
        'event_id',
        'event_name',
        'schema_version',
        'occurred_at',
        'session_id',
        'identity_id',
        'platform',
        'app_version',
        'environment',
        'payload',
      });
    },
  );

  test(
    'identify response arriving after account switch cannot bind new events',
    () async {
      uid = 'alice';
      transport.identifyGate = Completer<Map<String, Object?>>();
      final identifying = analytics.identify();
      await Future<void>.delayed(Duration.zero);
      uid = 'bob';
      transport.identifyGate!.complete({
        'identity_id': 'identity-alice',
        'user_id': 'alice',
      });
      await identifying;
      await analytics.record('screen_viewed', {'screen': 'home'});
      expect((await store.batch(now)).last['identity_id'], isNull);
    },
  );

  test(
    'anonymous identify does not prevent identifying a subsequent login',
    () async {
      await analytics.identify();
      uid = 'alice';
      await analytics.identify();
      await analytics.record('screen_viewed', {'screen': 'home'});
      expect((await store.batch(now)).last['identity_id'], 'identity-alice');
    },
  );

  test('attribution ACK cannot erase a newer UID update', () async {
    await analytics.attribution(rawPayload: {'campaign': 'first'});
    final revision = store.pendingAttribution!['revision'];
    await analytics.attribution(appsflyerId: 'later-uid');
    await store.acknowledgeAttribution(revision);
    expect(store.pendingAttribution?['appsflyer_id'], 'later-uid');
  });

  test(
    'default 10000 record cap evicts oldest views before first open',
    () async {
      final first = (await store.batch(now)).first;
      await Hive.box<Map>('analytics_events_v1').putAll({
        for (var i = 2; i <= 10005; i++)
          i: {...first, 'event_id': 'view-$i', 'event_name': 'screen_viewed'},
      });
      final batch = await store.batch(now);
      expect(store.diagnostics['queued_events'], 10000);
      expect(store.diagnostics['dropped_overflow'], 6);
      expect(batch.first['event_name'], 'first_open');
      expect(batch.any((e) => e['event_id'] == 'view-2'), isFalse);
    },
  );

  test(
    'bootstrap retries with stable credentials and complete environment',
    () async {
      transport.failBootstrap = true;
      final context = store.context;
      await analytics.flush();
      expect(store.context['registered'], isNot(true));
      analytics.dispose();
      await Hive.close();
      await open();
      transport.failBootstrap = false;
      await analytics.flush();
      expect(transport.installations, hasLength(2));
      expect(transport.installations.first, transport.installations.last);
      expect(transport.installations.last, {
        'installation_id': context['installation_id'],
        'platform': 'ios',
        'environment': 'test',
        'app_version': '1.0.5+55',
      });
      expect(store.context['token'], context['token']);
    },
  );

  test(
    'checkout context preserves the queued attempt without secrets or UID',
    () async {
      uid = 'alice';
      await analytics.identify();
      await analytics.record('checkout_started', {
        'feature': 'subscription',
        'product_id': 'asteria_pro_month',
      });
      final event = (await store.batch(now)).last;
      final context = await analytics.checkoutContext(
        'asteria_pro_month',
        'alice',
      );
      expect(context?['attempt_id'], (event['payload'] as Map)['attempt_id']);
      expect(context?['identity_id'], event['identity_id']);
      expect(context?.keys.toSet(), {
        'installation_id',
        'session_id',
        'identity_id',
        'attempt_id',
      });
      uid = 'bob';
      expect(
        await analytics.checkoutContext('asteria_pro_month', 'alice'),
        isNull,
      );
    },
  );

  test(
    'test to production rotates analytics without replaying test history',
    () async {
      uid = 'alice';
      await analytics.attribution(
        appsflyerId: 'af-existing',
        rawPayload: {
          'data': {'media_source': 'test-campaign'},
        },
      );
      await analytics.flush();
      await analytics.claimFirstUsefulResult();
      await analytics.record('checkout_started', {'feature': 'subscription'});
      final old = store.context;
      final oldIds = (await store.batch(now)).map((e) => e['event_id']).toSet();
      transport = FakeTransport();
      analytics.dispose();
      analytics = DurableAnalytics(
        store: store,
        transport: transport,
        currentUid: () => uid,
        accessToken: (_) async => 'verified-token',
        platform: 'ios',
        appVersion: '2',
        environment: 'production',
        enabled: true,
        clock: () => now,
      );
      final mirrored = <String>[];
      analytics.onEventRecorded = (e) =>
          mirrored.add(e['event_name'] as String);
      await analytics.initialize();
      expect(store.context['installation_id'], isNot(old['installation_id']));
      expect(store.context['token'], isNot(old['token']));
      expect(store.context['identity_id'], isNull);
      expect(store.context['attempt_ids'], isNull);
      expect(await analytics.claimFirstUsefulResult(), false);
      await analytics.identify();
      await analytics.record('screen_viewed', {});
      await analytics.flush();
      expect(store.context['environment'], 'production');
      expect(transport.calls, contains('identify'));
      expect(transport.events, isNotEmpty);
      expect(
        transport.events.every((e) => e['environment'] == 'production'),
        true,
      );
      expect(
        transport.events.any((e) => oldIds.contains(e['event_id'])),
        false,
      );
      expect(mirrored, ['session_started', 'screen_viewed']);
      expect(transport.attributions.single['appsflyer_id'], 'af-existing');
      expect(
        transport.attributions.single['installation_id'],
        store.context['installation_id'],
      );
      expect(transport.attributions.single['raw_payload'], {
        'data': {'media_source': 'test-campaign'},
      });
      final replacement = store.context['installation_id'];
      await analytics.initialize();
      expect(store.context['installation_id'], replacement);
    },
  );

  for (final phase in ['journal', 'events', 'attribution', 'context']) {
    test(
      'production transition resumes after persisted $phase phase',
      () async {
        analytics.dispose();
        final contextBox = Hive.box<Map>('analytics_context_v1');
        final eventBox = Hive.box<Map>('analytics_events_v1');
        final attributionBox = Hive.box<Map>('analytics_attribution_v1');
        final replacement = {
          'installation_id': 'stable-replacement',
          'token': 'stable-replacement-token',
          'platform': 'ios',
          'environment': 'production',
          'first_open_done': true,
        };
        final attribution = {
          'appsflyer_id': 'af-existing',
          'raw_payload': {'af_status': 'Organic'},
          'revision': 'stable-revision',
        };
        await contextBox.put('production_transition', {
          'context': replacement,
          'attribution': attribution,
        });
        if (phase != 'journal') await eventBox.clear();
        if (phase == 'attribution' || phase == 'context') {
          await attributionBox.put('initial', attribution);
        }
        if (phase == 'context') {
          await contextBox.put('installation', replacement);
        }
        await Hive.close();
        store = await AnalyticsStore.open();
        analytics = DurableAnalytics(
          store: store,
          transport: transport,
          currentUid: () => null,
          accessToken: (_) async => null,
          platform: 'ios',
          appVersion: '2',
          environment: 'production',
          enabled: true,
          clock: () => now,
        );
        transport.failBootstrap = true;
        await analytics.initialize();
        await analytics.record('screen_viewed', {});
        await analytics.flush();
        expect(store.context['installation_id'], 'stable-replacement');
        expect(
          Hive.box<Map>('analytics_context_v1').get('production_transition'),
          isNull,
        );
        expect(transport.events, isEmpty);
        expect(await store.batch(now), hasLength(2));
        transport.failBootstrap = false;
        await analytics.flush();
        expect(transport.events.map((e) => e['event_name']), [
          'session_started',
          'screen_viewed',
        ]);
        expect(
          transport.events.every((e) => e['environment'] == 'production'),
          true,
        );
        expect(transport.attributions.single['raw_payload'], {
          'af_status': 'Organic',
        });
      },
    );
  }

  test(
    'transition preserves attribution quarantine and resends only its UID',
    () async {
      await analytics.attribution(
        appsflyerId: 'af-blocked',
        rawPayload: {'fixture': 'x' * 66000},
      );
      await analytics.flush();
      expect(store.pendingAttribution, isNull);
      analytics.dispose();
      transport = FakeTransport();
      analytics = DurableAnalytics(
        store: store,
        transport: transport,
        currentUid: () => null,
        accessToken: (_) async => null,
        platform: 'ios',
        appVersion: '2',
        environment: 'production',
        enabled: true,
        clock: () => now,
      );
      await analytics.initialize();
      await analytics.flush();
      expect(transport.attributions.single['appsflyer_id'], 'af-blocked');
      expect(transport.attributions.single['raw_payload'], isEmpty);
      expect(store.pendingAttribution, isNull);
      expect(store.diagnostics['attribution_blocked'], true);
    },
  );

  test(
    'transition without attribution does not invent one or replay pending first open',
    () async {
      final oldFirst = (await store.batch(now)).first;
      await store.updateContext({
        'first_open_done': false,
        'first_open_pending': oldFirst,
        'diagnostic_pending': oldFirst,
      });
      analytics.dispose();
      analytics = DurableAnalytics(
        store: store,
        transport: transport,
        currentUid: () => null,
        accessToken: (_) async => null,
        platform: 'ios',
        appVersion: '2',
        environment: 'production',
        enabled: true,
        clock: () => now,
      );
      await analytics.initialize();
      await analytics.flush();
      expect(transport.attributions, isEmpty);
      expect(transport.events.map((e) => e['event_name']), ['session_started']);
      expect(store.context['first_open_pending'], isNull);
      expect(store.context['diagnostic_pending'], isNull);
    },
  );

  for (final mismatch in ['reverse', 'platform', 'unknown']) {
    test(
      '$mismatch context mismatch stays blocked without deleting events',
      () async {
        analytics.dispose();
        await store.updateContext({
          if (mismatch == 'reverse') 'environment': 'production',
          if (mismatch == 'platform') 'platform': 'android',
          if (mismatch == 'unknown') 'environment': 'unknown',
        });
        final before = store.context;
        analytics = DurableAnalytics(
          store: store,
          transport: transport,
          currentUid: () => null,
          accessToken: (_) async => null,
          platform: 'ios',
          appVersion: '2',
          environment: mismatch == 'reverse' ? 'test' : 'production',
          enabled: true,
          clock: () => now,
        );
        await analytics.initialize();
        await analytics.record('screen_viewed', {});
        await analytics.flush();
        expect(store.context, before);
        expect(await store.batch(now), hasLength(2));
        expect(transport.calls, isEmpty);
      },
    );
  }

  test(
    'oversized diagnostic survives UID delivery failure without blocking product events',
    () async {
      transport.failAttribution = true;
      await analytics.attribution(
        appsflyerId: 'uid',
        rawPayload: {'campaign': List.filled(66000, 'a').join()},
      );
      await analytics.flush();
      expect(store.diagnostics['attribution_oversized'], 1);
      expect(await store.batch(now), isEmpty);
      transport.failAttribution = false;
      await analytics.flush();
      expect(transport.attributions.single['appsflyer_id'], 'uid');
      expect(store.pendingAttribution, isNull);
      expect(store.diagnostics['attribution_oversized'], 1);
    },
  );

  test(
    'oversized raw is quarantined visibly; UID and events still deliver',
    () async {
      final raw = {'campaign': List.filled(12000, '\u0416').join()};
      await analytics.attribution(appsflyerId: 'sdk-uid', rawPayload: raw);
      await analytics.flush();
      expect(await store.batch(now), isEmpty);
      expect(store.diagnostics['attribution_oversized'], 1);
      expect(store.diagnostics['attribution_blocked'], true);
      expect(store.pendingAttribution, isNull);
      expect(
        Hive.box<Map>(
          'analytics_attribution_v1',
        ).get('initial')!['raw_payload'],
        raw,
      );
      expect(transport.attributions.single['raw_payload'], isEmpty);
      await analytics.flush();
      expect(transport.attributions, hasLength(1));
      analytics.dispose();
      await Hive.close();
      await open();
      expect(store.diagnostics['attribution_blocked'], true);
      expect(store.pendingAttribution, isNull);
    },
  );

  test(
    'checkout attempt survives process restart and later identify',
    () async {
      uid = 'alice';
      await analytics.record('checkout_started', {'feature': 'subscription'});
      final start = (await store.batch(now)).last;
      await analytics.identify();
      analytics.dispose();
      await Hive.close();
      await open();
      await analytics.record('checkout_outcome', {
        'feature': 'subscription',
        'outcome': 'success',
      });
      expect(
        ((await store.batch(now)).last['payload'] as Map)['attempt_id'],
        (start['payload'] as Map)['attempt_id'],
      );
    },
  );

  test(
    'new session only after 30 minutes of absence, including restart',
    () async {
      final session = (await store.batch(now)).last['session_id'];
      await analytics.pause();
      now = now.add(const Duration(minutes: 29));
      await analytics.resume();
      await analytics.record('screen_viewed', {'screen': 'home'});
      expect((await store.batch(now)).last['session_id'], session);
      await analytics.pause();
      now = now.add(const Duration(minutes: 30));
      await analytics.resume();
      expect((await store.batch(now)).last['session_id'], isNot(session));
      expect(
        (await store.batch(
          now,
        )).where((e) => e['event_name'] == 'session_started'),
        hasLength(2),
      );
    },
  );

  test(
    'overflow evicts old views before conversion and counts expiry',
    () async {
      analytics.dispose();
      await Hive.close();
      await open(maxEvents: 3);
      await analytics.record('checkout_started', {'feature': 'subscription'});
      await analytics.record('screen_viewed', {'screen': 'home'});
      await analytics.record('screen_viewed', {'screen': 'shop'});
      expect(await store.batch(now), hasLength(3));
      expect(
        (await store.batch(
          now,
        )).any((e) => e['event_name'] == 'checkout_started'),
        isTrue,
      );
      expect(store.diagnostics['dropped_overflow'], 3);
      now = now.add(const Duration(days: 7, seconds: 1));
      expect(await store.batch(now), isEmpty);
      expect(store.diagnostics['dropped_expired'], 3);
      expect(store.context['installation_id'], isNotNull);
    },
  );

  test(
    'UTF8 bytes bounded and partial ACK removes only submitted accepted IDs',
    () async {
      analytics.dispose();
      await Hive.close();
      await open(maxBytes: 1400);
      for (var i = 0; i < 10; i++) {
        await analytics.record('screen_viewed', {'screen': 'home'});
      }
      expect(store.queuedBytes, lessThanOrEqualTo(1400));
      final batch = await store.batch(now);
      transport.acceptOnly = [batch.first['event_id'] as String, 'unknown'];
      await analytics.flush();
      expect((await store.batch(now)).length, batch.length - 1);
    },
  );

  test(
    'attribution UID and full callback persist independently of failed events',
    () async {
      transport.failEvents = true;
      transport.failAttribution = true;
      await analytics.attribution(appsflyerId: 'sdk-id');
      final raw = {
        'status': 'success',
        'data': {
          'campaign': 'original',
          'nested': [
            1,
            {'unknown': true},
          ],
        },
      };
      await analytics.attribution(rawPayload: raw);
      await analytics.flush();
      analytics.dispose();
      await Hive.close();
      await open();
      transport.failAttribution = false;
      await analytics.flush();
      expect(transport.attributions.last['raw_payload'], raw);
      expect(transport.attributions.last['appsflyer_id'], 'sdk-id');
      expect(await store.batch(now), isNotEmpty);
      expect(store.pendingAttribution, isNull);
    },
  );

  test('background events cannot shorten the users absence', () async {
    final session = (await store.batch(now)).last['session_id'];
    await analytics.pause();
    now = now.add(const Duration(minutes: 31));
    await analytics.record('checkout_outcome', {
      'feature': 'subscription',
      'outcome': 'pending',
    });
    await analytics.resume();
    expect((await store.batch(now)).last['session_id'], isNot(session));
  });

  test('disabled collection sends nothing and creates no first open', () async {
    analytics.dispose();
    await Hive.close();
    await directory.delete(recursive: true);
    directory = await Directory.systemTemp.createTemp('gmkt22-disabled');
    Hive.init(directory.path);
    store = await AnalyticsStore.open();
    analytics = DurableAnalytics(
      store: store,
      transport: transport,
      currentUid: () => null,
      accessToken: (_) async => null,
      platform: 'ios',
      appVersion: '1',
      environment: 'test',
      enabled: false,
    );
    await analytics.initialize();
    await analytics.record('screen_viewed', {'screen': 'home'});
    await analytics.flush();
    expect(await store.batch(now), isEmpty);
    expect(transport.calls, isEmpty);
  });

  test(
    'every batch is capped at 100 and concurrent flushes do not resend',
    () async {
      for (var i = 0; i < 105; i++) {
        await analytics.record('screen_viewed', {'screen': 'home'});
      }
      await Future.wait([analytics.flush(), analytics.flush()]);
      expect(transport.batchSizes, [100, 7]);
      expect(
        transport.events.map((e) => e['event_id']).toSet(),
        hasLength(107),
      );
      expect(await store.batch(now), isEmpty);
    },
  );

  test(
    'default 20 MiB bound counts UTF8, including oversized single records',
    () async {
      final event = Map<String, Object?>.from((await store.batch(now)).last);
      event['event_id'] = 'oversized-fixture';
      event['event_name'] = 'screen_viewed';
      event['payload'] = {
        'fixture': List.filled(11 * 1024 * 1024, '\u0430').join(),
      };
      await store.enqueue(event, now);
      expect(store.queuedBytes, lessThanOrEqualTo(20 * 1024 * 1024));
      expect(store.diagnostics['dropped_overflow'], 1);
      expect(await store.batch(now), hasLength(2));
    },
  );
}

class FakeTransport implements AnalyticsTransport {
  final calls = <String>[];
  final events = <Map<String, Object?>>[];
  final batchSizes = <int>[];
  final attributions = <Map<String, Object?>>[];
  final installations = <Map<String, Object?>>[];
  final deviceContexts = <Map<String, Object?>>[];
  bool failDeviceContext = false;
  bool failBootstrap = false;
  bool failEvents = false;
  bool failAttribution = false;
  List<String>? acceptOnly;
  Completer<Map<String, Object?>>? identifyGate;

  @override
  Future<Map<String, Object?>> post(
    String path,
    Map<String, Object?> body, {
    required String token,
    String? accessToken,
  }) async {
    calls.add(path);
    expect(token, isNotEmpty);
    if (path == 'device-context') {
      if (failDeviceContext) throw const AnalyticsDeliveryException(503);
      deviceContexts.add(body);
      return {'accepted': true};
    }
    if (path == 'installations') {
      installations.add(body);
      if (failBootstrap) throw const AnalyticsDeliveryException(503);
    }
    if (path == 'identify') {
      expect(accessToken, 'verified-token');
      return identifyGate?.future ??
          Future.value({
            'identity_id': calls.where((e) => e == 'identify').length == 1
                ? 'identity-alice'
                : 'identity-bob',
            'user_id': calls.where((e) => e == 'identify').length == 1
                ? 'alice'
                : 'bob',
          });
    }
    if (path == 'events/batch') {
      final submitted = (body['events'] as List).cast<Map<String, Object?>>();
      batchSizes.add(submitted.length);
      events.addAll(submitted);
      if (failEvents) throw const AnalyticsDeliveryException(503);
      return {
        'accepted_event_ids':
            acceptOnly ?? submitted.map((e) => e['event_id']).toList(),
      };
    }
    if (path == 'install-attribution') {
      if (failAttribution) throw const AnalyticsDeliveryException(503);
      attributions.add(body);
    }
    return {};
  }
}
