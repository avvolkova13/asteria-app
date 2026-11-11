import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'dart:async';

import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/failure_reason.dart';
import 'package:asteria_app/core/analytics/dictionaries/failure_stage.dart';
import 'package:asteria_app/core/analytics/dictionaries/payment_method_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/payments/api/arc_pay_payments_api.dart';
import 'package:asteria_app/core/payments/routing/payment_return_link_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_cubit.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentsScreen extends StatefulWidget {
  final String? productId;
  final int? amountMinor;
  final num? price;
  final String? currency;

  const PaymentsScreen({
    super.key,
    this.productId,
    this.amountMinor,
    this.price,
    this.currency,
  });

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with WidgetsBindingObserver {
  static const _originSurface = 'coins_paywall';
  static const _paymentProvider = 'arc_pay';

  Uri? _checkoutUrl;
  bool _successTracked = false;
  bool _failureTracked = false;
  StreamSubscription<Uri>? _appLinksSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final returnLinks = di.get<PaymentReturnLinkService>();
    _appLinksSubscription = returnLinks.links.listen((uri) {
      if (!mounted) return;
      context.read<ArcPayCheckoutCubit>().handlePaymentReturn(uri);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ArcPayCheckoutCubit>();
      cubit
          .start(
            productId: widget.productId,
            amountMinor: widget.amountMinor,
            currency: widget.currency,
          )
          .then((_) {
            final pendingLink = returnLinks.takePending();
            if (pendingLink != null) cubit.handlePaymentReturn(pendingLink);
          });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appLinksSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ArcPayCheckoutCubit>().checkNow();
    }
  }

  Future<void> _openCheckout() async {
    final uri = _checkoutUrl;
    if (uri == null) return;
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.paymentOpenError)));
    }
  }

  PaymentMethodType _methodType(String? method) => switch (method) {
    'bank_card' || 'card' => PaymentMethodType.card,
    'sbp' => PaymentMethodType.sbp,
    'google_pay' => PaymentMethodType.googlePay,
    'apple_pay' => PaymentMethodType.applePay,
    _ => PaymentMethodType.unknown,
  };

  void _trackSuccess(ArcPayOrder order) {
    if (_successTracked) return;
    _successTracked = true;
    final priceRub = order.amountMinor / 100;
    if (order.productType == 'pro_access') {
      di.get<ProductAnalyticsService>().trackSubscriptionPurchaseSuccess(
        originSurface: 'subscription_screen',
        afRevenue: priceRub,
        afCurrency: order.currency,
        planId: order.productId,
        paymentProvider: _paymentProvider,
        underlyingPaymentProvider: order.paymentMethod ?? 'hosted_h2h',
      );
      return;
    }
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.coinsPurchaseSuccess,
      params: {
        EventParams.featureName: 'coins',
        EventParams.packageId: order.productId,
        EventParams.price: priceRub,
        EventParams.purchaseType: 'coins_pack',
        EventParams.paymentMethod: order.paymentMethod ?? 'unknown',
      },
    );
    di.get<ProductAnalyticsService>().trackPaymentMethodSelect(
      originSurface: _originSurface,
      paymentMethodType: _methodType(order.paymentMethod),
    );
    di.get<ProductAnalyticsService>().trackCoinPurchaseSuccess(
      originSurface: _originSurface,
      afRevenue: priceRub,
      afCurrency: order.currency,
      packageId: order.productId,
      paymentProvider: _paymentProvider,
      underlyingPaymentProvider: order.paymentMethod ?? 'unknown',
    );
  }

  void _trackTerminalFailure(ArcPayOrder order) {
    final reason = switch (order.failureCode) {
      'payment_declined' => FailureReasons.paymentDeclined,
      'payment_expired' ||
      'qr_expired' ||
      'timeout' => FailureReasons.qrExpired,
      _ => FailureReasons.unknown,
    };
    if (order.productType == 'pro_access') {
      di.get<ProductAnalyticsService>().trackSubscriptionPurchaseFailed(
        originSurface: 'subscription_screen',
        failureReason: reason,
        failureStage: FailureStages.confirmation,
        planId: order.productId,
        paymentProvider: _paymentProvider,
        underlyingPaymentProvider: order.paymentMethod ?? 'unknown',
      );
      return;
    }
    _trackFailure(
      reason: reason,
      stage: FailureStages.confirmation,
      packageId: order.productId,
      price: order.amountMinor / 100,
      currency: order.currency,
      underlyingPaymentProvider: order.paymentMethod ?? 'unknown',
    );
  }

  void _trackCheckoutFailure(ArcPayCheckoutErrorCode code) {
    final failure = switch (code) {
      ArcPayCheckoutErrorCode.productsUnavailable => null,
      ArcPayCheckoutErrorCode.authenticationRequired => (
        reason: FailureReasons.unknown,
        stage: FailureStages.checkoutStart,
      ),
      ArcPayCheckoutErrorCode.noPendingPayment => (
        reason: FailureReasons.unknown,
        stage: FailureStages.checkoutStart,
      ),
      ArcPayCheckoutErrorCode.createPayment => (
        reason: FailureReasons.networkError,
        stage: FailureStages.checkoutStart,
      ),
    };
    if (failure == null) return;
    if (_isProProductId(widget.productId)) {
      di.get<ProductAnalyticsService>().trackSubscriptionPurchaseFailed(
        originSurface: 'subscription_screen',
        failureReason: failure.reason,
        failureStage: failure.stage,
        planId: widget.productId,
        paymentProvider: _paymentProvider,
        underlyingPaymentProvider: 'unknown',
      );
      return;
    }
    _trackFailure(reason: failure.reason, stage: failure.stage);
  }

  void _trackAbandoned() {
    _trackFailure(
      reason: FailureReasons.userCancelled,
      stage: FailureStages.providerRedirect,
    );
  }

  void _trackFailure({
    required String reason,
    required String stage,
    String? packageId,
    num? price,
    String? currency,
    String underlyingPaymentProvider = 'unknown',
  }) {
    if (_failureTracked) return;
    _failureTracked = true;
    di.get<ProductAnalyticsService>().trackCoinPurchaseFailed(
      originSurface: _originSurface,
      failureReason: reason,
      failureStage: stage,
      packageId: packageId ?? widget.productId,
      price: price ?? widget.price,
      afCurrency: currency ?? widget.currency,
      paymentProvider: _paymentProvider,
      underlyingPaymentProvider: underlyingPaymentProvider,
    );
  }

  bool _isProProductId(String? productId) =>
      productId?.startsWith('asteria_pro_') ?? false;

  void _retry() {
    _failureTracked = false;
    context.read<ArcPayCheckoutCubit>().start(
      productId: widget.productId,
      amountMinor: widget.amountMinor,
      currency: widget.currency,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocConsumer<ArcPayCheckoutCubit, ArcPayCheckoutState>(
        listener: (context, state) {
          if (state is ArcPayCheckoutReady) {
            _checkoutUrl = state.checkout.checkoutUrl;
            if (!state.restored) _openCheckout();
          } else if (state is ArcPayCheckoutFulfilled) {
            _trackSuccess(state.order);
          } else if (state is ArcPayCheckoutTerminalFailure) {
            _trackTerminalFailure(state.order);
          } else if (state is ArcPayCheckoutFailure) {
            _trackCheckoutFailure(state.code);
          } else if (state is ArcPayCheckoutAbandoned) {
            _trackAbandoned();
          }
        },
        builder: (context, state) => Column(
          children: [
            TopNavBar(
              userName: context.l10n.paymentTitle,
              type: TopNavBarType.payment,
              canPop: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildContent(context, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ArcPayCheckoutState state) {
    if (state is ArcPayCheckoutFulfilled) return _success(state.order);
    if (state is ArcPayCheckoutTerminalFailure) {
      return _terminalError(state.order);
    }
    if (state is ArcPayCheckoutFailure) {
      return _error(_checkoutErrorMessage(context, state.code));
    }
    if (state is ArcPayCheckoutAbandoned) {
      return _abandoned(state.serverConfirmed);
    }
    if (state is ArcPayCheckoutConfirming) {
      return _statusCard(
        title: context.l10n.paymentConfirming,
        message: context.l10n.paymentConfirmingMessage,
        loading: true,
      );
    }
    if (state is ArcPayCheckoutReady || state is ArcPayCheckoutPending) {
      return _statusCard(
        title: context.l10n.paymentWaiting,
        message: context.l10n.paymentWaitingMessage,
        loading: true,
        action: Column(
          children: [
            if (_checkoutUrl != null)
              CustomButton(
                onPressed: _openCheckout,
                text: context.l10n.paymentOpenPage,
                isFullWidth: true,
              ),
            const SizedBox(height: 12),
            LotusButtons.text(
              onPressed: _confirmAbandon,
              child: Text(context.l10n.paymentLeaveAttempt),
            ),
          ],
        ),
      );
    }
    return _statusCard(
      title: context.l10n.paymentCreating,
      message: context.l10n.paymentCreatingMessage,
      loading: true,
    );
  }

  String _checkoutErrorMessage(
    BuildContext context,
    ArcPayCheckoutErrorCode code,
  ) {
    return switch (code) {
      ArcPayCheckoutErrorCode.productsUnavailable =>
        context.l10n.paymentPackagesLoadError,
      ArcPayCheckoutErrorCode.authenticationRequired =>
        context.l10n.paymentAuthenticationRequired,
      ArcPayCheckoutErrorCode.noPendingPayment =>
        context.l10n.paymentNoPendingPayment,
      ArcPayCheckoutErrorCode.createPayment => context.l10n.paymentCreateError,
    };
  }

  Widget _statusCard({
    required String title,
    required String message,
    bool loading = false,
    Widget? action,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 450),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading) ...[
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 24),
              ],
              Text(title, style: context.textTheme.playfairSemiBold24),
              const SizedBox(height: 12),
              Text(
                message,
                style: context.textTheme.urbanistRegular16.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (action != null) ...[const SizedBox(height: 28), action],
            ],
          ),
        ),
      ),
    );
  }

  Widget _success(ArcPayOrder order) => Center(
    child: Column(
      children: [
        Image.asset('assets/images/payment/purchase_success.png', height: 280),
        Text(
          context.l10n.paymentSuccess,
          style: context.textTheme.playfairSemiBold24,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          _successMessage(context, order),
          style: context.textTheme.urbanistRegular16.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        CustomButton(
          onPressed: () => Navigator.of(context).pop(true),
          text: context.l10n.commonBack,
          isFullWidth: true,
        ),
      ],
    ),
  );

  String _successMessage(BuildContext context, ArcPayOrder order) {
    if (order.productType == 'pro_access') {
      return context.l10n.subscriptionActivated;
    }
    final coins = order.coins ?? 0;
    return order.balance == null
        ? context.l10n.paymentCoinsCreditedBalanceUpdated(coins)
        : context.l10n.paymentCoinsCredited(coins, order.balance!);
  }

  Future<void> _confirmAbandon() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.paymentLeaveQuestion),
        content: Text(context.l10n.paymentLeaveDescription),
        actions: [
          LotusButtons.text(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.paymentContinue),
          ),
          LotusButtons.text(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.paymentLeaveAttempt),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<ArcPayCheckoutCubit>().abandon();
    }
  }

  Widget _abandoned(bool serverConfirmed) => Center(
    child: Column(
      children: [
        Image.asset('assets/images/payment/purchase_fail.png', height: 220),
        const SizedBox(height: 24),
        Text(
          context.l10n.paymentAttemptLeft,
          style: context.textTheme.playfairBold24,
        ),
        const SizedBox(height: 12),
        Text(
          serverConfirmed
              ? context.l10n.paymentAbandonedServerConfirmed
              : context.l10n.paymentAbandonedLocal,
          style: context.textTheme.urbanistRegular16.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (widget.productId != null)
          CustomButton(
            onPressed: _retry,
            text: context.l10n.paymentCreateNew,
            isFullWidth: true,
          ),
      ],
    ),
  );

  Widget _terminalError(ArcPayOrder order) {
    final message = switch (order.failureCode) {
      'payment_declined' => context.l10n.paymentDeclined,
      'payment_expired' => context.l10n.paymentExpired,
      'partial_refund' => context.l10n.paymentManualReview,
      _ => context.l10n.paymentNotCompleted,
    };
    return _error(message);
  }

  Widget _error(String message) => Center(
    child: Column(
      children: [
        Image.asset('assets/images/payment/purchase_fail.png', height: 220),
        const SizedBox(height: 24),
        Text(
          context.l10n.paymentFailed,
          style: context.textTheme.playfairBold24,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: context.textTheme.urbanistRegular16.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (widget.productId != null)
          CustomButton(
            onPressed: _retry,
            text: context.l10n.commonRetry,
            isFullWidth: true,
          ),
      ],
    ),
  );
}
