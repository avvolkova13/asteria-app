import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compatibility_layout.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _accentColor = Color(0xFFFFB45E);
const _glassCardGradient = LinearGradient(
  colors: [Color(0x339A7DB8), Color(0x339A7DB8)],
);

class CompatibilityRequestsLeftScreen extends StatelessWidget {
  final VoidCallback onBuyRequestsPressed;
  final VoidCallback onSubscriptionPressed;

  const CompatibilityRequestsLeftScreen({
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
    final quota = context.watch<MonetizationProvider>().requestQuota(
      'compatibility',
    );
    final requestsLeft = quota.totalRemaining;
    final daysUntilReset = quota.daysUntilReset;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RequestsLeftBadge(requestsLeft: requestsLeft),
        const SizedBox(height: 179),
        if (requestsLeft == 0)
          _NoRequestsLeftTitle(daysUntilReset: daysUntilReset)
        else
          _RequestsLeftTitle(
            requestsLeft: requestsLeft,
            daysUntilReset: daysUntilReset,
          ),
        const SizedBox(height: 16),
        _SubscriptionOfferCard(onTap: onSubscriptionPressed),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _BuyAttemptsCard(onTap: onBuyRequestsPressed)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                context.l10n.purchasedAttemptsAdd,
                style: context.textTheme.tertiaryUrbanistRegular16.copyWith(
                  height: 1.2,
                  letterSpacing: -0.408,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RequestsLeftBadge extends StatelessWidget {
  final int requestsLeft;

  const _RequestsLeftBadge({required this.requestsLeft});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: _accentColor,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          context.l10n.requestsRemaining(requestsLeft, 3),
          style: context.textTheme.urbanistRegular12.copyWith(
            color: AppColors.textPrimary,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _RequestsLeftTitle extends StatelessWidget {
  final int requestsLeft;
  final int daysUntilReset;

  const _RequestsLeftTitle({
    required this.requestsLeft,
    required this.daysUntilReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.requestsLeftThisWeek(requestsLeft),
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.limitResetsIn(daysUntilReset),
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            height: 1.2,
            letterSpacing: -0.408,
          ),
        ),
      ],
    );
  }
}

class _NoRequestsLeftTitle extends StatelessWidget {
  final int daysUntilReset;

  const _NoRequestsLeftTitle({required this.daysUntilReset});

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
        const SizedBox(height: 14),
        Text(
          context.l10n.freeLimitResetsIn(daysUntilReset),
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            height: 1.2,
            letterSpacing: -0.408,
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
    return LotusTap(
      onTap: onTap,
      child: CompatibilityGlassCard(
        padding: const EdgeInsets.all(16),
        gradient: _glassCardGradient,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 125),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OfferHeader(title: context.l10n.offerProTitle),
                    const SizedBox(height: 17),
                    Text(
                      context.l10n.offerIncludesTitle,
                      style: context.textTheme.inversePlayfairSemiBold17
                          .copyWith(height: 22 / 17, letterSpacing: -0.408),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 226,
                      child: Text(
                        context.l10n.offerUnlimitedDescription,
                        style: context.textTheme.inverseUrbanistRegular16
                            .copyWith(height: 1.2, letterSpacing: -0.408),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -2,
                bottom: -4,
                child: Image.asset(
                  'assets/images/sonnik/pro_crystal.webp',
                  width: 89,
                  height: 103,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
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
    return LotusTap(
      onTap: onTap,
      child: SizedBox(
        height: 93,
        child: CompatibilityGlassCard(
          padding: const EdgeInsets.all(8),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          gradient: _glassCardGradient,
          child: Stack(
            children: [
              Positioned(top: 0, right: 0, child: const _OfferArrow()),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.noSubscriptionQuestion,
                    style: context.textTheme.tertiaryUrbanistRegular12,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        context.l10n.buyAttempts,
                        style: AppTypography.text1SemiBold.copyWith(color: Colors.white),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _CoinPill(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferHeader extends StatelessWidget {
  final String title;

  const _OfferHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: AppTypography.text1SemiBold.copyWith(color: _accentColor),
              maxLines: 1,
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
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(color: _accentColor),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: ClayAssetIcon(
          'assets/icons/right_arrow_icon.svg',
          width: 10,
          tint: _accentColor,
        ),
      ),
    );
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _accentColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${context.l10n.questionCoinPrice(10)} ',
            style: context.textTheme.urbanistRegular14.copyWith(
              color: AppColors.textPrimary,
              height: 1,
            ),
          ),
          LotusRasterIcon('assets/icons/star_coin_icon.png', height: 14),
        ],
      ),
    );
  }
}
