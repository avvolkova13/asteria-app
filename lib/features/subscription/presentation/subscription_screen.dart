import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/payments/api/arc_pay_payments_api.dart';
import 'package:asteria_app/core/payments/api/arc_pay_subscriptions_api.dart';
import 'package:asteria_app/core/payments/catalog/google_subscription_offers.dart';
import 'package:asteria_app/core/payments/catalog/product_catalog.dart';
import 'package:asteria_app/core/payments/models/payment_product.dart';
import 'package:asteria_app/core/payments/routing/payment_provider_route.dart';
import 'package:asteria_app/core/payments/routing/payment_provider_route_builder.dart';
import 'package:asteria_app/core/payments/widgets/google_subscription_price.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/contextual_purchase_page.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_cubit.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_state.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/arc_pay_subscription_cubit.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/arc_pay_subscription_state.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_cubit.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_state.dart';
import 'package:asteria_app/features/subscription/presentation/paywall_failure_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

@visibleForTesting
Uri googlePlaySubscriptionManagementUrl() => Uri.parse(
  'https://play.google.com/store/account/subscriptions'
  '?package=com.finext.asteria',
);

class SubscriptionScreen extends StatelessWidget {
  final String? originSurface;

  const SubscriptionScreen({super.key, this.originSurface});

  @override
  Widget build(BuildContext context) {
    final monetization = MonetizationProvider.maybeOf(context);
    final effectiveGrants = monetization?.state?.effectiveGrants ?? const [];
    final activeProvider = effectiveGrants.isEmpty
        ? null
        : effectiveGrants.first.provider;
    final activeSubscriptionRoute =
        PaymentProviderRouter.activeSubscriptionProvider(activeProvider);
    return PaymentProviderRouteBuilder(
      router: di.get<PaymentProviderRouter>(),
      activeSubscriptionRoute: activeSubscriptionRoute,
      builder: (context, route) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<PaywallCubit>(
              create: (_) {
                final cubit = di.get<PaywallCubit>();
                if (route != PaymentProviderRoute.arcPay) {
                  cubit.loadProducts(ProductCatalog.subscriptionIds);
                }
                return cubit;
              },
            ),
            if (route == PaymentProviderRoute.arcPay)
              BlocProvider<ArcPayCheckoutCubit>(
                create: (_) => di.get<ArcPayCheckoutCubit>()..loadProducts(),
              ),
          ],
          child: _SubscriptionScreenContent(
            route: route,
            originSurface: originSurface,
          ),
        );
      },
    );
  }
}

class _SubscriptionScreenContent extends StatefulWidget {
  final PaymentProviderRoute? route;
  final String? originSurface;

  const _SubscriptionScreenContent({this.route, this.originSurface});

  @override
  State<_SubscriptionScreenContent> createState() =>
      _SubscriptionScreenContentState();
}

class _SubscriptionScreenContentState extends State<_SubscriptionScreenContent>
    with WidgetsBindingObserver {
  bool _paywallTracked = false;
  PaymentProduct? _selectedProduct;

  String get _paymentProvider =>
      widget.route == PaymentProviderRoute.googlePlay ? 'google' : 'apple';

  String get _underlyingPaymentProvider =>
      widget.route == PaymentProviderRoute.googlePlay
      ? 'play_billing'
      : 'storekit';

  void _purchase(PaymentProduct product) {
    _selectedProduct = product;
    di.get<ProductAnalyticsService>().trackSubscriptionPurchaseStart(
      originSurface: widget.originSurface ?? _defaultOriginSurface,
      planId: product.id,
      price: product.rawPrice,
      afCurrency: product.currencyCode,
      paymentProvider: _paymentProvider,
      underlyingPaymentProvider: _underlyingPaymentProvider,
    );
    context.read<PaywallCubit>().purchase(product);
  }

  void _onNativePurchaseState(BuildContext context, PaywallState state) {
    if (state is PaywallSuccess || state is PaywallRestored) {
      PurchaseVerifiedNotification().dispatch(context);
    }
    String? message;
    if (state is PaywallRestored) {
      _selectedProduct = null;
      final count = state.restoredProductIds.length;
      message = count == 0
          ? context.l10n.subscriptionNoPurchasesToRestore
          : context.l10n.subscriptionPurchasesRestored(count);
      if (!(MonetizationProvider.maybeOf(
            context,
            listen: false,
          )?.effectivePro ??
          false)) {
        context.read<PaywallCubit>().loadProducts(
          ProductCatalog.subscriptionIds,
        );
      }
    } else if (state is PaywallFailed) {
      message = localizedPaywallFailure(context, state.code);
      if (state.code == PaywallFailureCode.canceled) {
        context.read<PaywallCubit>().loadProducts(
          ProductCatalog.subscriptionIds,
        );
      }
    } else if (state is PaywallPending) {
      message = state is PaywallAppleStatus
          ? localizedApplePurchaseStatus(context, state)
          : context.l10n.subscriptionActivationPending;
    }
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            action: state is PaywallAppleStatus
                ? SnackBarAction(
                    label: context.l10n.applePurchaseCheckStatus,
                    onPressed: LotusFeedback.action(
                      () => context.read<PaywallCubit>().refreshAppleStatus(),
                    ),
                  )
                : null,
          ),
        );
    }
    final product = _selectedProduct;
    if (product == null) return;
    if (state is PaywallSuccess && product.id == state.productId) {
      _selectedProduct = null;
      di.get<ProductAnalyticsService>().trackSubscriptionPurchaseSuccess(
        originSurface: widget.originSurface ?? _defaultOriginSurface,
        afRevenue: product.rawPrice,
        afCurrency: product.currencyCode,
        planId: product.id,
        paymentProvider: _paymentProvider,
        underlyingPaymentProvider: _underlyingPaymentProvider,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.subscriptionActivated)),
      );
    } else if (state is PaywallFailed &&
        state.code != PaywallFailureCode.productsLoad &&
        state.code != PaywallFailureCode.restoreFailed &&
        (state.productId == null || state.productId == product.id)) {
      _selectedProduct = null;
    }
  }

  static const _featureParam = {EventParams.featureName: 'subscription'};

  /// Stable surface id for subscription analytics.
  static const String _defaultOriginSurface = 'subscription_screen';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        widget.route == PaymentProviderRoute.arcPay) {
      context.read<ArcPayCheckoutCubit>().loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.route == PaymentProviderRoute.arcPay) {
      return _buildContent(context);
    }
    // Activating PRO removes the plans, but checkout still awaits its result.
    return BlocListener<PaywallCubit, PaywallState>(
      listener: _onNativePurchaseState,
      child: Builder(builder: _buildContent),
    );
  }

  Widget _buildContent(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;
    final monetization = MonetizationProvider.maybeOf(context);
    final activeGrant = monetization?.state?.effectiveGrants.isNotEmpty == true
        ? monetization!.state!.effectiveGrants.first
        : null;
    final hasProSubscription =
        user != null && (monetization?.effectivePro ?? false);

    if (!hasProSubscription && !_paywallTracked) {
      _paywallTracked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        di.get<AnalyticsFacade>().trackEvent(
          AnalyticsEvents.subscriptionPaywallView,
          params: _featureParam,
        );
        di.get<ProductAnalyticsService>().trackSubscriptionPaywallView(
          originSurface: widget.originSurface ?? _defaultOriginSurface,
        );
      });
    }

    if (hasProSubscription) {
      return Scaffold(
        backgroundColor: ProfileFlowColors.background,
        body: ProfileFlowBackground(
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileFlowHeader(
                    title: context.l10n.subscriptionTitle,
                    canPop: true,
                  ).withEntrance(),
                  const SizedBox(height: 32),
                  _SubscriptionActiveScreen(
                    route: widget.route,
                    grant: activeGrant,
                    originSurface:
                        widget.originSurface ?? _defaultOriginSurface,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ProfileFlowColors.background,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _SubscribeCta(route: widget.route),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: ProfileFlowBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 116),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileFlowHeader(
                  title: context.l10n.subscriptionTitle,
                  canPop: true,
                ).withEntrance(),
                const SizedBox(height: 32),
                const _SubscriptionInfoCard(isActive: false).withEntrance(),
                if (widget.route != PaymentProviderRoute.arcPay) ...[
                  const SizedBox(height: 42),
                  _IosSubscriptionPlans(onPurchase: _purchase),
                  if (widget.route == PaymentProviderRoute.appleStoreKit) ...[
                    const SizedBox(height: 24),
                    const _RestorePurchasesButton(),
                  ],
                ] else if (widget.route == PaymentProviderRoute.arcPay) ...[
                  const SizedBox(height: 42),
                  _ArcPayOneTimeProPlans(
                    onPurchaseVerified: () {
                      if (mounted) {
                        PurchaseVerifiedNotification().dispatch(this.context);
                      }
                    },
                    originSurface:
                        widget.originSurface ?? _defaultOriginSurface,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscribeCta extends StatelessWidget {
  const _SubscribeCta({required this.route});

  final PaymentProviderRoute? route;

  @override
  Widget build(BuildContext context) {
    if (route != null && route != PaymentProviderRoute.arcPay) {
      return BlocBuilder<PaywallCubit, PaywallState>(
        builder: (context, state) {
          final isBusy =
              state is PaywallPurchasing ||
              state is PaywallVerifying ||
              state is PaywallLoading;
          return ProfilePrimaryButton(
            text: isBusy
                ? context.l10n.loading
                : context.l10n.subscriptionConnect,
            isLoading: isBusy,
            onPressed: isBusy
                ? null
                : () {
                    _trackCtaClick(context);
                    Scrollable.ensureVisible(
                      _IosSubscriptionPlans.globalKey.currentContext ?? context,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
          );
        },
      );
    }
    if (route == PaymentProviderRoute.arcPay) {
      return BlocBuilder<ArcPayCheckoutCubit, ArcPayCheckoutState>(
        builder: (context, state) {
          final isBusy =
              state is ArcPayProductsLoading || state is ArcPayCheckoutCreating;
          return ProfilePrimaryButton(
            text: isBusy
                ? context.l10n.loading
                : context.l10n.subscriptionConnect,
            isLoading: isBusy,
            onPressed: isBusy
                ? null
                : () {
                    _trackCtaClick(context);
                    Scrollable.ensureVisible(
                      _ArcPayOneTimeProPlans.globalKey.currentContext ??
                          context,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
          );
        },
      );
    }
    return ProfilePrimaryButton(
      text: context.l10n.commonUnavailable,
      onPressed: null,
    );
  }

  void _trackCtaClick(BuildContext context) {
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.paywallCtaClick,
      params: const {EventParams.featureName: 'subscription'},
    );
  }
}

class _IosSubscriptionPlans extends StatelessWidget {
  const _IosSubscriptionPlans({required this.onPurchase});

  static final GlobalKey globalKey = GlobalKey();
  final ValueChanged<PaymentProduct> onPurchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _IosSubscriptionPlans.globalKey,
      child: BlocBuilder<PaywallCubit, PaywallState>(
        builder: (context, state) {
          if (state is PaywallInitial || state is PaywallLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.white),
              ),
            );
          }
          if (state is PaywallProductsLoaded) {
            return _PlansList(products: state.products, onPurchase: onPurchase);
          }
          if (state is PaywallPurchasing || state is PaywallVerifying) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.white),
              ),
            );
          }
          return _ReloadProducts(
            onPressed: () => context.read<PaywallCubit>().loadProducts(
              ProductCatalog.subscriptionIds,
            ),
          );
        },
      ),
    );
  }
}

class _ArcPayOneTimeProPlans extends StatelessWidget {
  const _ArcPayOneTimeProPlans({
    required this.originSurface,
    required this.onPurchaseVerified,
  });

  final VoidCallback onPurchaseVerified;

  static final GlobalKey globalKey = GlobalKey();

  final String originSurface;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: globalKey,
      child: BlocBuilder<ArcPayCheckoutCubit, ArcPayCheckoutState>(
        builder: (context, state) {
          if (state is ArcPayProductsLoading ||
              state is ArcPayCheckoutInitial) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: AsteriaEntrance(
                  child: CircularProgressIndicator(color: AppColors.white),
                ),
              ),
            );
          }
          if (state is ArcPayProductsLoaded) {
            final products = state.products
                .where((product) => product.productType == 'pro_access')
                .toList(growable: false);
            return _ArcPayOneTimeProPlansList(
              onPurchaseVerified: onPurchaseVerified,
              products: products,
              originSurface: originSurface,
            );
          }
          return _ReloadProducts(
            onPressed: context.read<ArcPayCheckoutCubit>().loadProducts,
          );
        },
      ),
    );
  }
}

class _ArcPayOneTimeProPlansList extends StatelessWidget {
  const _ArcPayOneTimeProPlansList({
    required this.onPurchaseVerified,
    required this.products,
    required this.originSurface,
  });

  final List<ArcPayProduct> products;
  final String originSurface;
  final VoidCallback onPurchaseVerified;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            context.l10n.subscriptionPlansUnavailable,
            textAlign: TextAlign.center,
            style: context.textTheme.inverseUrbanistRegular16,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.subscriptionChoosePlan,
          style: context.textTheme.inverseUrbanistSemiBold17,
        ),
        const SizedBox(height: 12),
        for (final product in products) ...[
          ProfileGlassCard(
            padding: const EdgeInsets.all(16),
            onTap: () => _purchase(context, product),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: context.textTheme.inverseUrbanistSemiBold17,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(product.amountMinor / 100).toStringAsFixed(0)} ₽',
                  style: context.textTheme.inverseUrbanistSemiBold20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ]),
    );
  }

  Future<void> _purchase(BuildContext context, ArcPayProduct product) async {
    final priceRub = product.amountMinor / 100;
    di.get<ProductAnalyticsService>().trackSubscriptionPurchaseStart(
      originSurface: originSurface,
      planId: product.productId,
      price: priceRub,
      afCurrency: product.currency,
      paymentProvider: 'arc_pay',
      underlyingPaymentProvider: 'hosted_h2h',
    );
    final purchased = await PaymentsRoute.pushForResult(
      context,
      params: PaymentsRouteParams(
        productId: product.productId,
        amountMinor: product.amountMinor,
        price: priceRub,
        currency: product.currency,
      ),
    );
    // The list is removed when fulfillment activates PRO, before this route
    // returns. Dispatch through the surviving subscription screen.
    if (purchased == true) onPurchaseVerified();
  }
}

class _ArcPaySubscriptionPlans extends StatefulWidget {
  const _ArcPaySubscriptionPlans();

  static final GlobalKey globalKey = GlobalKey();

  @override
  State<_ArcPaySubscriptionPlans> createState() =>
      _ArcPaySubscriptionPlansState();
}

class _ArcPaySubscriptionPlansState extends State<_ArcPaySubscriptionPlans> {
  bool _opening = false;

  Future<void> _open(Uri? url) async {
    if (url == null || _opening) return;
    setState(() => _opening = true);
    var launched = false;
    try {
      launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.paymentOpenError)));
    }
    if (mounted) setState(() => _opening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _ArcPaySubscriptionPlans.globalKey,
      child: BlocConsumer<ArcPaySubscriptionCubit, ArcPaySubscriptionState>(
        listener: (context, state) {
          if (state is ArcPaySubscriptionCheckoutReady && !state.restored) {
            _open(state.subscription.checkoutUrl);
          } else if (state is ArcPaySubscriptionActive) {
            PurchaseVerifiedNotification().dispatch(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.subscriptionActivated)),
            );
          } else if (state is ArcPaySubscriptionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_subscriptionErrorMessage(context, state.code)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ArcPaySubscriptionInitial ||
              state is ArcPaySubscriptionProductsLoading ||
              state is ArcPaySubscriptionCreating) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.white),
              ),
            );
          }
          if (state is ArcPaySubscriptionProductsLoaded) {
            return _ArcPayPlansList(products: state.products);
          }
          if (state is ArcPaySubscriptionCheckoutReady ||
              state is ArcPaySubscriptionPending) {
            final subscription = state is ArcPaySubscriptionCheckoutReady
                ? state.subscription
                : (state as ArcPaySubscriptionPending).subscription;
            return ProfileGlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.white),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.subscriptionConfirmingCard,
                    textAlign: TextAlign.center,
                    style: context.textTheme.inverseUrbanistRegular16,
                  ),
                  if (subscription.checkoutUrl != null) ...[
                    const SizedBox(height: 12),
                    LotusButtons.text(
                      onPressed: () => _open(subscription.checkoutUrl),
                      child: Text(context.l10n.subscriptionOpenPaymentAgain),
                    ),
                  ],
                ],
              ),
            );
          }
          return _ReloadProducts(
            onPressed: context.read<ArcPaySubscriptionCubit>().loadProducts,
          );
        },
      ),
    );
  }

  String _subscriptionErrorMessage(
    BuildContext context,
    ArcPaySubscriptionErrorCode code,
  ) {
    return switch (code) {
      ArcPaySubscriptionErrorCode.productsUnavailable =>
        context.l10n.arcSubscriptionProductsError,
      ArcPaySubscriptionErrorCode.createSubscription =>
        context.l10n.arcSubscriptionCreateError,
      ArcPaySubscriptionErrorCode.cancelSubscription =>
        context.l10n.arcSubscriptionCancelError,
      ArcPaySubscriptionErrorCode.subscriptionNotFound =>
        context.l10n.arcSubscriptionNotFound,
      ArcPaySubscriptionErrorCode.retryPayment =>
        context.l10n.arcSubscriptionRetryError,
    };
  }
}

class _ArcPayPlansList extends StatelessWidget {
  final List<ArcPaySubscriptionProduct> products;

  const _ArcPayPlansList({required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.subscriptionChoosePlan,
          style: context.textTheme.inverseUrbanistSemiBold17,
        ),
        const SizedBox(height: 12),
        for (final product in products) ...[
          ProfileGlassCard(
            padding: const EdgeInsets.all(16),
            onTap: () => context.read<ArcPaySubscriptionCubit>().start(
              product.productId,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: context.textTheme.inverseUrbanistSemiBold17,
                  ),
                ),
                Text(
                  '${(product.amountMinor / 100).toStringAsFixed(0)} ₽',
                  style: context.textTheme.inverseUrbanistSemiBold20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ]),
    );
  }
}

class _ReloadProducts extends StatelessWidget {
  const _ReloadProducts({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LotusButtons.text(
        onPressed: onPressed,
        child: Text(
          context.l10n.subscriptionLoadPlans,
          style: context.textTheme.inverseUrbanistRegular17,
        ),
      ),
    );
  }
}

class _PlansList extends StatelessWidget {
  const _PlansList({required this.products, required this.onPurchase});

  final List<PaymentProduct> products;
  final ValueChanged<PaymentProduct> onPurchase;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            context.l10n.subscriptionPlansUnavailable,
            textAlign: TextAlign.center,
            style: context.textTheme.inverseUrbanistRegular16,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.subscriptionChoosePlan,
          style: context.textTheme.inverseUrbanistSemiBold17,
        ),
        const SizedBox(height: 12),
        for (final product in products) ...[
          _PlanTile(product: product, onTap: () => onPurchase(product)),
          const SizedBox(height: 12),
        ],
      ]),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.product, required this.onTap});

  final PaymentProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final googleTerms = googleSubscriptionTerms(product.rawDetails);
    return ProfileGlassCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: context.textTheme.inverseUrbanistSemiBold17,
                ),
                if (googleTerms != null) ...[
                  const SizedBox(height: 8),
                  GoogleSubscriptionPrice(
                    terms: googleTerms,
                    style: context.textTheme.inverseUrbanistRegular16,
                  ),
                ],
                if (product.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: context.textTheme.inverseUrbanistRegular14.copyWith(
                      color: ProfileFlowColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (googleTerms == null)
            Text(
              product.localizedPrice,
              style: context.textTheme.inverseUrbanistSemiBold20,
            ),
        ],
      ),
    );
  }
}

class _SubscriptionActiveScreen extends StatelessWidget {
  const _SubscriptionActiveScreen({
    required this.route,
    required this.grant,
    required this.originSurface,
  });

  final EntitlementGrantModel? grant;
  final PaymentProviderRoute? route;
  final String originSurface;

  @override
  Widget build(BuildContext context) {
    final nextPaymentDate = grant?.endsAt ?? grant?.graceUntil;
    final formattedDate = nextPaymentDate != null
        ? nextPaymentDate.toLocalizedShortDate(Localizations.localeOf(context))
        : '';
    final isArcPayOneTime = grant?.provider == 'arc_pay';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        _SubscriptionInfoCard(
          isActive: true,
          nextPaymentDateText: formattedDate,
          cancelAtPeriodEnd:
              isArcPayOneTime || (grant?.cancelAtPeriodEnd ?? false),
        ),
        if (isArcPayOneTime) ...[
          const SizedBox(height: 42),
          _ArcPayOneTimeProPlans(
            originSurface: originSurface,
            onPurchaseVerified: () {
              if (context.mounted) {
                PurchaseVerifiedNotification().dispatch(context);
              }
            },
          ),
        ] else ...[
          const SizedBox(height: 146),
          if (route == PaymentProviderRoute.appleStoreKit) ...[
            const _RestorePurchasesButton(),
            const SizedBox(height: 16),
          ],
          _CancelSubscriptionButton(grant: grant),
        ],
      ]),
    );
  }
}

class _SubscriptionInfoCard extends StatelessWidget {
  const _SubscriptionInfoCard({
    required this.isActive,
    this.nextPaymentDateText,
    this.cancelAtPeriodEnd = false,
  });

  final bool isActive;
  final String? nextPaymentDateText;
  final bool cancelAtPeriodEnd;

  @override
  Widget build(BuildContext context) {
    final title = isActive
        ? context.l10n.subscriptionActive
        : context.l10n.subscriptionInactive;

    return ProfileGlassCard(
      borderRadius: AsteriaCardRadii.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final artSize = (constraints.maxWidth * .29).clamp(64.0, 108.0);
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.textTheme.inversePlayfairSemiBold24,
                        ),
                        if (isActive) ...[
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: cancelAtPeriodEnd
                                      ? context.l10n.subscriptionAccessUntil
                                      : context
                                            .l10n
                                            .subscriptionNextPaymentInline,
                                ),
                                TextSpan(
                                  text: nextPaymentDateText,
                                  style: const TextStyle(
                                    color: ProfileFlowColors.accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            style: context.textTheme.inverseUrbanistRegular17
                                .copyWith(height: 1.05),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Image.asset(
                    'assets/images/sonnik/pro_crystal.webp',
                    width: artSize,
                    height: artSize,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            isActive
                ? context.l10n.subscriptionAvailableToYou
                : context.l10n.subscriptionBenefitsTitle,
            style: isActive
                ? context.textTheme.inverseUrbanistSemiBold17
                : context.textTheme.inversePlayfairSemiBold17,
          ),
          const SizedBox(height: 12),
          _BenefitsItem(
            iconPath: 'assets/icons/sub/moon_icon.svg',
            title: context.l10n.subscriptionBenefitUnlimited,
          ),
          const SizedBox(height: 12),
          _BenefitsItem(
            iconPath: 'assets/icons/sub/lock_icon.svg',
            title: context.l10n.subscriptionBenefitHoroscope,
          ),
          const SizedBox(height: 12),
          _BenefitsItem(
            iconPath: 'assets/icons/sub/calendar_icon.svg',
            title: context.l10n.subscriptionBenefitMoon,
          ),
          const SizedBox(height: 12),
          _BenefitsItem(
            iconPath: 'assets/icons/sub/people_icon.svg',
            title: context.l10n.subscriptionBenefitCompatibility,
          ),
          const SizedBox(height: 12),
          _BenefitsItem(
            iconPath: 'assets/icons/sub/star_icon.svg',
            title: context.l10n.subscriptionBenefitAffirmations,
          ),
        ],
      ),
    );
  }
}

class _BenefitsItem extends StatelessWidget {
  const _BenefitsItem({required this.iconPath, required this.title});

  final String iconPath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: ClayAssetIcon(
            iconPath,
            width: 24,
            height: 24,
            tint: ProfileFlowColors.accent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: context.textTheme.inverseUrbanistRegular17.copyWith(
              height: 1.08,
            ),
          ),
        ),
      ],
    );
  }
}

class _RestorePurchasesButton extends StatelessWidget {
  const _RestorePurchasesButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaywallCubit, PaywallState>(
      builder: (context, state) {
        final isBusy =
            state is PaywallLoading ||
            state is PaywallPurchasing ||
            state is PaywallVerifying;
        return ProfileGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          onTap: isBusy
              ? null
              : () {
                  context.read<PaywallCubit>().restorePurchases();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.subscriptionRestoreInProgress),
                    ),
                  );
                },
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.subscriptionRestorePurchases,
                  style: context.textTheme.inverseUrbanistRegular17,
                ),
              ),
              SizedBox(
                width: LotusArrowBubble.diameter,
                height: LotusArrowBubble.diameter,
                child: isBusy
                    ? const Padding(
                        padding: EdgeInsets.all(3),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ProfileFlowColors.accent,
                        ),
                      )
                    : const LotusArrowBubble(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CancelSubscriptionButton extends StatelessWidget {
  final EntitlementGrantModel? grant;

  const _CancelSubscriptionButton({required this.grant});

  @override
  Widget build(BuildContext context) {
    return ProfileOutlineButton(
      text: context.l10n.subscriptionDisable,
      onPressed: () async {
        final confirmed = await _showCancelConfirmation(context);
        if (confirmed != true || !context.mounted) return;
        await _runCancelBehavior(context);
      },
    );
  }

  Future<bool?> _showCancelConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return ModalGlassAlert(
          color: AppColorsDark.modal,
          titlePadding: const EdgeInsets.fromLTRB(24, 18, 24, 4),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
          actionsPadding: EdgeInsets.zero,
          title: Text(
            context.l10n.subscriptionCancelQuestion,
            textAlign: TextAlign.center,
            style: context.textTheme.inverseUrbanistBold18.copyWith(
              height: 1.15,
            ),
          ),
          content: Text(
            context.l10n.subscriptionCancelDescription,
            textAlign: TextAlign.center,
            style: context.textTheme.inverseUrbanistRegular14.copyWith(
              height: 1.18,
            ),
          ),
          actions: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: LotusButtons.text(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text(
                        context.l10n.cancel,
                        style: context.textTheme.inverseUrbanistRegular16,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 44,
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: AppColors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  Expanded(
                    child: LotusButtons.text(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: Text(
                        context.l10n.subscriptionDisable,
                        style: context.textTheme.inverseUrbanistRegular16
                            .copyWith(color: ProfileFlowColors.accent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _runCancelBehavior(BuildContext context) async {
    final provider = grant?.provider;
    final subscriptionState = grant?.cancelAtPeriodEnd == true
        ? 'cancel_at_period_end'
        : grant?.status.isNotEmpty == true
        ? grant!.status
        : 'active';
    if (provider == 'arc_pay' || provider == 'arcopay') {
      di.get<AnalyticsFacade>().trackEvent(
        AnalyticsEvents.subscriptionCancelled,
        params: const {EventParams.featureName: 'subscription'},
      );
      await context.read<ArcPaySubscriptionCubit>().cancelCurrent();
    } else if (provider == 'apple') {
      await di.get<ProductAnalyticsService>().trackSubscriptionManageClick(
        originSurface: 'subscription_screen',
        platform: 'ios',
        subscriptionState: subscriptionState,
      );
      final uri = Uri.parse('https://apps.apple.com/account/subscriptions');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (provider == 'google') {
      await di.get<ProductAnalyticsService>().trackSubscriptionManageClick(
        originSurface: 'subscription_screen',
        platform: 'android',
        subscriptionState: subscriptionState,
      );
      await launchUrl(
        googlePlaySubscriptionManagementUrl(),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
