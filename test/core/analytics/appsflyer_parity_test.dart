import 'dart:io';

import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/durable/analytics_store.dart';
import 'package:asteria_app/core/analytics/durable/durable_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'analytics_integration_test.dart' show RecordingSdk;
import 'durable_analytics_test.dart' show FakeTransport;

void main() {
  late Directory directory;
  late AnalyticsStore store;
  late DurableAnalytics analytics;
  late AnalyticsFacade facade;
  late RecordingSdk sdk;
  late FakeTransport transport;
  late DateTime now;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('asteria-af-parity');
    Hive.init(directory.path);
    store = await AnalyticsStore.open();
    sdk = RecordingSdk()..gate.complete(true);
    transport = FakeTransport();
    now = DateTime.utc(2026, 9, 16, 12);
    analytics = DurableAnalytics(
      store: store,
      transport: transport,
      currentUid: () => null,
      accessToken: (_) async => null,
      platform: 'ios',
      appVersion: '1.0.5+59',
      environment: 'test',
      enabled: true,
      clock: () => now,
    );
    facade = AnalyticsFacade(
      appsFlyerService: sdk,
      durableAnalytics: analytics,
    );
    await analytics.initialize();
  });

  tearDown(() async {
    analytics.dispose();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'AF-only fields survive without widening the warehouse payload',
    () async {
      await facade.trackEvent(
        'ast_anakra_message_sent',
        params: {
          'message_length_band': 'short',
          'entry_surface': 'home',
          'message_index': 2,
          'email': 'private',
        },
      );
      expect(sdk.params.last['message_length_band'], 'short');
      expect(sdk.params.last['entry_surface'], 'home');
      expect(
        (await store.batch(now)).last['payload'],
        isNot(contains('message_length_band')),
      );
      expect(
        (await store.batch(now)).last['payload'],
        isNot(contains('entry_surface')),
      );
    },
  );

  test(
    'existing AF checkout and paywall survive disabled first-party collection',
    () async {
      analytics.dispose();
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
      facade = AnalyticsFacade(
        appsFlyerService: sdk,
        durableAnalytics: analytics,
      );
      sdk.events.clear();
      await facade.trackEvent('ast_subscription_paywall_view');
      await facade.trackEvent('ast_subscription_purchase_start');
      expect(sdk.events, ['ast_paywall_view', 'af_initiated_checkout']);
      expect((await store.batch(now)).length, 2);
    },
  );

  test(
    'crash recovery of pending first open is not mirrored as a new AF fact',
    () async {
      final original = (await store.batch(now)).first;
      await store.updateContext({
        'first_open_done': false,
        'first_open_pending': original,
      });
      sdk.events.clear();
      await analytics.initialize();
      expect(sdk.events, isNot(contains('ast_first_open')));
      expect(
        (await store.batch(now)).where((e) => e['event_name'] == 'first_open'),
        hasLength(1),
      );
    },
  );

  test(
    'observer failures cannot mutate or interrupt the durable channel',
    () async {
      analytics.onEventRecorded = (event) {
        expect(
          () => (event['payload'] as Map)['feature'] = 'tampered',
          throwsUnsupportedError,
        );
        expect(() => event['event_name'] = 'tampered', throwsUnsupportedError);
        throw StateError('observer unavailable');
      };
      await analytics.record('feature_action_started', {'feature': 'sonnik'});
      await analytics.record('feature_result_viewed', {'feature': 'sonnik'});
      final before = await store.batch(now);
      expect(before.map((e) => e['event_name']), [
        'first_open',
        'session_started',
        'feature_action_started',
        'feature_result_viewed',
      ]);
      transport.failEvents = true;
      await analytics.flush();
      expect(await store.batch(now), before);
      transport.failEvents = false;
      await analytics.flush();
      expect(await store.batch(now), isEmpty);
      expect(before.last['payload'], containsPair('feature', 'sonnik'));
    },
  );

  test('pending warehouse events never replay into AF after restart', () async {
    await facade.trackEvent(
      'ast_screen_view',
      params: {'screen_name': '/home/profile'},
    );
    final before = await store.batch(now);
    analytics.dispose();
    await Hive.close();
    store = await AnalyticsStore.open();
    sdk.events.clear();
    analytics = DurableAnalytics(
      store: store,
      transport: transport,
      currentUid: () => null,
      accessToken: (_) async => null,
      platform: 'ios',
      appVersion: '1.0.5+59',
      environment: 'test',
      enabled: true,
      clock: () => now,
    );
    facade = AnalyticsFacade(
      appsFlyerService: sdk,
      durableAnalytics: analytics,
    );
    await analytics.initialize();
    await analytics.flush();
    expect(sdk.events, isEmpty);
    expect(transport.events, before);
  });

  test(
    'lifecycle mirrors actual first-open and session boundaries, not replay',
    () async {
      expect(sdk.events, ['ast_first_open', 'ast_app_open']);
      await facade.trackEvent('ast_app_open');
      await analytics.pause();
      now = now.add(const Duration(minutes: 5));
      await analytics.resume();
      expect(sdk.events, ['ast_first_open', 'ast_app_open']);
      await analytics.pause();
      now = now.add(const Duration(minutes: 31));
      await analytics.resume();
      expect(sdk.events, ['ast_first_open', 'ast_app_open', 'ast_app_open']);
      final beforeFlush = List<String>.from(sdk.events);
      await analytics.flush();
      await analytics.flush();
      expect(sdk.events, beforeFlush);
      expect(transport.events.map((e) => e['event_name']), [
        'first_open',
        'session_started',
        'session_started',
      ]);
    },
  );

  test('specific screen and existing paywall own their aliases', () async {
    sdk.events.clear();
    sdk.params.clear();
    await facade.trackEvent('ast_profile_view');
    await facade.trackEvent(
      'ast_screen_view',
      params: {'screen_name': '/home/profile'},
    );
    await facade.trackEvent('ast_subscription_paywall_view');
    await facade.trackEvent(
      'ast_screen_view',
      params: {'screen_name': '/settings'},
    );
    expect(sdk.events, [
      'ast_profile_view',
      'ast_paywall_view',
      'ast_settings_view',
    ]);
    expect(sdk.events, isNot(contains('screen_viewed')));
    expect(sdk.events, isNot(contains('ast_subscription_paywall_view')));
    final product = (await store.batch(now)).skip(2).toList();
    expect(product.map((e) => e['event_name']), [
      'screen_viewed',
      'paywall_viewed',
      'screen_viewed',
    ]);
    expect(product.first['payload'], {'screen': '/home/profile'});
    expect(product.last['payload'], {'screen': '/settings'});
    expect(sdk.params.first, isNot(contains('screen')));
    expect(sdk.params.last, isNot(contains('screen')));
  });

  for (final enabled in [true, false]) {
    test(
      'screen names preserve warehouse data with collection=$enabled',
      () async {
        analytics.dispose();
        analytics = DurableAnalytics(
          store: store,
          transport: transport,
          currentUid: () => null,
          accessToken: (_) async => null,
          platform: 'ios',
          appVersion: '1',
          environment: 'test',
          enabled: enabled,
          clock: () => now,
        );
        await analytics.initialize();
        facade = AnalyticsFacade(
          appsFlyerService: sdk,
          durableAnalytics: analytics,
        );
        sdk.events.clear();
        sdk.params.clear();
        for (final screen in [
          '/settings',
          '/balance-history',
          '/auth/email/code',
        ]) {
          await facade.trackEvent(
            'ast_screen_view',
            params: {'screen_name': screen},
          );
        }
        await facade.trackEvent(
          'ast_subscription_paywall_view',
          params: {'screen_name': '/subscription'},
        );
        expect(sdk.events, [
          'ast_settings_view',
          'ast_balance_history_view',
          'ast_auth_email_code_view',
          'ast_paywall_view',
        ]);
        for (final params in sdk.params.take(3)) {
          expect(params, isNot(contains('screen')));
          expect(params, isNot(contains('screen_name')));
        }
        expect(sdk.params.last, containsPair('screen', '/subscription'));
        final product = (await store.batch(now)).skip(2).toList();
        if (enabled) {
          expect(
            product.take(3).map((e) => e['event_name']),
            everyElement('screen_viewed'),
          );
          expect(product.take(3).map((e) => e['payload']), [
            {'screen': '/settings'},
            {'screen': '/balance-history'},
            {'screen': '/auth/email/code'},
          ]);
        } else {
          expect(product, isEmpty);
        }
        final sent = List<String>.of(sdk.events);
        await analytics.flush();
        await analytics.flush();
        expect(sdk.events, sent);
      },
    );
  }

  test(
    'auto-selected offer, checkout and restore mirror without client money',
    () async {
      sdk.events.clear();
      sdk.params.clear();
      await facade.trackEvent(
        'ast_subscription_purchase_start',
        params: {'plan_id': 'asteria_pro_month', 'af_revenue': 4.99},
      );
      await facade.trackEvent(
        'ast_subscription_purchase_success',
        params: {'plan_id': 'asteria_pro_month', 'af_revenue': 4.99},
      );
      const restoreId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
      await facade.trackEvent(
        'restore_started',
        params: {'restore_id': restoreId},
      );
      await facade.trackEvent(
        'restore_outcome',
        params: {
          'restore_id': restoreId,
          'outcome': 'empty',
          'restored_count': 0,
        },
      );
      expect(sdk.events, [
        'ast_subscription_plan_select',
        'af_initiated_checkout',
        'ast_checkout_outcome',
        'ast_purchase_restore_click',
        'ast_purchase_restore_empty',
      ]);
      expect(sdk.params.every((p) => !p.containsKey('af_revenue')), isTrue);
      expect(sdk.params[1]['attempt_id'], sdk.params[2]['attempt_id']);
      expect(sdk.params[1]['attempt_id'], isNotNull);
      expect(sdk.params[3]['restore_id'], restoreId);
      expect(sdk.params[4]['outcome'], 'empty');
      final product = (await store.batch(now)).skip(2).toList();
      expect(product.map((e) => e['event_name']), [
        'offer_selected',
        'checkout_started',
        'checkout_outcome',
        'restore_started',
        'restore_outcome',
      ]);
      expect(
        product.every((e) => !(e['payload'] as Map).containsKey('af_revenue')),
        isTrue,
      );
    },
  );

  test(
    'extra actions go only to AF; rejected result aliases remain rejected',
    () async {
      sdk.events.clear();
      sdk.params.clear();
      await facade.trackEvent(
        'ast_home_card_click',
        params: {
          'entry_point_id': 'sonnik',
          'email': 'private@example.test',
          'dream': 'private',
        },
      );
      await facade.trackEvent(
        'ast_profile_menu_click',
        params: {'menu_item': 'settings'},
      );
      await facade.trackEvent(
        'ast_sonnik_generation_complete',
        params: {'generation_status': 'success'},
      );
      await facade.trackEvent('ast_tarot_card_reveal');
      await facade.trackEvent('ast_runes_reveal');
      await facade.trackEvent(
        'ast_anakra_response_view',
        params: {'result_status': 'greeting'},
      );
      await facade.trackEvent('ast_activation_complete');
      await facade.trackEvent('af_purchase', params: {'af_revenue': 4.99});
      expect(sdk.events, [
        'ast_home_card_click',
        'ast_profile_menu_click',
        'ast_sonnik_generation_complete',
      ]);
      expect(sdk.params.toString(), isNot(contains('private')));
      expect(sdk.params[0]['entry_point_id'], 'sonnik');
      expect(sdk.params[1]['menu_item'], 'settings');
      expect((await store.batch(now)).length, 2);
    },
  );
}
