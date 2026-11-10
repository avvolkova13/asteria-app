import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/widgets/card_advertisement_widget.dart';
import 'package:flutter/material.dart';

class HomeProSubscriptionCard extends StatelessWidget {
  final VoidCallback onPressed;
  final double? horizontalMargin;
  final bool compactHome;

  const HomeProSubscriptionCard({
    super.key,
    required this.onPressed,
    this.horizontalMargin,
    this.compactHome = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compactHome) {
      return _CompactHomePromo(
        key: const ValueKey('home-pro-subscription-card'),
        horizontalMargin: horizontalMargin ?? 16,
        onPressed: onPressed,
      );
    }
    return CardAdvertisementWidget(
      key: const ValueKey('home-pro-subscription-card'),
      variant: CardAdvertisementVariant.balanceSubscriptionBanner,
      title: context.l10n.homeProSubscriptionTitle,
      description: context.l10n.homeProSubscriptionDescription,
      buttonText: context.l10n.homeProSubscriptionCta,
      onPressed: onPressed,
      horizontalMargin: horizontalMargin,
    );
  }
}

class _CompactHomePromo extends StatelessWidget {
  const _CompactHomePromo({
    super.key,
    required this.horizontalMargin,
    required this.onPressed,
  });

  final double horizontalMargin;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x339A7DB8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final artWidth = (constraints.maxWidth * 99 / 358).clamp(0.0, 99.0);
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 131),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.homeProSubscriptionTitle,
                                style: context
                                    .textTheme
                                    .inversePlayfairSemiBold24
                                    .copyWith(fontFamily: 'Lora', height: 1),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.l10n.homeProSubscriptionDescription,
                                style: context
                                    .textTheme
                                    .inverseUrbanistRegular16
                                    .copyWith(fontFamily: 'Onest'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Image.asset(
                          'assets/images/home/home_subscription_orb.webp',
                          width: artWidth,
                          height: artWidth * 115 / 99,
                          excludeFromSemantics: true,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: onPressed,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        minimumSize: const Size(0, 48),
                        visualDensity: VisualDensity.standard,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Ink(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE6994D),
                              Color(0xFFF3B76A),
                              Color(0xFFE6994D),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          context.l10n.homeProSubscriptionCta,
                          textAlign: TextAlign.center,
                          style: context.textTheme.urbanistRegular17.copyWith(
                            fontFamily: 'Onest',
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
