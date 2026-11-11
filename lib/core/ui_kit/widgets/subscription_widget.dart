import 'package:asteria_app/core/ui_kit/widgets/pro_badge_surface.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class SubscriptionWidget extends StatelessWidget {
  const SubscriptionWidget({
    super.key,
    this.onTap,
    this.labelStyle,
    this.originSurface = 'top_nav_pro_badge',
  });

  final VoidCallback? onTap;
  final TextStyle? labelStyle;
  final String originSurface;

  @override
  Widget build(BuildContext context) {
    final active = MonetizationProvider.maybeOf(context)?.effectivePro ?? false;
    final badge = ProBadgeSurface(
      isActive: active,
      labelStyle: labelStyle ?? context.textTheme.inversePlayfairSemiBold17,
    );

    return Semantics(
      button: true,
      label: 'PRO',
      child: LotusTap(
        behavior: HitTestBehavior.opaque,
        onTap:
            onTap ??
            () => SubscriptionRoute.push(
              context,
              params: SubscriptionRouteParams(originSurface: originSurface),
            ),
        child: badge,
      ),
    );
  }
}
