import 'package:asteria_app/features/home/presentation/widgets/moon_calendar_widget.dart';
import 'package:asteria_app/features/scenarios/calendar_plan.dart';
import 'package:asteria_app/core/localization/locale_formatters.dart';
import 'package:asteria_app/core/services/calendar_plan_reminders.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/models/day_status_advice.dart';
import 'package:asteria_app/features/home/presentation/widgets/day_status_icon.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_phase_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';

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
    duration: const Duration(seconds: 12),
    builder: (context, time, still, now) {
      final dates = introUpcomingDates(now);
      const statuses = [
        DayStatus.unfavorable,
        DayStatus.neutral,
        DayStatus.favorable,
        DayStatus.favorable,
        DayStatus.neutral,
      ];
      final selected = still || time >= 3
          ? 2
          : time >= 1.5
          ? 1
          : 0;
      final date = dates[selected];
      final locale = Localizations.localeOf(context).toLanguageTag();
      final media = MediaQuery.of(context);
      final compact = media.size.height < 740;
      final usableHeight = media.size.height - media.viewPadding.vertical;
      final extra =
          !compact &&
              media.size.width >= 350 &&
              media.textScaler.scale(16) <= 18
          ? (usableHeight - 660).clamp(0.0, 110.0)
          : 0.0;
      final roomy = extra >= 55;
      final favorable = selected == 2;
      final saved = still || time >= 6.8;
      final drift = still
          ? 1.0
          : Curves.easeOutCubic.transform((time / 4.8).clamp(0, 1));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StoryEntrance(
            time: time,
            start: .17,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColorsDark.homeCanvas,
                ),
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
                        vertical: compact ? 5 : 12 + extra * .24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!compact)
                            Text(
                              context.l10n.lunarHaircut,
                              style: AppTypography.text2SemiBold.copyWith(
                                color: AppColorsDark.linkGold,
                              ),
                            ),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10,
                            children: [
                              AnimatedSwitcher(
                                duration: still
                                    ? Duration.zero
                                    : const Duration(milliseconds: 220),
                                child: Text(
                                  '${date.day}',
                                  key: ValueKey(date),
                                  style: AppTypography.h1.copyWith(
                                    fontSize: compact ? 36 : 55,
                                    height: 1,
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
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              DayStatusIcon(
                                status: statuses[selected],
                                size: 16,
                                excludeFromSemantics: true,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  statuses[selected].title(context),
                                  style: AppTypography.text2SemiBold.copyWith(
                                    color: AppColors.textInverse,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 6 : 10 + extra * .07),
          LayoutBuilder(
            builder: (context, bounds) {
              final count = bounds.maxWidth < 300 ? 3 : dates.length;
              return Row(
                children: [
                  for (var i = 0; i < count; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: StoryEntrance(
                        time: time,
                        start: .26 + i * .05,
                        rise: 5,
                        child: MoonDayPreview(
                          key: ValueKey('intro-calendar-day-$i'),
                          date: dates[i],
                          status: statuses[i],
                          isSelected: i == selected,
                          markers: saved && i == selected
                              ? StoryEntrance(
                                  time: time,
                                  start: 6.8,
                                  rise: 3,
                                  child: CalendarDayMarkers(
                                    key: const ValueKey('intro-saved-scissors'),
                                    status: statuses[i],
                                    activities: const [
                                      CalendarActivity.haircut,
                                    ],
                                    selected: true,
                                  ),
                                )
                              : null,
                          markerLabel: saved && i == selected
                              ? context.l10n.introCalendarSavedTitle
                              : null,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          if (favorable)
            Padding(
              padding: EdgeInsets.only(top: compact ? 6 : 10 + extra * .07),
              child: StoryReveal(
                time: still ? 12 : time,
                start: saved ? (still ? -1 : 6.8) : 2.99,
                child: _DayOutcome(
                  confirmed: still || time >= 5.4,
                  saved: saved,
                  showAdvice: !saved || still || roomy,
                  compact: compact,
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _DayOutcome extends StatelessWidget {
  const _DayOutcome({
    required this.confirmed,
    required this.saved,
    required this.showAdvice,
    required this.compact,
  });

  final bool confirmed, saved, showAdvice, compact;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final detail = AppTypography.text2.copyWith(
      color: AppColors.textInverse,
      height: 1.25,
    );
    return HomeGlassSurface(
      key: ValueKey(saved ? 'intro-day-result' : 'intro-day-advice'),
      animateEntrance: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: compact ? 7 : 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAdvice) Text(l.introCalendarInsight, style: detail),
            if (showAdvice) SizedBox(height: compact ? 4 : 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    saved ? l.introCalendarSavedText : l.scenarioCalendarSelectDay,
                    style: saved
                        ? AppTypography.text2SemiBold.copyWith(color: AppColorsDark.linkGold)
                        : detail,
                  ),
                ),
                const SizedBox(width: 10),
                Semantics(
                  checked: confirmed,
                  label: l.scenarioCalendarSelectDay,
                  child: Container(
                    key: const ValueKey('intro-day-selection-mark'),
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColorsDark.secondary,
                      gradient: confirmed ? AsteriaActionButton.goldGradient : null,
                    ),
                    child: confirmed
                        ? const Icon(Icons.check_rounded, size: 18, color: AppColors.deepPurple)
                        : null,
                  ),
                ),
              ],
            ),
            if (saved) ...[
              if (const CalendarPlanReminders().supported) ...[
                const SizedBox(height: 4),
                Row(
                  key: const ValueKey('intro-calendar-reminder'),
                  children: [
                    const LotusRasterIcon(
                      'assets/icons/clay/profile_notifications_icon.webp',
                      width: 16,
                      height: 16,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l.planReminderAt(
                          LocaleFormatters.timeOfDay(
                            context,
                            const TimeOfDay(hour: 9, minute: 0),
                          ),
                        ),
                        style: detail,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
