import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:flutter/material.dart';

class MoonPhaseMarker extends StatelessWidget {
  const MoonPhaseMarker({
    super.key,
    this.size = 12,
    this.color = MoonDesignTokens.selectedDay,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClayAssetIcon(
      'assets/icons/nav_bar/tab_star_icon.svg',
      width: size,
      height: size,
      tint: color,
      excludeFromSemantics: true,
    );
  }
}
