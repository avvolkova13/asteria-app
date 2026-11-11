import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'dart:io' show Platform;
import 'dart:ui' as ui;
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/monetization/presentation/contextual_purchase_page.dart';

import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/const/pricing_catalog.dart';
import 'package:asteria_app/core/payments/catalog/product_catalog.dart';
import 'package:asteria_app/core/payments/models/payment_product.dart';
import 'package:asteria_app/core/payments/api/arc_pay_payments_api.dart';
import 'package:asteria_app/core/payments/routing/payment_provider_route.dart';
import 'package:asteria_app/core/payments/routing/payment_provider_route_builder.dart';
import 'package:asteria_app/core/payments/routing/google_play_country_service.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/widgets/card_advertisement_widget.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_cubit.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_state.dart';
import 'package:asteria_app/features/subscription/presentation/paywall_failure_localization.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_cubit.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Stable surface id used for `ast_coin_*` analytics. The coins paywall is
/// typically reached from the "not enough coins" modal — we still tag it as
/// `coins_paywall` here so the funnel is self-describing.
const String _coinsPaywallOriginSurface = 'coins_paywall';
const String _coinsPaymentProvider = 'arc_pay';
const bool _paymentDiagnosticsEnabled = bool.fromEnvironment(
  'ASTERIA_PAYMENT_DIAGNOSTICS',
);

class CoinsPaywallScreen extends StatelessWidget {
  const CoinsPaywallScreen({super.key, this.minimumStars = 0});

  final int minimumStars;

  @override
  Widget build(BuildContext context) {
    return PaymentProviderRouteBuilder(
      router: di.get<PaymentProviderRouter>(),
      builder: (context, route) {
        final diagnostic = _paymentDiagnosticsEnabled
            ? _PaymentRegionDiagnostic(route: route)
            : null;
        if (route == PaymentProviderRoute.arcPay) {
          return BlocProvider<ArcPayCheckoutCubit>(
            create: (_) => di.get<ArcPayCheckoutCubit>()..loadProducts(),
            child: _CoinsPaywallAndroid(
              minimumStars: minimumStars,
              storefrontDiagnostic: diagnostic,
            ),
          );
        }
        return BlocProvider<PaywallCubit>(
          create: (_) =>
              di.get<PaywallCubit>()
                ..loadProducts(ProductCatalog.consumableIds),
          child: _CoinsPaywallIos(
            route: route,
            minimumStars: minimumStars,
            storefrontDiagnostic: diagnostic,
          ),
        );
      },
    );
  }
}

class _PaymentRegionDiagnostic extends StatefulWidget {
  const _PaymentRegionDiagnostic({required this.route});

  final PaymentProviderRoute route;

  @override
  State<_PaymentRegionDiagnostic> createState() =>
      _PaymentRegionDiagnosticState();
}

class _PaymentRegionDiagnosticState extends State<_PaymentRegionDiagnostic> {
  late Future<String?> _countryCode;

  @override
  void initState() {
    super.initState();
    _countryCode = Platform.isAndroid
        ? di.get<GooglePlayCountryService>().currentCountryCode()
        : di.get<AppleStorefrontService>().currentCountryCode();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _countryCode,
      builder: (context, snapshot) {
        final countryCode = switch (snapshot.connectionState) {
          ConnectionState.waiting => context.l10n.loading,
          _ => snapshot.data?.toUpperCase() ?? context.l10n.commonUnavailable,
        };
        final provider = switch (widget.route) {
          PaymentProviderRoute.arcPay => 'Arc Pay',
          PaymentProviderRoute.appleStoreKit => 'Apple StoreKit',
          PaymentProviderRoute.googlePlay => 'Google Play',
        };
        return DecoratedBox(
          decoration: BoxDecoration(
            color: ProfileFlowColors.cardStrong,
            border: Border.all(color: ProfileFlowColors.accent),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              context.l10n.paymentDiagnostics(countryCode, provider),
              style: context.textTheme.inverseUrbanistRegular16.copyWith(
                color: ProfileFlowColors.textMuted,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ----- Android Arc Pay Hosted Checkout ------------------------------------

class _CoinsPaywallAndroid extends StatefulWidget {
  const _CoinsPaywallAndroid({
    required this.minimumStars,
    this.storefrontDiagnostic,
  });

  final int minimumStars;
  final _PaymentRegionDiagnostic? storefrontDiagnostic;

  @override
  State<_CoinsPaywallAndroid> createState() => _CoinsPaywallAndroidState();
}

class _CoinsPaywallAndroidState extends State<_CoinsPaywallAndroid> {
  int? _selectedPackageIndex;
  bool _isOpeningCheckout = false;

  static const _featureParam = {EventParams.featureName: 'coins'};

  @override
  void initState() {
    super.initState();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.coinsPaywallView,
      params: _featureParam,
    );
    di.get<ProductAnalyticsService>().trackCoinPaywallView(
      originSurface: _coinsPaywallOriginSurface,
    );
  }

  Future<void> _handlePurchase(List<ArcPayProduct> products) async {
    final index = _selectedPackageIndex;
    if (_isOpeningCheckout || index == null || index >= products.length) return;
    setState(() => _isOpeningCheckout = true);

    final selectedPackage = products[index];
    final facade = di.get<AnalyticsFacade>();
    final productAnalytics = di.get<ProductAnalyticsService>();
    final packageId = selectedPackage.productId;
    final priceRub = selectedPackage.amountMinor / 100;

    facade.trackEvent(
      AnalyticsEvents.coinsPackageSelected,
      params: {
        ..._featureParam,
        EventParams.packageId: packageId,
        EventParams.price: priceRub,
        EventParams.currency: selectedPackage.currency,
      },
    );
    productAnalytics.trackCoinPackageSelect(
      packageId: packageId,
      price: priceRub,
      afCurrency: selectedPackage.currency,
    );

    facade.trackEvent(
      AnalyticsEvents.coinsPurchaseStart,
      params: {
        ..._featureParam,
        EventParams.packageId: packageId,
        EventParams.price: priceRub,
        EventParams.currency: selectedPackage.currency,
      },
    );
    productAnalytics.trackCoinPurchaseStart(
      originSurface: _coinsPaywallOriginSurface,
      packageId: packageId,
      price: priceRub,
      afCurrency: selectedPackage.currency,
      paymentProvider: _coinsPaymentProvider,
      underlyingPaymentProvider: 'unknown',
    );

    final purchased = await PaymentsRoute.pushForResult(
      context,
      params: PaymentsRouteParams(
        productId: selectedPackage.productId,
        amountMinor: selectedPackage.amountMinor,
        price: priceRub,
        currency: selectedPackage.currency,
      ),
    );
    if (mounted) {
      setState(() => _isOpeningCheckout = false);
      if (purchased == true) PurchaseVerifiedNotification().dispatch(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArcPayCheckoutCubit, ArcPayCheckoutState>(
      builder: (context, state) {
        final products = state is ArcPayProductsLoaded
            ? filterArcPayCoinProductsForMinimumStars(
                state.products,
                widget.minimumStars,
              )
            : const <ArcPayProduct>[];
        return Scaffold(
          backgroundColor: ProfileFlowColors.background,
          body: ProfileFlowBackground(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileFlowHeader(
                      title: context.l10n.commonBuy,
                      canPop: true,
                    ).withEntrance(),
                    if (widget.storefrontDiagnostic case final diagnostic?) ...[
                      const SizedBox(height: 12),
                      diagnostic,
                    ],
                    const SizedBox(height: 32),
                    Text(
                      context.l10n.choosePackageTitle,
                      style: context.textTheme.inversePlayfairSemiBold32,
                    ).withEntrance(),
                    const SizedBox(height: 16),
                    _AndroidPaywallContent(
                      state: state,
                      products: products,
                      selectedPackageIndex: _selectedPackageIndex,
                      isOpeningCheckout: _isOpeningCheckout,
                      onRetry: context.read<ArcPayCheckoutCubit>().loadProducts,
                      onPackageTap: (index) => setState(() {
                        _selectedPackageIndex = index;
                      }),
                      onPurchase: () => _handlePurchase(products),
                    ),
                    const SizedBox(height: 24),
                    CardAdvertisementWidget(
                      horizontalMargin: 0,
                      variant:
                          CardAdvertisementVariant.balanceSubscriptionBanner,
                      title: context.l10n.balanceSubscriptionPrompt,
                      description: context.l10n.subscriptionUnlimitedAccess,
                      buttonText: context.l10n.balanceChooseSubscription,
                      onPressed: () => openSubscriptionFromCoins(context),
                    ).withEntrance(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AndroidPaywallContent extends StatelessWidget {
  final ArcPayCheckoutState state;
  final List<ArcPayProduct> products;
  final int? selectedPackageIndex;
  final bool isOpeningCheckout;
  final VoidCallback onRetry;
  final ValueChanged<int> onPackageTap;
  final VoidCallback onPurchase;

  const _AndroidPaywallContent({
    required this.state,
    required this.products,
    required this.selectedPackageIndex,
    required this.isOpeningCheckout,
    required this.onRetry,
    required this.onPackageTap,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    if (state is ArcPayProductsLoading || state is ArcPayCheckoutInitial) {
      return const _AndroidPaywallStateCard(
        child: Center(
          child: CircularProgressIndicator(color: ProfileFlowColors.accent),
        ),
      );
    }

    if (state is ArcPayCheckoutFailure) {
      return _AndroidPaywallStateCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _checkoutErrorMessage(
                context,
                (state as ArcPayCheckoutFailure).code,
              ),
              textAlign: TextAlign.center,
              style: context.textTheme.inverseUrbanistRegular16,
            ),
            const SizedBox(height: 16),
            LotusButtons.text(
              onPressed: onRetry,
              child: Text(
                context.l10n.commonRetry,
                style: context.textTheme.inverseUrbanistRegular16.copyWith(
                  color: ProfileFlowColors.accent,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return _AndroidPaywallStateCard(
        child: Text(
          context.l10n.coinPackagesUnavailable,
          textAlign: TextAlign.center,
          style: context.textTheme.inverseUrbanistRegular16,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        ...products.asMap().entries.map((entry) {
          final index = entry.key;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < products.length - 1 ? 16 : 0,
            ),
            child: _PackageItem(
              package: entry.value,
              isSelected: selectedPackageIndex == index,
              onTap: () => onPackageTap(index),
            ),
          );
        }),
        if (selectedPackageIndex != null) ...[
          const SizedBox(height: 16),
          ProfilePrimaryButton(
            text: context.l10n.paymentOpenPage,
            onPressed: isOpeningCheckout ? null : onPurchase,
            isLoading: isOpeningCheckout,
          ),
        ],
      ]),
    );
  }
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

class _AndroidPaywallStateCard extends StatelessWidget {
  final Widget child;

  const _AndroidPaywallStateCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ProfileGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}

class _PackageItem extends StatelessWidget {
  final ArcPayProduct package;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageItem({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = _coinPackageTitle(
      context,
      package.productId,
      fallback: package.name,
    );
    final description = _coinPackageDescription(
      context,
      package.coins ?? 0,
      fallback: context.l10n.coinPackageFallback(package.coins ?? 0),
    )!;
    final radius = BorderRadius.circular(AsteriaCardRadii.tile);

    final tile = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.transparent,
          child: LotusInkTap(
            onTap: onTap,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 117),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: CardLensDecoration(
                  color: isSelected
                      ? ProfileFlowColors.cardStrong
                      : ProfileFlowColors.card,
                  borderRadius: radius,
                  border: Border.all(
                    color: isSelected
                        ? ProfileFlowColors.purple
                        : ProfileFlowColors.border,
                    width: isSelected ? 1.1 : 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.inversePlayfairSemiBold24,
                          ),
                          const SizedBox(height: 6),
                          _PackagePriceRow(
                            coins: package.coins ?? 0,
                            priceRubles: package.amountMinor ~/ 100,
                          ),
                          const SizedBox(height: 7),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.inverseUrbanistRegular16
                                .copyWith(
                                  color: ProfileFlowColors.textMuted,
                                  height: 1.12,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _PackageSelectionControl(
                      coins: package.coins ?? 0,
                      isSelected: isSelected,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(button: true, selected: isSelected, child: tile);
  }
}

class _PackagePriceRow extends StatelessWidget {
  final int coins;
  final int priceRubles;

  const _PackagePriceRow({required this.coins, required this.priceRubles});

  @override
  Widget build(BuildContext context) {
    final amountStyle = context.textTheme.inverseUrbanistRegular20.copyWith(
      height: 1,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$coins', style: amountStyle),
        const SizedBox(width: 6),
        LotusRasterIcon(
          'assets/icons/star_coin_icon.png',
          width: 17,
          height: 17,
        ),
        const SizedBox(width: 10),
        LotusRasterIcon(
          'assets/icons/right_long_arrow.png',
          width: 18,
          height: 10,
        ),
        const SizedBox(width: 10),
        Text(
          '$priceRubles ₽',
          style: amountStyle.copyWith(color: ProfileFlowColors.accent),
        ),
      ],
    );
  }
}

class _PackageSelectionControl extends StatelessWidget {
  final int coins;
  final bool isSelected;

  const _PackageSelectionControl({
    required this.coins,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final benefit = switch (coins) {
      120 => '17%',
      300 => '33%',
      _ => null,
    };

    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(5),
      decoration: CardLensDecoration.button(
        borderRadius: BorderRadius.circular(28),
        color: isSelected ? AppColors.primary : AppColorsDark.modal,
        border: Border.all(color: ProfileFlowColors.border, width: .8),
      ),
      child: isSelected
          ? const ClayIcon(
              Icons.check_rounded,
              color: AppColors.white,
              size: 24,
            )
          : benefit == null
          ? null
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.savings,
                    style: context.textTheme.inverseUrbanistRegular16.copyWith(
                      color: ProfileFlowColors.textMuted,
                      fontSize: 11,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    benefit,
                    style: context.textTheme.inverseUrbanistSemiBold16.copyWith(
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
// ----- iOS (new) flow ------------------------------------------------------

class _CoinsPaywallIos extends StatefulWidget {
  const _CoinsPaywallIos({
    required this.route,
    required this.minimumStars,
    this.storefrontDiagnostic,
  });

  final PaymentProviderRoute route;
  final int minimumStars;
  final _PaymentRegionDiagnostic? storefrontDiagnostic;

  @override
  State<_CoinsPaywallIos> createState() => _CoinsPaywallIosState();
}

class _CoinsPaywallIosState extends State<_CoinsPaywallIos> {
  static const _featureParam = {EventParams.featureName: 'coins'};
  PaymentProduct? _activePurchase;

  @override
  void initState() {
    super.initState();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.coinsPaywallView,
      params: _featureParam,
    );
    di.get<ProductAnalyticsService>().trackCoinPaywallView(
      originSurface: _coinsPaywallOriginSurface,
    );
  }

  void _onPurchase(PaymentProduct product) {
    _activePurchase = product;
    final facade = di.get<AnalyticsFacade>();
    final productAnalytics = di.get<ProductAnalyticsService>();

    facade.trackEvent(
      AnalyticsEvents.coinsPackageSelected,
      params: {
        ..._featureParam,
        EventParams.packageId: product.id,
        EventParams.price: product.rawPrice,
        EventParams.currency: product.currencyCode,
      },
    );
    productAnalytics.trackCoinPackageSelect(
      packageId: product.id,
      price: product.rawPrice,
      afCurrency: product.currencyCode,
    );

    facade.trackEvent(
      AnalyticsEvents.coinsPurchaseStart,
      params: {
        ..._featureParam,
        EventParams.packageId: product.id,
        EventParams.price: product.rawPrice,
        EventParams.currency: product.currencyCode,
      },
    );
    productAnalytics.trackCoinPurchaseStart(
      originSurface: _coinsPaywallOriginSurface,
      packageId: product.id,
      price: product.rawPrice,
      afCurrency: product.currencyCode,
      paymentProvider: widget.route == PaymentProviderRoute.googlePlay
          ? 'google'
          : 'apple',
      underlyingPaymentProvider: widget.route == PaymentProviderRoute.googlePlay
          ? 'play_billing'
          : 'storekit',
    );

    context.read<PaywallCubit>().purchase(product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileFlowColors.background,
      body: BlocConsumer<PaywallCubit, PaywallState>(
        listener: (context, state) {
          if (state is PaywallSuccess) {
            PurchaseVerifiedNotification().dispatch(context);
            _trackPurchaseSuccess(state);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.purchaseSuccess)),
            );
            // Refresh products so prices stay current after purchase.
            context.read<PaywallCubit>().loadProducts(
              ProductCatalog.consumableIds,
            );
          } else if (state is PaywallFailed) {
            _trackPurchaseFailure(state);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizedPaywallFailure(context, state.code)),
              ),
            );
            if (state.code == PaywallFailureCode.canceled) {
              context.read<PaywallCubit>().loadProducts(
                ProductCatalog.consumableIds,
              );
            }
          } else if (state is PaywallPending) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state is PaywallAppleStatus
                      ? localizedApplePurchaseStatus(context, state)
                      : context.l10n.coinPurchasePending,
                ),
                action: state is PaywallAppleStatus
                    ? SnackBarAction(
                        label: context.l10n.applePurchaseCheckStatus,
                        onPressed: LotusFeedback.action(
                          () =>
                              context.read<PaywallCubit>().refreshAppleStatus(),
                        ),
                      )
                    : null,
              ),
            );
          }
        },
        builder: (context, state) {
          return ProfileFlowBackground(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfileFlowHeader(
                      title: context.l10n.commonBuy,
                      canPop: true,
                    ).withEntrance(),
                    if (widget.storefrontDiagnostic case final diagnostic?) ...[
                      const SizedBox(height: 12),
                      diagnostic,
                    ],
                    const SizedBox(height: 32),
                    Text(
                      context.l10n.choosePackageTitle,
                      style: context.textTheme.inversePlayfairSemiBold32,
                    ).withEntrance(),
                    const SizedBox(height: 16),
                    _IosPaywallContent(
                      state: state,
                      minimumStars: widget.minimumStars,
                      onRetry: () => context.read<PaywallCubit>().loadProducts(
                        ProductCatalog.consumableIds,
                      ),
                      onPurchase: _onPurchase,
                    ),
                    const SizedBox(height: 24),
                    CardAdvertisementWidget(
                      horizontalMargin: 0,
                      variant:
                          CardAdvertisementVariant.balanceSubscriptionBanner,
                      title: context.l10n.balanceSubscriptionPrompt,
                      description: context.l10n.subscriptionUnlimitedAccess,
                      buttonText: context.l10n.balanceChooseSubscription,
                      onPressed: () => openSubscriptionFromCoins(context),
                    ).withEntrance(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _trackPurchaseSuccess(PaywallSuccess state) {
    final product = _activePurchase;
    if (product == null || product.id != state.productId) return;
    _activePurchase = null;

    di.get<ProductAnalyticsService>().trackCoinPurchaseSuccess(
      originSurface: _coinsPaywallOriginSurface,
      afRevenue: product.rawPrice,
      afCurrency: product.currencyCode,
      packageId: product.id,
      paymentProvider: _paymentProvider,
      underlyingPaymentProvider: _underlyingPaymentProvider,
    );
  }

  void _trackPurchaseFailure(PaywallFailed state) {
    final product = _activePurchase;
    if (product == null ||
        state.code == PaywallFailureCode.productsLoad ||
        state.code == PaywallFailureCode.restoreFailed ||
        (state.productId != null && state.productId != product.id)) {
      return;
    }
    // NativeCheckoutAnalytics owns failed/cancelled/pending outcomes.
    _activePurchase = null;
  }

  String get _paymentProvider =>
      widget.route == PaymentProviderRoute.googlePlay ? 'google' : 'apple';

  String get _underlyingPaymentProvider =>
      widget.route == PaymentProviderRoute.googlePlay
      ? 'play_billing'
      : 'storekit';
}

class _IosPaywallContent extends StatelessWidget {
  final PaywallState state;
  final int minimumStars;
  final VoidCallback onRetry;
  final ValueChanged<PaymentProduct> onPurchase;

  const _IosPaywallContent({
    required this.state,
    required this.minimumStars,
    required this.onRetry,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    if (state is PaywallLoading ||
        state is PaywallInitial ||
        state is PaywallPurchasing ||
        state is PaywallVerifying) {
      return const _AndroidPaywallStateCard(
        child: Center(
          child: CircularProgressIndicator(color: ProfileFlowColors.accent),
        ),
      );
    }

    if (state is PaywallProductsLoaded) {
      final products = filterStoreCoinProductsForMinimumStars(
        (state as PaywallProductsLoaded).products,
        minimumStars,
      );
      if (products.isEmpty) {
        return _AndroidPaywallStateCard(
          child: Text(
            context.l10n.coinPackagesUnavailableRetry,
            textAlign: TextAlign.center,
            style: context.textTheme.inverseUrbanistRegular16,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          ...products.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < products.length - 1 ? 16 : 0,
              ),
              child: _IosPackageTile(
                product: product,
                onTap: () => onPurchase(product),
              ),
            );
          }),
        ]),
      );
    }

    return _AndroidPaywallStateCard(
      child: Center(
        child: LotusButtons.text(
          onPressed: onRetry,
          child: Text(
            context.l10n.coinPackagesLoad,
            style: context.textTheme.inverseUrbanistRegular16.copyWith(
              color: ProfileFlowColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _IosPackageTile extends StatelessWidget {
  final PaymentProduct product;
  final VoidCallback onTap;

  const _IosPackageTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final metadata = PricingCatalog.coinPackageFor(product.id);
    final description = _coinPackageDescription(
      context,
      metadata?.stars,
      fallback: product.description.isEmpty ? null : product.description,
    );
    final radius = BorderRadius.circular(AsteriaCardRadii.tile);

    final tile = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.transparent,
          child: LotusInkTap(
            onTap: onTap,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 117),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: CardLensDecoration(
                  color: ProfileFlowColors.card,
                  borderRadius: radius,
                  border: Border.all(
                    color: ProfileFlowColors.border,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _coinPackageTitle(
                              context,
                              product.id,
                              fallback: product.title,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.inversePlayfairSemiBold24,
                          ),
                          const SizedBox(height: 6),
                          _IosPackagePriceRow(
                            stars: metadata?.stars,
                            localizedPrice: product.localizedPrice,
                          ),
                          if (description != null) ...[
                            const SizedBox(height: 7),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.inverseUrbanistRegular16
                                  .copyWith(
                                    color: ProfileFlowColors.textMuted,
                                    height: 1.12,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _PackageSelectionControl(
                      coins: metadata?.stars ?? 0,
                      isSelected: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(button: true, child: tile);
  }
}

class _IosPackagePriceRow extends StatelessWidget {
  final int? stars;
  final String localizedPrice;

  const _IosPackagePriceRow({
    required this.stars,
    required this.localizedPrice,
  });

  @override
  Widget build(BuildContext context) {
    final amountStyle = context.textTheme.inverseUrbanistRegular20.copyWith(
      height: 1,
    );

    return Row(
      children: [
        if (stars != null) ...[
          Text('${stars!}', style: amountStyle),
          const SizedBox(width: 6),
          LotusRasterIcon(
            'assets/icons/star_coin_icon.png',
            width: 17,
            height: 17,
          ),
          const SizedBox(width: 10),
          LotusRasterIcon(
            'assets/icons/right_long_arrow.png',
            width: 18,
            height: 10,
          ),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            localizedPrice,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: amountStyle.copyWith(color: ProfileFlowColors.accent),
          ),
        ),
      ],
    );
  }
}

String _coinPackageTitle(
  BuildContext context,
  String productId, {
  required String fallback,
}) {
  return switch (productId) {
    'asteria_stars_10' => context.l10n.coinPackageFirstMoon,
    'asteria_stars_30' => context.l10n.coinPackageRetrogradePath,
    'asteria_stars_60' => context.l10n.coinPackageSunlight,
    'asteria_stars_120' => context.l10n.coinPackageStarPath,
    'asteria_stars_300' => context.l10n.coinPackageUniverseSecret,
    _ => fallback,
  };
}

String? _coinPackageDescription(
  BuildContext context,
  int? stars, {
  String? fallback,
}) {
  return switch (stars) {
    10 => context.l10n.coinPackageDescription10,
    30 => context.l10n.coinPackageDescription30,
    60 => context.l10n.coinPackageDescription60,
    120 => context.l10n.coinPackageDescription120,
    300 => context.l10n.coinPackageDescription300,
    _ => fallback,
  };
}

List<ArcPayProduct> filterArcPayCoinProductsForMinimumStars(
  List<ArcPayProduct> products,
  int minimumStars,
) {
  return products
      .where((product) {
        if (product.productType != 'stars') return false;
        return minimumStars <= 0 || (product.coins ?? 0) >= minimumStars;
      })
      .toList(growable: false);
}

List<PaymentProduct> filterStoreCoinProductsForMinimumStars(
  List<PaymentProduct> products,
  int minimumStars,
) {
  return products
      .where((product) {
        if (minimumStars <= 0) return true;
        final package = PricingCatalog.coinPackageFor(product.id);
        return package != null && package.stars >= minimumStars;
      })
      .toList(growable: false);
}
