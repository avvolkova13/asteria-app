import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

const double _purchaseSuccessScreenHeight = 250;
const double _purchaseModalSheetHeight = 329;
const Color _purchaseModalBackground = Color(0xFF12052A);
const Color _purchaseModalPurple = Color(0xFF6E4BFF);
const Color _purchaseModalPurpleDark = Color(0xFF5436D9);
const Color _purchaseModalGold = Color(0xFFF3B76A);
const LinearGradient _purchaseModalButtonGradient = LinearGradient(
  colors: [_purchaseModalPurple, _purchaseModalPurpleDark],
);

class PurchaseModalSheet extends StatefulWidget {
  final ShopItemModel product;
  final VoidCallback onConfirm;

  const PurchaseModalSheet({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  @override
  State<PurchaseModalSheet> createState() => _PurchaseModalSheetState();
}

class _PurchaseModalSheetState extends State<PurchaseModalSheet> {
  int _quantity = 1;
  bool _isPurchaseSuccess = false;
  bool _isSubmitting = false;
  String? _purchaseIdempotencyKey;

  @override
  void initState() {
    super.initState();
  }

  void _incrementQuantity() {
    if (!(MonetizationProvider.maybeOf(
          context,
          listen: false,
        )?.canSpend(_totalPrice + widget.product.price) ??
        false)) {
      return;
    } else {
      setState(() {
        _quantity++;
        _purchaseIdempotencyKey = null;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _purchaseIdempotencyKey = null;
      });
    }
  }

  int get _totalPrice => widget.product.price * _quantity;

  @override
  Widget build(BuildContext context) {
    return Consumer<MonetizationProvider>(
      builder: (context, monetizationProvider, child) {
        final bool isNotEnoughBalance = !monetizationProvider.canSpend(
          _totalPrice,
        );
        final bool showNotEnoughContent =
            isNotEnoughBalance && !_isPurchaseSuccess;
        final textScale = MediaQuery.textScalerOf(
          context,
        ).scale(1).clamp(1.0, 1.3);
        final baseHeight = _isPurchaseSuccess
            ? _purchaseSuccessScreenHeight
            : _purchaseModalSheetHeight;
        final scaleAllowance = _isPurchaseSuccess ? 80.0 : 300.0;
        final requestedHeight = baseHeight + ((textScale - 1) * scaleAllowance);
        final maximumHeight = MediaQuery.sizeOf(context).height * 0.92;

        return Container(
          height: showNotEnoughContent
              ? null
              : requestedHeight.clamp(0.0, maximumHeight).toDouble(),
          decoration: BoxDecoration(
            color: showNotEnoughContent
                ? const Color(0xFF110628)
                : _purchaseModalBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: showNotEnoughContent
                ? NotEnoughStarsPurchaseContent(
                    balance: monetizationProvider.balance,
                    requiredAmount: _totalPrice,
                    onCancel: () => Navigator.pop(context),
                    onBuyStars: () {
                      final missingStars =
                          _totalPrice > monetizationProvider.balance
                          ? _totalPrice - monetizationProvider.balance
                          : 0;
                      final navigatorContext = Navigator.of(context).context;
                      Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        CoinsPaywallRoute.push(
                          navigatorContext,
                          params: CoinsPaywallRouteParams(
                            minimumStars: missingStars,
                          ),
                        );
                      });
                    },
                  )
                : Builder(
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const _PurchaseGrabber(),
                            const SizedBox(height: 14),
                            _isPurchaseSuccess
                                ? _PurchaseSuccessScreen(
                                    balance: monetizationProvider.balance,
                                  )
                                : Expanded(
                                    child: Column(
                                      children: AsteriaEntrance.sections([
                                        Text(
                                          widget.product.title,
                                          style: context
                                              .textTheme
                                              .inversePlayfairSemiBold20
                                              .copyWith(height: 1),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          context.l10n.shopQuantityQuestion,
                                          style: context
                                              .textTheme
                                              .inversePlayfairMedium18
                                              .copyWith(height: 1.1),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 28),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: _CoinAmountLabel(
                                                  text: context.l10n
                                                      .shopUnitPriceValue(
                                                        widget.product.price,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Flexible(
                                              flex: 0,
                                              child: _QuantitySelector(
                                                quantity: _quantity,
                                                onIncrement: _incrementQuantity,
                                                onDecrement: _decrementQuantity,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        _BalanceChangeWidget(
                                          balance: monetizationProvider.balance,
                                          price: _totalPrice,
                                          newBalance: monetizationProvider
                                              .balanceAfterSpend(_totalPrice),
                                          isNotEnoughBalance: false,
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 18,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child:
                                                    _PurchaseModalActionButton.outline(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ),
                                                      text: context
                                                          .l10n
                                                          .commonCancel,
                                                    ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _PurchaseModalActionButton.primary(
                                                  onPressed: _isSubmitting
                                                      ? null
                                                      : () async {
                                                          setState(() {
                                                            _isSubmitting =
                                                                true;
                                                            _purchaseIdempotencyKey ??=
                                                                const Uuid()
                                                                    .v4();
                                                          });
                                                          final analytics = di
                                                              .get<
                                                                ProductAnalyticsService
                                                              >();
                                                          final balanceBefore =
                                                              monetizationProvider
                                                                  .balance;
                                                          analytics
                                                              .trackCoinSpendStart(
                                                                originSurface:
                                                                    'shop',
                                                                offerType:
                                                                    OfferType
                                                                        .shopItem,
                                                                coinAmount:
                                                                    _totalPrice,
                                                                balanceBefore:
                                                                    balanceBefore,
                                                              );
                                                          try {
                                                            await monetizationProvider
                                                                .purchaseShopRequestPack(
                                                                  productId:
                                                                      widget
                                                                          .product
                                                                          .id,
                                                                  quantity:
                                                                      _quantity,
                                                                  expectedPrice:
                                                                      _totalPrice,
                                                                  feature: widget
                                                                      .product
                                                                      .purchase
                                                                      ?.featureKey,
                                                                  idempotencyKey:
                                                                      _purchaseIdempotencyKey,
                                                                );
                                                            setState(() {
                                                              _isPurchaseSuccess =
                                                                  true;
                                                              _purchaseIdempotencyKey =
                                                                  null;
                                                            });
                                                            analytics.trackCoinSpendSuccess(
                                                              originSurface:
                                                                  'shop',
                                                              offerType:
                                                                  OfferType
                                                                      .shopItem,
                                                              coinAmount:
                                                                  _totalPrice,
                                                              balanceBefore:
                                                                  balanceBefore,
                                                              balanceAfter:
                                                                  monetizationProvider
                                                                      .balance,
                                                            );
                                                            widget.onConfirm();
                                                          } finally {
                                                            if (mounted &&
                                                                !_isPurchaseSuccess) {
                                                              setState(() {
                                                                _isSubmitting =
                                                                    false;
                                                              });
                                                            }
                                                          }
                                                        },
                                                  text: context.l10n.commonBuy,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

class _PurchaseGrabber extends StatelessWidget {
  const _PurchaseGrabber();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      height: 4,
      width: 64,
      decoration: BoxDecoration(
        color: AppColors.cardTinted.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _PurchaseSuccessScreen extends StatelessWidget {
  final int balance;
  const _PurchaseSuccessScreen({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: AsteriaEntrance.sections([
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClayAssetIcon(
              'assets/icons/success_square_icon.svg',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.shopPurchaseComplete,
              style: context.textTheme.inversePlayfairSemiBold24,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.balanceStarsLabel(balance),
              style: context.textTheme.inverseUrbanistMedium20,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 3, left: 4),
              child: LotusRasterIcon('assets/icons/star_coin_icon.png', width: 20),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _PurchaseModalActionButton.primary(
          onPressed: () => Navigator.pop(context),
          text: context.l10n.commonContinue,
        ),
      ]),
    );
  }
}

class _BalanceChangeWidget extends StatelessWidget {
  final int balance;
  final int price;
  final int newBalance;
  final bool isNotEnoughBalance;

  const _BalanceChangeWidget({
    required this.balance,
    required this.price,
    required this.newBalance,
    required this.isNotEnoughBalance,
  });

  @override
  Widget build(BuildContext context) {
    final balanceLabel = _labelWithoutTrailingColon(context.l10n.balanceLabel);
    final resultLabel = isNotEnoughBalance
        ? _labelWithoutTrailingColon(context.l10n.shopRequired)
        : _labelWithoutTrailingColon(context.l10n.shopAfterPurchase);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 340) {
          return Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              _CoinAmountLabel(text: '$balanceLabel $balance'),
              const _PurchaseArrowIcon(),
              _CoinAmountLabel(text: '$resultLabel $newBalance'),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _CoinAmountLabel(text: '$balanceLabel $balance'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: _PurchaseArrowIcon(),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _CoinAmountLabel(text: '$resultLabel $newBalance'),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _labelWithoutTrailingColon(String label) {
  return label.endsWith(':') ? label.substring(0, label.length - 1) : label;
}

class _CoinAmountLabel extends StatelessWidget {
  final String text;

  const _CoinAmountLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            text,
            style: context.textTheme.inverseUrbanistRegular14.copyWith(
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        LotusRasterIcon(
          'assets/icons/star_coin_icon.png',
          width: 16,
          height: 16,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _PurchaseArrowIcon extends StatelessWidget {
  const _PurchaseArrowIcon();

  @override
  Widget build(BuildContext context) {
    return LotusRasterIcon(
      'assets/icons/right_long_arrow.png',
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      color: _purchaseModalPurple,
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantitySelector({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _purchaseModalGold.withValues(alpha: 0.78)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              LotusFeedback(
                onActivate: quantity > 1 ? onDecrement : null,
                keyboard: true,
                builder: (activate) => Semantics(
                  button: true,
                  enabled: quantity > 1,
                  label: context.l10n.shopDecreaseQuantity,
                  onTap: activate,
                  child: ExcludeSemantics(
                    child: GestureDetector(
                      onTap: activate,
                      child: ClayAssetIcon(
                        'assets/icons/minus_circle_icon.svg',
                        height: 22,
                        tint: quantity > 1
                              ? _purchaseModalPurple
                              : _purchaseModalPurple.withValues(alpha: 0.62),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$quantity',
                style: context.textTheme.inverseUrbanistRegular16.copyWith(
                  color: _purchaseModalGold,
                  height: 1,
                ),
              ),
              const Spacer(),
              LotusFeedback(
                onActivate: onIncrement,
                keyboard: true,
                builder: (activate) => Semantics(
                  button: true,
                  label: context.l10n.shopIncreaseQuantity,
                  onTap: activate,
                  child: ExcludeSemantics(
                    child: GestureDetector(
                      onTap: activate,
                      child: ClayAssetIcon(
                        'assets/icons/plus_circle_icon.svg',
                        height: 22,
                        tint: _purchaseModalGold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PurchaseModalActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _PurchaseModalActionButton.primary({
    required this.text,
    required this.onPressed,
  }) : isPrimary = true;

  const _PurchaseModalActionButton.outline({
    required this.text,
    required this.onPressed,
  }) : isPrimary = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final textStyle = context.textTheme.button.copyWith(
      color: isPrimary ? AppColors.textInverse : _purchaseModalPurple,
    );

    return Semantics(
      button: true,
      label: text,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 44,
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            child: Ink(
              decoration: CardLensDecoration.button(
                enabled: onPressed != null,
                gradient: isPrimary && onPressed != null
                    ? _purchaseModalButtonGradient
                    : null,
                color: isPrimary && onPressed == null
                    ? _purchaseModalPurple.withValues(alpha: 0.42)
                    : null,
                borderRadius: borderRadius,
                border: isPrimary
                    ? null
                    : Border.all(color: _purchaseModalPurple),
              ),
              child: LotusInkTap(
                onTap: onPressed,
                borderRadius: borderRadius,
                child: Center(
                  child: Text(
                    text,
                    style: textStyle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
