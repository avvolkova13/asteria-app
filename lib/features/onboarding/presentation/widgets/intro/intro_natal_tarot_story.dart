import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/tarot_card_frame.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:flutter/material.dart';

import 'intro_story.dart';

/// Two examples, on one clock, drawn from the chart and tarot catalogues.
class IntroNatalTarotStory extends StatelessWidget {
  const IntroNatalTarotStory({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final compact = MediaQuery.sizeOf(context).height < 650;
    final artworkSize = compact ? 65.0 : 102.0;
    final card = ru
        ? 'assets/images/cards/the_star.webp'
        : 'assets/images/cards/en/the_star.webp';

    return IntroStory(
      active: active,
      duration: const Duration(seconds: 5),
      builder: (context, time, still, _) {
        final wheelArrival = still
            ? 1.0
            : Curves.easeOutCubic.transform((time / .9).clamp(0.0, 1.0));
        final cardArrival = still
            ? 1.0
            : Curves.easeOutCubic.transform(
                ((time - .22) / .9).clamp(0.0, 1.0),
              );
        return IntroStoryFocus(
          child: HomeGlassSurface(
            animateEntrance: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: compact ? 10 : 18,
                horizontal: 14,
              ),
              child: Column(
                children: [
                  _Example(
                    label: context.l10n.natalChartTitle,
                    title: ru ? 'Луна в Тельце' : 'Moon in Taurus',
                    question: ru
                        ? 'Что даёт мне опору?'
                        : 'What helps me feel grounded?',
                    size: artworkSize,
                    artwork: Transform.rotate(
                      angle: -.24 * (1 - wheelArrival),
                      child: Image.asset(
                        'assets/images/home/natal_card_banner_wheel.webp',
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                  Divider(height: compact ? 16 : 30),
                  _Example(
                    key: const ValueKey('intro-natal-tarot-result'),
                    label: context.l10n.tarotCardsTitle,
                    title: ru ? 'Звезда' : 'The Star',
                    question: ru
                        ? 'Что меня вдохновляет?'
                        : 'What inspires me?',
                    size: artworkSize,
                    artwork: Transform.translate(
                      offset: Offset(
                        8 * (1 - cardArrival),
                        4 * (1 - cardArrival),
                      ),
                      child: Transform.rotate(
                        angle: -.07 - .12 * (1 - cardArrival),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 2 / 3,
                            child: TarotCardFrame(
                              radius: 6,
                              child: Image.asset(
                                card,
                                fit: BoxFit.cover,
                                excludeFromSemantics: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Example extends StatelessWidget {
  const _Example({
    super.key,
    required this.label,
    required this.title,
    required this.question,
    required this.size,
    required this.artwork,
  });

  final String label;
  final String title;
  final String question;
  final double size;
  final Widget artwork;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox.square(dimension: size, child: artwork),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.text2SemiBold.copyWith(
                color: AppColorsDark.linkGold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTypography.h3.copyWith(color: AppColors.textInverse),
            ),
            const SizedBox(height: 2),
            Text(
              question,
              style: AppTypography.text2.copyWith(color: AppColors.textInverse),
            ),
          ],
        ),
      ),
    ],
  );
}
