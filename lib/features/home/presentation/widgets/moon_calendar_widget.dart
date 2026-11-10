import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_state.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/day_status_icon.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_phase_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';

class MoonCalendarWidget extends StatelessWidget {
  const MoonCalendarWidget({super.key})
    : planningState = null,
      planningSelection = const {},
      firstSelectableDay = null,
      onPlanDay = null,
      onPlanMonth = null;

  const MoonCalendarWidget.planning({
    super.key,
    required this.planningState,
    required this.planningSelection,
    required this.firstSelectableDay,
    required this.onPlanDay,
    required this.onPlanMonth,
  });

  final MoonScreenState? planningState;
  final Set<DateTime> planningSelection;
  final DateTime? firstSelectableDay;
  final ValueChanged<DateTime>? onPlanDay;
  final ValueChanged<DateTime>? onPlanMonth;

  bool _isSelected(MoonScreenState state, DateTime day) => planningState == null
      ? isSameDay(state.selectedDate, day)
      : planningSelection.contains(DateTime.utc(day.year, day.month, day.day));

  bool _isEnabled(DateTime day) =>
      firstSelectableDay == null ||
      !DateTime.utc(day.year, day.month, day.day).isBefore(firstSelectableDay!);

  @override
  Widget build(BuildContext context) {
    final plan = planningState;
    if (plan != null) return _calendar(context, plan);
    return BlocBuilder<MoonScreenCubit, MoonScreenState>(builder: _calendar);
  }

  Widget _calendar(BuildContext context, MoonScreenState state) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final textScaler = MediaQuery.textScalerOf(context);
    final dayHeight = (textScaler.scale(20) * 1.25 + 32).clamp(
      57.0,
      double.infinity,
    );
    final rowHeight = dayHeight + 16;
    final weekdayHeight = textScaler.scale(13) * 18 / 13 + 8;
    final monthLabel = DateFormat('LLLL y', localeTag).format(state.focusedDay);
    final title = monthLabel[0].toUpperCase() + monthLabel.substring(1);
    Widget dayCell(
      DateTime day, {
      bool selected = false,
      bool outside = false,
    }) {
      final status = outside ? null : _getDayStatus(day, state.dayStatuses);
      final primaryPhase =
          !outside &&
          state.selectedSphere == null &&
          _hasPrimaryPhase(day, state.primaryPhaseDates);
      return Center(
        child: Opacity(
          opacity: outside || !_isEnabled(day) ? 0.4 : 1,
          child: selected
              ? _buildSelectedDayCell(
                  context,
                  day,
                  status,
                  primaryPhase,
                  state.selectedSphere != null || state.dayStatuses.isNotEmpty,
                  dayHeight,
                )
              : _buildDayCell(
                  context,
                  day,
                  status,
                  primaryPhase,
                  state.selectedSphere != null || state.dayStatuses.isNotEmpty,
                  dayHeight,
                ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
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
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MonthArrow(
                  previous: true,
                  onTap:
                      state.focusedDay.year * 12 + state.focusedDay.month >
                          (firstSelectableDay?.year ?? 2000) * 12 +
                              (firstSelectableDay?.month ?? 1)
                      ? () => _changeMonth(context, state.focusedDay, -1)
                      : null,
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        height: 22 / 17,
                        letterSpacing: -0.408,
                        color: AppColors.textInverse,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                _MonthArrow(
                  previous: false,
                  onTap:
                      (state.focusedDay.year < 2050 ||
                          state.focusedDay.month < 12)
                      ? () => _changeMonth(context, state.focusedDay, 1)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                // Figma aligns the first and last 32-point digits 16 points from the card edges.
                final inset = ((448 - constraints.maxWidth) / 12).clamp(
                  0.0,
                  16.0,
                );
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: inset),
                  child: Stack(
                    children: [
                      ExcludeSemantics(
                        child: TableCalendar<DayStatus>(
                          firstDay:
                              firstSelectableDay ?? DateTime.utc(2000, 1, 1),
                          lastDay: DateTime.utc(2050, 12, 31),
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          availableGestures: AvailableGestures.horizontalSwipe,
                          headerVisible: false,
                          locale: localeTag,
                          focusedDay: state.focusedDay,
                          selectedDayPredicate: (day) =>
                              _isSelected(state, day),
                          onDaySelected: (selectedDay, focusedDay) =>
                              _selectDay(
                                context,
                                state,
                                selectedDay,
                                focusedDay,
                              ),
                          onPageChanged: (focusedDay) {
                            if (!_isSameMonth(focusedDay, state.focusedDay)) {
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
                                child: Text(
                                  label[0].toUpperCase() + label.substring(1),
                                  style: const TextStyle(
                                    fontFamily: '.SF Pro Text',
                                    fontSize: 13,
                                    height: 18 / 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.078,
                                    color: Color(0xFFA89CAA),
                                  ),
                                ),
                              );
                            },
                            defaultBuilder: (_, day, _) => dayCell(day),
                            todayBuilder: (_, day, _) => dayCell(day),
                            outsideBuilder: (_, day, _) =>
                                dayCell(day, outside: true),
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
  ) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final focusedMonth = DateTime.utc(
      state.focusedDay.year,
      state.focusedDay.month,
    );
    final firstDisplayedDay = focusedMonth.subtract(
      Duration(days: focusedMonth.weekday - DateTime.monday),
    );
    final lastDayOfMonth = DateTime.utc(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    );
    final trailingDays =
        (DateTime.sunday - lastDayOfMonth.weekday) % DateTime.daysPerWeek;
    final displayedDayCount =
        lastDayOfMonth.difference(firstDisplayedDay).inDays + 1 + trailingDays;
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
                      final dayLabel = DateFormat.yMMMMEEEEd(
                        localeTag,
                      ).format(day);
                      final isInFocusedMonth =
                          day.year == focusedMonth.year &&
                          day.month == focusedMonth.month;
                      final normalizedDay = DateTime(
                        day.year,
                        day.month,
                        day.day,
                      );
                      final status = isInFocusedMonth
                          ? state.dayStatuses[normalizedDay]
                          : null;
                      final phaseChange =
                          isInFocusedMonth &&
                          state.selectedSphere == null &&
                          state.primaryPhaseDates.contains(normalizedDay);
                      return Semantics(
                        button: true,
                        selected: _isSelected(state, day),
                        label: [
                          dayLabel,
                          if (phaseChange) context.l10n.moonPhaseChange,
                          if (status != null)
                            _statusSemanticsLabel(context, status),
                        ].join(', '),
                        enabled: _isEnabled(day),
                        onTap: _isEnabled(day)
                            ? () => _selectDay(context, state, day, day)
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
    _loadMonth(
      context,
      DateTime.utc(focusedMonth.year, focusedMonth.month + monthDelta),
    );
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
    DateTime focusedDay,
  ) {
    if (!_isEnabled(selectedDay)) return;
    if (onPlanDay != null) {
      if (!_isSameMonth(selectedDay, state.focusedDay)) {
        _loadMonth(context, focusedDay);
      }
      onPlanDay!(selectedDay);
      return;
    }
    final cubit = context.read<MoonScreenCubit>();
    final isOutsideFocusedMonth =
        selectedDay.month != state.focusedDay.month ||
        selectedDay.year != state.focusedDay.year;
    if (isOutsideFocusedMonth) {
      cubit.loadDayStatuses(focusedDay);
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
    double rowHeight,
  ) {
    return Semantics(
      button: true,
      label: DateFormat.yMMMMEEEEd(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(day),
      child: ExcludeSemantics(
        child: SizedBox(
          width: 32,
          height: rowHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _CalendarDayNumber(
                day: day.day,
                color: AppColors.textInverse,
                hasPrimaryPhase: hasPrimaryPhase,
              ),
              if (showStatusRow) ...[
                const SizedBox(height: 5),
                SizedBox.square(
                  dimension: 14,
                  child: status == null
                      ? null
                      : DayStatusIcon(
                          status: status,
                          size: 14,
                          excludeFromSemantics: true,
                        ),
                ),
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
    double rowHeight,
  ) {
    final highlightHeight = rowHeight;

    return Semantics(
      button: true,
      selected: true,
      label: DateFormat.yMMMMEEEEd(
        Localizations.localeOf(context).toLanguageTag(),
      ).format(day),
      child: ExcludeSemantics(
        child: SizedBox(
          width: 32,
          height: rowHeight,
          child: Center(
            child: _SelectedDayHighlight(
              date: day,
              width: 32,
              height: highlightHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    key: ValueKey(
                      'selected-day-text-${day.year}-${day.month}-${day.day}',
                    ),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return _CalendarDayNumber(
                        day: day.day,
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
                    SizedBox.square(
                      dimension: 14,
                      child: status == null
                          ? null
                          : DayStatusIcon(
                              status: status,
                              size: 14,
                              excludeFromSemantics: true,
                            ),
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
      duration: const Duration(milliseconds: 380),
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
    this.selected = false,
  });

  final int day;
  final Color color;
  final bool hasPrimaryPhase;
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
              fontFamily: '.SF Pro Display',
              fontSize: 20,
              height: 1.25,
              letterSpacing: 0.38,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
        if (hasPrimaryPhase)
          Positioned(
            top: -7,
            right: -5,
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
  const _MonthArrow({required this.previous, required this.onTap});

  final bool previous;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = previous
        ? context.l10n.calendarPreviousMonth
        : context.l10n.calendarNextMonth;
    return SizedBox.square(
      dimension: 44,
      child: IconButton(
        tooltip: label,
        onPressed: onTap,
        padding: EdgeInsets.zero,
        icon: Opacity(
          opacity: onTap == null ? 0.3 : 1,
          child: SvgPicture.asset(
            previous
                ? 'assets/icons/moon_calendar_previous.svg'
                : 'assets/icons/moon_calendar_next.svg',
            width: 10,
            height: 18,
            excludeFromSemantics: true,
            colorFilter: const ColorFilter.mode(
              MoonDesignTokens.chipOrange,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
