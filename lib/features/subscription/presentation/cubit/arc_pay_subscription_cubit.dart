import 'dart:async';

import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/payments/api/arc_pay_subscriptions_api.dart';
import 'package:asteria_app/core/payments/storage/arc_pay_pending_subscription_store.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/arc_pay_subscription_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class ArcPaySubscriptionCubit extends Cubit<ArcPaySubscriptionState> {
  final ArcPaySubscriptionsApi _api;
  final ArcPayPendingSubscriptionStore _store;
  final Future<void> Function() _refreshUser;
  final String? Function() _currentUserId;
  final Duration pollingInterval;
  Timer? _timer;
  bool _creating = false;
  bool _checking = false;

  ArcPaySubscriptionCubit({
    required ArcPaySubscriptionsApi api,
    required ArcPayPendingSubscriptionStore store,
    UserProvider? userProvider,
    Future<void> Function()? refreshUser,
    String? Function()? currentUserId,
    this.pollingInterval = const Duration(seconds: 3),
  }) : _api = api,
       _store = store,
       _currentUserId = currentUserId ?? (() => userProvider?.currentUser?.id),
       _refreshUser =
           refreshUser ??
           (() async {
             await userProvider?.refreshCurrentUser();
           }),
       super(const ArcPaySubscriptionInitial());

  // Requests may finish after the screen closes. Keep durable recovery work,
  // but never publish a late UI state or restart screen-owned polling.
  void _emitIfOpen(ArcPaySubscriptionState nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> initialize() async {
    if (isClosed) return;
    final saved = _store.read();
    if (saved == null) {
      await loadProducts();
      return;
    }
    final currentUserId = _currentUserId();
    if (currentUserId == null ||
        (saved.userId != null && saved.userId != currentUserId)) {
      await _store.clear();
      await loadProducts();
      return;
    }
    _emitIfOpen(
      ArcPaySubscriptionCheckoutReady(
        ArcPaySubscription(
          subscriptionId: saved.subscriptionId,
          status: 'pending',
          checkoutUrl: saved.checkoutUrl,
          productId: saved.productId,
          currentPeriodEnd: null,
          nextChargeAt: null,
          cancelAtPeriodEnd: false,
          failureCode: null,
        ),
        restored: true,
      ),
    );
    _startPolling();
    await checkNow();
  }

  Future<void> loadProducts() async {
    if (isClosed) return;
    _emitIfOpen(const ArcPaySubscriptionProductsLoading());
    try {
      _emitIfOpen(ArcPaySubscriptionProductsLoaded(await _api.getProducts()));
    } catch (_) {
      _emitIfOpen(
        const ArcPaySubscriptionFailure(
          ArcPaySubscriptionErrorCode.productsUnavailable,
        ),
      );
    }
  }

  Future<void> start(String productId) async {
    if (isClosed || _creating) return;
    _creating = true;
    _emitIfOpen(const ArcPaySubscriptionCreating());
    try {
      final subscription = await _api.createCheckout(
        productId: productId,
        requestId: const Uuid().v4(),
      );
      final url = subscription.checkoutUrl;
      if (url == null) throw StateError('Checkout URL is missing');
      final currentUserId = _currentUserId();
      if (currentUserId == null) throw StateError('Authentication is required');
      await _store.save(
        ArcPayPendingSubscription(
          subscriptionId: subscription.subscriptionId,
          productId: subscription.productId,
          userId: currentUserId,
          checkoutUrl: url,
        ),
      );
      _emitIfOpen(ArcPaySubscriptionCheckoutReady(subscription));
      _startPolling();
    } catch (_) {
      _emitIfOpen(
        const ArcPaySubscriptionFailure(
          ArcPaySubscriptionErrorCode.createSubscription,
        ),
      );
    } finally {
      _creating = false;
    }
  }

  void _startPolling() {
    if (isClosed) return;
    _timer?.cancel();
    _timer = Timer.periodic(pollingInterval, (_) => checkNow());
  }

  Future<void> checkNow() async {
    if (isClosed) return;
    if (_checking) return;
    final saved = _store.read();
    if (saved == null) return;
    _checking = true;
    try {
      final subscription = await _api.getCurrent();
      if (subscription == null) return;
      if (subscription.status == 'active') {
        _timer?.cancel();
        await _store.clear();
        await _refreshUser();
        _emitIfOpen(ArcPaySubscriptionActive(subscription));
      } else if ({
        'failed',
        'expired',
        'canceled',
        'manual_review',
      }.contains(subscription.status)) {
        _timer?.cancel();
        await _store.clear();
        _emitIfOpen(ArcPaySubscriptionTerminal(subscription));
      } else {
        _emitIfOpen(ArcPaySubscriptionPending(subscription));
      }
    } catch (_) {
      // A local timeout is not a payment failure. Polling continues.
    } finally {
      _checking = false;
    }
  }

  Future<void> cancel(String subscriptionId) async {
    if (isClosed) return;
    try {
      final subscription = await _api.cancel(subscriptionId);
      await _refreshUser();
      _emitIfOpen(ArcPaySubscriptionCancelled(subscription));
    } catch (_) {
      _emitIfOpen(
        const ArcPaySubscriptionFailure(
          ArcPaySubscriptionErrorCode.cancelSubscription,
        ),
      );
    }
  }

  Future<void> cancelCurrent() async {
    if (isClosed) return;
    try {
      final current = await _api.getCurrent();
      if (current == null) {
        _emitIfOpen(
          const ArcPaySubscriptionFailure(
            ArcPaySubscriptionErrorCode.subscriptionNotFound,
          ),
        );
        return;
      }
      await cancel(current.subscriptionId);
    } catch (_) {
      _emitIfOpen(
        const ArcPaySubscriptionFailure(
          ArcPaySubscriptionErrorCode.cancelSubscription,
        ),
      );
    }
  }

  Future<void> retry(String subscriptionId) async {
    if (isClosed) return;
    try {
      final subscription = await _api.retry(subscriptionId);
      _emitIfOpen(ArcPaySubscriptionPending(subscription));
      _startPolling();
    } catch (_) {
      _emitIfOpen(
        const ArcPaySubscriptionFailure(
          ArcPaySubscriptionErrorCode.retryPayment,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    return super.close();
  }
}
