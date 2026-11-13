import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
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
const Color _purchaseModalBackground = ModalGlassTokens.surface;
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
        final textScale = (MediaQuery.textScalerOf(context).scale(16) / 16)
            .clamp(1.0, 3.0);
        final baseHeight = _isPurchaseSuccess
            ? _purchaseSuccessScreenHeight
            : _purchaseModalSheetHeight;
        final scaleAllowance = _isPurchaseSuccess ? 180.0 : 300.0;
        final requestedHeight = baseHeight + ((textScale - 1) * scaleAllowance);
        final maximumHeight = MediaQuery.sizeOf(context).height * 0.92;

        return ModalGlassSurface(
          height: showNotEnoughContent
              ? null
              : requestedHeight.clamp(0.0, maximumHeight).toDouble(),
          color: _purchaseModalBackground,
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
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ModalGlassScrollBody(
                      key: ValueKey(_isPurchaseSuccess),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: AsteriaEntrance.sections([
                            const Center(child: _PurchaseGrabber()),
                            const SizedBox(height: 14),
                            if (_isPurchaseSuccess)
                              _PurchaseSuccessScreen(
                                balance: monetizationProvider.balance,
                              )
                            else ...[
                              Text(
                                widget.product.title,
                                style: context
                                    .textTheme
                                    .inversePlayfairSemiBold20
                                    .copyWith(height: 1.1),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.l10n.shopQuantityQuestion,
                                style: context.textTheme.inversePlayfairMedium18
                                    .copyWith(height: 1.1),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 28),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 12,
                                runSpacing: 10,
                                children: [
                                  _CoinAmountLabel(
                                    text: context.l10n.shopUnitPriceValue(
                                      widget.product.price,
                                    ),
                                  ),
                                  _QuantitySelector(
                                    quantity: _quantity,
                                    onIncrement: _incrementQuantity,
                                    onDecrement: _decrementQuantity,
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
                            ],
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 18),
                          child: _isPurchaseSuccess
                              ? _PurchaseModalActionButton.primary(
                                  onPressed: () => Navigator.pop(context),
                                  text: context.l10n.commonContinue,
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: _PurchaseModalActionButton.outline(
                                        onPressed: () => Navigator.pop(context),
                                        text: context.l10n.commonCancel,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _PurchaseModalActionButton.primary(
                                        onPressed: _isSubmitting
                                            ? null
                                            : () async {
                                                setState(() {
                                                  _isSubmitting = true;
                                                  _purchaseIdempotencyKey ??=
                                                      const Uuid().v4();
                                                });
                                                final analytics = di
                                                    .get<
                                                      ProductAnalyticsService
                                                    >();
                                                final balanceBefore =
                                                    monetizationProvider
                                                        .balance;
                                                analytics.trackCoinSpendStart(
                                                  originSurface: 'shop',
                                                  offerType: OfferType.shopItem,
                                                  coinAmount: _totalPrice,
                                                  balanceBefore: balanceBefore,
                                                );
                                                try {
                                                  await monetizationProvider
                                                      .purchaseShopRequestPack(
                                                        productId:
                                                            widget.product.id,
                                                        quantity: _quantity,
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
                                                    _isPurchaseSuccess = true;
                                                    _purchaseIdempotencyKey =
                                                        null;
                                                  });
                                                  analytics
                                                      .trackCoinSpendSuccess(
                                                        originSurface: 'shop',
                                                        offerType:
                                                            OfferType.shopItem,
                                                        coinAmount: _totalPrice,
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
                                                      _isSubmitting = false;
                                                    });
                                                  }
                                                }
                                              },
                                        text: context.l10n.commonBuy,
                                      ),
                                    ),
                                  ],
                                ),
                        ).withEntrance(),
                      ],
                    ),
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
        color: ModalGlassTokens.grabber,
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
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            ClayAssetIcon(
              'assets/icons/success_square_icon.svg',
              width: 24,
              height: 24,
            ),
            Text(
              context.l10n.shopPurchaseComplete,
              style: context.textTheme.inversePlayfairSemiBold24,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            text: context.l10n.balanceStarsLabel(balance),
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: LotusRasterIcon(
                    'assets/icons/star_coin_icon.png',
                    width: 20,
                  ),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: context.textTheme.inverseUrbanistMedium20,
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
          padding: const EdgeInsets.symmetric(horizontal: 4),
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
                      behavior: HitTestBehavior.opaque,
                      onTap: activate,
                      child: SizedBox.square(
                        dimension: 44,
                        child: Center(
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
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$quantity',
                    style: context.textTheme.inverseUrbanistRegular16.copyWith(
                      color: _purchaseModalGold,
                      height: 1,
                    ),
                  ),
                ),
              ),
              LotusFeedback(
                onActivate: onIncrement,
                keyboard: true,
                builder: (activate) => Semantics(
                  button: true,
                  label: context.l10n.shopIncreaseQuantity,
                  onTap: activate,
                  child: ExcludeSemantics(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: activate,
                      child: SizedBox.square(
                        dimension: 44,
                        child: Center(
                          child: ClayAssetIcon(
                            'assets/icons/plus_circle_icon.svg',
                            height: 22,
                            tint: _purchaseModalGold,
                          ),
                        ),
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
    final borderRadius = BorderRadius.circular(16);
    final textStyle = context.textTheme.button.copyWith(
      color: isPrimary ? AppColors.textInverse : ModalGlassTokens.text,
    );

    return Semantics(
      button: true,
      label: text,
      enabled: onPressed != null,
      onTap: onPressed == null ? null : LotusFeedback.action(onPressed!),
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 50,
            minWidth: double.infinity,
          ),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: Center(
                    child: Text(
                      text,
                      style: textStyle,
                      textAlign: TextAlign.center,
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
