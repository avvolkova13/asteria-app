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
  final _revision = ValueNotifier(0);
  int _locationVersion = 0;
  final _selected = <DateTime>{};
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
    final month = _monthOf(date);
    final request = ++_request;
    final locationVersion = _locationVersion;
    setState(() {
      _focused = date.isBefore(_today) ? _today : date;
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
      _revision.value++;
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

  @override
  void dispose() {
    _revision.dispose();
    super.dispose();
  }

  void _toggle(DateTime day) {
    final normalized = calendarDay(day);
    if (_selected.contains(normalized)) {
      setState(() => _selected.remove(normalized));
    } else if (_selected.length < 2 && !normalized.isBefore(_today)) {
      setState(() => _selected.add(normalized));
    } else if (_selected.length == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.scenarioCalendarRemoveDate)),
      );
    }
  }

  LunarDayModel? _dayData(DateTime day) => _months[_monthOf(day)]?.days
      .where((item) => calendarDay(item.date) == day)
      .firstOrNull;

  @override
  Widget build(BuildContext context) {
    final month = _months[_monthOf(_focused)];
    final statuses = <DateTime, DayStatus>{};
    for (final day in month?.days ?? const <LunarDayModel>[]) {
      final recommendation = widget.activity.recommendation(day);
      if (recommendation != null) {
        statuses[DateTime(day.date.year, day.date.month, day.date.day)] =
            DayStatus.fromRecommendation(recommendation.status);
      }
    }
    return ScenarioPage(
      title: context.l10n.scenarioCalendarChooseDates,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          Text(
            _activityLabel(context, widget.activity),
            style: context.textTheme.playfairSemiBold20.copyWith(
              color: AppColors.textInverse,
            ),
          ),
          const SizedBox(height: 16),
          CalendarPlansBuilder(
            compact: true,
            builder: (context, plans) => MoonCalendarWidget.planning(
              savedPlans: plans,
              planningState: MoonScreenState(
                focusedDay: _focused,
                dayStatuses: statuses,
              ),
              planningSelection: _selected,
              firstSelectableDay: _today,
              onPlanDay: _toggle,
              onPlanMonth: _showMonth,
            ),
          ),
          const SizedBox(height: 8),
          if (_loading)
            const LinearProgressIndicator()
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
          else if (statuses.isNotEmpty)
            const CalendarStatusesWidget()
          else
            Text(context.l10n.scenarioCalendarUnratedDates),
          const SizedBox(height: 16),
          for (final day in _selected)
            AsteriaEntrance(
              key: ValueKey(day),
              child: Text(_dateLabel(context, day)),
            ),
          if (_selected.isNotEmpty) ...[
            const SizedBox(height: 12),
            AuthGradientButton(
              text: _selected.length == 2
                  ? context.l10n.scenarioCalendarCompareAction
                  : context.l10n.scenarioCalendarSingleDate,
              onPressed: () => _open(
                context,
                ListenableBuilder(
                  listenable: _revision,
                  builder: (_, _) => _Comparison(
                    activity: widget.activity,
                    days: {for (final day in _selected) day: _dayData(day)},
                    replaceDay: (date) {
                      setState(() => _selected.remove(date));
                      _showMonth(date, refresh: true);
                    },
                  ),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({
    required this.activity,
    required this.days,
    required this.replaceDay,
  });
  final CalendarActivity activity;
  final Map<DateTime, LunarDayModel?> days;
  final ValueChanged<DateTime> replaceDay;
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
    return ScenarioPage(
      title: days.length == 2
          ? c.l10n.scenarioCalendarComparisonTitle
          : _activityLabel(c, activity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          if (tied)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(c.l10n.scenarioCalendarEqualRating),
            ),
          for (final entry in days.entries)
            AppCard(
              backgroundColor: MoonDesignTokens.calendarSurface,
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dateLabel(c, entry.key),
                    style: c.textTheme.playfairSemiBold20.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if ((entry.value?.lunarContext.moonPhaseName ??
                          LunarAlmanacDay.on(entry.key)?.phase.label(c))
                      case final phaseName?) ...[
                    Text(phaseName, style: AppTypography.text1SemiBold),
                    const SizedBox(height: 8),
                  ],
                  if (ratings[entry.key] case final recommendation?)
                    _Recommendation(recommendation)
                  else
                    Text(c.l10n.scenarioCalendarRecommendationMissing),
                  const SizedBox(height: 12),
                  AuthGradientButton(
                    text: c.l10n.scenarioCalendarSelectDay,
                    onPressed: () => _open(
                      c,
                      _SavePlan(
                        activity: activity,
                        date: entry.key,
                        recommendation: ratings[entry.key],
                      ),
                    ),
                  ),
                  if (ratings[entry.key] == null)
                    CustomButton(
                      type: CustomButtonType.text,
                      text: c.l10n.scenarioCalendarChangeDate,
                      onPressed: () {
                        Navigator.pop(c);
                        replaceDay(entry.key);
                      },
                    ),
                ],
              ),
            ),
        ]),
      ),
    );
  }
}

class _Recommendation extends StatelessWidget {
  const _Recommendation(this.rec);
  final TaskRecommendationModel rec;
  @override
  Widget build(BuildContext c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          DayStatusIcon(
            status: DayStatus.fromRecommendation(rec.status),
            size: 24,
            excludeFromSemantics: true,
          ),
          const SizedBox(width: 6),
          Flexible(child: Text(_statusLabel(c, rec.status))),
        ],
      ),
      const SizedBox(height: 8),
      Text(rec.description),
    ],
  );
}

class _SavePlan extends StatefulWidget {
  const _SavePlan({
    required this.activity,
    required this.date,
    required this.recommendation,
  });
  final CalendarActivity activity;
  final DateTime date;
  final TaskRecommendationModel? recommendation;
  @override
  State<_SavePlan> createState() => _SavePlanState();
}

class _SavePlanState extends State<_SavePlan> {
  final _name = TextEditingController();
  final _id = const Uuid().v4();
  final _owner = di.get<UserProvider>().currentUser?.id;
  bool _startedEditing = false;
  bool _saving = false;
  bool _error = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_startedEditing) {
      _name.text = _activityLabel(context, widget.activity);
      _startedEditing = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
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
      activity: widget.activity,
      title: _name.text.trim(),
      recommendation: widget.recommendation,
    );
    try {
      await CalendarPlans.save(plan);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        _PlannerPage<void>(context, _PlanDetails(plan: plan, saved: true)),
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
        Text(_activityLabel(c, widget.activity)),
        const SizedBox(height: 16),
        TextInputFieldWidget(
          controller: _name,
          label: c.l10n.scenarioCalendarActivityName,
          onChanged: (_) => setState(() {}),
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
        if (saved) Text(plan.title, style: c.textTheme.inversePlayfairSemiBold20),
        Text(_dateLabel(c, plan.day)),
        if (plan.title.trim() != _activityLabel(c, plan.activity))
          Text(_activityLabel(c, plan.activity)),
        const SizedBox(height: 16),
        if (plan.recommendation case final rec?) _Recommendation(rec),
        const SizedBox(height: 16),
        if (di.isRegistered<UserProvider>())
          ListenableBuilder(
            listenable: di.get<UserProvider>(),
            builder: (_, _) => di.get<UserProvider>().currentUser?.id == plan.owner
                ? CalendarPlanReminderControl(plan: plan)
                : const SizedBox.shrink(),
          ),
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
  Widget build(BuildContext c) => CustomButton(
    type: CustomButtonType.text,
    textColor: AppColors.cardTinted,
    text: c.l10n.scenarioCalendarMyPlans,
    onPressed: () => _open(c, const _PlansScreen(), fromTab: fromTab),
  );
}

class _PlansScreen extends StatelessWidget {
  const _PlansScreen();
  @override
  Widget build(BuildContext c) => ScenarioPage(
    title: c.l10n.scenarioCalendarMyPlans,
    child: CalendarPlansBuilder(
      builder: (c, plans) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: AsteriaEntrance.sections([
          if (plans.isEmpty) ...[
            Text(c.l10n.scenarioCalendarEmptyPlans),
            const SizedBox(height: 12),
            AuthGradientButton(
              text: c.l10n.scenarioCalendarChooseDate,
              onPressed: () => _open(c, const CalendarScenarioScreen()),
            ),
          ],
          for (final plan in plans)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ScenarioTile(
                title: plan.title,
                subtitle: _dateLabel(c, plan.day),
                onTap: () => _open(c, _PlanDetails(plan: plan)),
              ),
            ),
        ]),
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
      AuthGradientButton(
        text: c.l10n.scenarioCalendarFindDate,
        onPressed: () =>
            _open(c, const CalendarScenarioScreen(), fromTab: true),
      ).withEntrance(),
      const CalendarPlansButton(fromTab: true).withEntrance(),
      CalendarPlansBuilder(
        compact: true,
        builder: (c, plans) {
          final next = plans
              .where((plan) => !plan.day.isBefore(calendarDay(DateTime.now())))
              .firstOrNull;
          return next == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ScenarioTile(
                    title: next.title,
                    subtitle: _dateLabel(c, next.day),
                    onTap: () =>
                        _open(c, _PlanDetails(plan: next), fromTab: true),
                  ),
                );
        },
      ),
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
        return const Center(child: CircularProgressIndicator());
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
