import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

import 'intro_story.dart';
import 'intro_mood_merge.dart';
import 'intro_mood_artwork.dart';

export 'intro_calendar_story.dart';
export 'intro_pair_story.dart';
export 'intro_tarot_story.dart';

class IntroMoodStory extends StatelessWidget {
  const IntroMoodStory({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) => IntroStory(
    active: active,
    duration: const Duration(seconds: 14),
    builder: (context, time, isStatic, now) {
      final l = context.l10n;
      final result = _StoryStatement(
        title: l.introMoodMatched,
        text: l.introMoodAffirmation,
      );
      final practice = StoryCard(
        key: const ValueKey('intro-mood-practice'),
        title: l.introMoodPracticeTitle,
        text: l.introMoodPractice,
      );
      if (isStatic) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            result,
            const SizedBox(height: 12),
            const SizedBox(height: 210, child: IntroMoodArtwork()),
            const SizedBox(height: 16),
            practice,
          ],
        );
      }
      return IntroMoodMerge(seconds: time, result: result, practice: practice);
    },
  );
}

class _StoryStatement extends StatelessWidget {
  const _StoryStatement({required this.title, required this.text});
  final String title, text;

  @override
  Widget build(BuildContext context) => IntroStoryFocus(
    child: Padding(
      key: const ValueKey('intro-mood-insight'),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.text2.copyWith(color: AppColorsDark.linkGold),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.h3.copyWith(
              color: AppColors.textInverse,
              height: 1.3,
            ),
          ),
        ],
      ),
    ),
  );
}
