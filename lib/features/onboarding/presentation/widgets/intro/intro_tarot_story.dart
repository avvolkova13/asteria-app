import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'intro_story.dart';
import 'native_tarot_deal.dart';

class IntroTarotStory extends StatelessWidget {
  const IntroTarotStory({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) => IntroStory(
    active: active,
    duration: const Duration(seconds: 14),
    builder: (context, time, static, now) {
      final l = context.l10n;
      final answer = IntroStoryFocus(
        child: Row(
          key: const ValueKey('intro-tarot-insight'),
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/year_animals/horse.webp',
              width: 44,
              height: 64,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StoryCard(
                title: l.introTarotInsight,
                text: l.introAnakraMessage,
              ),
            ),
          ],
        ),
      );
      final cards = IntroStoryFocus(
        enabled: static || (time >= 2.8 && time < 8.5),
        child: NativeTarotDeal(seconds: static ? 6 : time - 2.8),
      );
      if (static) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StoryCard(text: l.introTarotRequest),
            const SizedBox(height: 12),
            Center(child: SizedBox(width: 220, child: cards)),
            const SizedBox(height: 18),
            answer,
          ],
        );
      }
      final shrink = Curves.easeInOutCubic.transform(
        ((time - 7.8) / .7).clamp(0.0, 1.0),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StoryReveal(
            time: time,
            start: .2,
            end: 3,
            child: StoryCard(text: l.introTarotRequest, emphasis: true),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300 - 80 * shrink),
              child: cards,
            ),
          ),
          const SizedBox(height: 12),
          StoryReveal(time: time, start: 8.5, child: answer),
        ],
      );
    },
  );
}
