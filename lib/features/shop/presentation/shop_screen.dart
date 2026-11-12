import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'dart:ui' as ui;
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';

import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/failure_reason.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/subscription_widget.dart';
import 'package:asteria_app/features/home/presentation/models/year_animal_asset.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_pro_subscription_card.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:asteria_app/features/shop/presentation/widgets/purchase_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late final ShopBloc _shopBloc;

  static const _featureParam = {EventParams.featureName: 'shop'};

  @override
  void initState() {
    super.initState();
    _shopBloc = di.get<ShopBloc>();
    _shopBloc.add(const ShopLoadProducts());
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.funnelStart,
      params: _featureParam,
    );
    di.get<ProductAnalyticsService>().trackShopView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showPurchaseModalSheet(ShopItemModel product) {
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.paywallView,
      params: {
        ..._featureParam,
        EventParams.paywallVariant: 'shop_item',
        EventParams.productId: product.id,
        EventParams.price: product.price,
        EventParams.currency: 'coins',
      },
    );
    di.get<ProductAnalyticsService>().trackShopItemSelect(
      itemId: product.id,
      itemType: product.category,
      coinAmount: product.price,
      originSurface: 'shop',
    );
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return PurchaseModalSheet(
          key: ObjectKey('purchase_modal_sheet'),
          product: product,
          onConfirm: () {
            context.read<ShopBloc>().add(ShopLoadProducts());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ShopColors.background,
      body: BlocConsumer<ShopBloc, ShopState>(
        listenWhen: (prev, next) => next is ShopError && prev is! ShopError,
        listener: (context, state) {
          if (state is ShopError) {
            di.get<ProductAnalyticsService>().trackErrorStateView(
              screenName: 'shop',
              errorType: FailureReasons.serverError,
              originSurface: 'shop',
            );
          }
        },
        builder: (context, state) {
          return _ShopBackground(
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: _ShopHeader()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.shopTitle,
                            style: context.textTheme.inversePlayfairSemiBold32
                                .copyWith(height: 1.2),
                          ).withEntrance(),
                          const SizedBox(height: 13),
                          Text(
                            context.l10n.shopSubtitle,
                            style: context.textTheme.inverseUrbanistRegular16
                                .copyWith(height: 1.2),
                          ).withEntrance(),
                          const SizedBox(height: 16),
                          _buildSubscriptionPromoSection(
                            context,
                          ).withEntrance(),
                          KeyedSubtree(
                            key: ValueKey(state.runtimeType),
                            child: _buildShopContent(context, state),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopContent(BuildContext context, ShopState state) {
    return switch (state) {
      ShopInitial() => const SizedBox.shrink(),
      ShopLoading() => const _ShopLoadingState(),
      ShopLoaded(products: final products) => _buildProductsList(products),
      ShopError() => Center(
        child: Column(
          children: AsteriaEntrance.sections([
            Text(
              context.l10n.shopLoadError,
              style: context.textTheme.inverseUrbanistRegular16,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LotusButtons.elevated(
              onPressed: () =>
                  context.read<ShopBloc>().add(const ShopLoadProducts()),
              child: Text(context.l10n.commonRetry),
            ),
          ]),
        ),
      ),
      ShopPurchaseLoading(products: final products) => _buildProductsList(
        products,
      ),
      ShopPurchaseSuccess(products: final products) => Column(
        children: [
          _ShopStatusBanner(
            message: context.l10n.shopPurchaseComplete,
            color: AppColors.success,
          ).withEntrance(),
          const SizedBox(height: 16),
          _buildProductsList(products),
        ],
      ),
      ShopPurchaseError(products: final products) => Column(
        children: [
          _ShopStatusBanner(
            message: context.l10n.shopPurchaseError,
            color: AppColors.error,
          ).withEntrance(),
          const SizedBox(height: 16),
          _buildProductsList(products),
        ],
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildSubscriptionPromoSection(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final monetization = MonetizationProvider.maybeOf(context);
    if (user == null || (monetization?.effectivePro ?? false)) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        HomeProSubscriptionCard(
          horizontalMargin: 0,
          onPressed: () => SubscriptionRoute.push(
            context,
            params: SubscriptionRouteParams(
              originSurface: 'shop_pro_promo_card',
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProductsList(List<ShopItemModel> products) {
    if (products.isEmpty) {
      return Center(
        child: Text(
          context.l10n.shopNoProducts,
          style: context.textTheme.inverseUrbanistRegular16,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: products
          .map(
            (product) => _ShopListItem(
              product: product,
              onTap: () => showPurchaseModalSheet(product),
            ).withEntrance(),
          )
          .toList(),
    );
  }
}

class _ShopListItem extends StatelessWidget {
  final ShopItemModel product;
  final VoidCallback onTap;

  const _ShopListItem({required this.onTap, required this.product});

  @override
  Widget build(BuildContext context) {
    final quantity = product.purchasedQuantity ?? 0;
    final isEmpty = quantity <= 0;
    final visual = _ShopItemVisual.fromProduct(product);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LotusFeedback(
        onActivate: onTap,
        keyboard: true,
        builder: (activate) => Semantics(
          button: true,
          label:
              '${product.title}\n'
              '${context.l10n.shopUnitPriceValue(product.price)}\n'
              '${product.description}\n'
              '${context.l10n.shopItemsLeft} '
              '${context.l10n.shopItemCount(quantity)}',
          onTap: activate,
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: activate,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: DecoratedBox(
                    decoration: CardLensDecoration(
                      color: _ShopColors.card,
                      borderRadius: BorderRadius.circular(
                        AsteriaCardRadii.tile,
                      ),
                      border: Border.all(
                        color: _ShopColors.cardBorder,
                        width: 0.6,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ShopItemImage(visual: visual, isLocked: isEmpty),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 74),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.title,
                                          style: context
                                              .textTheme
                                              .inversePlayfairMedium20
                                              .copyWith(height: 1.1),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _ShopPrice(price: product.price),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context
                                        .textTheme
                                        .inverseUrbanistRegular12
                                        .copyWith(
                                          color: _ShopColors.textSecondary,
                                          height: 1.2,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 4,
                                      children: [
                                        Text(
                                          context.l10n.shopItemsLeft,
                                          style: context
                                              .textTheme
                                              .inverseUrbanistSemiBold12
                                              .copyWith(height: 1.2),
                                        ),
                                        _ShopQuantity(quantity: quantity),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShopBackground extends StatelessWidget {
  const _ShopBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (MediaQuery.sizeOf(context).width * pixelRatio).round();

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/shop/shop_background.webp',
            fit: BoxFit.cover,
            cacheWidth: cacheWidth,
            opacity: const AlwaysStoppedAnimation(0.43),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _ShopColors.background.withValues(alpha: 0.93),
                  _ShopColors.background.withValues(alpha: 0.58),
                  _ShopColors.background.withValues(alpha: 0.92),
                ],
                stops: const [0, 0.42, 1],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 275,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _ShopColors.background,
                  _ShopColors.background.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader();

  @override
  Widget build(BuildContext context) {
    final balance = MonetizationProvider.maybeOf(context)?.balance ?? 0;

    return SizedBox(
      height: 42,
      child: Padding(
        padding: const EdgeInsets.only(left: 6, right: 16),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  LotusFeedback(
                    onActivate: () => Navigator.of(context).pop(),
                    keyboard: true,
                    builder: (activate) => Semantics(
                      button: true,
                      label: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      onTap: activate,
                      child: ExcludeSemantics(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: activate,
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: LotusArrowBubble(back: true),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      context.l10n.shopTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.inversePlayfairSemiBold17
                          .copyWith(height: 1.2),
                    ).withEntrance(),
                  ),
                ],
              ),
            ),
            LotusFeedback(
              onActivate: () => BalanceRoute.push(context),
              keyboard: true,
              builder: (activate) => Semantics(
                button: true,
                label: context.l10n.balanceStarsLabel(balance),
                onTap: activate,
                child: ExcludeSemantics(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: activate,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$balance ',
                            style: context.textTheme.inversePlayfairSemiBold17
                                .copyWith(height: 1.2),
                          ).withEntrance(),
                          LotusRasterIcon(
                            'assets/icons/star_coin_icon.png',
                            width: 14,
                            height: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const SizedBox(width: 76, height: 28, child: SubscriptionWidget()),
          ],
        ),
      ),
    );
  }
}

class _ShopItemImage extends StatelessWidget {
  const _ShopItemImage({required this.visual, required this.isLocked});

  final _ShopItemVisual visual;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (74 * pixelRatio).round();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 74,
        height: 74,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Padding(
                padding: visual.padding,
                child: Image.asset(
                  visual.asset,
                  fit: visual.fit,
                  alignment: visual.alignment,
                  cacheWidth: cacheWidth,
                ),
              ),
            ),
            if (isLocked) ...[
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: ColoredBox(
                  color: AppColorsDark.homeCanvas.withValues(alpha: 0.60),
                ),
              ),
              Center(
                child: ClayAssetIcon(
                  'assets/icons/white_lock_icon.svg',
                  width: 32,
                  height: 32,
                  tint: AppColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShopPrice extends StatelessWidget {
  const _ShopPrice({required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GradientText(
          price.toString(),
          style: context.textTheme.inversePlayfairMedium20.copyWith(
            height: 1.1,
          ),
        ),
        const SizedBox(width: 2),
        LotusRasterIcon(
          'assets/icons/star_coin_icon.png',
          width: 17,
          height: 17,
        ),
      ],
    );
  }
}

class _ShopQuantity extends StatelessWidget {
  const _ShopQuantity({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    final countStyle = context.textTheme.inverseUrbanistSemiBold12.copyWith(
      color: quantity <= 0 ? _ShopColors.zero : _ShopColors.gold,
      height: 1.2,
    );

    return Text(
      context.l10n.shopItemCount(quantity),
      style: countStyle,
      maxLines: 1,
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          _ShopColors.goldGradient.createShader(Offset.zero & bounds.size),
      child: Text(text, style: style),
    );
  }
}

class _ShopLoadingState extends StatelessWidget {
  const _ShopLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 28),
      child: Center(
        child: AsteriaEntrance(
          child: CircularProgressIndicator(
            color: _ShopColors.gold,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

class _ShopStatusBanner extends StatelessWidget {
  const _ShopStatusBanner({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: DecoratedBox(
          decoration: CardLensDecoration(
            color: color.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              message,
              style: context.textTheme.inverseUrbanistSemiBold14,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShopItemVisual {
  static const _loveTarotShopItemId = '464ef852-f767-49f1-b8d7-724f188f90c4';

  const _ShopItemVisual({
    required this.asset,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.all(6),
  });

  final String asset;
  final BoxFit fit;
  final Alignment alignment;
  final EdgeInsets padding;

  static _ShopItemVisual fromProduct(ShopItemModel product) {
    if (product.id == UserProvider.shopItemCompatibilityId) {
      return const _ShopItemVisual(
        asset: 'assets/images/shop/shop_compatibility.webp',
        fit: BoxFit.contain,
        alignment: Alignment.center,
      );
    }

    if (product.id == UserProvider.shopItemAnakraId) {
      return const _ShopItemVisual(
        asset: 'assets/images/shop/shop_ai_astrologer.webp',
        fit: BoxFit.contain,
        alignment: Alignment.center,
      );
    }

    if (product.id == _loveTarotShopItemId) {
      return const _ShopItemVisual(
        asset: 'assets/images/shop/shop_love_deck.webp',
        fit: BoxFit.contain,
        alignment: Alignment.center,
        padding: EdgeInsets.all(7),
      );
    }

    return _ShopItemVisual(
      asset: YearAnimalAsset.forYear(DateTime.now().year),
      fit: BoxFit.contain,
      alignment: Alignment.center,
    );
  }
}

class _ShopColors {
  static const background = Color(0xFF0F0A1A);
  static const card = Color(0x339A7DB8);
  static const cardBorder = Color(0x52FFFFFF);
  static const textSecondary = Color(0xD9FFFFFF);
  static const gold = Color(0xFFF3B76A);
  static const zero = Color(0xFFE36A6A);

  static const goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );
}
