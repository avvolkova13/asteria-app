import 'dart:async';

import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/payments/api/arc_pay_payments_api.dart';
import 'package:asteria_app/core/payments/storage/arc_pay_pending_order_store.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class ArcPayCheckoutCubit extends Cubit<ArcPayCheckoutState> {
  final ArcPayPaymentsApi _api;
  final ArcPayPendingOrderStore _store;
  final String? Function() _currentUserId;
  final Future<void> Function() _refreshUser;
  final Duration pollingInterval;
  final String platform;
  final Future<Map<String, Object?>?> Function(String productId, String uid)?
  analyticsContext;
  Timer? _pollingTimer;
  bool _creating = false;
  bool _checking = false;
  int _attemptGeneration = 0;

  ArcPayCheckoutCubit({
    required ArcPayPaymentsApi api,
    required ArcPayPendingOrderStore store,
    UserProvider? userProvider,
    String? Function()? currentUserId,
    Future<void> Function()? refreshUser,
    this.pollingInterval = const Duration(seconds: 3),
    this.platform = 'android',
    this.analyticsContext,
  }) : assert(userProvider != null || currentUserId != null),
       _api = api,
       _store = store,
       _currentUserId = currentUserId ?? (() => userProvider?.currentUser?.id),
       _refreshUser =
           refreshUser ??
           (() async {
             await userProvider?.refreshCurrentUser();
           }),
       super(const ArcPayCheckoutInitial());

  Future<void> loadProducts() async {
    emit(const ArcPayProductsLoading());
    try {
      emit(ArcPayProductsLoaded(await _api.getProducts()));
    } catch (_) {
      emit(
        const ArcPayCheckoutFailure(
          ArcPayCheckoutErrorCode.productsUnavailable,
        ),
      );
    }
  }

  Future<void> start({
    String? productId,
    int? amountMinor,
    String? currency,
  }) async {
    if (_creating) return;
    final userId = _currentUserId();
    if (userId == null || userId.isEmpty) {
      emit(
        const ArcPayCheckoutFailure(
          ArcPayCheckoutErrorCode.authenticationRequired,
        ),
      );
      return;
    }
    final saved = _store.read();
    final hasRequestedProduct = productId != null && productId.isNotEmpty;
    final hasCompletePaymentIdentity =
        hasRequestedProduct &&
        amountMinor != null &&
        currency != null &&
        currency.isNotEmpty;
    final matchesSavedOrder =
        saved != null &&
        saved.userId == userId &&
        hasCompletePaymentIdentity &&
        saved.productId == productId &&
        saved.amountMinor == amountMinor &&
        saved.currency == currency;
    if (matchesSavedOrder) {
      final checkout = ArcPayPendingCheckout(
        orderId: saved.orderId,
        productId: saved.productId,
        userId: saved.userId,
        checkoutUrl: saved.checkoutUrl,
      );
      emit(ArcPayCheckoutReady(checkout, restored: true));
      _startPolling(checkout);
      await checkNow();
      return;
    }
    if (saved != null && saved.userId == userId && hasRequestedProduct) {
      await _store.clear();
    }
    if (!hasCompletePaymentIdentity) {
      emit(
        const ArcPayCheckoutFailure(ArcPayCheckoutErrorCode.noPendingPayment),
      );
      return;
    }

    _attemptGeneration++;
    _creating = true;
    emit(ArcPayCheckoutCreating(productId));
    try {
      final response = await _api.createCheckout(
        userId: userId,
        productId: productId,
        requestId: const Uuid().v4(),
        platform: platform,
        analyticsContext: await analyticsContext?.call(productId, userId),
      );
      final checkout = ArcPayPendingCheckout(
        orderId: response.orderId,
        productId: productId,
        userId: userId,
        checkoutUrl: response.checkoutUrl,
      );
      await _store.save(
        ArcPayPendingOrder(
          orderId: checkout.orderId,
          productId: checkout.productId,
          amountMinor: amountMinor,
          currency: currency,
          userId: checkout.userId,
          checkoutUrl: checkout.checkoutUrl,
        ),
      );
      emit(ArcPayCheckoutReady(checkout));
      _startPolling(checkout);
    } catch (_) {
      emit(const ArcPayCheckoutFailure(ArcPayCheckoutErrorCode.createPayment));
    } finally {
      _creating = false;
    }
  }

  void _startPolling(ArcPayPendingCheckout checkout) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(pollingInterval, (_) => checkNow());
  }

  Future<void> checkNow() async {
    if (_checking) return;
    final saved = _store.read();
    if (saved == null) return;
    final generation = _attemptGeneration;
    _checking = true;
    try {
      final order = await _api.getOrder(
        orderId: saved.orderId,
        userId: saved.userId,
      );
      if (generation != _attemptGeneration) return;
      if (order.status == 'fulfilled') {
        _pollingTimer?.cancel();
        await _refreshUser();
        await _store.clear();
        emit(ArcPayCheckoutFulfilled(order));
      } else if (order.status == 'confirming' ||
          order.providerStatus == 'captured' ||
          order.providerStatus == 'settled') {
        emit(ArcPayCheckoutConfirming(order));
      } else if ({
        'failed',
        'reversed',
        'manual_review',
      }.contains(order.status)) {
        _pollingTimer?.cancel();
        await _store.clear();
        emit(ArcPayCheckoutTerminalFailure(order));
      } else if (order.clientState == 'abandoned') {
        _pollingTimer?.cancel();
        await _store.clear();
        emit(const ArcPayCheckoutAbandoned(serverConfirmed: true));
      } else {
        emit(ArcPayCheckoutPending(order));
      }
    } catch (_) {
      // A transient polling failure is not a payment failure. Keep polling.
    } finally {
      _checking = false;
    }
  }

  Future<void> handlePaymentReturn(Uri uri) async {
    if (uri.scheme != 'asteria' || uri.host != 'payment-return') return;
    final saved = _store.read();
    if (saved == null || uri.queryParameters['order_id'] != saved.orderId) {
      return;
    }
    if (uri.queryParameters['result'] == 'cancel') {
      await abandon();
    } else {
      await checkNow();
    }
  }

  Future<void> abandon() async {
    final saved = _store.read();
    if (saved == null) return;
    _attemptGeneration++;
    _pollingTimer?.cancel();
    var serverConfirmed = false;
    try {
      final order = await _api.abandonOrder(
        orderId: saved.orderId,
        userId: saved.userId,
      );
      serverConfirmed = order.clientState == 'abandoned';
      if (order.status == 'fulfilled') {
        await _refreshUser();
        await _store.clear();
        emit(ArcPayCheckoutFulfilled(order));
        return;
      }
      if ({'failed', 'reversed', 'manual_review'}.contains(order.status)) {
        await _store.clear();
        emit(ArcPayCheckoutTerminalFailure(order));
        return;
      }
    } catch (_) {
      // The local attempt must not keep blocking the user if Arc Pay/backend is
      // temporarily unavailable. The server order remains safe for webhook and
      // reconciliation processing.
    }
    await _store.clear();
    emit(ArcPayCheckoutAbandoned(serverConfirmed: serverConfirmed));
  }

  @override
  Future<void> close() async {
    _pollingTimer?.cancel();
    return super.close();
  }
}
