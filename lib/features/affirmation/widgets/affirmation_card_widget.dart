import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

class AffirmationCardWidget extends StatelessWidget {
  final AffirmationModel affirmation;
  final int imageIndex;
  final double borderOpacity;

  const AffirmationCardWidget({
    super.key,
    required this.affirmation,
    required this.imageIndex,
    this.borderOpacity = 0.1,
  });

  String _getImageName() {
    switch (affirmation.effectiveCategoryId) {
      case 'love':
        return 'love';
      case 'abundance':
        return 'izobilie';
      case 'strength':
        return 'power';
      case 'creativity':
        return 'creative';
      case 'lunar':
        return 'moon';
      case 'calm':
        return 'calm';
      default:
        return 'love';
    }
  }

  String get imageAssetPath {
    final normalizedImageIndex = (imageIndex % 3 + 3) % 3;
    final imageSuffix = normalizedImageIndex == 0
        ? ''
        : '_${normalizedImageIndex + 1}';

    return 'assets/images/affirmation/'
        'category_${_getImageName()}$imageSuffix.webp';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
      child: Container(
        foregroundDecoration: CardLensDecoration(
          borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
          border: Border.all(
            color: AppColors.white.withValues(alpha: borderOpacity),
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Reuse the portrait scene's ambient colours outside its frame.
            Image.asset(
              imageAssetPath,
              fit: BoxFit.fill,
              cacheWidth: 3,
              excludeFromSemantics: true,
            ),
            LayoutBuilder(
              builder: (_, bounds) => Center(
                child: SizedBox(
                  width: bounds.maxHeight * 450 / 560,
                  height: bounds.maxHeight,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white,
                        Colors.white,
                        Colors.transparent,
                      ],
                      stops: [0, .09, .91, 1],
                    ).createShader,
                    child: Image.asset(
                      imageAssetPath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00151028), Color(0xFF151028)],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: const _CardIconButton(icon: Icons.play_arrow),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Text(
                affirmation.text,
                style: context.textTheme.inverseUrbanistRegular16.copyWith(
                  height: 1.2,
                  letterSpacing: -0.408,
                ),
                textAlign: TextAlign.left,
                maxLines: 8,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardIconButton extends StatelessWidget {
  final IconData icon;

  const _CardIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: ClayIcon(
        icon,
        size: 20,
        color: AppColors.white.withValues(alpha: 0.74),
      ),
    );
  }
}
