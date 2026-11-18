import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
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
    final date = nextPaymentDateText?.trim();
    final paymentText = date == null || date.isEmpty
        ? null
        : oneTimeAccess
        ? '${context.l10n.subscriptionAccessUntil}$date'
        : context.l10n.subscriptionNextPaymentOn(date);

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
  final String? subtitle;
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
          final stackContent =
              constraints.maxWidth <
              MediaQuery.textScalerOf(context).scale(16) * 18;
          final artWidth = buttonText == null
              ? (constraints.maxWidth * .41).clamp(80.0, 152.0)
              : (constraints.maxWidth * .35).clamp(76.0, 122.0);
          return Container(
            key: const ValueKey('profile-subscription-status-card'),
            constraints: const BoxConstraints(minHeight: _cardHeight),
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flex(
                  direction: stackContent ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: stackContent ? 0 : 1,
                      fit: stackContent ? FlexFit.loose : FlexFit.tight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: context.textTheme.inversePlayfairSemiBold24
                                .copyWith(height: 1),
                          ),
                          if (subtitle case final text?) ...[
                            const SizedBox(height: 8),
                            Text(
                              text.replaceAll('\n', ' '),
                              style: context.textTheme.inverseUrbanistRegular16
                                  .copyWith(height: 1.2),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!stackContent) const SizedBox(width: 12),
                    if (!stackContent)
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
                  AsteriaActionButton(
                    text: buttonText!,
                    gold: true,
                    onPressed: onTap,
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
