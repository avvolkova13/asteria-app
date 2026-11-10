import 'package:asteria_app/core/ui_kit/ui_kit.dart';
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
          final cardWidth = constraints.maxWidth;
          final compactScale = (cardWidth / 358).clamp(0.86, 1.0);
          final titleWidth = 174.0 * compactScale;
          final descriptionWidth = 170.0 * compactScale;
          final buttonWidth = 175.0 * compactScale;
          final artWidth = 198.0 * compactScale;
          final artHeight = 217.0 * compactScale;

          return SizedBox(
            key: const ValueKey('profile-subscription-status-card'),
            height: _cardHeight,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  top: 4,
                  right: -42,
                  child: Image.asset(
                    key: const ValueKey('profile-subscription-status-art'),
                    'assets/images/home/balance_subscription_art.webp',
                    width: artWidth,
                    height: artHeight,
                    cacheWidth: 500,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: titleWidth,
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontFamily: 'Lora',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: descriptionWidth,
                        child: Text(
                          subtitle,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontFamily: 'Onest',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: -0.41,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (buttonText != null)
                  Positioned(
                    left: 16,
                    bottom: 16,
                    width: buttonWidth,
                    height: 44,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: ProfileFlowColors.accent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          buttonText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'Onest',
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: -0.41,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (actionText != null)
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: actionColor ?? ProfileFlowColors.accent,
                        fontFamily: 'Onest',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        letterSpacing: -0.41,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          color: actionColor ?? ProfileFlowColors.accent,
                          size: 16,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(actionText!),
                            const SizedBox(width: 6),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
