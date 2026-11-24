import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:flutter/material.dart';

import 'intro_story.dart';

/// A sample entry unfolds on the same clock as the tour's pause and replay.
class IntroJournalStory extends StatelessWidget {
  const IntroJournalStory.dream({super.key, required this.active})
    : dream = true;
  const IntroJournalStory.practice({super.key, required this.active})
    : dream = false;

  final bool active;
  final bool dream;

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final (source, entry, destination, takeaway, asset) = dream
        ? (
            ru ? 'Дневник снов' : 'Dream journal',
            ru
                ? 'Я шла по берегу. Вдалеке зажёгся маяк.'
                : 'I was walking along the shore. A lighthouse lit up in the distance.',
            ru ? 'Разбор с Ливеей' : 'Exploring the dream with Liveya',
            ru
                ? 'Маяк может напоминать об опоре. Что помогает тебе найти дорогу сейчас?'
                : 'A lighthouse might bring guidance to mind. What helps you find your way these days?',
            'assets/images/sonnik/liveya_character.webp',
          )
        : (
            ru ? 'Утро без спешки' : 'An Unhurried Morning',
            ru
                ? 'Почувствуй, как стопы касаются пола. Сделай спокойный выдох.'
                : 'Feel your feet on the floor. Breathe out slowly.',
            ru
                ? 'Мои заметки · Утро без спешки'
                : 'My notes · An Unhurried Morning',
            ru
                ? 'Хочу начинать утро с открытого окна. Телефон подождёт.'
                : 'Tomorrow I want to open the window first. My phone can wait.',
            'assets/images/home/hand_with_star.webp',
          );
    return IntroStory(
      active: active,
      duration: const Duration(seconds: 10),
      builder: (context, time, isStatic, _) {
        final reveal = isStatic
            ? 1.0
            : Curves.easeOutCubic.transform(
                ((time - 3.2) / .8).clamp(0.0, 1.0),
              );
        final breath = isStatic ? 0.0 : math.sin(time * math.pi / 5);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height < 650 ? 112 : 156,
              child: Transform.translate(
                offset: Offset(0, -4 * breath),
                child: Transform.scale(
                  scale: 1 + .025 * breath,
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            IntroStoryFocus(
              child: HomeGlassSurface(
                animateEntrance: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source,
                        style: AppTypography.text2SemiBold.copyWith(
                          color: AppColorsDark.linkGold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _EntryText(
                        entry,
                        progress: dream && !isStatic
                            ? (time / 2).clamp(0, 1)
                            : 1,
                      ),
                      if (reveal > 0)
                        IntroStoryFocus(
                          child: Opacity(
                            opacity: reveal,
                            child: Transform.translate(
                              offset: Offset(0, (1 - reveal) * 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(height: 28),
                                  Text(
                                    destination,
                                    style: AppTypography.text2SemiBold.copyWith(
                                      color: AppColorsDark.linkGold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _EntryText(
                                    takeaway,
                                    key: ValueKey(
                                      dream
                                          ? 'intro-dream-result'
                                          : 'intro-practice-result',
                                    ),
                                    progress: isStatic
                                        ? 1
                                        : ((time - 3.2) / 2.2).clamp(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Reserve the final line breaks while the words appear. Assistive technology
// receives the complete sentence once, including while the demo is paused.
class _EntryText extends StatelessWidget {
  const _EntryText(this.text, {super.key, required this.progress});
  final String text;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    final visible = (progress * words.length).ceil().clamp(1, words.length);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: words.take(visible).join(' ')),
          if (visible < words.length)
            TextSpan(
              text: ' ${words.skip(visible).join(' ')}',
              style: const TextStyle(color: Colors.transparent),
            ),
        ],
      ),
      semanticsLabel: text,
      style: AppTypography.text1.copyWith(color: AppColors.textInverse),
    );
  }
}
