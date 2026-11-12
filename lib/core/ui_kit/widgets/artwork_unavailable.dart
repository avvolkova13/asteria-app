import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

/// Retains the illustration's footprint while an asset is unavailable.
class ArtworkUnavailable extends StatelessWidget {
  const ArtworkUnavailable({
    super.key,
    this.width,
    this.height,
    this.radius = 12,
  });

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: CardLensDecoration(
        color: AppColorsDark.modal,
        borderRadius: BorderRadius.circular(radius),
        intensity: .5,
      ),
      child: const Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ClayIcon(
            Icons.image_not_supported,
            size: 24,
            color: AppColors.uiDisabled,
          ),
        ),
      ),
    );
  }
}
