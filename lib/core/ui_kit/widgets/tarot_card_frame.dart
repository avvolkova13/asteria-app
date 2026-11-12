import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

/// A consistent, fine gold edge that keeps tarot artwork distinct from its surface.
class TarotCardFrame extends StatelessWidget {
  const TarotCardFrame({super.key, required this.child, this.radius = 12});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColorsDark.linkGold.withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: borderRadius,
      ),
      child: ClipRRect(borderRadius: borderRadius, child: child),
    );
  }
}
