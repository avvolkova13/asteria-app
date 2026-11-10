import 'package:asteria_app/core/payments/apple/apple_purchase_coordinator.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/durable/native_checkout_analytics.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Apple restore error closes operation and permits a new correlated restore',
    () {
      final facade = RecordingFacade();
      final analytics = NativeCheckoutAnalytics(facade);
      analytics.onState(const PaywallRestoring());
      analytics.onState(
        const PaywallAppleStatus('', ApplePurchasePhase.error, 'offline'),
      );
      analytics.onState(const PaywallRestoring());
      analytics.onState(const PaywallRestored(['asteria_pro_month']));
      expect(facade.events.map((e) => e['name']), [
        'restore_started',
        'restore_outcome',
        'restore_started',
        'restore_outcome',
      ]);
      expect(facade.events[1]['outcome'], 'failed');
      expect(facade.events[3]['outcome'], 'success');
      expect(facade.events[1]['restore_id'], facade.events[0]['restore_id']);
      expect(facade.events[3]['restore_id'], facade.events[2]['restore_id']);
      expect(
        facade.events[0]['restore_id'],
        isNot(facade.events[2]['restore_id']),
      );
    },
  );
  test(
    'Apple errors and account action report failed checkout, approval stays pending',
    () {
      final facade = RecordingFacade();
      final analytics = NativeCheckoutAnalytics(facade);
      for (final phase in [
        ApplePurchasePhase.error,
        ApplePurchasePhase.accountAction,
        ApplePurchasePhase.approval,
      ]) {
        analytics.onState(const PaywallPurchasing('asteria_stars_10'));
        analytics.onState(
          PaywallAppleStatus('asteria_stars_10', phase, 'offline'),
        );
      }
      expect(facade.outcomes, ['failed', 'failed', 'pending']);
    },
  );
  test('repeated pending state is one outcome per purchase attempt', () {
    final facade = RecordingFacade();
    final analytics = NativeCheckoutAnalytics(facade);
    analytics.onState(const PaywallPurchasing('asteria_stars_10'));
    analytics.onState(const PaywallPending('asteria_stars_10'));
    analytics.onState(const PaywallVerifying('asteria_stars_10'));
    analytics.onState(const PaywallPending('asteria_stars_10'));
    analytics.onState(
      const PaywallFailed(
        PaywallFailureCode.purchaseFailed,
        productId: 'asteria_stars_10',
      ),
    );
    analytics.onState(const PaywallPurchasing('asteria_stars_10'));
    analytics.onState(const PaywallPending('asteria_stars_10'));
    expect(facade.outcomes, ['pending', 'failed', 'pending']);
  });

  test('authentication failure before purchasing is still an outcome', () {
    final facade = RecordingFacade();
    final analytics = NativeCheckoutAnalytics(facade);
    analytics.onState(
      const PaywallFailed(
        PaywallFailureCode.notAuthenticated,
        productId: 'asteria_stars_10',
      ),
    );
    expect(facade.outcomes, ['failed']);
  });

  test(
    'native pending and cancellation are outcomes; restore is not checkout',
    () {
      final facade = RecordingFacade();
      final analytics = NativeCheckoutAnalytics(facade);
      analytics.onState(const PaywallPurchasing('asteria_pro_month'));
      analytics.onState(const PaywallPending('asteria_pro_month'));
      analytics.onState(
        const PaywallFailed(
          PaywallFailureCode.canceled,
          productId: 'asteria_pro_month',
        ),
      );
      analytics.onState(const PaywallRestored(['asteria_pro_month']));
      analytics.onState(const PaywallPending('restore'));
      analytics.onState(const PaywallFailed(PaywallFailureCode.restoreFailed));
      expect(facade.outcomes, ['pending', 'cancelled']);
    },
  );
}

class RecordingFacade implements AnalyticsFacade {
  final outcomes = <Object?>[];
  final events = <Map<String, dynamic>>[];
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    events.add({'name': name, ...?params});
    if (name == 'checkout_outcome') outcomes.add(params?['outcome']);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
