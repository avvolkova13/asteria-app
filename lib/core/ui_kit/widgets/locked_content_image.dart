import 'package:asteria_app/core/ui_kit/widgets/artwork_unavailable.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

class LockedContentImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final bool isLocked;
  final BoxFit fit;
  final double borderRadius;
  final VoidCallback? onTap;

  const LockedContentImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.isLocked = false,
    this.fit = BoxFit.cover,
    this.borderRadius = 12,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LotusTap(
      onTap: isLocked ? null : onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            Image.asset(
              imagePath,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return ArtworkUnavailable(
                  width: width,
                  height: height,
                  radius: borderRadius,
                );
              },
            ),
            if (isLocked)
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Center(
                  child: ClayAssetIcon(
                    'assets/icons/white_lock_icon.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
