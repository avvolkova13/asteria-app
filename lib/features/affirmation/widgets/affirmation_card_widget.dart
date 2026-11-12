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
                    _CardArtwork(asset: imageAssetPath),
                    if (isFront)
                      const Positioned(
                        top: 12,
                        right: 14,
                        child: _CardIconButton(icon: Icons.play_arrow),
                      ),
                    if (isFront && showSwipeHint)
                      const Center(
                        child: IgnorePointer(child: _SwipeHandHint()),
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

// Keep the subject proportional and extend only the outer edges of its
// original scenery into the margins of the wide card.
class _CardArtwork extends StatelessWidget {
  const _CardArtwork({required this.asset});
  final String asset;
  static const alignment = Alignment(0, -.35);

  @override
  Widget build(BuildContext context) {
    final image = AssetImage(asset);
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = (height * .83)
            .clamp(0.0, constraints.maxWidth)
            .toDouble();

        final edgeWidth = width * .08;
        Widget slice(double sliceWidth, Alignment anchor, Widget content) =>
            SizedBox(
              width: sliceWidth,
              height: height,
              child: ClipRect(
                child: OverflowBox(
                  alignment: anchor,
                  minWidth: width,
                  maxWidth: width,
                  child: content,
                ),
              ),
            );
        final scenery = DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: image,
              fit: BoxFit.cover,
              alignment: alignment,
            ),
          ),
          child: const SizedBox.expand(),
        );
        Widget margin(Alignment side) => Expanded(
          child: FittedBox(
            fit: BoxFit.fill,
            child: slice(edgeWidth, side, scenery),
          ),
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            margin(Alignment.centerLeft),
            slice(
              width - 2 * edgeWidth,
              Alignment.center,
              Image(
                image: image,
                fit: BoxFit.cover,
                alignment: alignment,
                excludeFromSemantics: true,
              ),
            ),
            margin(Alignment.centerRight),
          ],
        );
      },
    );
  }
}

class _SwipeHandHint extends StatelessWidget {
  const _SwipeHandHint();

  @override
  Widget build(BuildContext context) {
    const hand = Image(
      image: AssetImage('assets/icons/clay/swipe_hand.webp'),
      width: 60,
      height: 60,
      excludeFromSemantics: true,
    );
    if (MediaQuery.disableAnimationsOf(context)) return hand;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 3600),
      tween: Tween(begin: 0, end: 2),
      child: hand,
      builder: (_, value, child) {
        final phase = value == 2 ? 1.0 : value % 1;
        final travel = const Interval(
          .23,
          .75,
          curve: Curves.easeInOutCubic,
        ).transform(phase);
        final touch = const Interval(
          .10,
          .23,
          curve: Curves.easeOut,
        ).transform(phase);
        final release = const Interval(
          .75,
          .88,
          curve: Curves.easeOut,
        ).transform(phase);
        final opacity =
            const Interval(0, .10).transform(phase) *
            (1 - const Interval(.81, .97).transform(phase));
        return Opacity(
          opacity: opacity,
          child: SizedBox(
            width: 80,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  bottom: 45,
                  child: Container(
                    width: 4,
                    height: 84 * travel,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.white.withValues(alpha: .85),
                          AppColors.white.withValues(alpha: .08),
                        ],
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, 42 - 84 * travel),
                  child: Transform.scale(
                    scale: 1 - .12 * (touch - release),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
