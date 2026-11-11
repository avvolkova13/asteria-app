import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:flutter/material.dart';

class SubscriptionActiveStatusWidget extends StatelessWidget {
  const SubscriptionActiveStatusWidget({
    super.key,
    required this.onTap,
    this.nextPaymentDateText,
    this.oneTimeAccess = false,
  });

  final VoidCallback onTap;
  final String? nextPaymentDateText;
  final bool oneTimeAccess;

  @override
  Widget build(BuildContext context) {
    final paymentText = oneTimeAccess
        ? (nextPaymentDateText?.isNotEmpty == true
              ? '${context.l10n.subscriptionAccessUntil}${nextPaymentDateText!}'
              : context.l10n.subscriptionAvailableToYou)
        : (nextPaymentDateText?.isNotEmpty == true
              ? context.l10n.subscriptionNextPaymentOn(nextPaymentDateText!)
              : context.l10n.subscriptionNextPayment);

    return _SubscriptionStatusCard(
      onTap: onTap,
      title: context.l10n.subscriptionActive,
      subtitle: paymentText,
      actionText: context.l10n.manage,
      actionColor: ProfileFlowColors.accent,
    );
  }
}

class SubscriptionInactiveStatusWidget extends StatelessWidget {
  const SubscriptionInactiveStatusWidget({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SubscriptionStatusCard(
      onTap: onTap,
      title: context.l10n.subscriptionInactive,
      subtitle: context.l10n.subscriptionInactiveDescription,
      buttonText: context.l10n.subscriptionConnect,
    );
  }
}

class _SubscriptionStatusCard extends StatelessWidget {
  const _SubscriptionStatusCard({
    required this.onTap,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.actionText,
    this.actionColor,
  });

  static const _cardHeight = 224.0;
  static const _cardColor = Color(0x339A7DB8);

  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final String? buttonText;
  final String? actionText;
  final Color? actionColor;

  @override
  Widget build(BuildContext context) {
    return ProfileGlassCard(
      color: _cardColor,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final artWidth = (constraints.maxWidth * .32).clamp(68.0, 116.0);
          return Container(
            key: const ValueKey('profile-subscription-status-card'),
            constraints: const BoxConstraints(minHeight: _cardHeight),
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: context.textTheme.inversePlayfairSemiBold24
                                .copyWith(height: 1),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle.replaceAll('\n', ' '),
                            style: context.textTheme.inverseUrbanistRegular16
                                .copyWith(height: 1.2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      'assets/images/home/balance_subscription_art.webp',
                      key: const ValueKey('profile-subscription-status-art'),
                      width: artWidth,
                      height: artWidth * 1.05,
                      cacheWidth: 500,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (buttonText != null)
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: 44,
                      minWidth: 175,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: CardLensDecoration.button(
                      color: ProfileFlowColors.accent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      buttonText!,
                      textAlign: TextAlign.center,
                      style: context.textTheme.urbanistRegular17.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  )
                else if (actionText != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          actionText!,
                          style: AppTypography.text1SemiBold.copyWith(
                            color: actionColor ?? ProfileFlowColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ClayIcon(
                        Icons.chevron_right,
                        size: 16,
                        color: actionColor ?? ProfileFlowColors.accent,
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
