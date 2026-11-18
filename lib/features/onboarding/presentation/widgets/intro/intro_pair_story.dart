import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'intro_story.dart';

class IntroPairStory extends StatelessWidget {
  const IntroPairStory({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) => IntroStory(
    active: active,
    duration: const Duration(seconds: 14),
    builder: (context, time, static, now) {
      final l = context.l10n;
      final result = IntroStoryFocus(
        child: Column(
          key: const ValueKey('intro-pair-insight'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PairAvatar(man: true, size: 80),
                SizedBox(width: 12),
                _PairAvatar(man: false, size: 80),
              ],
            ),
            const SizedBox(height: 16),
            StoryCard(
              title: l.introPairQuestion,
              text: l.introPairPrompt,
              emphasis: true,
            ),
          ],
        ),
      );
      final male = _PairSpeech(
        key: const ValueKey('intro-pair-man-speech'),
        man: true,
        text: l.introPairNeedTime,
      );
      final female = _PairSpeech(
        key: const ValueKey('intro-pair-woman-speech'),
        man: false,
        text: l.introPairNeedTalk,
      );
      if (static) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StoryCard(text: l.introPairRequest),
            const SizedBox(height: 16),
            male,
            const SizedBox(height: 16),
            female,
            const SizedBox(height: 20),
            result,
          ],
        );
      }
      return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 280),
        child: Stack(
          key: const ValueKey('intro-pair-explanation'),
          children: [
            StoryReveal(
              time: time,
              start: .2,
              end: 3,
              child: StoryCard(text: l.introPairRequest, emphasis: true),
            ),
            StoryReveal(time: time, start: 3.2, end: 6.2, child: male),
            StoryReveal(time: time, start: 6.4, end: 9.5, child: female),
            StoryReveal(time: time, start: 9.8, child: result),
          ],
        ),
      );
    },
  );
}

class _PairSpeech extends StatelessWidget {
  const _PairSpeech({super.key, required this.man, required this.text});
  final bool man;
  final String text;

  @override
  Widget build(BuildContext context) => IntroStoryFocus(
    child: Semantics(
      container: true,
      label: man ? context.l10n.maleGender : context.l10n.femaleGender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _PairAvatar(man: man, size: 112)),
          const SizedBox(height: 14),
          StoryCard(text: text),
        ],
      ),
    ),
  );
}

class _PairAvatar extends StatelessWidget {
  const _PairAvatar({required this.man, required this.size});
  final bool man;
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/onboarding/intro_pair_${man ? 'man' : 'woman'}.png',
    width: size,
    height: size,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
    cacheWidth: 336,
  );
}
