import 'package:asteria_app/core/ui_kit/widgets/asteria_activity_indicator.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'scenario_completion.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/lunar_month_model.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:asteria_app/core/location/current_location_resolver.dart';
import 'package:asteria_app/core/location/widgets/current_location_controls.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_state.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:asteria_app/features/home/presentation/widgets/lunar_card_image.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/calendar_statuses_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/day_status_icon.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:asteria_app/features/home/presentation/models/lunar_almanac.dart';
import 'calendar_plan.dart';
import 'calendar_plans_view.dart';
import 'calendar_plan_reminder_control.dart';
import 'scenario_ui.dart';

String _dateLabel(BuildContext c, DateTime date) => DateFormat.yMMMMEEEEd(
  Localizations.localeOf(c).toLanguageTag(),
).format(date);

String _activityLabel(BuildContext c, CalendarActivity activity) =>
    switch (activity) {
      CalendarActivity.haircut => c.l10n.lunarHaircut,
      CalendarActivity.transplant => c.l10n.scenarioCalendarRepotPlants,
      CalendarActivity.coloring => c.l10n.lunarHairColoring,
      CalendarActivity.planting => c.l10n.lunarSowingPlanting,
      CalendarActivity.watering => c.l10n.lunarWateringFertilizing,
    };

String _statusLabel(BuildContext c, RecommendationStatus status) =>
    switch (status) {
      RecommendationStatus.favorable => c.l10n.dayFavorable,
      RecommendationStatus.unfavorable => c.l10n.dayUnfavorable,
      RecommendationStatus.neutral => c.l10n.dayNeutral,
    };

// Carry the originating tab route through the planner so finishing a plan
// can pop back to the same calendar instance, including its scroll position.
class _PlannerPage<T> extends MaterialPageRoute<T> {
  _PlannerPage(BuildContext context, Widget page, {bool fromTab = false})
    : tab = fromTab ? ModalRoute.of(context) : tabOf(context),
      super(builder: (_) => page);

  final ModalRoute<dynamic>? tab;

  static ModalRoute<dynamic>? tabOf(BuildContext context) {
    final route = ModalRoute.of(context);
    return route is _PlannerPage ? route.tab : null;
  }
}

Future<void> _open(BuildContext c, Widget page, {bool fromTab = false}) async {
  await Navigator.of(c).push(_PlannerPage<void>(c, page, fromTab: fromTab));
}

Future<void> openSavedCalendarPlanFromTab(
  BuildContext context,
  CalendarPlan plan,
) => _open(context, _PlanDetails(plan: plan), fromTab: true);

class CalendarScenarioScreen extends StatelessWidget {
  const CalendarScenarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget activityCard(CalendarActivity activity, {bool wide = false}) {
      final image = switch (activity) {
        CalendarActivity.haircut => 'beauty_haircut',
        CalendarActivity.coloring => 'beauty_hair_coloring',
        CalendarActivity.transplant => 'gardening_transplanting_pricking',
        CalendarActivity.planting => 'gardening_sowing_planting',
        CalendarActivity.watering => 'gardening_watering_fertilizing',
      };
      return ScenarioChoiceCard(
        title: _activityLabel(context, activity),
        art: 'assets/images/prediction_images/moon_card_$image.webp',
        tint: activity.sphere == 'beauty'
            ? const Color(0xFFE4AFCC)
            : const Color(0xFF95C2AA),
        wide: wide,
        onTap: () => _open(context, _DaySelection(activity: activity)),
      );
    }

    Widget heading(String title) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: AppTypography.h3.copyWith(color: AppColors.textInverse),
      ),
    );
    return ScenarioPage(
      title: context.l10n.scenarioCalendarChooseActivity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          ScenarioChoiceHero(
            description: context.l10n.scenarioCalendarActivityIntro,
            art: 'assets/images/scenarios/calendar.webp',
          ),
          heading(context.l10n.sphereBeauty),
          ScenarioChoiceGrid(
            children: [
              activityCard(CalendarActivity.haircut),
              activityCard(CalendarActivity.coloring),
            ],
          ),
          heading(context.l10n.sphereGarden),
          activityCard(CalendarActivity.transplant, wide: true),
          const SizedBox(height: 12),
          ScenarioChoiceGrid(
            children: [
              activityCard(CalendarActivity.planting),
              activityCard(CalendarActivity.watering),
            ],
          ),
          const SizedBox(height: 12),
          const CalendarPlansButton(),
        ]),
      ),
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.text, required this.onRetry});
  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext c) => Column(
    children: AsteriaEntrance.sections([
      Text(text),
      const SizedBox(height: 8),
      AuthGradientButton(text: c.l10n.retry, onPressed: onRetry),
    ]),
  );
}

class _DaySelection extends StatefulWidget {
  const _DaySelection({required this.activity});
  final CalendarActivity activity;
  @override
  State<_DaySelection> createState() => _DaySelectionState();
}

class _DaySelectionState extends State<_DaySelection> {
  final _months = <DateTime, LunarMonthModel>{};
  final _detailsKey = GlobalKey();
  final _calendarKey = GlobalKey();
  int _locationVersion = 0;
  final _selected = <DateTime>{};
  var _mode = PlansCalendarMode.month;
  late DateTime _focused;
  late DateTime _today;
  int _request = 0;
  bool _loading = false;
  bool _failed = false;
  bool _needsLocation = false;

  DateTime _monthOf(DateTime day) => DateTime.utc(day.year, day.month);

  @override
  void initState() {
    super.initState();
    _today = calendarDay(DateTime.now());
    _focused = _today;
    _showMonth(_today, resolveToday: true);
  }

  Future<void> _showMonth(
    DateTime date, {
    bool refresh = false,
    bool resolveToday = false,
  }) async {
    final focus = date.isBefore(_today) ? _today : date;
    final month = _monthOf(focus);
    final request = ++_request;
    final locationVersion = _locationVersion;
    setState(() {
      _focused = focus;
      _failed = false;
      _needsLocation = false;
      _loading = refresh || !_months.containsKey(month);
    });
    if (!_loading) return;
    try {
      final model = await di.get<ContentProvider>().loadPersonalizedLunarMonth(
        month,
        forceRefresh: refresh,
      );
      if (!mounted || locationVersion != _locationVersion) return;
      _months[month] = model;
      if (request != _request) return;
      if (resolveToday) {
        String? localDate;
        try {
          localDate = await const MethodChannel(
            'asteria/calendar',
          ).invokeMethod<String>('today', model.timezone);
        } on MissingPluginException {
          // The device calendar still supports planning without a timezone bridge.
        } on PlatformException {
          // Continue using the device date if the calendar timezone is unavailable.
        }
        if (!mounted || request != _request) return;
        final resolved = localDate == null
            ? null
            : DateTime.tryParse(localDate);
        if (resolved != null) {
          _today = calendarDay(resolved);
          _selected.removeWhere((day) => day.isBefore(_today));
          _focused = _today;
          if (_monthOf(_today) != month) {
            await _showMonth(_today);
            return;
          }
        }
      }
      setState(() {
        _loading = false;
      });
    } catch (error) {
      if (!mounted || request != _request) return;
      setState(() {
        _loading = false;
        _failed = true;
        _needsLocation = error is CurrentLocationRequiredException;
      });
    }
  }

  void _reveal(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = key.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(
        target,
        alignment: .08,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _toggle(DateTime day) {
    final normalized = calendarDay(day);
    if (_selected.contains(normalized)) {
      setState(() => _selected.remove(normalized));
    } else if (_selected.length < 2 && !normalized.isBefore(_today)) {
      setState(() => _selected.add(normalized));
      _reveal(_detailsKey);
    } else if (_selected.length == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.scenarioCalendarRemoveDate)),
      );
    }
  }

  LunarDayModel? _dayData(DateTime day) => _months[_monthOf(day)]?.days
      .where((item) => calendarDay(item.date) == day)
      .firstOrNull;

  DateTime get _weekStart =>
      _focused.subtract(Duration(days: _focused.weekday - DateTime.monday));

  VoidCallback? _movePeriod(int delta) {
    final week = _mode == PlansCalendarMode.week;
    final next = _focused.add(Duration(days: delta * (week ? 7 : 1)));
    if (next.isAfter(DateTime.utc(2050, 12, 31)) ||
        next
            .add(Duration(days: week ? 6 - (_focused.weekday - 1) : 0))
            .isBefore(_today)) {
      return null;
    }
    return () => _showMonth(next);
  }

  @override
  Widget build(BuildContext context) {
    final week = _mode == PlansCalendarMode.week;
    final dayView = _mode == PlansCalendarMode.day;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final exposedMonths = week
        ? {
            _monthOf(_weekStart),
            _monthOf(_weekStart.add(const Duration(days: 6))),
          }
        : {_monthOf(_focused)};
    final statuses = <DateTime, DayStatus>{};
    for (final month in exposedMonths) {
      for (final day in _months[month]?.days ?? const <LunarDayModel>[]) {
        final recommendation = widget.activity.recommendation(day);
        if (recommendation != null) {
          statuses[DateTime(day.date.year, day.date.month, day.date.day)] =
              DayStatus.fromRecommendation(recommendation.status);
        }
      }
    }
    return ScenarioPage(
      title: context.l10n.scenarioCalendarChooseDates,
      child: CalendarPlansBuilder(
        builder: (context, plans) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: AsteriaEntrance.sections([
            Text(
              _activityLabel(context, widget.activity),
              style: context.textTheme.playfairSemiBold20.copyWith(
                color: AppColors.textInverse,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedPicker<PlansCalendarMode>(
              options: PlansCalendarMode.values,
              selectedValue: _mode,
              onChanged: (mode) {
                setState(() => _mode = mode);
                if (mode == PlansCalendarMode.day && _selected.isNotEmpty) {
                  _showMonth(_selected.last);
                }
              },
              labelBuilder: (mode) => switch (mode) {
                PlansCalendarMode.month => context.l10n.scenarioPlansMonth,
                PlansCalendarMode.week => context.l10n.scenarioPlansWeek,
                PlansCalendarMode.day => context.l10n.scenarioPlansDay,
              },
            ),
            const SizedBox(height: 16),
            if (dayView)
              Row(
                children: [
                  LotusButtons.icon(
                    tooltip: context.l10n.scenarioPlansPrevious,
                    onPressed: _movePeriod(-1),
                    icon: const LotusArrowBubble(back: true),
                  ),
                  Expanded(
                    child: Text(
                      DateFormat.MMMMd(locale).format(_focused),
                      textAlign: TextAlign.center,
                      style: AppTypography.navTitle,
                    ),
                  ),
                  LotusButtons.icon(
                    tooltip: context.l10n.scenarioPlansNext,
                    onPressed: _movePeriod(1),
                    icon: const LotusArrowBubble(),
                  ),
                ],
              )
            else
              MoonCalendarWidget.planning(
                key: _calendarKey,
                savedPlans: plans,
                planningState: MoonScreenState(
                  focusedDay: _focused,
                  dayStatuses: statuses,
                ),
                planningSelection: _selected,
                firstSelectableDay: _today,
                onPlanDay: _toggle,
                onPlanMonth: _showMonth,
                week: week,
                periodTitle: week
                    ? '${DateFormat.MMMd(locale).format(_weekStart)} — ${DateFormat.MMMd(locale).format(_weekStart.add(const Duration(days: 6)))}'
                    : null,
                onPrevious: week ? _movePeriod(-1) : null,
                onNext: week ? _movePeriod(1) : null,
              ),
            const SizedBox(height: 8),
            if (_loading)
              const AsteriaLoadingLine()
            else if (_needsLocation) ...[
              Text(context.l10n.moonLocationSetupDescription),
              CurrentLocationControls(
                onLocationUpdated: () {
                  _locationVersion++;
                  _months.clear();
                  _showMonth(
                    _focused,
                    refresh: true,
                    resolveToday: _monthOf(_focused) == _monthOf(_today),
                  );
                },
              ),
            ] else if (_failed)
              _Retry(
                text: context.l10n.scenarioCalendarMonthError,
                onRetry: () => _showMonth(_focused, refresh: true),
              )
            else if (statuses.isNotEmpty && !dayView)
              const CalendarStatusesWidget()
            else if (statuses.isEmpty)
              Text(context.l10n.scenarioCalendarUnratedDates),
            const SizedBox(height: 16),
            if (dayView || _selected.isNotEmpty)
              _Comparison(
                key: _detailsKey,
                activity: widget.activity,
                plans: plans,
                days: {
                  for (final day in dayView ? [_focused] : _selected)
                    day: _dayData(day),
                },
                loading: _loading,
                replaceDay: dayView
                    ? null
                    : (date) {
                        setState(() => _selected.remove(date));
                        _showMonth(date, refresh: true);
                        _reveal(_calendarKey);
                      },
              ),
          ]),
        ),
      ),
    );
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({
    super.key,
    required this.loading,
    required this.activity,
    required this.days,
    required this.replaceDay,
    required this.plans,
  });
  final CalendarActivity activity;
  final Map<DateTime, LunarDayModel?> days;
  final bool loading;
  final ValueChanged<DateTime>? replaceDay;
  final List<CalendarPlan> plans;
  @override
  Widget build(BuildContext c) {
    final ratings = {
      for (final entry in days.entries)
        entry.key: activity.recommendation(entry.value),
    };
    final tied =
        ratings.length == 2 &&
        ratings.values.every(
          (rating) =>
              rating != null && rating.status == ratings.values.first?.status,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        if (days.length == 2) ...[
          Text(
            c.l10n.scenarioCalendarComparisonTitle,
            style: c.textTheme.playfairSemiBold20.copyWith(
              color: AppColors.textInverse,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (tied)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(c.l10n.scenarioCalendarEqualRating),
          ),
        for (final entry in days.entries)
          _DatePlanCard(
            plans: plans.where((plan) => plan.day == entry.key).toList(),
            activity: activity,
            date: entry.key,
            data: entry.value,
            recommendation: ratings[entry.key],
            loading: loading,
            replaceDay: replaceDay == null
                ? null
                : () => replaceDay!(entry.key),
          ),
      ]),
    );
  }
}

class _DatePlanCard extends StatelessWidget {
  const _DatePlanCard({
    required this.plans,
    required this.activity,
    required this.date,
    required this.data,
    required this.recommendation,
    required this.loading,
    required this.replaceDay,
  });

  final List<CalendarPlan> plans;
  final CalendarActivity activity;
  final DateTime date;
  final LunarDayModel? data;
  final TaskRecommendationModel? recommendation;
  final bool loading;
  final VoidCallback? replaceDay;

  @override
  Widget build(BuildContext c) {
    final alreadyPlanned = plans.any((plan) => plan.activity == activity);
    final phase =
        data?.lunarContext.moonPhaseName ??
        LunarAlmanacDay.on(date)?.phase.label(c);
    return AppCard(
      backgroundColor: MoonDesignTokens.calendarSurface,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plans.isEmpty) ...[
            Text(
              _dateLabel(c, date),
              style: c.textTheme.inversePlayfairSemiBold20,
            ),
            if (phase != null) ...[
              const SizedBox(height: 8),
              Text(phase, style: AppTypography.text1SemiBold),
            ],
            const SizedBox(height: 8),
          ],
          for (final plan in plans) ...[
            _SavedPlanContent(
              key: ValueKey(plan.id),
              plan: plan,
              phase: phase,
              recommendation: plan.activity == activity
                  ? recommendation ?? plan.recommendation
                  : plan.recommendation,
            ),
            const SizedBox(height: 12),
          ],
          if (!alreadyPlanned) ...[
            if (recommendation case final rating?)
              _Recommendation(rating)
            else if (loading)
              const AsteriaLoadingLine()
            else
              Text(c.l10n.scenarioCalendarRecommendationMissing),
            const SizedBox(height: 12),
            AuthGradientButton(
              text: plans.isEmpty
                  ? c.l10n.scenarioCalendarSelectDay
                  : c.l10n.scenarioCalendarSavePlan,
              onPressed: loading && data == null
                  ? null
                  : () => _open(
                      c,
                      _SavePlan(activity: activity, date: date, dayData: data),
                    ),
            ),
            if (!loading && recommendation == null && replaceDay != null)
              CustomButton(
                type: CustomButtonType.text,
                text: c.l10n.scenarioCalendarChangeDate,
                onPressed: replaceDay,
              ),
          ],
        ],
      ),
    );
  }
}

class _SavedPlanContent extends StatelessWidget {
  const _SavedPlanContent({
    super.key,
    required this.plan,
    this.recommendation,
    this.onDeleted,
    this.embedded = true,
    this.phase,
  });

  final CalendarPlan plan;
  final TaskRecommendationModel? recommendation;
  final VoidCallback? onDeleted;
  final bool embedded;
  final String? phase;

  @override
  Widget build(BuildContext c) {
    final locale = Localizations.localeOf(c).toLanguageTag();
    final dateFormat = plan.day.year == DateTime.now().year
        ? DateFormat.MMMMd(locale)
        : DateFormat.yMMMd(locale);
    final activity = _activityLabel(c, plan.activity);
    final whitespace = RegExp(r'[\s\u00a0\u202f]+');
    final hasCustomTitle =
        plan.title.replaceAll(whitespace, ' ').trim() !=
        activity.replaceAll(whitespace, ' ').trim();
    final metadataStyle = AppTypography.text2.copyWith(
      color: AppColors.cardTinted,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (embedded) ...[
          Text(plan.title, style: c.textTheme.inversePlayfairSemiBold20),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(dateFormat.format(plan.day), style: metadataStyle),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppColorsDark.linkGold,
                  ),
                  const SizedBox(width: 4),
                  Text(c.l10n.scenarioPlanPlanned, style: metadataStyle),
                ],
              ),
            ],
          ),
        ],
        if (hasCustomTitle) ...[
          if (embedded) const SizedBox(height: 6),
          Text(activity, style: metadataStyle),
        ],
        if (recommendation case final rec?) ...[
          const SizedBox(height: 8),
          _Recommendation(rec, collapsible: embedded, phase: phase),
        ],
        const SizedBox(height: 12),
        if (di.isRegistered<UserProvider>())
          ListenableBuilder(
            listenable: di.get<UserProvider>(),
            builder: (_, _) =>
                di.get<UserProvider>().currentUser?.id == plan.owner
                ? CalendarPlanReminderControl(
                    plan: plan,
                    onDeletePlan: () async {
                      if (di.get<UserProvider>().currentUser?.id !=
                          plan.owner) {
                        return false;
                      }
                      await CalendarPlans.delete(plan);
                      onDeleted?.call();
                      return true;
                    },
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}

class _Recommendation extends StatelessWidget {
  const _Recommendation(this.rec, {this.collapsible = false, this.phase});

  final TaskRecommendationModel rec;
  final bool collapsible;
  final String? phase;

  @override
  Widget build(BuildContext c) {
    final status = Row(
      children: [
        DayStatusIcon(
          status: DayStatus.fromRecommendation(rec.status),
          size: 24,
          excludeFromSemantics: true,
        ),
        const SizedBox(width: 6),
        Flexible(child: Text(_statusLabel(c, rec.status))),
      ],
    );
    if (collapsible) {
      return ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 2, bottom: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        minTileHeight: 44,
        shape: const Border(),
        collapsedShape: const Border(),
        textColor: AppColors.textInverse,
        collapsedTextColor: AppColors.textInverse,
        iconColor: AppColors.cardTinted,
        collapsedIconColor: AppColors.cardTinted,
        title: status,
        children: [
          if (phase case final label?) ...[
            Text(
              label,
              style: AppTypography.text2.copyWith(color: AppColors.cardTinted),
            ),
            const SizedBox(height: 6),
          ],
          Text(rec.description),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [status, const SizedBox(height: 8), Text(rec.description)],
    );
  }
}

class _SavePlan extends StatefulWidget {
  const _SavePlan({
    required this.activity,
    required this.date,
    required this.dayData,
  });
  final CalendarActivity activity;
  final DateTime date;
  final LunarDayModel? dayData;
  @override
  State<_SavePlan> createState() => _SavePlanState();
}

class _SavePlanState extends State<_SavePlan> {
  final _name = TextEditingController();
  final _id = const Uuid().v4();
  final _owner = di.get<UserProvider>().currentUser?.id;
  late CalendarActivity _activity = widget.activity;
  TaskRecommendationModel? get _recommendation =>
      _activity.recommendation(widget.dayData);
  bool _startedEditing = false;
  bool _saving = false;
  bool _error = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_startedEditing) {
      _name.text = _activityLabel(context, _activity);
      _startedEditing = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _chooseActivity(CalendarActivity activity) {
    if (_saving) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final previousLabel = _activityLabel(context, _activity);
    setState(() {
      _activity = activity;
      if (_name.text.trim().isEmpty || _name.text.trim() == previousLabel) {
        _name.text = _activityLabel(context, activity);
      }
      _error = false;
    });
  }

  Future<void> _save() async {
    if (_saving || _name.text.trim().isEmpty) return;
    final owner = _owner;
    if (owner == null || owner != di.get<UserProvider>().currentUser?.id) {
      setState(() => _error = true);
      return;
    }
    setState(() {
      _saving = true;
      _error = false;
    });
    final plan = CalendarPlan(
      id: _id,
      owner: owner,
      day: widget.date,
      activity: _activity,
      title: _name.text.trim(),
      recommendation: _recommendation,
    );
    try {
      final box = await CalendarPlans.open();
      if (!mounted) return;
      if (di.get<UserProvider>().currentUser?.id != owner) {
        setState(() {
          _saving = false;
          _error = true;
        });
        return;
      }
      final existing = CalendarPlans.read(box, owner)
          .where(
            (entry) => entry.day == plan.day && entry.activity == plan.activity,
          )
          .firstOrNull;
      final destination = existing ?? plan;
      if (existing == null) await CalendarPlans.save(plan);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        _PlannerPage<void>(
          context,
          _PlanDetails(plan: destination, saved: existing == null),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext c) => ScenarioPage(
    title: c.l10n.scenarioCalendarSavePlan,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        Text(_dateLabel(c, widget.date)),
        const SizedBox(height: 20),
        Text(
          c.l10n.scenarioCalendarChooseActivity,
          style: c.textTheme.playfairSemiBold20.copyWith(
            color: AppColors.textInverse,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final activity in CalendarActivity.values)
              ChoiceChip(
                key: ValueKey('plan-activity-${activity.name}'),
                selected: _activity == activity,
                onSelected: _saving ? null : (_) => _chooseActivity(activity),
                label: Text(_activityLabel(c, activity)),
                avatar: switch (LunarCardAsset.forTaskKey(
                  activity.keys.first,
                )) {
                  final assetName? => Image.asset(
                    LunarCardAsset.path(assetName),
                    width: 26,
                    height: 26,
                    excludeFromSemantics: true,
                  ),
                  null => null,
                },
                showCheckmark: false,
                color: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColorsDark.linkGold
                      : AppColorsDark.modal,
                ),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pressElevation: 0,
                labelStyle: AppTypography.text2.copyWith(
                  color: _activity == activity
                      ? AppColorsDark.homeCanvas
                      : AppColors.textInverse,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(
                  color: AppColorsDark.linkGold.withValues(
                    alpha: _activity == activity ? 1 : .2,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        TextInputFieldWidget(
          controller: _name,
          label: c.l10n.scenarioCalendarActivityName,
          hintText: _activityLabel(c, _activity),
          onClear: () => setState(() {}),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        AppCard(
          backgroundColor: MoonDesignTokens.calendarSurface,
          child: switch (_recommendation) {
            final recommendation? => _Recommendation(recommendation),
            null => Text(c.l10n.scenarioCalendarRecommendationMissing),
          },
        ),
        const SizedBox(height: 16),
        if (_error) Text(c.l10n.scenarioCalendarSaveError),
        AuthGradientButton(
          text: c.l10n.scenarioSave,
          isLoading: _saving,
          onPressed: _name.text.trim().isEmpty ? null : _save,
        ),
      ]),
    ),
  );
}

class _PlanDetails extends StatelessWidget {
  const _PlanDetails({required this.plan, this.saved = false});
  final CalendarPlan plan;
  final bool saved;
  @override
  Widget build(BuildContext c) => ScenarioPage(
    title: saved ? c.l10n.scenarioCalendarSaved : plan.title,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        if (saved)
          Text(plan.title, style: c.textTheme.inversePlayfairSemiBold20),
        Text(_dateLabel(c, plan.day)),
        const SizedBox(height: 16),
        _SavedPlanContent(
          plan: plan,
          recommendation: plan.recommendation,
          embedded: false,
          onDeleted: () => Navigator.of(c).pop(),
        ),
        if (saved && _PlannerPage.tabOf(c) == null) ...[
          const SizedBox(height: 20),
          ScenarioCompletion(
            message: Localizations.localeOf(c).languageCode == 'ru'
                ? 'Ваш план отмечен в лунном календаре. Его можно открыть во вкладке «Календарь» → «Мои планы». На главной вас ждут карта дня и аудиопрактика.'
                : 'Your plan is marked in the lunar calendar. Find it in Calendar → My plans. Home also has your daily card and an audio practice.',
          ),
        ] else
          AuthGradientButton(
            text: _PlannerPage.tabOf(c) == null
                ? c.l10n.scenarioGoHome
                : c.l10n.scenarioCalendarBackToCalendar,
            onPressed: () {
              final tab = _PlannerPage.tabOf(c);
              if (tab != null && tab.isActive) {
                Navigator.of(c).popUntil((route) => identical(route, tab));
              } else {
                scenarioHome(c);
              }
            },
          ),
      ]),
    ),
  );
}

class CalendarPlansButton extends StatelessWidget {
  const CalendarPlansButton({super.key, this.fromTab = false});
  final bool fromTab;
  @override
  Widget build(BuildContext c) => LotusButtons.text(
    onPressed: () => _open(c, const _PlansScreen(), fromTab: fromTab),
    style: TextButton.styleFrom(
      foregroundColor: AppColorsDark.linkGold,
      minimumSize: const Size(44, 44),
    ),
    child: Text(
      c.l10n.scenarioCalendarMyPlans,
      style: AppTypography.text1SemiBold.copyWith(
        color: AppColorsDark.linkGold,
      ),
    ),
  );
}

class _PlansScreen extends StatelessWidget {
  const _PlansScreen();
  @override
  Widget build(BuildContext c) => ScenarioPage(
    title: c.l10n.scenarioCalendarMyPlans,
    child: CalendarPlansBuilder(
      builder: (c, plans) => CalendarPlansView(
        plans: plans,
        onOpenPlan: (plan) => _open(c, _PlanDetails(plan: plan)),
        onChooseDate: () => _open(c, const CalendarScenarioScreen()),
      ),
    ),
  );
}

class CalendarPlanningEntry extends StatelessWidget {
  const CalendarPlanningEntry({super.key});
  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ScenarioTile(
        title: c.l10n.scenarioCalendarChooseDate,
        subtitle: c.l10n.scenarioCalendarSubtitle,
        onTap: () => _open(c, const CalendarScenarioScreen(), fromTab: true),
      ).withEntrance(),
      const SizedBox(height: 20),
      const CalendarPlansButton(fromTab: true).withEntrance(),
    ],
  );
}

class CalendarPlansBuilder extends StatelessWidget {
  const CalendarPlansBuilder({
    super.key,
    required this.builder,
    this.compact = false,
  });
  final Widget Function(BuildContext, List<CalendarPlan>) builder;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    if (!di.isRegistered<UserProvider>() ||
        !Hive.isBoxOpen(HiveBoxNames.appSettings)) {
      return builder(context, const []);
    }
    final user = di.get<UserProvider>();
    return ListenableBuilder(
      listenable: user,
      builder: (c, _) {
        final owner = user.currentUser?.id;
        if (owner == null || owner.isEmpty) return builder(c, const []);
        return _AccountPlans(
          key: ValueKey(owner),
          owner: owner,
          builder: builder,
          compact: compact,
        );
      },
    );
  }
}

class _AccountPlans extends StatefulWidget {
  const _AccountPlans({
    super.key,
    required this.owner,
    required this.builder,
    required this.compact,
  });
  final String owner;
  final Widget Function(BuildContext, List<CalendarPlan>) builder;
  final bool compact;
  @override
  State<_AccountPlans> createState() => _AccountPlansState();
}

class _AccountPlansState extends State<_AccountPlans> {
  late Future<Box<Map>> _openBox;
  @override
  void initState() {
    super.initState();
    _openBox = CalendarPlans.open();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Box<Map>>(
    future: _openBox,
    builder: (c, snapshot) {
      if (snapshot.hasError) {
        if (widget.compact) return widget.builder(c, const []);
        return _Retry(
          text: c.l10n.scenarioCalendarPlansError,
          onRetry: () => setState(() => _openBox = CalendarPlans.open()),
        );
      }
      final box = snapshot.data;
      if (box == null && !widget.compact) {
        return const Center(child: AsteriaActivityIndicator());
      }
      return StreamBuilder<BoxEvent>(
        stream: box?.watch(),
        builder: (c, _) => widget.builder(
          c,
          box == null ? const [] : CalendarPlans.read(box, widget.owner),
        ),
      );
    },
  );
}
