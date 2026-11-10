import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class SubscriptionWidget extends StatelessWidget {
  const SubscriptionWidget({
    super.key,
    this.onTap,
    this.originSurface = 'top_nav_pro_badge',
  });

  final VoidCallback? onTap;
  final String originSurface;

  static const _gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF3B76A), Color(0xFF8A6BFF), Color(0xFF5A3FD1)],
    stops: [0, 0.50032, 1],
  );

  @override
  Widget build(BuildContext context) {
    final badge = Transform.translate(
      offset: const Offset(0, -2),
      child: Container(
        width: 76,
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          gradient: _gradient,
          borderRadius: BorderRadius.circular(100),
        ),
        alignment: Alignment.center,
        child: Text('PRO', style: context.textTheme.inversePlayfairSemiBold17),
      ),
    );

    return Semantics(
      button: true,
      label: 'PRO',
      child: GestureDetector(
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
