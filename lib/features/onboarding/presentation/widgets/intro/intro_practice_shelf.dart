import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

import 'intro_story.dart';

typedef _Choice = ({
  String title,
  String kind,
  String asset,
  String note,
  List<Color> colors,
});

/// A catalogue preview. Selecting a cover changes the example, never playback.
class IntroPracticeShelf extends StatefulWidget {
  const IntroPracticeShelf({
    super.key,
    required this.time,
    required this.still,
  });
  final double time;
  final bool still;
  @override
  State<IntroPracticeShelf> createState() => _IntroPracticeShelfState();
}

class _IntroPracticeShelfState extends State<IntroPracticeShelf> {
  int? _picked;

  @override
  void didUpdateWidget(IntroPracticeShelf oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.time < oldWidget.time) _picked = null;
  }

  static double _step(double time, double start) =>
      Curves.easeInOutCubic.transform(((time - start) / .7).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final compact = MediaQuery.sizeOf(context).height < 650;
    final choices = <_Choice>[
      (
        title: ru ? 'Спокойствие' : 'Calm',
        kind: ru ? 'Аффирмация' : 'Affirmation',
        asset: 'assets/images/affirmation/lavender-clay-lotus.webp',
        note: ru
            ? 'Мне легче вернуться к себе, когда вокруг тихо.'
            : 'Quiet helps me feel like myself again.',
        colors: const [Color(0xFF855B8C), Color(0xFF33283D)],
      ),
      (
        title: ru ? 'Стряхнуть день' : 'Shake Off the Day',
        kind: ru ? 'Телесная практика · 2 мин' : 'Movement · 2 min',
        asset: 'assets/images/practices/shake-off-the-day.webp',
        note: ru
            ? 'После долгого дня за столом мне хочется движения.'
            : 'After a day at my desk, I want to move.',
        colors: const [Color(0xFF9A646E), Color(0xFF432A41)],
      ),
      (
        title: ru ? 'Рабочий день закончился' : 'The Workday Is Over',
        kind: ru ? 'Медитация · 4 мин' : 'Meditation · 4 min',
        asset: 'assets/images/practices/workday-is-over.webp',
        note: ru
            ? 'Вечер начинается, когда я закрываю ноутбук.'
            : 'My evening begins when I close my laptop.',
        colors: const [Color(0xFFB47B72), Color(0xFF4A314D)],
      ),
    ];
    final cursor =
        _picked?.toDouble() ??
        (widget.still
            ? 2.0
            : _step(widget.time, 1.45) + _step(widget.time, 3.42));
    final current = cursor.round();
    final selected = choices[current];
    final noteProgress = widget.still || _picked != null
        ? 1.0
        : Curves.easeOutCubic.transform(
            ((widget.time - 5.35) / .75).clamp(0.0, 1.0),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, bounds) {
            final height = compact ? 96.0 : 151.0;
            final cardWidth = math.min(bounds.maxWidth * .48, height * 1.32);
            // Cycle the two neighbours around the featured cover; they disappear
            // at the outer edge as the next illustrated cover moves into focus.
            final distances = List.generate(
              choices.length,
              (i) => ((i - cursor + 1.5) % 3) - 1.5,
            );
            final order = [
              0,
              1,
              2,
            ]..sort((a, b) => distances[b].abs().compareTo(distances[a].abs()));
            return SizedBox(
              height: height + 16,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (final index in order)
                    Transform.translate(
                      offset: Offset(
                        distances[index] * bounds.maxWidth * .32,
                        distances[index].abs() * 6,
                      ),
                      child: Transform.rotate(
                        angle: distances[index] * .105,
                        child: Transform.scale(
                          scale: 1 - .23 * distances[index].abs(),
                          child: Opacity(
                            opacity: (1 - .43 * distances[index].abs()).clamp(
                              0.0,
                              1.0,
                            ),
                            child: Semantics(
                              button: true,
                              selected: current == index,
                              label:
                                  '${choices[index].kind}. ${choices[index].title}',
                              child: GestureDetector(
                                onTap: () => setState(() => _picked = index),
                                child: Container(
                                  key: ValueKey('intro-practice-cover-$index'),
                                  width: cardWidth,
                                  height: height,
                                  padding: EdgeInsets.all(compact ? 10 : 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: choices[index].colors,
                                    ),
                                    border: Border.all(
                                      color: current == index
                                          ? AppColorsDark.linkGold.withValues(
                                              alpha: .8,
                                            )
                                          : AppColorsDark.textSecondary
                                                .withValues(alpha: .35),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 9,
                                        offset: const Offset(0, 3),
                                        color: AppColorsDark.homeCanvas
                                            .withValues(alpha: .52),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    choices[index].asset,
                                    fit: BoxFit.contain,
                                    excludeFromSemantics: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          selected.kind,
          key: ValueKey('intro-practice-selected-$current'),
          textAlign: TextAlign.center,
          style: AppTypography.text2SemiBold.copyWith(
            color: AppColorsDark.linkGold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          selected.title,
          textAlign: TextAlign.center,
          style: AppTypography.h3.copyWith(
            color: AppColors.textInverse,
            height: 1.24,
          ),
        ),
        if (noteProgress > 0)
          IntroStoryFocus(
            child: Padding(
              padding: EdgeInsets.only(top: compact ? 9 : 16),
              child: Opacity(
                opacity: noteProgress,
                child: Transform.translate(
                  offset: Offset(0, 9 * (1 - noteProgress)),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          width: 2,
                          color: AppColorsDark.linkGold.withValues(alpha: .75),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.edit_note_rounded,
                                size: 19,
                                color: AppColorsDark.linkGold,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  ru
                                      ? 'Сохранено в «Мои заметки»'
                                      : 'Saved in My Notes',
                                  style: AppTypography.text2SemiBold.copyWith(
                                    color: AppColorsDark.linkGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selected.note,
                            key: const ValueKey('intro-practice-result'),
                            style: AppTypography.h4.copyWith(
                              color: AppColors.textInverse,
                              height: 1.32,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
