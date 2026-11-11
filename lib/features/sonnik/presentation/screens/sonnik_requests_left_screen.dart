import 'package:asteria_app/core/config/app_feature_visibility.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SonnikRequestsLeftScreen extends StatelessWidget {
  final VoidCallback onBuyRequestsPressed;
  final VoidCallback onSubscriptionPressed;

  const SonnikRequestsLeftScreen({
    Key? key,
    required this.onBuyRequestsPressed,
    required this.onSubscriptionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (context.watch<MonetizationProvider>().effectivePro) {
      return Column(
        children: [
          Text(
            context.l10n.unlimited,
            style: context.textTheme.inversePlayfairSemiBold24,
          ),
          LotusButtons.text(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.commonBack),
          ),
        ],
      );
    }
    final quota = context.watch<MonetizationProvider>().requestQuota('sonnik');
    final requestsLeft = quota.totalRemaining;
    final daysUntilReset = quota.daysUntilReset;
    final title = requestsLeft == 0
        ? context.l10n.requestsExhausted
        : context.l10n.requestsLeftThisWeek(requestsLeft);
    final subtitle = requestsLeft == 0
        ? context.l10n.freeRequestsResetIn(daysUntilReset)
        : context.l10n.requestLimitResetIn(daysUntilReset);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          title,
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            height: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          subtitle,
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            color: SonnikPalette.white.withValues(alpha: 0.78),
          ),
        ),
        const SizedBox(height: 28),
        _SonnikProCard(onTap: onSubscriptionPressed),
        const SizedBox(height: 12),
        _SonnikBuyAttemptsCard(onTap: onBuyRequestsPressed),
        const SizedBox(height: 20),
        const _SonnikProBenefits(),
        const SizedBox(height: 18),
        Text(
          context.l10n.purchasedAttemptsCombine,
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            color: SonnikPalette.white.withValues(alpha: 0.62),
          ),
        ),
      ]),
    );
  }
}

class _SonnikProCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SonnikProCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SonnikGlassPanel(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -22,
            child: Image.asset(SonnikAssets.proCrystal, width: 112),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 82),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SonnikPill(
                  child: Text(
                    context.l10n.unlimited,
                    style: context.textTheme.inverseUrbanistSemiBold17.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _OfferTitleRow(title: context.l10n.offerProTitle),
                const SizedBox(height: 10),
                Text(
                  context.l10n.offerUnlimitedDescription,
                  style: context.textTheme.inverseUrbanistRegular16.copyWith(
                    color: SonnikPalette.white.withValues(alpha: 0.78),
                    height: 1.22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SonnikBuyAttemptsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SonnikBuyAttemptsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SonnikGlassPanel(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.noSubscriptionQuestion,
                  style: context.textTheme.inverseUrbanistRegular16.copyWith(
                    color: SonnikPalette.white.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 8),
                _OfferTitleRow(title: context.l10n.buyAttempts),
                const SizedBox(height: 12),
                SonnikPill(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${context.l10n.questionCoinPrice(7)} ',
                        style: context.textTheme.inverseUrbanistSemiBold17
                            .copyWith(fontSize: 14),
                      ),
                      LotusRasterIcon(
                        'assets/icons/star_coin_icon.png',
                        height: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          LotusRasterIcon('assets/icons/star_coin_icon.png', width: 42),
        ],
      ),
    );
  }
}

class _SonnikProBenefits extends StatelessWidget {
  const _SonnikProBenefits();

  @override
  Widget build(BuildContext context) {
    final benefits = [
      context.l10n.subscriptionBenefitUnlimited,
      if (AppFeatureVisibility.horoscopes)
        context.l10n.subscriptionBenefitHoroscope,
      context.l10n.subscriptionBenefitMoon,
      context.l10n.subscriptionBenefitCompatibility,
      context.l10n.subscriptionBenefitAffirmations,
    ];

    return SonnikGlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.subscriptionBenefitsTitle,
            style: context.textTheme.inversePlayfairSemiBold17,
          ),
          const SizedBox(height: 12),
          for (final benefit in benefits) ...[
            _BenefitRow(text: benefit),
            if (benefit != benefits.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;

  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClayIcon(
          Icons.check_circle_rounded,
          color: SonnikPalette.gold,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.inverseUrbanistRegular16.copyWith(
              color: SonnikPalette.white.withValues(alpha: 0.8),
              height: 1.22,
            ),
          ),
        ),
      ],
    );
  }
}

class _OfferTitleRow extends StatelessWidget {
  final String title;

  const _OfferTitleRow({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.text1SemiBold.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        const ClayIcon(
          Icons.arrow_forward_rounded,
          color: SonnikPalette.white,
          size: 20,
        ),
      ],
    );
  }
}
