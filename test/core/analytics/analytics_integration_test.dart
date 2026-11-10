import 'dart:async';
import 'dart:io';

import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/analytics_route_observer.dart';
import 'package:asteria_app/core/analytics/durable/analytics_store.dart';
import 'package:asteria_app/core/analytics/durable/durable_analytics.dart';
import 'package:asteria_app/core/analytics/durable/native_checkout_analytics.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_state.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/services/apps_flyer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import 'durable_analytics_test.dart' show FakeTransport;

void main() {
  test(
    'restore correlation survives storage and AF without checkout or revenue',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'asteria-restore',
      );
      Hive.init(directory.path);
      final store = await AnalyticsStore.open();
      final analytics = DurableAnalytics(
        store: store,
        transport: FakeTransport(),
        currentUid: () => 'alice',
        accessToken: (_) async => null,
        platform: 'ios',
        appVersion: '1',
        environment: 'test',
        enabled: true,
      );
      addTearDown(() async {
        analytics.dispose();
        await Hive.close();
        await directory.delete(recursive: true);
      });
      await analytics.initialize();
      final sdk = RecordingSdk()..gate.complete(true);
      final facade = AnalyticsFacade(
        appsFlyerService: sdk,
        durableAnalytics: analytics,
      );
      final native = NativeCheckoutAnalytics(facade);
      native.onState(const PaywallRestoring());
      native.onState(const PaywallRestoring());
      native.onState(const PaywallRestored([]));
      native.onState(const PaywallRestored([]));
      // Drain the same serialized local queue used by facade.record.
      await analytics.record('screen_viewed', {'screen': '/subscription'});
      final events = (await store.batch(DateTime.now().toUtc()))
          .where((e) => (e['event_name'] as String).startsWith('restore_'))
          .toList();
      expect(events.map((e) => e['event_name']), [
        'restore_started',
        'restore_outcome',
      ]);
      final start = events.first['payload'] as Map;
      final finish = events.last['payload'] as Map;
      expect(start['restore_id'], isNotNull);
      expect(finish, {
        'restore_id': start['restore_id'],
        'outcome': 'empty',
        'restored_count': 0,
      });
      native.onState(const PaywallRestoring());
      native.onState(const PaywallFailed(PaywallFailureCode.restoreFailed));
      await analytics.record('screen_viewed', {'screen': '/subscription'});
      final retry = (await store.batch(
        DateTime.now().toUtc(),
      )).where((e) => e['event_name'] == 'restore_outcome').last;
      expect(
        (retry['payload'] as Map)['restore_id'],
        isNot(start['restore_id']),
      );
      expect((retry['payload'] as Map)['outcome'], 'failed');
      expect(
        (await store.batch(DateTime.now().toUtc())).any(
          (e) =>
              (e['event_name'] as String).startsWith('checkout_') ||
              e['event_name'] == 'payment_succeeded',
        ),
        isFalse,
      );
      expect(sdk.events, [
        'ast_purchase_restore_click',
        'ast_purchase_restore_empty',
        'ast_subscription_view',
        'ast_purchase_restore_click',
        'ast_purchase_restore_failed',
        'ast_subscription_view',
      ]);
      expect(
        sdk.params.every((params) => !params.containsKey('af_revenue')),
        isTrue,
      );
    },
  );
  test(
    'UI checkout order and context claim never reuse a previous purchase',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'gmkt22-checkout-order',
      );
      Hive.init(directory.path);
      final store = await AnalyticsStore.open();
      final analytics = DurableAnalytics(
        store: store,
        transport: FakeTransport(),
        currentUid: () => 'alice',
        accessToken: (_) async => null,
        platform: 'ios',
        appVersion: '1',
        environment: 'test',
        enabled: true,
      );
      await analytics.initialize();
      final sdk = RecordingSdk()..gate.complete(true);
      final facade = AnalyticsFacade(
        appsFlyerService: sdk,
        durableAnalytics: analytics,
      );
      final product = ProductAnalyticsService(facade);
      final native = NativeCheckoutAnalytics(facade);
      // Same synchronous call order as _IosSubscriptionPlansState._purchase.
      product.trackSubscriptionPaywallView(originSurface: 'profile');
      product.trackSubscriptionPurchaseStart(
        originSurface: 'profile',
        planId: 'asteria_pro_month',
        price: 4.99,
        afCurrency: 'USD',
      );
      native.onState(const PaywallPurchasing('asteria_pro_month'));
      final first = await analytics.checkoutContext(
        'asteria_pro_month',
        'alice',
      );
      var events = (await store.batch(DateTime.now().toUtc())).skip(2).toList();
      expect(events.map((e) => e['event_name']), [
        'paywall_viewed',
        'offer_selected',
        'checkout_started',
      ]);
      for (final event in events.skip(1)) {
        expect((event['payload'] as Map)['price'], 4.99);
        expect((event['payload'] as Map)['currency'], 'USD');
      }
      final selectionIndex = sdk.events.indexOf('ast_subscription_plan_select');
      expect(selectionIndex, greaterThanOrEqualTo(0));
      expect(sdk.params[selectionIndex]['price'], 4.99);
      expect(sdk.params[selectionIndex]['currency'], 'USD');
      expect(sdk.params[selectionIndex].containsKey('af_revenue'), isFalse);
      expect(
        (events.last['payload'] as Map)['attempt_id'],
        first?['attempt_id'],
      );
      final next = await analytics.checkoutContext(
        'asteria_pro_month',
        'alice',
      );
      expect(next?['attempt_id'], isNot(first?['attempt_id']));
      // Explicit selection does not get repeated by purchase or Purchasing state.
      await product.trackSubscriptionPlanSelect(planId: 'asteria_pro_year');
      await product.trackSubscriptionPurchaseStart(
        originSurface: 'profile',
        planId: 'asteria_pro_year',
      );
      native.onState(const PaywallPurchasing('asteria_pro_year'));
      final yearly = await analytics.checkoutContext(
        'asteria_pro_year',
        'alice',
      );
      expect(yearly?['attempt_id'], isNot(next?['attempt_id']));
      events = (await store.batch(DateTime.now().toUtc())).skip(2).toList();
      expect(
        events.where((e) => e['event_name'] == 'checkout_started'),
        hasLength(3),
      );
      expect(
        events.where((e) => e['event_name'] == 'offer_selected'),
        hasLength(2),
      );
      await analytics.record('checkout_started', {
        'feature': 'subscription',
        'product_id': 'asteria_pro_month',
      });
      final different = await analytics.checkoutContext(
        'asteria_pro_year',
        'alice',
      );
      events = await store.batch(DateTime.now().toUtc());
      expect((events.last['payload'] as Map)['product_id'], 'asteria_pro_year');
      expect(
        different?['attempt_id'],
        (events.last['payload'] as Map)['attempt_id'],
      );
      analytics.dispose();
      await Hive.close();
      await directory.delete(recursive: true);
    },
  );
  test(
    'first useful result is once per installation, never profile completion',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'gmkt22-activation',
      );
      Hive.init(directory.path);
      final sdk = RecordingSdk();
      sdk.gate.complete(true);
      final transport = FakeTransport();
      for (var launch = 0; launch < 2; launch++) {
        final store = await AnalyticsStore.open();
        final analytics = DurableAnalytics(
          store: store,
          transport: transport,
          currentUid: () => launch == 0 ? 'alice' : 'bob',
          accessToken: (_) async => 'verified-token',
          platform: 'ios',
          appVersion: '1',
          environment: 'test',
          enabled: true,
        );
        await analytics.initialize();
        final facade = AnalyticsFacade(
          appsFlyerService: sdk,
          durableAnalytics: analytics,
        );
        await facade.trackEvent('signup_completed');
        await facade.trackEvent('profile_completed');
        await Future.wait(
          List.generate(3, (_) => facade.trackEvent('ast_activation_complete')),
        );
        if (launch == 0) expect(sdk.events, isEmpty);
        await facade.trackEvent(
          'ast_sonnik_generation_complete',
          params: {'generation_status': 'failed'},
        );
        await facade.trackEvent('ast_subscription_paywall_view');
        await Future.wait(
          List.generate(3, (_) => facade.trackEvent('ast_sonnik_result_view')),
        );
        await analytics.identify();
        expect(store.context['identity_id'], isNotNull);
        analytics.dispose();
        await Hive.close();
      }
      expect(
        sdk.events.where((e) => e == 'ast_first_useful_result'),
        hasLength(1),
      );
      expect(sdk.events.where((e) => e == 'ast_paywall_view'), hasLength(2));
      expect(sdk.events, isNot(contains('ast_activation_complete')));
      await directory.delete(recursive: true);
    },
  );

  test(
    'facade persists immediately while SDK marketing hangs; money never reaches SDK',
    () async {
      final directory = await Directory.systemTemp.createTemp('gmkt22-facade');
      Hive.init(directory.path);
      final store = await AnalyticsStore.open();
      final analytics = DurableAnalytics(
        store: store,
        transport: FakeTransport(),
        currentUid: () => null,
        accessToken: (_) async => null,
        platform: 'android',
        appVersion: '1',
        environment: 'test',
        enabled: true,
      );
      await analytics.initialize();
      final sdk = RecordingSdk();
      final facade = AnalyticsFacade(
        appsFlyerService: sdk,
        durableAnalytics: analytics,
      );
      final product = ProductAnalyticsService(facade);
      await product.trackAstEvent('ast_subscription_purchase_start', {
        'af_revenue': 999,
      });
      await product.trackAstEvent('ast_subscription_purchase_success', {
        'af_revenue': 999,
      });
      await facade.trackEvent('af_purchase', params: {'af_revenue': 999});
      final events = await store.batch(DateTime.now().toUtc());
      expect(
        events.map((e) => e['event_name']),
        containsAll(['checkout_started', 'checkout_outcome']),
      );
      expect(sdk.events, [
        'ast_subscription_plan_select',
        'af_initiated_checkout',
        'ast_checkout_outcome',
      ]);
      expect(
        sdk.params.every((params) => !params.containsKey('af_revenue')),
        isTrue,
      );
      expect(
        (events.last['payload'] as Map)['attempt_id'],
        (events.firstWhere(
              (e) => e['event_name'] == 'checkout_started',
            )['payload']
            as Map)['attempt_id'],
      );
      await expectLater(
        facade.runFeatureAction(
          'tarot',
          () async => throw StateError('private text'),
        ),
        throwsStateError,
      );
      final failed = (await store.batch(
        DateTime.now().toUtc(),
      )).sublist(events.length);
      expect(failed.map((e) => e['event_name']), [
        'feature_action_started',
        'feature_action_failed',
      ]);
      expect(
        (failed.first['payload'] as Map)['attempt_id'],
        (failed.last['payload'] as Map)['attempt_id'],
      );
      expect(failed.toString(), isNot(contains('private text')));
      analytics.dispose();
      sdk.gate.complete(true);
      await Hive.close();
      await directory.delete(recursive: true);
    },
  );

  testWidgets(
    'route views cover unnamed Pages, pop and replace without query text',
    (tester) async {
      final views = <String>[];
      final observer = AnalyticsRouteObserver(
        onScreen: (screen, previous) => views.add(screen),
      );
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          for (final name in ['/home', '/home/profile', '/shop', '/settings'])
            GoRoute(
              path: name,
              name: name,
              pageBuilder: (_, state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: const SizedBox(),
              ),
            ),
        ],
      );
      observer.attach(router);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      router.push('/shop?private=secret');
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      router.go('/settings');
      await tester.pumpAndSettle();
      expect(views, ['/home', '/shop', '/home', '/settings']);
      router.go('/home');
      await tester.pumpAndSettle();
      observer.homeTab(3);
      observer.homeTab(3);
      router.push('/home/profile');
      await tester.pumpAndSettle();
      router.push('/shop');
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      expect(views.sublist(4), [
        '/home',
        '/home/practices',
        '/home/profile',
        '/shop',
        '/home/profile',
        '/home/practices',
      ]);
      router.go('/settings');
      await tester.pumpAndSettle();
      router.go('/home');
      await tester.pumpAndSettle();
      expect(
        views.last,
        '/home',
        reason: 'A recreated Home starts on its first tab',
      );
      observer.detach();
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    },
  );
}

class RecordingSdk implements AppsFlyerService {
  final events = <String>[];
  final params = <Map<String, dynamic>>[];
  final gate = Completer<bool>();
  @override
  Future<bool?> logEvent(String name, Map<String, dynamic>? values) {
    events.add(name);
    params.add(values ?? {});
    return gate.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
