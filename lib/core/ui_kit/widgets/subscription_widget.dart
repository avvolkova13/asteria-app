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
    this.isActive,
    this.semanticLabel,
    this.labelStyle,
    this.originSurface = 'top_nav_pro_badge',
  });

  final VoidCallback? onTap;
  final bool? isActive;
  final String? semanticLabel;
  final TextStyle? labelStyle;
  final String originSurface;

  @override
  Widget build(BuildContext context) {
    final active =
        isActive ??
        MonetizationProvider.maybeOf(context)?.effectivePro ??
        false;
    final badge = ProBadgeSurface(
      isActive: active,
      labelStyle: labelStyle ?? context.textTheme.inversePlayfairSemiBold17,
    );

    final label = semanticLabel ?? 'PRO';
    if (ModalRoute.settingsOf(context)?.name == SubscriptionRoute.routeName) {
      return Semantics(label: label, excludeSemantics: true, child: badge);
    }
    final open =
        onTap ??
        () => SubscriptionRoute.push(
          context,
          params: SubscriptionRouteParams(originSurface: originSurface),
        );
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: LotusFeedback.action(open),
      child: LotusTap(
        behavior: HitTestBehavior.opaque,
        onTap: open,
        child: SizedBox(width: 76, height: 44, child: Center(child: badge)),
      ),
    );
  }
}
