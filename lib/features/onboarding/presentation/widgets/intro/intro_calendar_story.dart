import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/models/day_status_advice.dart';
import 'package:asteria_app/features/home/presentation/widgets/day_status_icon.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_phase_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    duration: const Duration(seconds: 7),
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
      final compact = MediaQuery.sizeOf(context).height < 650;
      final drift = still
          ? 1.0
          : Curves.easeOutCubic.transform((time / 4.8).clamp(0, 1));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
            child: DecoratedBox(
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
                          context.l10n.lunarHaircut,
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
                        const SizedBox(height: 6),
                        Row(
                          key: selected == 2
                              ? const ValueKey('intro-day-result')
                              : null,
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
          const SizedBox(height: 12),
          IntroStoryFocus(
            enabled: !still && time >= .6,
            child: LayoutBuilder(
              builder: (context, bounds) {
                final count = bounds.maxWidth < 300 ? 3 : dates.length;
                return Row(
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
          ),
        ],
      );
    },
  );
}
