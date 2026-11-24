import 'dart:math' as math;
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'intro_story.dart';

class IntroGuideStory extends StatelessWidget {
  const IntroGuideStory({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    return IntroStory(
      active: active,
      duration: const Duration(seconds: 12),
      builder: (context, time, still, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Transform.translate(
            offset: Offset(0, still ? 0 : 4 * math.sin(time * 1.4)),
            child: Image.asset(
              'assets/images/anakra/avatar.png',
              height: 112,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(left: 32),
              child: StoryCard(
                text: ru
                    ? 'Как решиться на важный разговор?'
                    : 'How can I start a difficult conversation?',
              ),
            ),
          ),
          const SizedBox(height: 12),
          StoryReveal(
            time: still ? 12 : time,
            start: 1.8,
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: StoryCard(
                title: context.l10n.anakraName,
                text: ru
                    ? 'Что тебе больше всего хочется сказать? Попробуй начать именно с этого.'
                    : 'What do you most want the other person to hear? Try starting there.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          StoryReveal(
            time: still ? 12 : time,
            start: 5.8,
            child: IntroStoryFocus(
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/achievements/achievement-runes.webp',
                    width: 42,
                    height: 42,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ru
                          ? 'В профиле видно, сколько рун ты уже открыла. А за чтение статей можно получить звездочёты.'
                          : 'Your profile tracks the runes you’ve opened. Reading articles can also earn you stars.',
                      key: const ValueKey('intro-guide-result'),
                      style: AppTypography.text1.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
