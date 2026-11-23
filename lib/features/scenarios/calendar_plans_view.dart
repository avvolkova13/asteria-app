import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/home/presentation/widgets/lunar_card_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'calendar_plan.dart';
import 'scenario_ui.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_calendar_widget.dart';

enum PlansCalendarMode { month, week, day }

/// Calendar projection of the existing account-owned, date-only plans.
class CalendarPlansView extends StatefulWidget {
  const CalendarPlansView({
    super.key,
    required this.plans,
    required this.onOpenPlan,
    required this.onChooseDate,
    this.now = DateTime.now,
  });

  final List<CalendarPlan> plans;
  final ValueChanged<CalendarPlan> onOpenPlan;
  final VoidCallback onChooseDate;
  final DateTime Function() now;

  @override
  State<CalendarPlansView> createState() => _CalendarPlansViewState();
}

class _CalendarPlansViewState extends State<CalendarPlansView> {
  late DateTime _selected = _bounded(calendarDay(widget.now()));
  PlansCalendarMode _mode = PlansCalendarMode.month;

  String get _locale => Localizations.localeOf(context).toLanguageTag();
  DateTime get _today => calendarDay(widget.now());

  List<CalendarPlan> _on(DateTime day) => widget.plans
      .where((plan) => calendarDateKey(plan.day) == calendarDateKey(day))
      .toList();

  DateTime _weekStart(DateTime day) {
    final first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    return DateTime.utc(
      day.year,
      day.month,
      day.day - (day.weekday % 7 - first + 7) % 7,
    );
  }

  DateTime _bounded(DateTime date) {
    final first = DateTime.utc(2000);
    final last = DateTime.utc(2050, 12, 31);
    return date.isBefore(first) ? first : (date.isAfter(last) ? last : date);
  }

  VoidCallback? _moveAction(int direction) =>
      (direction < 0 && !_selected.isAfter(DateTime.utc(2000))) ||
          (direction > 0 && !_selected.isBefore(DateTime.utc(2050, 12, 31)))
      ? null
      : () => _move(direction);

  void _move(int direction) => setState(() {
    if (_mode == PlansCalendarMode.month) {
      final month = DateTime.utc(_selected.year, _selected.month + direction);
      final last = DateTime.utc(month.year, month.month + 1, 0).day;
      _selected = DateTime.utc(
        month.year,
        month.month,
        math.min(_selected.day, last),
      );
    } else {
      _selected = DateTime.utc(
        _selected.year,
        _selected.month,
        _selected.day + direction * (_mode == PlansCalendarMode.week ? 7 : 1),
      );
    }
    _selected = _bounded(_selected);
  });

  String get _periodLabel {
    if (_mode == PlansCalendarMode.day) {
      return _capitalized(DateFormat.EEEE(_locale).format(_selected));
    }
    if (_mode == PlansCalendarMode.month) {
      return DateFormat.yMMMM(_locale).format(_selected);
    }
    final first = _weekStart(_selected);
    final last = first.add(const Duration(days: 6));
    if (first.year == last.year && first.month == last.month) {
      if (Localizations.localeOf(context).languageCode == 'en') {
        return '${DateFormat.MMMd(_locale).format(first)}–${last.day}';
      }
      return '${first.day}–${DateFormat.MMMMd(_locale).format(last)}';
    }
    return '${DateFormat.MMMd(_locale).format(first)} — ${DateFormat.yMMMd(_locale).format(last)}';
  }

  String _capitalized(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';

  double _measureLabel(
    BuildContext context,
    String text,
    TextStyle style,
    TextScaler scaler,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: scaler,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  Widget _dateCard(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final numberScaler = scaler.clamp(maxScaleFactor: 1.3);
    final day = '${_selected.day}';
    final monthPrefix = _capitalized(
      DateFormat.LLLL(_locale).format(_selected),
    );
    final month = _capitalized(DateFormat.yMMMM(_locale).format(_selected));
    final numberStyle = AppTypography.h3.copyWith(
      fontSize: 56,
      height: 1,
      color: AppColorsDark.linkGold,
    );
    final monthStyle = AppTypography.h3.copyWith(color: AppColors.textInverse);
    final number = Text(day, style: numberStyle, textScaler: numberScaler);
    final detail = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(month, style: monthStyle),
        const SizedBox(height: 8),
        Text(
          context.l10n.scenarioPlansCount(_on(_selected).length),
          style: AppTypography.text2.copyWith(
            color: AppColorsDark.textSecondary,
          ),
        ),
      ],
    );
    const separation = 20.0;
    final minimumRowWidth =
        _measureLabel(context, day, numberStyle, numberScaler) +
        separation +
        _measureLabel(context, monthPrefix, monthStyle, scaler);
    return HomeGlassSurface(
      animateEntrance: false,
      tint: AppColorsDark.modal.withValues(alpha: .4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: LayoutBuilder(
          builder: (_, constraints) => constraints.maxWidth < minimumRowWidth
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [number, const SizedBox(height: 12), detail],
                )
              : Row(
                  children: [
                    number,
                    const SizedBox(width: separation),
                    Expanded(child: detail),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final textActionStyle = TextButton.styleFrom(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 12),
      minimumSize: const Size(44, 44),
    );
    final weekStart = _weekStart(_selected);
    final days = _mode == PlansCalendarMode.week
        ? List.generate(7, (i) => weekStart.add(Duration(days: i)))
        : [_selected];
    final shown = days.where((day) => _on(day).isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedPicker<PlansCalendarMode>(
          options: PlansCalendarMode.values,
          selectedValue: _mode,
          onChanged: (mode) => setState(() => _mode = mode),
          labelBuilder: (mode) => switch (mode) {
            PlansCalendarMode.month => l.scenarioPlansMonth,
            PlansCalendarMode.week => l.scenarioPlansWeek,
            PlansCalendarMode.day => l.scenarioPlansDay,
          },
        ),
        const SizedBox(height: 16),
        _CalendarSizeTransition(
          key: const ValueKey('plans-calendar-transition'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_mode == PlansCalendarMode.day)
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          _periodLabel,
                          maxLines: 1,
                          softWrap: false,
                          style: AppTypography.h3.copyWith(
                            color: AppColors.textInverse,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    LotusButtons.icon(
                      tooltip: l.scenarioPlansPrevious,
                      onPressed: _moveAction(-1),
                      icon: const LotusArrowBubble(back: true),
                    ),
                    LotusButtons.icon(
                      tooltip: l.scenarioPlansNext,
                      onPressed: _moveAction(1),
                      icon: const LotusArrowBubble(),
                    ),
                  ],
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: LotusButtons.text(
                  style: textActionStyle,
                  onPressed: () => setState(() => _selected = _bounded(_today)),
                  child: Text(
                    '${l.scenarioPlansToday}, ${DateFormat.MMMMd(_locale).format(_today)}',
                    style: AppTypography.text2SemiBold.copyWith(
                      color: AppColorsDark.linkGold,
                    ),
                  ),
                ),
              ),
              if (_mode == PlansCalendarMode.day) ...[
                _dateCard(context),
                const SizedBox(height: 24),
              ],
              if (_mode != PlansCalendarMode.day) ...[
                MoonCalendarWidget.plans(
                  savedPlans: widget.plans,
                  selectedDay: _selected,
                  currentDay: _today,
                  week: _mode == PlansCalendarMode.week,
                  periodTitle: _mode == PlansCalendarMode.week
                      ? _periodLabel
                      : null,
                  onPlanDay: (day) =>
                      setState(() => _selected = calendarDay(day)),
                  onPlanMonth: (day) => setState(() {
                    if (_mode == PlansCalendarMode.week) {
                      _selected = calendarDay(day);
                    } else {
                      final last = DateTime.utc(day.year, day.month + 1, 0).day;
                      _selected = DateTime.utc(
                        day.year,
                        day.month,
                        math.min(_selected.day, last),
                      );
                    }
                  }),
                  onPrevious: _moveAction(-1),
                  onNext: _moveAction(1),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
        if (_mode == PlansCalendarMode.month)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              DateFormat.yMMMMEEEEd(_locale).format(_selected),
              style: AppTypography.text1SemiBold.copyWith(
                color: AppColors.textInverse,
                height: 1.4,
              ),
            ),
          ),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              _mode == PlansCalendarMode.week
                  ? l.scenarioPlansEmptyWeek
                  : l.scenarioPlansEmptyDay,
              style: AppTypography.text1.copyWith(
                color: AppColorsDark.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        for (final day in shown) ...[
          if (_mode == PlansCalendarMode.week)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text(
                _capitalized(DateFormat.MMMMEEEEd(_locale).format(day)),
                style: AppTypography.text1SemiBold.copyWith(
                  color: AppColorsDark.linkGold,
                  height: 1.4,
                ),
              ),
            ),
          for (final plan in _on(day))
            ScenarioTile(
              key: ValueKey('saved-plan-${plan.id}'),
              title: plan.title,
              subtitle: _mode == PlansCalendarMode.month
                  ? l.scenarioPlansAllDay
                  : null,
              art: _mode == PlansCalendarMode.month
                  ? null
                  : LunarCardAsset.path(
                      LunarCardAsset.forTaskKey(plan.activity.keys.first)!,
                    ),
              onTap: () => widget.onOpenPlan(plan),
            ),
          if (_mode == PlansCalendarMode.week) const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: LotusButtons.text(
            style: textActionStyle,
            onPressed: widget.onChooseDate,
            child: Text(
              l.scenarioCalendarChooseDate,
              style: AppTypography.text1SemiBold.copyWith(
                color: AppColorsDark.linkGold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarSizeTransition extends StatelessWidget {
  const _CalendarSizeTransition({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
      alignment: Alignment.topCenter,
      child: child,
    );
  }
}
