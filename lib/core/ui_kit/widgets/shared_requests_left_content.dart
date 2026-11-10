import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

class SharedRequestsLeftContent extends StatelessWidget {
  final int requestsLeft;
  final int daysUntilReset;
  final VoidCallback onBuyRequestsPressed;
  final VoidCallback onSubscriptionPressed;

  const SharedRequestsLeftContent({
    Key? key,
    required this.requestsLeft,
    required this.daysUntilReset,
    required this.onBuyRequestsPressed,
    required this.onSubscriptionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (requestsLeft == 0)
          Text(
            context.l10n.requestsExhausted,
            style: context.textTheme.playfairSemiBold24,
          )
        else
          _RequestsLeftBlock(
            requestsLeft: requestsLeft,
            daysUntilReset: daysUntilReset,
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _PurchaseBlock(
                title: context.l10n.offerProTitle,
                subtitle: _SubscriptionSubtitle(),
                onPressed: onSubscriptionPressed,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _PurchaseBlock(
                title: context.l10n.buyAttempts,
                subtitle: const _BuyRequestsSubtitle(),
                onPressed: onBuyRequestsPressed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.purchasedAttemptsCombine,
          style: context.textTheme.tertiaryUrbanistRegular16,
        ),
        const SizedBox(height: 300),
      ],
    );
  }
}

class _RequestsLeftBlock extends StatelessWidget {
  final int requestsLeft;
  final int daysUntilReset;

  const _RequestsLeftBlock({
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
          style: context.textTheme.playfairSemiBold24,
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.limitResetsIn(daysUntilReset),
          style: context.textTheme.playfairSemiBold24,
        ),
      ],
    );
  }
}

class _SubscriptionSubtitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        context.l10n.unlimited,
        style: context.textTheme.inverseUrbanistRegular16,
      ),
    );
  }
}

class _BuyRequestsSubtitle extends StatelessWidget {
  const _BuyRequestsSubtitle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${context.l10n.questionCoinPrice(10)} ',
            style: context.textTheme.inverseUrbanistRegular16,
          ),
          Image.asset('assets/icons/star_coin_icon.png', height: 14),
        ],
      ),
    );
  }
}

class _PurchaseBlock extends StatelessWidget {
  final String title;
  final Widget subtitle;
  final VoidCallback onPressed;

  const _PurchaseBlock({
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: AssetImage('assets/images/home/birth_map_bg.webp'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: context.textTheme.inversePlayfairMedium20,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ClayAssetIcon(
                    'assets/icons/cursor_icon.svg',
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
              const SizedBox(height: 45),
              subtitle,
            ],
          ),
        ),
      ),
    );
  }
}
