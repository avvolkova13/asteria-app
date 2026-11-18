import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:flutter/material.dart';

import 'intro_story.dart';
import 'intro_mood_artwork.dart';

/// Stable header, rounded artwork and a separate panel below the flower.
class IntroMoodMerge extends StatelessWidget {
  const IntroMoodMerge({
    super.key,
    required this.seconds,
    required this.result,
    required this.practice,
  });
  final double seconds;
  final Widget result;
  final Widget practice;

  double phase(double start, double end) => Curves.easeInOutCubic.transform(
    ((seconds - start) / (end - start)).clamp(0.0, 1.0),
  );

  double measure(
    BuildContext context,
    String text,
    TextStyle style,
    double width,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.localeOf(context),
    )..layout(maxWidth: width);
    final height = painter.height;
    painter.dispose();
    return height;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final l = context.l10n;
      final width = bounds.maxWidth;
      final artHeight = (width * .62).clamp(180.0, 230.0);
      final requestHeight =
          measure(
            context,
            l.introMoodRequest,
            AppTypography.h3.copyWith(height: 1.3),
            width - 32,
          ) +
          32;
      final reflectionHeight =
          measure(
            context,
            l.introMoodMatched,
            AppTypography.text2,
            width - 24,
          ) +
          8 +
          measure(
            context,
            l.introMoodAffirmation,
            AppTypography.h3.copyWith(height: 1.3),
            width - 24,
          );
      final headerHeight = math.max(requestHeight, reflectionHeight) + 4;
      final captionHeight = [l.introMoodTired, l.introMoodRush, l.introMoodCalm]
          .map(
            (text) =>
                measure(
                  context,
                  text,
                  AppTypography.text2SemiBold.copyWith(
                    fontSize: 13,
                    height: 1.3,
                  ),
                  (width - 18) / 3 - 16,
                ) +
                24,
          )
          .reduce(math.max);
      final practiceHeight =
          measure(
            context,
            l.introMoodPracticeTitle,
            AppTypography.text2SemiBold,
            width - 32,
          ) +
          7 +
          measure(
            context,
            l.introMoodPractice,
            AppTypography.text1.copyWith(height: 1.3),
            width - 32,
          ) +
          32;
      final lowerHeight =
          math.max(math.max(62.0, captionHeight), practiceHeight) + 4;
      final arrival = phase(1.4, 2.25);
      final merge = phase(3.6, 4.55);
      final expand = phase(4.55, 5.65);
      final small = Rect.fromCenter(
        center: Offset(width / 2, artHeight / 2),
        width: width * .55,
        height: artHeight * .88,
      );
      final main = Rect.lerp(
        small,
        Offset.zero & Size(width, artHeight),
        expand,
      )!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: headerHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                StoryReveal(
                  time: seconds,
                  start: .15,
                  end: 5.65,
                  child: StoryCard(text: l.introMoodRequest, emphasis: true),
                ),
                StoryReveal(time: seconds, start: 6.05, child: result),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: artHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final side in [-1, 1])
                  if (seconds < 4.85)
                    Positioned.fromRect(
                      rect: small.shift(
                        Offset(side * width * .22 * (1 - merge), 0),
                      ),
                      child: Opacity(
                        opacity: arrival * (1 - phase(4.35, 4.85)),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, .0014)
                            ..rotateY(side * .28)
                            ..rotateZ(side * .10 * (1 - merge)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              side < 0
                                  ? 'assets/images/affirmation/category_power.webp'
                                  : 'assets/images/affirmation/category_moon.webp',
                              fit: BoxFit.cover,
                              excludeFromSemantics: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                Positioned.fromRect(
                  rect: main,
                  child: Opacity(
                    opacity: arrival,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const IntroMoodArtwork(),
                        if (expand < 1)
                          Opacity(
                            opacity: 1 - expand,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                'assets/images/affirmation/category_calm.webp',
                                fit: BoxFit.cover,
                                excludeFromSemantics: true,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: lowerHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                StoryReveal(
                  time: seconds,
                  start: 2.25,
                  end: 5.65,
                  child: IntroStoryFocus(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var index = 0; index < 3; index++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: Opacity(
                                opacity: index == 1 ? 1 : 1 - phase(3.9, 4.5),
                                child: _MoodCaption(
                                  text: [
                                    l.introMoodTired,
                                    l.introMoodRush,
                                    l.introMoodCalm,
                                  ][index],
                                  selection: index == 1 ? phase(2.85, 3.25) : 0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                StoryReveal(time: seconds, start: 8.5, child: practice),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class _MoodCaption extends StatelessWidget {
  const _MoodCaption({required this.text, this.selection = 0});
  final String text;
  final double selection;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: CardLensDecoration(
      borderRadius: BorderRadius.circular(24),
      intensity: .65,
      color: Color.alphaBlend(
        AppColorsDark.linkGold.withValues(alpha: .08 * selection),
        AppColorsDark.modal.withValues(alpha: .92),
      ),
      border: Border.all(
        width: .8,
        color: Color.lerp(
          AppColors.textInverse.withValues(alpha: .18),
          AppColorsDark.linkGold.withValues(alpha: .8),
          selection,
        )!,
      ),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 62),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.text2SemiBold.copyWith(
              fontSize: 13,
              height: 1.3,
              color: Color.lerp(
                AppColors.textInverse,
                AppColorsDark.linkGold,
                selection,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
