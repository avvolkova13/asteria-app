import 'dart:async';

import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/payments/apple/apple_purchase_coordinator.dart';
import 'package:asteria_app/core/payments/catalog/product_catalog.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_state.dart';
import 'package:uuid/uuid.dart';

/// Native success/start signals already come from the purchase UI. These are
/// the missing non-revenue outcomes from the native state machine.
class NativeCheckoutAnalytics {
  NativeCheckoutAnalytics(this._facade);
  final AnalyticsFacade _facade;
  String? _activeProduct;
  bool _pendingReported = false;
  String? _restoreId;

  void onState(PaywallState state) {
    final appleFailed =
        state is PaywallAppleStatus &&
        (state.phase == ApplePurchasePhase.error ||
            state.phase == ApplePurchasePhase.accountAction);
    if (state is PaywallRestoring) {
      if (_restoreId != null) return;
      _activeProduct = null;
      _restoreId = const Uuid().v4();
      unawaited(
        _facade.trackEvent(
          'restore_started',
          params: {'restore_id': _restoreId},
        ),
      );
      return;
    }
    if (_restoreId != null &&
        (state is PaywallRestored || state is PaywallFailed || appleFailed)) {
      final count = state is PaywallRestored
          ? state.restoredProductIds.toSet().length
          : 0;
      unawaited(
        _facade.trackEvent(
          'restore_outcome',
          params: {
            'restore_id': _restoreId,
            'outcome': state is PaywallFailed || appleFailed
                ? 'failed'
                : count == 0
                ? 'empty'
                : 'success',
            if (state is PaywallRestored) 'restored_count': count,
          },
        ),
      );
      _restoreId = null;
      return;
    }
    if (state is PaywallPurchasing) {
      _activeProduct = state.productId;
      _pendingReported = false;
    } else if (appleFailed &&
        _activeProduct != null &&
        (state.productId.isEmpty || state.productId == _activeProduct)) {
      _outcome('failed');
      _activeProduct = null;
    } else if (state is PaywallPending && state.productId == _activeProduct) {
      if (!_pendingReported) {
        _outcome('pending');
        _pendingReported = true;
      }
    } else if (state is PaywallFailed &&
        state.code == PaywallFailureCode.notAuthenticated &&
        ProductCatalog.allIds.contains(state.productId)) {
      // The cubit rejects a signed-out purchase before emitting Purchasing.
      _activeProduct = state.productId;
      _outcome('failed');
      _activeProduct = null;
    } else if (state is PaywallFailed &&
        _activeProduct != null &&
        (state.productId == null || state.productId == _activeProduct) &&
        state.code != PaywallFailureCode.productsLoad &&
        state.code != PaywallFailureCode.restoreFailed) {
      _outcome(
        state.code == PaywallFailureCode.canceled ? 'cancelled' : 'failed',
      );
      _activeProduct = null;
    } else if (state is PaywallSuccess || state is PaywallRestored) {
      _activeProduct = null;
    }
  }

  void _outcome(String outcome) {
    unawaited(
      _facade.trackEvent(
        'checkout_outcome',
        params: {
          'feature': ProductCatalog.subscriptionIds.contains(_activeProduct)
              ? 'subscription'
              : 'stars',
          'product_id': _activeProduct,
          'outcome': outcome,
        },
      ),
    );
  }
}
