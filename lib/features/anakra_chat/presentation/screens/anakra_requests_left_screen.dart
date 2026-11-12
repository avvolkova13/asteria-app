import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_layout.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnakraRequestsLeftScreen extends StatelessWidget {
  final VoidCallback onBuyRequestsPressed;
  final VoidCallback onSubscriptionPressed;

  const AnakraRequestsLeftScreen({
    super.key,
    required this.onBuyRequestsPressed,
    required this.onSubscriptionPressed,
  });

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
    final quota = context.watch<MonetizationProvider>().requestQuota('anakra');
    final freeRequestsLeft = quota.freeRemaining;
    final paidRequestsLeft = quota.paidRemaining;
    final hasAnyRequests = freeRequestsLeft > 0 || paidRequestsLeft > 0;
    final daysUntilReset = quota.daysUntilReset;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        const SizedBox(height: 24),
        if (!hasAnyRequests)
          _NoRequestsTitle(daysUntilReset: daysUntilReset)
        else
          _RequestsTitle(
            freeRequestsLeft: freeRequestsLeft,
            paidRequestsLeft: paidRequestsLeft,
            daysUntilReset: daysUntilReset,
          ),
        const SizedBox(height: 16),
        _SubscriptionOfferCard(onTap: onSubscriptionPressed),
        const SizedBox(height: 16),
        _BuyAttemptsCard(onTap: onBuyRequestsPressed),
        const SizedBox(height: 10),
        Text(
          context.l10n.purchasedAttemptsAdd,
          style: context.textTheme.tertiaryUrbanistRegular16.copyWith(
            color: AppColors.uiDisabled,
          ),
        ),
      ]),
    );
  }
}

class _RequestsTitle extends StatelessWidget {
  final int freeRequestsLeft;
  final int paidRequestsLeft;
  final int daysUntilReset;

  const _RequestsTitle({
    required this.freeRequestsLeft,
    required this.paidRequestsLeft,
    required this.daysUntilReset,
  });

  @override
  Widget build(BuildContext context) {
    final hasFreeRequests = freeRequestsLeft > 0;
    final hasPaidRequests = paidRequestsLeft > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          [
            if (hasFreeRequests)
              context.l10n.requestsLeftThisWeek(freeRequestsLeft),
            if (hasPaidRequests)
              context.l10n.paidRequestsLeft(paidRequestsLeft),
          ].join('\n'),
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hasFreeRequests
              ? context.l10n.limitResetsIn(daysUntilReset)
              : context.l10n.freeLimitResetsIn(daysUntilReset),
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _NoRequestsTitle extends StatelessWidget {
  final int daysUntilReset;

  const _NoRequestsTitle({required this.daysUntilReset});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.requestsExhausted,
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.limitResetsIn(daysUntilReset),
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            color: AnakraPalette.white.withValues(alpha: 0.82),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _SubscriptionOfferCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SubscriptionOfferCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnakraGlassCard(
      borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
      onTap: onTap,
      semanticLabel: context.l10n.offerProTitle,
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 125),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OfferHeader(title: context.l10n.offerProTitle),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.offerIncludesTitle,
                        style: context.textTheme.inversePlayfairSemiBold17,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.offerUnlimitedDescription,
                        style: context.textTheme.inverseUrbanistRegular16
                            .copyWith(height: 1.2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  AnakraAssets.proCrystal,
                  width: 76,
                  height: 88,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BuyAttemptsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _BuyAttemptsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnakraGlassCard(
      onTap: onTap,
      semanticLabel: context.l10n.buyAttemptsLabel,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.noSubscriptionQuestion,
            style: AppTypography.text2.copyWith(color: AppColors.uiDisabled),
          ),
          const SizedBox(height: 6),
          _OfferHeader(title: _anakraBuyAttemptsTitle(context)),
          const SizedBox(height: 8),
          const _CoinPill(),
        ],
      ),
    );
  }
}

String _anakraBuyAttemptsTitle(BuildContext context) {
  if (Localizations.localeOf(context).languageCode == 'ru') {
    return 'Купи попытки';
  }
  return context.l10n.buyAttempts;
}

class _OfferHeader extends StatelessWidget {
  final String title;

  const _OfferHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.text1SemiBold.copyWith(
              color: AppColorsDark.linkGold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const _OfferArrow(),
      ],
    );
  }
}

class _OfferArrow extends StatelessWidget {
  const _OfferArrow();

  @override
  Widget build(BuildContext context) {
    return const LotusArrowBubble();
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: CardLensDecoration.button(
        color: AppColorsDark.modal,
        borderRadius: BorderRadius.circular(AsteriaCardRadii.compact),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${context.l10n.questionCoinPrice(7)} ',
              style: context.textTheme.urbanistRegular14.copyWith(
                color: AppColorsDark.linkGold,
                height: 1,
              ),
            ),
            LotusRasterIcon(AnakraAssets.coin, height: 14),
          ],
        ),
      ),
    );
  }
}
