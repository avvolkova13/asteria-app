import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/practice_pencil.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_card_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:flutter/material.dart';

import 'intro_story.dart';

typedef _Practice = ({
  String category,
  String title,
  String detail,
  String art,
});

/// The same three categories as the practice catalogue, toured on the story clock.
class IntroPracticeShelf extends StatelessWidget {
  const IntroPracticeShelf({
    super.key,
    required this.time,
    required this.still,
  });
  final double time;
  final bool still;

  double _turn(double start) =>
      Curves.easeInOutCubic.transform(((time - start) / .65).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final works = <_Practice>[
      (
        category: ru ? 'Аффирмация' : 'Affirmation',
        title: context.l10n.affirmationCategoryCalm,
        detail: context.l10n.introMoodAffirmation,
        art: AffirmationCardWidget.artworkFor('calm', 0),
      ),
      (
        category: ru ? 'Телесная практика · 2 мин' : 'Body practice · 2 min',
        title: ru ? 'Стряхнуть день' : 'Shake Off the Day',
        detail: ru
            ? 'Лёгкое движение кистями и плечами, будто стряхиваешь капли воды.'
            : 'A gentle movement of the hands and shoulders, like shaking off drops of water.',
        art: 'assets/images/practices/shake-off-the-day.webp',
      ),
      (
        category: ru ? 'Медитация · 4 мин' : 'Meditation · 4 min',
        title: ru ? 'Рабочий день закончился' : 'The Workday Is Over',
        detail: ru
            ? 'Пауза между работой и вечером. Внимание возвращается от дел к тому, что вокруг.'
            : 'A pause between work and the evening, to notice the room around you again.',
        art: 'assets/images/practices/workday-is-over.webp',
      ),
    ];
    final height = MediaQuery.sizeOf(context).height;
    final compact = height < 650;
    final selected = still ? 2.0 : _turn(2.55) + _turn(5.25);
    final journal = still ? 1.0 : _turn(7.65);
    final illustrationHeight = compact
        ? 90.0
        : ((height - 438) * .6).clamp(162.0, 252.0) - 72 * journal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (still)
          for (var i = 0; i < 2; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox.square(
                      dimension: 48,
                      child: _Artwork(works[i], i),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: works[i].category,
                        style: AppTypography.text2SemiBold.copyWith(
                          color: AppColorsDark.linkGold,
                        ),
                        children: [
                          TextSpan(
                            text: '\n${works[i].title}',
                            style: AppTypography.h4.copyWith(
                              color: AppColors.textInverse,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        LayoutBuilder(
          builder: (context, bounds) => ClipRect(
            child: Stack(
              children: [
                for (var i = 0; i < works.length; i++)
                  if ((i - selected).abs() < 1)
                    Transform.translate(
                      offset: Offset(
                        (i - selected) * (bounds.maxWidth + 12),
                        0,
                      ),
                      child: ExcludeSemantics(
                        excluding: i != selected.round(),
                        child: HomeGlassSurface(
                          animateEntrance: false,
                          tint: AppColorsDark.modal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                key: ValueKey('intro-practice-cover-$i'),
                                height: still
                                    ? (compact ? 80 : 108)
                                    : illustrationHeight,
                                child: _Artwork(works[i], i),
                              ),
                              IntroStoryFocus(
                                enabled:
                                    !still &&
                                    i == selected.round() &&
                                    journal == 0,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    16,
                                    compact ? 9 : 14,
                                    16,
                                    compact ? 12 : 18,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        works[i].category,
                                        key: ValueKey(
                                          'intro-practice-selected-$i',
                                        ),
                                        style: AppTypography.text2SemiBold
                                            .copyWith(
                                              color: AppColorsDark.linkGold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        works[i].title,
                                        style: AppTypography.h2.copyWith(
                                          color: AppColors.textInverse,
                                          height: 1.16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        works[i].detail,
                                        style: AppTypography.text1.copyWith(
                                          color: AppColorsDark.textSecondary,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
        if (journal > 0)
          IntroStoryFocus(
            child: Opacity(
              opacity: journal,
              child: Padding(
                padding: EdgeInsets.only(top: compact ? 10 : 16, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: PracticePencil(size: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ru
                                ? 'Мои заметки · после медитации'
                                : 'My notes · after the meditation',
                            style: AppTypography.text2SemiBold.copyWith(
                              color: AppColorsDark.linkGold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            ru
                                ? 'Закрою ноутбук. Остальное может подождать до утра.'
                                : 'I’ll close my laptop. The rest can wait until morning.',
                            key: const ValueKey('intro-practice-result'),
                            style: AppTypography.h4.copyWith(
                              color: AppColors.textInverse,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork(this.practice, this.index);
  final _Practice practice;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (index == 0) return PracticeCardArtwork(asset: practice.art);
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/scenarios/picker_sky.webp',
          fit: BoxFit.cover,
          alignment: const Alignment(0, .7),
          excludeFromSemantics: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Image.asset(
            practice.art,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      ],
    );
  }
}
