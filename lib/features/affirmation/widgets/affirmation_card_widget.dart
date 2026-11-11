import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

class AffirmationCardWidget extends StatelessWidget {
  final AffirmationModel affirmation;
  final int imageIndex;
  final List<AffirmationModel>? deck;
  final double borderOpacity;
  final bool isFront;
  final bool showSwipeHint;
  final GestureDragUpdateCallback? onSwipe;
  final GestureDragEndCallback? onSwipeEnd;
  final VoidCallback? onSwipeCancel;

  const AffirmationCardWidget({
    super.key,
    required this.affirmation,
    required this.imageIndex,
    this.deck,
    this.borderOpacity = 0.1,
    this.isFront = true,
    this.showSwipeHint = false,
    this.onSwipe,
    this.onSwipeEnd,
    this.onSwipeCancel,
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
        color: AppColorsDark.modal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: onSwipe,
              onVerticalDragEnd: onSwipeEnd,
              onVerticalDragCancel: onSwipeCancel,
              child: SizedBox(
                height: 216,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imageAssetPath,
                      fit: BoxFit.fill,
                      cacheWidth: 3,
                      excludeFromSemantics: true,
                    ),
                    Center(
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: const LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white,
                              Colors.white,
                              Colors.transparent,
                            ],
                            stops: [0, .1, .9, 1],
                          ).createShader,
                          child: Image.asset(
                            imageAssetPath,
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                          ),
                        ),
                      ),
                    ),
                    if (isFront)
                      const Positioned(
                        top: 12,
                        right: 14,
                        child: _CardIconButton(icon: Icons.play_arrow),
                      ),
                    if (isFront && showSwipeHint)
                      const Positioned(
                        bottom: 12,
                        right: 14,
                        child: _CardIconButton(icon: Icons.swap_vert_rounded),
                      ),
                  ],
                ),
              ),
            ),
            if (isFront)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: IndexedStack(
                  index: deck == null ? 0 : imageIndex,
                  children: [
                    for (final card in deck ?? [affirmation])
                      Text(
                        card.text,
                        style: context.textTheme.inverseUrbanistRegular16
                            .copyWith(height: 1.3),
                        textAlign: TextAlign.start,
                      ),
                  ],
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
