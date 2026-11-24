import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
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
    duration: const Duration(seconds: 8),
    builder: (context, time, isStatic, now) {
      final dates = introUpcomingDates(now);
      final settled = isStatic || time >= 1.3;
      final selected = settled ? 2 : (time < .65 ? 0 : 1);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Transform.translate(
            offset: Offset(0, isStatic ? 0 : -4 * math.sin(time * math.pi / 4)),
            child: Image.asset(
              'assets/images/affirmation/motion/subjects/category_moon_whole.png',
              height: MediaQuery.sizeOf(context).height < 650 ? 92 : 156,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(height: 12),
          _CalendarPreview(
            dates: dates,
            selected: selected,
            time: isStatic ? 8 : time,
          ),
        ],
      );
    },
  );
}

class _CalendarPreview extends StatelessWidget {
  const _CalendarPreview({
    required this.dates,
    required this.selected,
    required this.time,
  });
  final List<DateTime> dates;
  final int selected;
  final double time;

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
                context.l10n.introCalendarSavedTitle,
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
              StoryReveal(
                time: time,
                start: 1.3,
                child: IntroStoryFocus(
                  child: Row(
                    key: const ValueKey('intro-day-result'),
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          Icons.notifications_active_outlined,
                          size: 20,
                          color: AppColorsDark.linkGold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${DateFormat.MMMMd(locale).format(dates[2])} · ${context.l10n.introCalendarReminderChoice}',
                          style: AppTypography.text2.copyWith(
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
        ),
      ),
    );
  }
}
