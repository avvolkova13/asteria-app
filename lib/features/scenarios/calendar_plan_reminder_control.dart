import 'package:asteria_app/core/localization/locale_formatters.dart';
import 'package:asteria_app/core/services/calendar_plan_reminders.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/features/auth/presentation/widgets/date_picker_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'calendar_plan.dart';
import 'scenario_ui.dart';

/// An optional action *after* saving. Reading pending requests is silent;
/// only explicit confirmation of a time may ask iOS for permission.
class CalendarPlanReminderControl extends StatefulWidget {
  const CalendarPlanReminderControl({
    super.key,
    required this.plan,
    this.reminders = const CalendarPlanReminders(),
  });

  final CalendarPlan plan;
  final CalendarPlanReminders reminders;

  @override
  State<CalendarPlanReminderControl> createState() => _ReminderState();
}

class _ReminderState extends State<CalendarPlanReminderControl>
    with WidgetsBindingObserver {
  DateTime? _scheduled;
  PlanReminderResult? _error;
  bool _busy = false;
  int _revision = 0;

  DateTime _local(int hour, int minute) {
    final day = widget.plan.day;
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  bool get _available =>
      widget.reminders.supported && _local(23, 59).isAfter(DateTime.now());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_busy) _refresh();
  }

  Future<void> _refresh() async {
    final revision = ++_revision;
    DateTime? existing;
    if (_available) {
      try {
        existing = await widget.reminders.scheduledTime(
          owner: widget.plan.owner,
          planId: widget.plan.id,
        );
      } catch (_) {
        // Failure to read iOS must never block viewing a saved plan.
      }
    }
    if (!mounted || revision != _revision) return;
    setState(() {
      _scheduled = existing?.isAfter(DateTime.now()) == true ? existing : null;
    });
  }

  Future<void> _pick() async {
    if (_busy || !_available) return;
    ++_revision;
    setState(() {
      _busy = true;
      _error = null;
    });
    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    final morning = _local(9, 0);
    final existing = _scheduled;
    final initial = existing != null && existing.isAfter(now)
        ? existing
        : morning.isBefore(nextMinute)
        ? nextMinute
        : morning;
    DateTime? chosen;
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: ModalGlassTokens.barrier,
        builder: (c) => DateTimePickerBottomSheet(
          title: c.l10n.planReminderTime,
          initialDate: initial,
          minimumDate: DateUtils.isSameDay(now, initial) ? nextMinute : null,
          mode: CupertinoDatePickerMode.time,
          use24hFormat: LocaleFormatters.uses24HourFormat(c),
          onDateChanged: (d) => chosen = d,
        ),
      );
      if (!mounted || chosen == null) return;
      final at = _local(chosen!.hour, chosen!.minute);
      final result = await widget.reminders.schedule(
        owner: widget.plan.owner,
        planId: widget.plan.id,
        at: at,
        title: context.l10n.planReminderNotificationTitle,
        body: widget.plan.title,
      );
      if (!mounted) return;
      if (result == PlanReminderResult.scheduled) {
        _scheduled = at;
      } else {
        _error = result;
      }
    } catch (_) {
      if (mounted) _error = PlanReminderResult.unavailable;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    if (_busy) return;
    ++_revision;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ok = await widget.reminders.cancel(
        owner: widget.plan.owner,
        planId: widget.plan.id,
      );
      if (ok) {
        _scheduled = null;
      } else {
        _error = PlanReminderResult.unavailable;
      }
    } catch (_) {
      _error = PlanReminderResult.unavailable;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    if (!_available) return const SizedBox.shrink();
    final texts = c.l10n;
    final time = _scheduled;
    final error = switch (_error) {
      PlanReminderResult.denied => texts.planReminderDenied,
      PlanReminderResult.past => texts.planReminderPast,
      PlanReminderResult.unavailable => texts.planReminderUnavailable,
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeFocus(
          excluding: _busy,
          child: IgnorePointer(
            ignoring: _busy,
            child: ScenarioTile(
              art: 'assets/icons/clay/profile_notifications_icon.webp',
              title: time == null
                  ? texts.planReminderAdd
                  : texts.planReminderAt(
                      LocaleFormatters.timeOfDay(
                        c,
                        TimeOfDay.fromDateTime(time),
                      ),
                    ),
              subtitle: time == null ? null : texts.planReminderEdit,
              onTap: _pick,
            ),
          ),
        ),
        if (time != null)
          LotusButtons.text(
            onPressed: _busy ? null : _remove,
            style: TextButton.styleFrom(foregroundColor: AppColors.textInverse),
            child: Text(texts.planReminderRemove),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Semantics(
              liveRegion: true,
              child: Text(
                error,
                style: AppTypography.text2.copyWith(
                  color: AppColors.textInverse,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
