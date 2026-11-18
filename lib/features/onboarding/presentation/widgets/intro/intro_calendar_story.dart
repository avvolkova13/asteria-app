import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_phase_widget.dart';
import 'intro_story.dart';

/// Civil dates, rather than 24-hour offsets, also work across DST boundaries.
List<DateTime> introUpcomingDates(DateTime now) =>
    List.generate(5, (i) => DateTime(now.year, now.month, now.day + i));

class IntroCalendarStory extends StatelessWidget {
  const IntroCalendarStory({
    super.key,
    required this.active,
    this.now = DateTime.now,
  });
  final bool active;
  final DateTime Function() now;

  @override
  Widget build(BuildContext context) => IntroStory(
    active: active,
    now: now,
    duration: const Duration(seconds: 18),
    builder: (context, time, static, now) {
      final l = context.l10n;
      final dates = introUpcomingDates(now);
      final locale = Localizations.localeOf(context).toLanguageTag();
      final date = DateFormat.MMMMd(locale).format(dates[2]);
      final image = SizedBox(
        height: 190,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
          child: Image.asset(
            'assets/images/onboarding/intro_scissors.webp',
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      );
      final plan = StoryCard(
        key: const ValueKey('intro-calendar-plan'),
        title: l.introCalendarSavedTitle,
        text: '${l.introCalendarSavedText}\n$date',
        emphasis: true,
      );
      final reminder = IntroStoryFocus(
        child: Column(
          key: const ValueKey('intro-calendar-reminder'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColorsDark.linkGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.introCalendarReminderChoice,
                    style: AppTypography.text2SemiBold.copyWith(
                      color: AppColorsDark.linkGold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StoryCard(
              title: l.introCalendarReminderTitle,
              text: l.introCalendarReminderEnabled,
              emphasis: true,
            ),
          ],
        ),
      );
      final complete = StoryCard(
        key: const ValueKey('intro-calendar-complete'),
        title: static ? l.introCalendarSavedTitle : l.introCalendarCompleted,
        text: static
            ? '${l.introCalendarSavedText}\n$date\n\n${l.introCalendarCompletedBody}'
            : l.introCalendarCompletedBody,
        emphasis: true,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          image,
          const SizedBox(height: 12),
          if (static)
            complete
          else
            Stack(
              fit: StackFit.passthrough,
              children: [
                StoryReveal(
                  time: time,
                  start: .2,
                  end: 3,
                  child: StoryCard(
                    text: l.introCalendarRequest,
                    emphasis: true,
                  ),
                ),
                StoryReveal(
                  time: time,
                  start: 3.2,
                  end: 6,
                  child: _CalendarPreview(
                    dates: dates,
                    selected: time < 4.1
                        ? 0
                        : time < 5
                        ? 1
                        : 2,
                  ),
                ),
                StoryReveal(
                  time: time,
                  start: 6.3,
                  end: 8.8,
                  child: StoryCard(
                    title: l.introCalendarResult(date),
                    text: l.introCalendarInsight,
                    emphasis: true,
                  ),
                ),
                StoryReveal(time: time, start: 9, end: 11.5, child: plan),
                StoryReveal(
                  time: time,
                  start: 11.8,
                  end: 14.5,
                  child: reminder,
                ),
                StoryReveal(time: time, start: 14.8, child: complete),
              ],
            ),
        ],
      );
    },
  );
}

class _CalendarPreview extends StatelessWidget {
  const _CalendarPreview({required this.dates, required this.selected});
  final List<DateTime> dates;
  final int selected;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return IntroStoryFocus(
      child: HomeGlassSurface(
        animateEntrance: false,
        tint: AppColorsDark.modal.withValues(alpha: .98),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.introCalendarFrom(
                  DateFormat.MMMMd(locale).format(dates.first),
                ),
                style: AppTypography.text2SemiBold.copyWith(
                  color: AppColorsDark.linkGold,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  // The onboarding demonstrates statuses; it is not a forecast.
                  const statuses = [
                    DayStatus.unfavorable,
                    DayStatus.neutral,
                    DayStatus.favorable,
                    DayStatus.favorable,
                    DayStatus.neutral,
                  ];
                  final count = constraints.maxWidth < 300 ? 3 : dates.length;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < count; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(
                          child: MoonDayPreview(
                            key: ValueKey('intro-calendar-day-$i'),
                            date: dates[i],
                            status: statuses[i],
                            isSelected: i == selected,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.introCalendarCompare,
                style: AppTypography.text2.copyWith(
                  color: AppColors.textInverse,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
