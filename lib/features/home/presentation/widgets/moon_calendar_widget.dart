import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_state.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/day_status_icon.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MoonCalendarWidget extends StatelessWidget {
  const MoonCalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoonScreenCubit, MoonScreenState>(
      builder: (context, state) {
        final localeTag = Localizations.localeOf(context).toLanguageTag();
        final isCompactHeight = MediaQuery.sizeOf(context).height < 860;
        final rowHeight = isCompactHeight ? 36.0 : 57.0;

        return Listener(
          onPointerMove: (event) {
            if (event.delta.dy.abs() > event.delta.dx.abs() &&
                event.delta.dy.abs() > 1) {
              final primaryScrollController = PrimaryScrollController.of(
                context,
              );
              if (primaryScrollController.hasClients) {
                primaryScrollController.jumpTo(
                  (primaryScrollController.offset - event.delta.dy).clamp(
                    0.0,
                    primaryScrollController.position.maxScrollExtent,
                  ),
                );
              }
            }
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                final metrics = notification.metrics;
                if (metrics.axis == Axis.vertical) {
                  final primaryScrollController = PrimaryScrollController.of(
                    context,
                  );
                  if (primaryScrollController.hasClients) {
                    final delta = notification.scrollDelta ?? 0;
                    if (delta.abs() > 0) {
                      primaryScrollController.jumpTo(
                        (primaryScrollController.offset - delta).clamp(
                          0.0,
                          primaryScrollController.position.maxScrollExtent,
                        ),
                      );
                    }
                  }
                  return true;
                }
              }
              return false;
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: MoonDesignTokens.calendarSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExcludeSemantics(
                        child: TableCalendar<DayStatus>(
                          firstDay: DateTime.utc(2000, 1, 1),
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          lastDay: DateTime.utc(2050, 12, 31),
                          locale: localeTag,
                          focusedDay: state.focusedDay,
                          selectedDayPredicate: (day) {
                            return isSameDay(state.selectedDate, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            _selectDay(context, state, selectedDay, focusedDay);
                          },
                          onPageChanged: (focusedDay) {
                            if (_isSameMonth(focusedDay, state.focusedDay)) {
                              return;
                            }
                            context.read<MoonScreenCubit>().loadDayStatuses(
                              focusedDay,
                            );
                          },
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: true,
                            outsideTextStyle: context
                                .textTheme
                                .urbanistRegular20
                                .copyWith(
                                  color: AppColors.textInverse.withValues(
                                    alpha: 0.35,
                                  ),
                                  height: 1.25,
                                ),
                            weekendTextStyle: context
                                .textTheme
                                .urbanistRegular20
                                .copyWith(
                                  color: AppColors.textInverse,
                                  height: 1.25,
                                ),
                            defaultTextStyle: context
                                .textTheme
                                .urbanistRegular20
                                .copyWith(
                                  color: AppColors.textInverse,
                                  height: 1.25,
                                ),
                            selectedTextStyle: context
                                .textTheme
                                .urbanistRegular20
                                .copyWith(
                                  color: AppColors.textInverse,
                                  height: 1.25,
                                ),
                            todayTextStyle: context.textTheme.urbanistRegular20
                                .copyWith(
                                  color: AppColors.textInverse,
                                  height: 1.25,
                                ),
                            selectedDecoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            todayDecoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            defaultDecoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            weekendDecoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                          ),
                          rowHeight: rowHeight,
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            leftChevronVisible: false,
                            rightChevronVisible: false,
                            titleCentered: true,
                            headerPadding: const EdgeInsets.only(bottom: 14),
                            titleTextFormatter: (date, locale) {
                              final formatted = DateFormat.yMMMM(
                                localeTag,
                              ).format(date);
                              return formatted[0].toUpperCase() +
                                  formatted.substring(1);
                            },
                            titleTextStyle: context.textTheme.urbanistSemiBold17
                                .copyWith(
                                  color: AppColors.textInverse,
                                  height: 1.29,
                                ),
                            leftChevronIcon: Semantics(
                              label: context.l10n.calendarPreviousMonth,
                              child: ExcludeSemantics(
                                child: Image.asset(
                                  'assets/icons/chevron_left.png',
                                  width: 10,
                                  height: 18,
                                ),
                              ),
                            ),
                            rightChevronIcon: Semantics(
                              label: context.l10n.calendarNextMonth,
                              child: ExcludeSemantics(
                                child: Image.asset(
                                  'assets/icons/chevron_right.png',
                                  width: 10,
                                  height: 18,
                                ),
                              ),
                            ),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: context.textTheme.urbanistSemiBold12
                                .copyWith(
                                  color: AppColors.textInverse.withValues(
                                    alpha: 0.55,
                                  ),
                                  fontSize: 13,
                                  height: 1.38,
                                ),
                            weekendStyle: context.textTheme.urbanistSemiBold12
                                .copyWith(
                                  color: AppColors.textInverse.withValues(
                                    alpha: 0.55,
                                  ),
                                  fontSize: 13,
                                  height: 1.38,
                                ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              final dayStatus = _getDayStatus(
                                day,
                                state.dayStatuses,
                              );
                              return _buildDayCell(
                                context,
                                day,
                                dayStatus,
                                _hasPrimaryPhase(day, state.primaryPhaseDates),
                                rowHeight,
                                isCompactHeight,
                              );
                            },
                            selectedBuilder: (context, day, focusedDay) {
                              final dayStatus = _getDayStatus(
                                day,
                                state.dayStatuses,
                              );
                              return _buildSelectedDayCell(
                                context,
                                day,
                                dayStatus,
                                _hasPrimaryPhase(day, state.primaryPhaseDates),
                                rowHeight,
                                isCompactHeight,
                              );
                            },
                            outsideBuilder: (context, day, focusedDay) {
                              return Opacity(
                                opacity: 0.35,
                                child: _buildDayCell(
                                  context,
                                  day,
                                  null,
                                  false,
                                  rowHeight,
                                  isCompactHeight,
                                  showStatusIcon: false,
                                ),
                              );
                            },
                            todayBuilder: (context, day, focusedDay) {
                              final dayStatus = _getDayStatus(
                                day,
                                state.dayStatuses,
                              );
                              return _buildDayCell(
                                context,
                                day,
                                dayStatus,
                                _hasPrimaryPhase(day, state.primaryPhaseDates),
                                rowHeight,
                                isCompactHeight,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned.fill(
                    child: _buildCalendarSemanticsOverlay(
                      context,
                      state,
                      rowHeight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarSemanticsOverlay(
    BuildContext context,
    MoonScreenState state,
    double rowHeight,
  ) {
    const daysOfWeekHeight = 16.0;
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
    final monthLabel = DateFormat.yMMMM(localeTag).format(focusedMonth);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / DateTime.daysPerWeek;
        final weekCount = displayedDayCount ~/ DateTime.daysPerWeek;
        // The title height follows the active font and text scale.
        final headerHeight =
            (constraints.maxHeight - daysOfWeekHeight - weekCount * rowHeight)
                .clamp(0.0, double.infinity);

        return Semantics(
          container: true,
          explicitChildNodes: true,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: 60,
                height: headerHeight,
                child: Semantics(
                  button: true,
                  label: context.l10n.calendarPreviousMonth,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _changeMonth(context, focusedMonth, -1),
                    child: Center(
                      child: ExcludeSemantics(
                        child: Image.asset(
                          'assets/icons/chevron_left.png',
                          width: 10,
                          height: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 60,
                right: 60,
                top: 0,
                height: headerHeight,
                child: Semantics(
                  header: true,
                  label: monthLabel[0].toUpperCase() + monthLabel.substring(1),
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                width: 60,
                height: headerHeight,
                child: Semantics(
                  button: true,
                  label: context.l10n.calendarNextMonth,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _changeMonth(context, focusedMonth, 1),
                    child: Center(
                      child: ExcludeSemantics(
                        child: Image.asset(
                          'assets/icons/chevron_right.png',
                          width: 10,
                          height: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              for (var index = 0; index < displayedDayCount; index++)
                Positioned(
                  left: (index % DateTime.daysPerWeek) * cellWidth,
                  top:
                      headerHeight +
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
                      return Semantics(
                        button: true,
                        selected: isSameDay(state.selectedDate, day),
                        label: status == null
                            ? dayLabel
                            : '$dayLabel, ${_statusSemanticsLabel(context, status)}',
                        onTap: () => _selectDay(context, state, day, day),
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
    context.read<MoonScreenCubit>().loadDayStatuses(
      DateTime.utc(focusedMonth.year, focusedMonth.month + monthDelta),
    );
  }

  void _selectDay(
    BuildContext context,
    MoonScreenState state,
    DateTime selectedDay,
    DateTime focusedDay,
  ) {
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
    double rowHeight,
    bool isCompactHeight, {
    bool showStatusIcon = true,
  }) {
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
              Text(
                '${day.day}',
                style: context.textTheme.urbanistRegular20.copyWith(
                  color: AppColors.textInverse,
                  fontSize: isCompactHeight ? 16 : 20,
                  height: 1.25,
                ),
              ),
              if (showStatusIcon)
                _buildDayIndicators(
                  context,
                  status,
                  hasPrimaryPhase: hasPrimaryPhase,
                ),
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
    double rowHeight,
    bool isCompactHeight,
  ) {
    final highlightHeight = isCompactHeight ? rowHeight : 48.0;

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
                      return Text(
                        '${day.day}',
                        style: context.textTheme.urbanistRegular20.copyWith(
                          color: Color.lerp(
                            AppColors.textInverse,
                            AppColors.textPrimary,
                            value,
                          ),
                          fontSize: isCompactHeight ? 16 : 20,
                          height: 1.25,
                        ),
                      );
                    },
                  ),
                  _buildDayIndicators(
                    context,
                    status,
                    hasPrimaryPhase: hasPrimaryPhase,
                    isSelected: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // /// Создает ячейку сегодняшнего дня
  // Widget _buildTodayCell(
  //   BuildContext context,
  //   DateTime day,
  //   DayStatus? status,
  // ) {
  //   return Container(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Text(
  //           '${day.day}',
  //           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
  //         ),
  //         _buildStatusIcon(status),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDayIndicators(
    BuildContext context,
    DayStatus? status, {
    required bool hasPrimaryPhase,
    bool isSelected = false,
  }) {
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (status != null)
            DayStatusIcon(
              status: status,
              size: 14,
              semanticLabel: _statusSemanticsLabel(context, status),
              excludeFromSemantics: true,
            ),
          if (hasPrimaryPhase)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.textPrimary
                      : MoonDesignTokens.selectedDay,
                ),
              ),
            ),
        ],
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
