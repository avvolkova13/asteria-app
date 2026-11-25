import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/practice_pencil.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/practices/practice_catalog_screen.dart';
import 'package:flutter/material.dart';

import 'intro_practice_fan.dart';
import 'intro_story.dart';

/// Illustrates choosing, reading and keeping a thought on the tour clock.
class IntroPracticeShelf extends StatelessWidget {
  const IntroPracticeShelf({
    super.key,
    required this.time,
    required this.still,
  });

  final double time;
  final bool still;

  double _turn(double start) =>
      Curves.easeInOutCubic.transform(((time - start) / .85).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final movement = practicePreview('shake-off-the-day', ru: ru);
    final meditation = practicePreview('workday-is-over', ru: ru);
    final covers = [
      (
        title: context.l10n.affirmationCategoryCalm,
        art: 'assets/images/affirmation/lavender-clay-lotus.webp',
      ),
      (title: movement.title, art: movement.art),
      (title: meditation.title, art: meditation.art),
    ];
    final cursor = still ? 2.0 : _turn(1.3) + _turn(3.0);
    final current = cursor.round();
    final categories = ru
        ? const ['Аффирмация', 'Телесная практика', 'Медитация']
        : const ['Affirmation', 'Body practice', 'Meditation'];

    final compact = MediaQuery.sizeOf(context).height < 740;
    final fan = IntroPracticeFan(
      cursor: cursor,
      time: time,
      still: still,
      covers: covers,
    );
    final caption = StoryEntrance(
      time: time,
      start: const [.28, 1.725, 3.425][current],
      rise: 4,
      child: Column(
        crossAxisAlignment: compact
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Text(
            categories[current],
            key: ValueKey('intro-practice-selected-$current'),
            style: AppTypography.text2SemiBold.copyWith(
              color: AppColorsDark.linkGold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            covers[current].title,
            textAlign: compact ? TextAlign.start : TextAlign.center,
            style: (compact ? AppTypography.h4 : AppTypography.h3).copyWith(
              color: AppColors.textInverse,
              height: 1.14,
            ),
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntroStoryFocus(
          enabled: !still && time >= 1.1 && time < 4,
          child: compact
              ? Row(
                  children: [
                    Expanded(flex: 3, child: fan),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: caption),
                  ],
                )
              : Column(children: [fan, const SizedBox(height: 4), caption]),
        ),
        StoryReveal(
          time: still ? 16 : time,
          start: 4.2,
          child: IntroStoryFocus(
            enabled: !still && time >= 4.5 && time < 8.2,
            child: Padding(
              padding: EdgeInsets.only(top: compact ? 6 : 9),
              child: Column(
                key: const ValueKey('intro-practice-description'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meditation.metadata,
                    style: AppTypography.text2SemiBold.copyWith(
                      color: AppColorsDark.linkGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meditation.description,
                    style: (compact ? AppTypography.text2 : AppTypography.text1)
                        .copyWith(color: AppColors.textInverse, height: 1.28),
                  ),
                ],
              ),
            ),
          ),
        ),
        StoryReveal(
          time: still ? 16 : time,
          start: 8.2,
          child: Padding(
            padding: EdgeInsets.only(top: compact ? 7 : 10, bottom: 2),
            child: _PracticeNote(ru: ru, time: time, still: still),
          ),
        ),
      ],
    );
  }
}

class _PracticeNote extends StatelessWidget {
  const _PracticeNote({
    required this.ru,
    required this.time,
    required this.still,
  });

  final bool ru, still;
  final double time;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 740;
    final note = ru
        ? 'Закрою ноутбук и пойду гулять. На письма отвечу утром.'
        : 'I’ll close my laptop and take a walk. Emails can wait.';
    final words = note.split(' ');
    final count = still
        ? words.length
        : (words.length * ((time - 9.4) / 2.0).clamp(0.0, 1.0)).ceil();
    final saved = still || time >= 11.9;
    final explanation = ru
        ? 'Перечитать и изменить: «Практики» → «Мои заметки».'
        : 'Read or edit in Practices → My notes.';
    final detail = AppTypography.text2.copyWith(
      color: AppColorsDark.textSecondary,
      height: 1.3,
    );
    return IntroStoryFocus(
      key: ValueKey(saved),
      enabled: !still,
      child: HomeGlassSurface(
        key: ValueKey(saved ? 'intro-practice-result' : 'intro-practice-note'),
        animateEntrance: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 11 : 16,
            vertical: compact ? 7 : 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StoryEntrance(
                time: time,
                start: saved ? 11.9 : 8.2,
                rise: 3,
                child: Row(
                  children: [
                    if (saved)
                      const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: AppColorsDark.linkGold,
                      )
                    else
                      const PracticePencil(size: 19),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        saved
                            ? (ru ? 'Заметка сохранена' : 'Note saved')
                            : (ru ? 'Добавить заметку' : 'Add a note'),
                        style: AppTypography.text2SemiBold.copyWith(
                          color: AppColorsDark.linkGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              if (count == 0)
                Text(
                  ru
                      ? 'Что хочется запомнить после практики?'
                      : 'What would you like to remember after this practice?',
                  style: detail,
                )
              else
                Text(
                  words.take(count).join(' '),
                  semanticsLabel: note,
                  style: (compact ? AppTypography.text2 : AppTypography.text1)
                      .copyWith(color: AppColors.textInverse, height: 1.28),
                ),
              if (saved) ...[
                const SizedBox(height: 6),
                StoryEntrance(
                  time: time,
                  start: 12.0,
                  rise: 4,
                  child: Text(explanation, style: detail),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
