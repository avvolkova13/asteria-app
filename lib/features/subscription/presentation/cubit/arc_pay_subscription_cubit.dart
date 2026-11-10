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

  Future<void> initialize() async {
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
    emit(
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
    emit(const ArcPaySubscriptionProductsLoading());
    try {
      emit(ArcPaySubscriptionProductsLoaded(await _api.getProducts()));
    } catch (_) {
      emit(
        const ArcPaySubscriptionFailure(
          ArcPaySubscriptionErrorCode.productsUnavailable,
        ),
      );
    }
  }

  Future<void> start(String productId) async {
    if (_creating) return;
    _creating = true;
    emit(const ArcPaySubscriptionCreating());
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
      emit(ArcPaySubscriptionCheckoutReady(subscription));
      _startPolling();
    } catch (_) {
      emit(
        const ArcPaySubscriptionFailure(
          ArcPaySubscriptionErrorCode.createSubscription,
        ),
      );
    } finally {
      _creating = false;
    }
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(pollingInterval, (_) => checkNow());
  }

  Future<void> checkNow() async {
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
        emit(ArcPaySubscriptionActive(subscription));
      } else if ({
        'failed',
        'expired',
        'canceled',
        'manual_review',
      }.contains(subscription.status)) {
        _timer?.cancel();
        await _store.clear();
        emit(ArcPaySubscriptionTerminal(subscription));
      } else {
        emit(ArcPaySubscriptionPending(subscription));
      }
    } catch (_) {
      // A local timeout is not a payment failure. Polling continues.
    } finally {
      _checking = false;
    }
  }

  Future<void> cancel(String subscriptionId) async {
    try {
      final subscription = await _api.cancel(subscriptionId);
      await _refreshUser();
      emit(ArcPaySubscriptionCancelled(subscription));
    } catch (_) {
      emit(
        const ArcPaySubscriptionFailure(
          ArcPaySubscriptionErrorCode.cancelSubscription,
        ),
      );
    }
  }

  Future<void> cancelCurrent() async {
    try {
      final current = await _api.getCurrent();
      if (current == null) {
        emit(
          const ArcPaySubscriptionFailure(
            ArcPaySubscriptionErrorCode.subscriptionNotFound,
          ),
        );
        return;
      }
      await cancel(current.subscriptionId);
    } catch (_) {
      emit(
        const ArcPaySubscriptionFailure(
          ArcPaySubscriptionErrorCode.cancelSubscription,
        ),
      );
    }
  }

  Future<void> retry(String subscriptionId) async {
    try {
      final subscription = await _api.retry(subscriptionId);
      emit(ArcPaySubscriptionPending(subscription));
      _startPolling();
    } catch (_) {
      emit(
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
