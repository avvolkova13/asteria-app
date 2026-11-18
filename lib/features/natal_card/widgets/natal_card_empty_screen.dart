import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/features/monetization/presentation/paywall_features_card.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/const/purchase_products_const.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class NatalCardEmptyScreen extends StatelessWidget {
  final VoidCallback onBuyPressed;
  final bool isPro;

  const NatalCardEmptyScreen({
    super.key,
    required this.onBuyPressed,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _NatalPaywall.maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: AsteriaEntrance.sections([
            Text(
              isPro
                  ? context.l10n.natalIncludedInPro
                  : context.l10n.natalCardPriceTitle(
                      PurchaseProductsConst.natalCard.price,
                    ),
              textAlign: TextAlign.center,
              style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                height: 1,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              context.l10n.natalPaywallIntro,
              textAlign: TextAlign.left,
              style: context.textTheme.inverseUrbanistRegular16.copyWith(
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 16),
            PaywallFeaturesCard(
              features: [
                PaywallFeatureItem(
                  title: context.l10n.natalElementsModalities,
                  description: context.l10n.natalElementsDescription,
                ),
                PaywallFeatureItem(
                  title: context.l10n.natalHousesThemes,
                  description: context.l10n.natalHousesDescription,
                ),
                PaywallFeatureItem(
                  title: context.l10n.natalMagicSummary,
                  description: context.l10n.natalSummaryDescription,
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _ForeverAccessItem(),
            const SizedBox(height: 18),
            _BuyButton(onPressed: onBuyPressed, isPro: isPro),
            const SizedBox(height: 8),
            Text(
              isPro
                  ? context.l10n.natalProAccessDescription
                  : context.l10n.natalInstantAccess,
              style: context.textTheme.inverseUrbanistRegular12.copyWith(
                color: AppColors.white.withValues(alpha: 0.82),
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _NatalPaywall {
  static const maxWidth = 358.0;

}

class _ForeverAccessItem extends StatelessWidget {
  const _ForeverAccessItem();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: const LotusRasterIcon(
            'assets/icons/clay/star_icon.webp',
            width: 19,
            height: 19,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            context.l10n.natalForeverDescription,
            style: context.textTheme.inverseUrbanistSemiBold16.copyWith(
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _BuyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isPro;

  const _BuyButton({required this.onPressed, required this.isPro});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isPro
          ? context.l10n.natalCreateCard
          : context.l10n.buyNatalCardLabel(
              PurchaseProductsConst.natalCard.price,
            ),
      child: AsteriaActionButton(
        text: isPro ? context.l10n.natalCreateCard : context.l10n.commonBuy,
        onPressed: onPressed,
        width: double.infinity,
      ),
    );
  }
}
