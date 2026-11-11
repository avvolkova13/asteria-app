import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/const/purchase_products_const.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class NatalCardEmptyScreen extends StatelessWidget {
  final VoidCallback onBuyPressed;
  final bool isPro;

  const NatalCardEmptyScreen({required this.onBuyPressed, this.isPro = false});

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
            const _InsideCard(),
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
  static const glass = Color(0x339A7DB8);
  static const glassBorder = Color(0x33FFFFFF);
  static const orangeStart = Color(0xFFE6994D);
  static const orangeMid = Color(0xFFF3B76A);
  static const purpleStart = Color(0xFF6E4BFF);
  static const purpleEnd = Color(0xFF5A3FD1);

  static const orangeGradient = LinearGradient(
    colors: [orangeStart, orangeMid, orangeStart],
    stops: [0, 0.5, 1],
  );

  static const purpleGradient = LinearGradient(
    colors: [purpleStart, purpleEnd],
  );
}

class _InsideCard extends StatelessWidget {
  const _InsideCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 260),
      padding: const EdgeInsets.all(16),
      decoration: CardLensDecoration(
        color: _NatalPaywall.glass,
        borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
        border: Border.all(color: _NatalPaywall.glassBorder, width: 0.7),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 300;
          final wandWidth = isCompact ? 82.0 : 105.0;
          final wandHeight = wandWidth * 157 / 105;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.natalInsideTitle,
                style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _InsideFeatureItem(
                          title: '${context.l10n.natalElementsModalities} ',
                          description: context.l10n.natalElementsDescription,
                        ),
                        const SizedBox(height: 8),
                        _InsideFeatureItem(
                          title: '${context.l10n.natalHousesThemes} ',
                          description: context.l10n.natalHousesDescription,
                        ),
                        const SizedBox(height: 8),
                        _InsideFeatureItem(
                          title: '${context.l10n.natalMagicSummary} ',
                          description: context.l10n.natalSummaryDescription,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Image.asset(
                      'assets/images/home/natal_paywall_wand.webp',
                      width: wandWidth,
                      height: wandHeight,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InsideFeatureItem extends StatelessWidget {
  final String title;
  final String description;

  const _InsideFeatureItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: const LotusRasterIcon(
            'assets/icons/clay/moon_icon.webp',
            width: 19,
            height: 19,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: _GradientText(
                    title,
                    gradient: _NatalPaywall.orangeGradient,
                    style: context.textTheme.inverseUrbanistSemiBold16.copyWith(
                      height: 1.2,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                TextSpan(
                  text: description,
                  style: context.textTheme.inverseUrbanistRegular16.copyWith(
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
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
    return DecoratedBox(
      decoration: CardLensDecoration.button(
        gradient: _NatalPaywall.purpleGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.1),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: _NatalPaywall.purpleStart.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.white.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SizedBox(
        height: 50,
        child: Semantics(
          button: true,
          label: isPro
              ? context.l10n.natalCreateCard
              : context.l10n.buyNatalCardLabel(
                  PurchaseProductsConst.natalCard.price,
                ),
          child: LotusButtons.text(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isPro ? context.l10n.natalCreateCard : context.l10n.commonBuy,
              textAlign: TextAlign.center,
              style: context.textTheme.button.copyWith(
                color: AppColors.white,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle style;

  const _GradientText(this.text, {required this.gradient, required this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
