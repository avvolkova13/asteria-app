import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/ast_events.dart';
import 'package:asteria_app/core/analytics/dictionaries/failure_reason.dart';
import 'package:asteria_app/core/analytics/dictionaries/failure_stage.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _RecordingAnalyticsFacade facade;
  late ProductAnalyticsService analytics;

  setUp(() {
    facade = _RecordingAnalyticsFacade();
    analytics = ProductAnalyticsService(facade);
  });

  test('subscription manage click carries canonical context', () async {
    await analytics.trackSubscriptionManageClick(
      originSurface: 'subscription_screen',
      platform: 'ios',
      subscriptionState: 'active',
    );

    expect(facade.eventName, AstEvents.subscriptionManageClick);
    expect(facade.params, <String, dynamic>{
      EventParams.canonicalEvent: 'subscription_manage_click',
      EventParams.funnelType: 'subscription',
      EventParams.originSurface: 'subscription_screen',
      EventParams.platform: 'ios',
      EventParams.subscriptionState: 'active',
    });
  });

  test('coin purchase success carries AppsFlyer revenue metadata', () async {
    await analytics.trackCoinPurchaseSuccess(
      originSurface: 'coins_paywall',
      afRevenue: 49.9,
      afCurrency: 'RUB',
      packageId: 'coins_10',
      paymentProvider: 'apple',
      underlyingPaymentProvider: 'storekit',
    );

    expect(facade.eventName, AstEvents.coinPurchaseSuccess);
    expect(
      facade.params,
      containsPair(EventParams.canonicalEvent, 'purchase_success'),
    );
    expect(facade.params, containsPair(EventParams.funnelType, 'coins'));
    expect(facade.params, containsPair(EventParams.afRevenue, 49.9));
    expect(facade.params, containsPair(EventParams.afCurrency, 'RUB'));
    expect(facade.params, containsPair(EventParams.packageId, 'coins_10'));
    expect(facade.params, containsPair(EventParams.paymentProvider, 'apple'));
    expect(
      facade.params,
      containsPair(EventParams.underlyingPaymentProvider, 'storekit'),
    );
  });

  test('coin purchase failure uses controlled failure metadata', () async {
    await analytics.trackCoinPurchaseFailed(
      originSurface: 'coins_paywall',
      failureReason: FailureReasons.serverError,
      failureStage: FailureStages.confirmation,
      packageId: 'coins_10',
      price: 49.9,
      afCurrency: 'RUB',
      paymentProvider: 'google',
      underlyingPaymentProvider: 'play_billing',
    );

    expect(facade.eventName, AstEvents.coinPurchaseFailed);
    expect(
      facade.params,
      containsPair(EventParams.canonicalEvent, 'purchase_failed'),
    );
    expect(facade.params, containsPair(EventParams.funnelType, 'coins'));
    expect(
      facade.params,
      containsPair(EventParams.failureReason, FailureReasons.serverError),
    );
    expect(
      facade.params,
      containsPair(EventParams.failureStage, FailureStages.confirmation),
    );
    expect(facade.params, containsPair(EventParams.price, 49.9));
    expect(facade.params, containsPair(EventParams.afCurrency, 'RUB'));
  });

  test('subscription start and success keep selected plan metadata', () async {
    await analytics.trackSubscriptionPurchaseStart(
      originSurface: 'subscription_screen',
      planId: 'pro_yearly',
      price: 1990,
      afCurrency: 'RUB',
      paymentProvider: 'apple',
      underlyingPaymentProvider: 'storekit',
    );

    expect(facade.eventName, AstEvents.subscriptionPurchaseStart);
    expect(facade.params, containsPair(EventParams.planId, 'pro_yearly'));
    expect(facade.params, containsPair(EventParams.price, 1990));
    expect(facade.params, containsPair(EventParams.afCurrency, 'RUB'));

    await analytics.trackSubscriptionPurchaseSuccess(
      originSurface: 'subscription_screen',
      afRevenue: 1990,
      afCurrency: 'RUB',
      planId: 'pro_yearly',
      paymentProvider: 'apple',
      underlyingPaymentProvider: 'storekit',
    );

    expect(facade.eventName, AstEvents.subscriptionPurchaseSuccess);
    expect(
      facade.params,
      containsPair(EventParams.canonicalEvent, 'purchase_success'),
    );
    expect(facade.params, containsPair(EventParams.funnelType, 'subscription'));
    expect(facade.params, containsPair(EventParams.afRevenue, 1990));
    expect(facade.params, containsPair(EventParams.afCurrency, 'RUB'));
    expect(facade.params, containsPair(EventParams.planId, 'pro_yearly'));
  });
}

class _RecordingAnalyticsFacade implements AnalyticsFacade {
  String? eventName;
  Map<String, dynamic>? params;

  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    eventName = name;
    this.params = params;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
