import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_state.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/day_status_icon.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_phase_marker.dart';
import 'package:asteria_app/features/home/presentation/widgets/lunar_card_image.dart';
import 'package:asteria_app/features/scenarios/calendar_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MoonCalendarWidget extends StatelessWidget {
  const MoonCalendarWidget({super.key, this.savedPlans = const []})
    : planningState = null,
      planningSelection = const {},
      firstSelectableDay = null,
      onPlanDay = null,
      onPlanMonth = null,
      plansOnly = false,
      week = false,
      periodTitle = null,
      currentDay = null,
      onPrevious = null,
      onNext = null;

  const MoonCalendarWidget.planning({
    super.key,
    this.savedPlans = const [],
    required this.planningState,
    required this.planningSelection,
    required this.firstSelectableDay,
    required this.onPlanDay,
    required this.onPlanMonth,
    this.week = false,
    this.periodTitle,
    this.onPrevious,
    this.onNext,
  }) : plansOnly = false,
       currentDay = null;

  MoonCalendarWidget.plans({
    super.key,
    required this.savedPlans,
    required DateTime selectedDay,
    required this.currentDay,
    required this.onPlanDay,
    required this.onPlanMonth,
    required this.onPrevious,
    required this.onNext,
    this.week = false,
    this.periodTitle,
  }) : planningState = MoonScreenState(
         focusedDay: selectedDay,
         selectedDate: selectedDay,
       ),
       planningSelection = {calendarDay(selectedDay)},
       firstSelectableDay = null,
       plansOnly = true;

  final bool plansOnly, week;
  final String? periodTitle;
  final DateTime? currentDay;
  final VoidCallback? onPrevious, onNext;

  final List<CalendarPlan> savedPlans;
  final MoonScreenState? planningState;
  final Set<DateTime> planningSelection;
  final DateTime? firstSelectableDay;
  final ValueChanged<DateTime>? onPlanDay;
  final ValueChanged<DateTime>? onPlanMonth;

  bool _isSelected(MoonScreenState state, DateTime day) => planningState == null
      ? isSameDay(state.selectedDate, day)
      : planningSelection.contains(DateTime.utc(day.year, day.month, day.day));

  bool _isEnabled(DateTime day) {
    final date = calendarDay(day);
    return !date.isBefore(firstSelectableDay ?? DateTime.utc(2000)) &&
        !date.isAfter(DateTime.utc(2050, 12, 31));
  }

  @override
  Widget build(BuildContext context) {
    final plan = planningState;
    if (plan != null) return _calendar(context, plan);
    return BlocBuilder<MoonScreenCubit, MoonScreenState>(builder: _calendar);
  }

  Widget _calendar(BuildContext context, MoonScreenState state) =>
      LayoutBuilder(
        builder: (context, constraints) => Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 656),
            child: _calendarGrid(
              context,
              state,
              roomy: constraints.maxWidth >= 510,
            ),
          ),
        ),
      );

  Widget _calendarGrid(
    BuildContext context,
    MoonScreenState state, {
    required bool roomy,
  }) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final textScaler = MediaQuery.textScalerOf(context);
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final weekdaySize = roomy ? 15.0 : 13.0;
    final numberSize = roomy ? 24.0 : 20.0;
    final weekdayHeight = textScaler.scale(weekdaySize) * 18 / 13 + 8;
    final monthLabel = DateFormat('LLLL y', localeTag).format(state.focusedDay);
    final title =
        periodTitle ?? (monthLabel[0].toUpperCase() + monthLabel.substring(1));
    final weekStart = plansOnly
        ? StartingDayOfWeek.values[(MaterialLocalizations.of(context)
                      .firstDayOfWeekIndex +
                  6) %
              7]
        : StartingDayOfWeek.monday;
    final plansByDay = <DateTime, List<CalendarPlan>>{};
    for (final plan in savedPlans) {
      if (plansOnly || week || _isSameMonth(state.focusedDay, plan.day)) {
        (plansByDay[calendarDay(plan.day)] ??= []).add(plan);
      }
    }
    const showMarkers = true;
    // Reserve rating and plan space before data arrives so loading and
    // category changes never resize the month grid.
    final dayHeight = (textScaler.scale(numberSize) * 1.25 + (roomy ? 32 : 29))
        .clamp(54.0, double.infinity);
    final rowHeight = dayHeight + 2;

    Widget dayCell(
      DateTime day, {
      bool selected = false,
      bool outside = false,
    }) {
      final status = outside || plansOnly
          ? null
          : _getDayStatus(day, state.dayStatuses);
      final plans = plansByDay[calendarDay(day)] ?? const <CalendarPlan>[];
      final marker =
          plans.any((plan) => plan.activity == CalendarActivity.haircut)
          ? CalendarActivity.haircut
          : plans.firstOrNull?.activity;
      final activities = plansOnly
          ? [
              if (plans.any((p) => p.activity.sphere == 'beauty'))
                CalendarActivity.haircut,
              if (plans.any((p) => p.activity.sphere == 'gardening'))
                CalendarActivity.transplant,
            ]
          : [if (marker != null) marker];
      final primaryPhase =
          !plansOnly &&
          !outside &&
          state.selectedSphere == null &&
          _hasPrimaryPhase(day, state.primaryPhaseDates);
      return Center(
        key: plansOnly ? ValueKey('plans-date-${calendarDateKey(day)}') : null,
        child: Opacity(
          opacity: outside || !_isEnabled(day) ? 0.4 : 1,
          child: selected
              ? _buildSelectedDayCell(
                  context,
                  day,
                  status,
                  primaryPhase,
                  showMarkers,
                  activities,
                  dayHeight,
                  numberSize,
                )
              : _buildDayCell(
                  context,
                  day,
                  status,
                  primaryPhase,
                  showMarkers,
                  activities,
                  dayHeight,
                  numberSize,
                ),
        ),
      );
    }

    return DecoratedBox(
      decoration: CardLensDecoration(
        color: MoonDesignTokens.calendarSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: roomy ? 14 : 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MonthArrow(
                  previous: true,
                  label: plansOnly || week
                      ? context.l10n.scenarioPlansPrevious
                      : null,
                  onTap: plansOnly || week
                      ? onPrevious
                      : (state.focusedDay.year * 12 + state.focusedDay.month >
                                (firstSelectableDay?.year ?? 2000) * 12 +
                                    (firstSelectableDay?.month ?? 1)
                            ? () => _changeMonth(context, state.focusedDay, -1)
                            : null),
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.navTitle.copyWith(
                        fontSize: roomy ? 20 : null,
                        color: AppColors.textInverse,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                _MonthArrow(
                  previous: false,
                  label: plansOnly || week
                      ? context.l10n.scenarioPlansNext
                      : null,
                  onTap: plansOnly || week
                      ? onNext
                      : ((state.focusedDay.year < 2050 ||
                                state.focusedDay.month < 12)
                            ? () => _changeMonth(context, state.focusedDay, 1)
                            : null),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                // Figma aligns the first and last 32-point digits 16 points from the card edges.
                final inset = ((448 - constraints.maxWidth) / 12).clamp(
                  0.0,
                  16.0,
                );
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: plansOnly ? inset.ceilToDouble() : inset,
                  ),
                  child: Stack(
                    children: [
                      ExcludeSemantics(
                        child: TableCalendar<DayStatus>(
                          firstDay:
                              firstSelectableDay ?? DateTime.utc(2000, 1, 1),
                          lastDay: DateTime.utc(2050, 12, 31),
                          currentDay: currentDay,
                          pageAnimationEnabled: !reducedMotion,
                          pageAnimationDuration: reducedMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 300),
                          pageAnimationCurve: Curves.easeOut,
                          formatAnimationDuration: reducedMotion
                              ? const Duration(microseconds: 1)
                              : const Duration(milliseconds: 200),
                          formatAnimationCurve: Curves.linear,
                          calendarFormat: week
                              ? CalendarFormat.week
                              : CalendarFormat.month,
                          startingDayOfWeek: weekStart,
                          availableGestures: AvailableGestures.horizontalSwipe,
                          headerVisible: false,
                          sixWeekMonthsEnforced: !week,
                          locale: localeTag,
                          focusedDay: state.focusedDay,
                          selectedDayPredicate: (day) =>
                              _isSelected(state, day),
                          onDaySelected: (selectedDay, _) =>
                              _selectDay(context, state, selectedDay),
                          onPageChanged: (focusedDay) {
                            if (week ||
                                !_isSameMonth(focusedDay, state.focusedDay)) {
                              _loadMonth(context, focusedDay);
                            }
                          },
                          rowHeight: rowHeight,
                          daysOfWeekHeight: weekdayHeight,
                          calendarBuilders: CalendarBuilders(
                            dowBuilder: (context, day) {
                              final label = DateFormat.E(localeTag).format(day);
                              return Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      label[0].toUpperCase() +
                                          label.substring(1),
                                      maxLines: 1,
                                      softWrap: false,
                                      style: AppTypography.text2SemiBold
                                          .copyWith(
                                            color: AppColorsDark.textTertiary,
                                            fontSize: roomy
                                                ? weekdaySize
                                                : null,
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            defaultBuilder: (_, day, _) => dayCell(day),
                            todayBuilder: (_, day, _) => dayCell(day),
                            outsideBuilder: (_, day, _) =>
                                dayCell(day, outside: !week),
                            disabledBuilder: (_, day, _) =>
                                dayCell(day, outside: true),
                            selectedBuilder: (_, day, _) =>
                                dayCell(day, selected: true),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: _buildCalendarSemanticsOverlay(
                          context,
                          state,
                          rowHeight,
                          weekdayHeight,
                          plansByDay,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSemanticsOverlay(
    BuildContext context,
    MoonScreenState state,
    double rowHeight,
    double daysOfWeekHeight,
    Map<DateTime, List<CalendarPlan>> plansByDay,
  ) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final focusedMonth = DateTime.utc(
      state.focusedDay.year,
      state.focusedDay.month,
    );
    final firstWeekday = plansOnly
        ? MaterialLocalizations.of(context).firstDayOfWeekIndex
        : 1;
    final anchor = week ? calendarDay(state.focusedDay) : focusedMonth;
    final firstDisplayedDay = anchor.subtract(
      Duration(days: (anchor.weekday % 7 - firstWeekday + 7) % 7),
    );
    final displayedDayCount = (week ? 1 : 6) * DateTime.daysPerWeek;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / DateTime.daysPerWeek;
        return Semantics(
          container: true,
          explicitChildNodes: true,
          child: Stack(
            children: [
              for (var index = 0; index < displayedDayCount; index++)
                Positioned(
                  left: (index % DateTime.daysPerWeek) * cellWidth,
                  top:
                      daysOfWeekHeight +
                      (index ~/ DateTime.daysPerWeek) * rowHeight,
                  width: cellWidth,
                  height: rowHeight,
                  child: Builder(
                    builder: (context) {
                      final day = firstDisplayedDay.add(Duration(days: index));
                      final dayLabel = DateFormat.yMMMMEEEEd(localeTag)
                          .format(day);
                      final isInFocusedMonth =
                          day.year == focusedMonth.year &&
                          day.month == focusedMonth.month;
                      final normalizedDay = DateTime(
                        day.year,
                        day.month,
                        day.day,
                      );
                      final status = !plansOnly && (week || isInFocusedMonth)
                          ? state.dayStatuses[normalizedDay]
                          : null;
                      final phaseChange =
                          !plansOnly &&
                          isInFocusedMonth &&
                          state.selectedSphere == null &&
                          state.primaryPhaseDates.contains(normalizedDay);
                      return Semantics(
                        button: true,
                        selected: _isSelected(state, day),
                        label: [
                          dayLabel,
                          if (plansOnly)
                            context.l10n.scenarioPlansCount(
                              (plansByDay[day] ?? []).length,
                            ),
                          if (plansOnly && isSameDay(day, currentDay))
                            context.l10n.scenarioPlansToday,
                          if (phaseChange) context.l10n.moonPhaseChange,
                          if (plansByDay[day] case final plans?)
                            '${context.l10n.scenarioCalendarMyPlans}: ${plans.map((p) => p.title).join(', ')}',
                          if (status != null)
                            _statusSemanticsLabel(context, status),
                        ].join(', '),
                        enabled: _isEnabled(day),
                        onTap: _isEnabled(day)
                            ? () => _selectDay(context, state, day)
                            : null,
                        child: const SizedBox.expand(),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _changeMonth(
    BuildContext context,
    DateTime focusedMonth,
    int monthDelta,
  ) {
    final month = onPlanMonth == null
        ? context.read<MoonScreenCubit>().state.focusedDay
        : focusedMonth;
    final target = DateTime.utc(month.year, month.month + monthDelta);
    if (target.isBefore(DateTime.utc(2000)) || target.year > 2050) return;
    _loadMonth(context, target);
  }

  void _loadMonth(BuildContext context, DateTime month) {
    if (onPlanMonth != null) {
      onPlanMonth!(month);
    } else {
      context.read<MoonScreenCubit>().loadDayStatuses(month);
    }
  }

  void _selectDay(
    BuildContext context,
    MoonScreenState state,
    DateTime selectedDay,
  ) {
    if (!_isEnabled(selectedDay)) return;
    LotusFeedback.selection();
    if (onPlanDay != null) {
      if (!_isSameMonth(selectedDay, state.focusedDay)) {
        _loadMonth(context, selectedDay);
      }
      onPlanDay!(selectedDay);
      return;
    }
    final cubit = context.read<MoonScreenCubit>();
    final isOutsideFocusedMonth =
        selectedDay.month != state.focusedDay.month ||
        selectedDay.year != state.focusedDay.year;
    if (isOutsideFocusedMonth) {
      cubit.loadDayStatuses(selectedDay);
    }
    cubit.selectDate(selectedDay);
  }

  DayStatus? _getDayStatus(
    DateTime day,
    Map<DateTime, DayStatus> stateStatuses,
  ) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return stateStatuses[normalizedDay];
  }

  bool _hasPrimaryPhase(DateTime day, Set<DateTime> primaryPhaseDates) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return primaryPhaseDates.contains(normalizedDay);
  }

  bool _isSameMonth(DateTime left, DateTime right) {
    return left.year == right.year && left.month == right.month;
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    DayStatus? status,
    bool hasPrimaryPhase,
    bool showStatusRow,
    List<CalendarActivity> activities,
    double rowHeight,
    double numberSize,
  ) {
    return Semantics(
      button: true,
      label: DateFormat.yMMMMEEEEd(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(day),
      child: ExcludeSemantics(
        child: SizedBox(
          width: numberSize > 20 ? 40 : 32,
          height: rowHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _CalendarDayNumber(
                day: day.day,
                fontSize: numberSize,
                color: AppColors.textInverse,
                hasPrimaryPhase: hasPrimaryPhase,
              ),
              if (showStatusRow) ...[
                const SizedBox(height: 5),
                CalendarDayMarkers(status: status, activities: activities),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Создает выбранную ячейку дня
  Widget _buildSelectedDayCell(
    BuildContext context,
    DateTime day,
    DayStatus? status,
    bool hasPrimaryPhase,
    bool showStatusRow,
    List<CalendarActivity> activities,
    double rowHeight,
    double numberSize,
  ) {
    final highlightWidth = numberSize > 20
        ? 44.0
        : (activities.length + (status == null ? 0 : 1) > 1 ? 40.0 : 32.0);

    return Semantics(
      button: true,
      selected: true,
      label: DateFormat.yMMMMEEEEd(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(day),
      child: ExcludeSemantics(
        child: SizedBox(
          width: highlightWidth,
          height: rowHeight,
          child: Center(
            child: _SelectedDayHighlight(
              date: day,
              width: highlightWidth,
              height: rowHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    key: ValueKey(
                      'selected-day-text-${day.year}-${day.month}-${day.day}',
                    ),
                    tween: Tween(begin: 0, end: 1),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 380),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return _CalendarDayNumber(
                        day: day.day,
                        fontSize: numberSize,
                        hasPrimaryPhase: hasPrimaryPhase,
                        selected: true,
                        color: Color.lerp(
                          AppColors.textInverse,
                          AppColors.textPrimary,
                          value,
                        )!,
                      );
                    },
                  ),
                  if (showStatusRow) ...[
                    const SizedBox(height: 5),
                    CalendarDayMarkers(
                      status: status,
                      activities: activities,
                      selected: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _statusSemanticsLabel(BuildContext context, DayStatus status) {
    switch (status) {
      case DayStatus.favorable:
        return context.l10n.dayFavorable.replaceAll('\n', ' ');
      case DayStatus.unfavorable:
        return context.l10n.dayUnfavorable.replaceAll('\n', ' ');
      case DayStatus.neutral:
        return context.l10n.dayNeutral.replaceAll('\n', ' ');
    }
  }
}

class CalendarDayMarkers extends StatelessWidget {
  const CalendarDayMarkers({
    super.key,
    required this.status,
    required this.activities,
    this.selected = false,
  });
  final bool selected;
  final DayStatus? status;
  final List<CalendarActivity> activities;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status case final dayStatus?)
            DayStatusIcon(
              status: dayStatus,
              size: 14,
              excludeFromSemantics: true,
            ),
          for (final task in activities)
            if (LunarCardAsset.forTaskKey(task.keys.first)
                case final asset?) ...[
              if (status != null) const SizedBox(width: 2),
              _activityIcon(context, task, asset),
            ],
        ],
      ),
    );
  }

  Widget _activityIcon(
    BuildContext context,
    CalendarActivity task,
    String asset,
  ) {
    final scissors = task == CalendarActivity.haircut;
    final image = Image.asset(
      LunarCardAsset.path(asset),
      width: 16,
      height: 16,
      cacheWidth: (16 * MediaQuery.devicePixelRatioOf(context)).ceil(),
      color: selected && scissors ? AppColorsDark.secondary : null,
      colorBlendMode: BlendMode.modulate,
      excludeFromSemantics: true,
    );
    if (scissors || !selected) return image;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.68),
        shape: BoxShape.circle,
      ),
      child: image,
    );
  }
}

class _SelectedDayHighlight extends StatelessWidget {
  const _SelectedDayHighlight({
    required this.date,
    required this.width,
    required this.height,
    required this.child,
  });

  final DateTime date;
  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(
        'selected-day-highlight-${date.year}-${date.month}-${date.day}',
      ),
      tween: Tween(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            key: const ValueKey('selected-day-highlight'),
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    key: const ValueKey('selected-day-background'),
                    decoration: BoxDecoration(
                      gradient: MoonDesignTokens.selectedDayGradient(value),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: DecoratedBox(
                      key: const ValueKey('selected-day-inner-glow'),
                      decoration: BoxDecoration(
                        gradient: MoonDesignTokens.selectedDayInnerGlow(value),
                      ),
                      child: const SizedBox(width: 32, height: 42),
                    ),
                  ),
                ),
                child!,
              ],
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _CalendarDayNumber extends StatelessWidget {
  const _CalendarDayNumber({
    required this.day,
    required this.color,
    required this.hasPrimaryPhase,
    required this.fontSize,
    this.selected = false,
  });

  final int day;
  final Color color;
  final bool hasPrimaryPhase;
  final double fontSize;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$day',
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontFamily: AppTypography.bodyFamily,
              fontSize: fontSize,
              height: 1.25,
              letterSpacing: 0.38,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
        if (hasPrimaryPhase)
          Positioned(
            top: -10,
            right: -10,
            child: MoonPhaseMarker(
              color: selected
                  ? AppColors.textPrimary
                  : MoonDesignTokens.selectedDay,
            ),
          ),
      ],
    );
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.previous, required this.onTap, this.label});

  final bool previous;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tooltip =
        label ??
        (previous
            ? context.l10n.calendarPreviousMonth
            : context.l10n.calendarNextMonth);
    return SizedBox.square(
      dimension: 44,
      child: LotusButtons.icon(
        tooltip: tooltip,
        onPressed: onTap,
        padding: EdgeInsets.zero,
        icon: Opacity(
          opacity: onTap == null ? 0.3 : 1,
          child: LotusArrowBubble(back: previous),
        ),
      ),
    );
  }
}
