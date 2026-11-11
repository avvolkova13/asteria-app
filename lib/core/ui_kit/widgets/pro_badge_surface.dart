import 'package:asteria_app/core/ui_kit/app_typography.dart';
import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

import 'card_lens_decoration.dart';
import 'clay_icon.dart';
import 'lotus_icon_surface.dart';

/// Shared visual surface. Its caller owns navigation and accessibility actions.
class ProBadgeSurface extends StatelessWidget {
  const ProBadgeSurface({super.key, required this.isActive, this.labelStyle});

  final bool isActive;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final radius = LotusPebbleContour.action.resolve(76, 28);
    return SizedBox(
      width: 76,
      height: 28,
      child: DecoratedBox(
        decoration: CardLensDecoration(
          borderRadius: radius,
          intensity: .72,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? const [
                    Color(0xB3F3B76A),
                    Color(0x998A6BFF),
                    Color(0x805A3FD1),
                  ]
                : const [
                    Color(0x557E6AA4),
                    Color(0x335A3F7A),
                    Color(0x4D8A6BBA),
                  ],
            stops: const [0, .52, 1],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PRO',
                  style: (labelStyle ?? AppTypography.navTitle).copyWith(
                    color: AppColors.textInverse,
                    height: 1,
                  ),
                  maxLines: 1,
                  softWrap: false,
                ),
                if (!isActive) ...[
                  const SizedBox(width: 4),
                  const ClayIcon(
                    Icons.lock_rounded,
                    size: 12,
                    color: AppColors.textInverse,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
