import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intro_story.dart';

/// Civil dates, rather than 24-hour offsets, also work across DST boundaries.
List<DateTime> introUpcomingDates(DateTime now) =>
    List.generate(5, (i) => DateTime(now.year, now.month, now.day + i));

enum _PlanStep { choose, saved, reminder }

class IntroCalendarStory extends StatefulWidget {
  const IntroCalendarStory({
    super.key,
    required this.active,
    this.now = DateTime.now,
  });

  final bool active;
  final DateTime Function() now;

  @override
  State<IntroCalendarStory> createState() => _IntroCalendarStoryState();
}

class _IntroCalendarStoryState extends State<IntroCalendarStory> {
  int? _chosenDay;
  _PlanStep? _manualStep;

  @override
  void didUpdateWidget(IntroCalendarStory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      _chosenDay = null;
      _manualStep = null;
    }
  }

  void _choose(int day, _PlanStep step) {
    final playback = IntroPlaybackScope.maybeOf(context);
    if (playback?.mode == IntroPlaybackMode.pause) playback?.toggle?.call();
    setState(() {
      _chosenDay = day;
      _manualStep = step;
    });
  }

  @override
  Widget build(BuildContext context) => IntroStory(
    active: widget.active,
    now: widget.now,
    duration: const Duration(seconds: 10),
    builder: (context, time, still, now) {
      final l = context.l10n;
      final locale = Localizations.localeOf(context).toLanguageTag();
      final dates = introUpcomingDates(now);
      final selected =
          _chosenDay ??
          (still || time >= 2.4
              ? 2
              : time >= 1.1
              ? 1
              : 0);
      final date = dates[selected];
      final step =
          _manualStep ??
          (still || time >= 6.9
              ? _PlanStep.reminder
              : time >= 4.8
              ? _PlanStep.saved
              : _PlanStep.choose);
      final status = [
        l.dayNeutral,
        l.dayUnfavorable,
        l.dayFavorable,
        l.dayFavorable,
        l.dayNeutral,
      ];
      final compact = MediaQuery.sizeOf(context).height < 650;
      final isRu = Localizations.localeOf(context).languageCode == 'ru';
      final reminderDate = selected == 0
          ? date
          : DateTime(date.year, date.month, date.day - 1);
      final reminderLabel = DateFormat.MMMMd(locale).format(reminderDate);
      final drift = still
          ? 1.0
          : Curves.easeOutCubic.transform((time / 4.8).clamp(0, 1));
      return Material(
        color: AppColors.modal,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(color: AppColorsDark.homeCanvas),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: .72,
                        heightFactor: 1,
                        child: ClipRect(
                          child: ShaderMask(
                            blendMode: BlendMode.dstIn,
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white,
                                Colors.white,
                              ],
                              stops: [0, .39, 1],
                            ).createShader(bounds),
                            child: Transform.scale(
                              scale: 1.12 - .12 * drift,
                              alignment: Alignment.centerRight,
                              child: Image.asset(
                                'assets/images/onboarding/intro_scissors.webp',
                                fit: BoxFit.cover,
                                alignment: const Alignment(0, -.52),
                                excludeFromSemantics: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: compact ? 8 : 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRu
                              ? 'Стрижка · пример плана'
                              : 'Haircut · sample plan',
                          style: AppTypography.text2SemiBold.copyWith(
                            color: AppColorsDark.linkGold,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: still
                              ? Duration.zero
                              : const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, .13),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: Text(
                            '${date.day}',
                            key: ValueKey(date),
                            style: AppTypography.h1.copyWith(
                              fontSize: compact ? 44 : 67,
                              height: 1.05,
                              color: AppColors.textInverse,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('MMM · EEEE', locale).format(date),
                          style: AppTypography.text2.copyWith(
                            color: AppColors.textInverse,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12, compact ? 6 : 12, 12, 4),
              child: LayoutBuilder(
                builder: (context, bounds) {
                  final count = bounds.maxWidth < 300 ? 3 : dates.length;
                  return Row(
                    children: [
                      for (var i = 0; i < count; i++)
                        Expanded(
                          child: Semantics(
                            key: ValueKey('intro-calendar-day-$i'),
                            label:
                                '${DateFormat.MMMMEEEEd(locale).format(dates[i])}. ${status[i]}',
                            selected: i == selected,
                            button: true,
                            child: InkWell(
                              onTap: () => _choose(i, _PlanStep.choose),
                              borderRadius: BorderRadius.circular(12),
                              child: ExcludeSemantics(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        DateFormat.E(locale).format(dates[i]),
                                        style: AppTypography.text2.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 38,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: i == selected
                                              ? AppColorsDark.secondary
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        child: Text(
                                          '${dates[i].day}',
                                          textAlign: TextAlign.center,
                                          style: AppTypography.h3.copyWith(
                                            color: i == selected
                                                ? AppColors.textInverse
                                                : AppColors.deepPurple,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const Divider(
              height: 1,
              color: AppColors.divider,
              indent: 16,
              endIndent: 16,
            ),
            IntroStoryFocus(
              key: ValueKey(step),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  compact ? 9 : 14,
                  16,
                  compact ? 10 : 14,
                ),
                child: switch (step) {
                  _PlanStep.choose => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        status[selected],
                        style: AppTypography.h3.copyWith(
                          color: AppColors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        switch (selected) {
                          1 =>
                            isRu
                                ? 'Посмотри соседние даты для смены образа.'
                                : 'Compare the nearby dates for a new look.',
                          2 || 3 => l.introFavorableTip,
                          _ => l.introNeutralTip,
                        },
                        style: AppTypography.text2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _PlannerAction(
                        key: const ValueKey('intro-calendar-save'),
                        icon: Icons.add_rounded,
                        label: isRu ? 'Добавить в планы' : 'Add to my plans',
                        onTap: () => _choose(selected, _PlanStep.saved),
                      ),
                    ],
                  ),
                  _PlanStep.saved => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.introCalendarSavedText,
                        style: AppTypography.h3.copyWith(
                          color: AppColors.deepPurple,
                        ),
                      ),
                      _PlannerAction(
                        key: const ValueKey('intro-calendar-remind'),
                        icon: Icons.notifications_none_rounded,
                        label: selected == 0
                            ? (isRu ? 'Напомнить сегодня' : 'Remind me today')
                            : (isRu
                                  ? 'Напомнить за день'
                                  : 'Remind me a day before'),
                        onTap: () => _choose(selected, _PlanStep.reminder),
                      ),
                    ],
                  ),
                  _PlanStep.reminder => Column(
                    key: const ValueKey('intro-day-result'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRu ? 'Стрижка в планах' : 'Haircut in my plans',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.notifications_active_outlined,
                            size: 20,
                            color: AppColors.deepPurple,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isRu
                                  ? 'Напоминание — $reminderLabel'
                                  : 'Reminder on $reminderLabel',
                              style: AppTypography.text1.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _PlannerAction extends StatelessWidget {
  const _PlannerAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: TextButton.icon(
      icon: Icon(icon, size: 19),
      onPressed: onTap,
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.deepPurple,
        backgroundColor: AppColors.cardTinted,
        minimumSize: const Size(44, 44),
        textStyle: AppTypography.text2SemiBold,
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
    ),
  );
}
