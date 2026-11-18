import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/features/monetization/presentation/paywall_features_card.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:flutter/material.dart';

class HoroscopeEmptyScreen extends StatelessWidget {
  final VoidCallback onBuyPressed;

  const HoroscopeEmptyScreen({super.key, required this.onBuyPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _HoroscopePaywall.maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: AsteriaEntrance.sections([
            Text(
              context.l10n.yearHoroscopePriceTitle(
                HoroscopeTypeEnum.year.price,
              ),
              textAlign: TextAlign.center,
              style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                height: 1,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              context.l10n.yearHoroscopeIntro,
              textAlign: TextAlign.left,
              style: context.textTheme.inverseUrbanistRegular16.copyWith(
                height: 1.2,
                letterSpacing: -0.408,
              ),
            ),
            const SizedBox(height: 16),
            PaywallFeaturesCard(
              features: [
                PaywallFeatureItem(
                  title: context.l10n.horoscopeEssence,
                  description: context.l10n.horoscopeEssenceDescription,
                ),
                PaywallFeatureItem(
                  title: context.l10n.horoscopeLifeAreas,
                  description: context.l10n.horoscopeLifeAreasDescription,
                ),
                PaywallFeatureItem(
                  title: context.l10n.horoscopeEvolution,
                  description: context.l10n.horoscopeEvolutionDescription,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              context.l10n.yearHoroscopeChapters,
              style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                height: 1,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 16),
            const _ChapterIncludesList(),
            const SizedBox(height: 18),
            _BuyButton(onPressed: onBuyPressed),
            const SizedBox(height: 8),
            Text(
              context.l10n.natalInstantAccess,
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

class _HoroscopePaywall {
  static const maxWidth = 358.0;

}

class _ChapterIncludesList extends StatelessWidget {
  const _ChapterIncludesList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AsteriaEntrance.sections([
        _ChapterItem(text: context.l10n.horoscopeGeneral, isStrong: true),
        const SizedBox(height: 8),
        _ChapterItem(text: context.l10n.horoscopeWeakPoints, isStrong: true),
        const SizedBox(height: 8),
        _ChapterItem(
          text: context.l10n.horoscopePersonalAdvice,
          isStrong: true,
        ),
        const SizedBox(height: 8),
        _ChapterItem(text: context.l10n.horoscopeLifetimeDescription),
      ]),
    );
  }
}

class _ChapterItem extends StatelessWidget {
  final String text;
  final bool isStrong;

  const _ChapterItem({required this.text, this.isStrong = false});

  @override
  Widget build(BuildContext context) {
    final regularStyle = context.textTheme.inverseUrbanistRegular16.copyWith(
      height: 1.2,
      letterSpacing: -0.408,
    );
    final strongStyle = context.textTheme.inverseUrbanistSemiBold16.copyWith(
      height: 1.2,
      letterSpacing: -0.408,
    );

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
          child: Text(text, style: isStrong ? strongStyle : regularStyle),
        ),
      ],
    );
  }
}

class _BuyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BuyButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.buyYearHoroscopeLabel(HoroscopeTypeEnum.year.price),
      child: AsteriaActionButton(
        text: context.l10n.commonBuy,
        onPressed: onPressed,
        width: double.infinity,
      ),
    );
  }
}
