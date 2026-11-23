import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/swipe_card_stack.dart';
import 'package:flutter/material.dart';

class AffirmationCardWidget extends StatelessWidget {
  final AffirmationModel affirmation;
  final int imageIndex;
  final List<AffirmationModel>? deck;
  final double borderOpacity;
  final bool isFront;
  final bool showSwipeHint;
  final bool showOpenIndicator;

  const AffirmationCardWidget({
    super.key,
    required this.affirmation,
    required this.imageIndex,
    this.deck,
    this.borderOpacity = 0.1,
    this.isFront = true,
    this.showSwipeHint = false,
    this.showOpenIndicator = true,
  });

  static String artworkFor(String categoryId, int imageIndex) {
    final imageName = switch (categoryId) {
      'abundance' => 'izobilie',
      'strength' => 'power',
      'creativity' => 'creative',
      'lunar' => 'moon',
      'calm' => 'calm',
      _ => 'love',
    };
    final normalizedImageIndex = imageIndex % 3;
    final imageSuffix = normalizedImageIndex == 0
        ? ''
        : '_${normalizedImageIndex + 1}';
    return 'assets/images/affirmation/category_$imageName$imageSuffix.webp';
  }

  /// Keep neighbouring covers distinct across the wrap from last to first.
  static int coverIndex(int index, int length) {
    if (index > 0 && index == length - 1 && index % 3 == 0) return 1;
    return index % 3;
  }

  String get imageAssetPath => artworkFor(
    affirmation.effectiveCategoryId,
    deck == null ? imageIndex : coverIndex(imageIndex, deck!.length),
  );

  @override
  Widget build(BuildContext context) => PracticeDeckCard(
    artwork: PracticeCardArtwork(asset: imageAssetPath),
    borderOpacity: borderOpacity,
    isFront: isFront,
    showSwipeHint: showSwipeHint,
    showOpenIndicator: showOpenIndicator,
    footer: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: IndexedStack(
        index: deck == null ? 0 : imageIndex,
        children: [
          for (final card in deck ?? [affirmation])
            Text(
              card.text,
              style: context.textTheme.inverseUrbanistRegular16.copyWith(
                height: 1.3,
              ),
              textAlign: TextAlign.start,
            ),
        ],
      ),
    ),
  );
}

class PracticeDeckCard extends StatelessWidget {
  const PracticeDeckCard({
    super.key,
    required this.artwork,
    required this.footer,
    this.borderOpacity = .1,
    this.isFront = true,
    this.showSwipeHint = false,
    this.showOpenIndicator = true,
  });

  final Widget artwork, footer;
  final double borderOpacity;
  final bool isFront, showSwipeHint, showOpenIndicator;

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
            SizedBox(
              height: SwipeCardStack.artworkHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  artwork,
                  if (isFront && showOpenIndicator)
                    const Positioned(
                      top: 12,
                      right: 14,
                      child: _CardIconButton(icon: Icons.chevron_right),
                    ),
                  if (isFront && showSwipeHint)
                    const Center(child: IgnorePointer(child: _SwipeHandHint())),
                ],
              ),
            ),
            if (isFront) footer,
          ],
        ),
      ),
    );
  }
}

/// Portrait artwork keeps its full height. Extend its outer color into the
/// card margins so the frame can be wider than the source.
class PracticeCardArtwork extends StatelessWidget {
  const PracticeCardArtwork({super.key, required this.asset});
  final String asset;

  // The bundled category portraits are 450 × 675.
  static const double _portraitAspectRatio = 2 / 3;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = constraints.maxHeight;
      final width = height * _portraitAspectRatio;
      Widget portrait() =>
          Image.asset(asset, fit: BoxFit.contain, excludeFromSemantics: true);

      if (constraints.maxWidth <= width) return portrait();

      Widget margin(Alignment side) => Expanded(
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: 1,
            height: height,
            child: ClipRect(
              child: OverflowBox(
                alignment: side,
                minWidth: width,
                maxWidth: width,
                minHeight: height,
                maxHeight: height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(asset),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      );

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          margin(Alignment.centerLeft),
          SizedBox(width: width, child: portrait()),
          margin(Alignment.centerRight),
        ],
      );
    },
  );
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
