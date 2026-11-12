import 'package:asteria_app/app/data/models/moon_phase/moon_phase_day_image.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/home/presentation/models/lunar_almanac.dart';
import 'package:intl/intl.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/features/scenarios/calendar_scenario.dart';
import 'package:asteria_app/features/scenarios/scenario_ui.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/analytics_route_observer.dart';
import 'package:asteria_app/core/analytics/dictionaries/entry_surface.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_state.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_section_heading.dart';
import 'package:asteria_app/features/home/presentation/widgets/calendar_statuses_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/lunar_recommendations_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_calendar_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/sphere_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asteria_app/core/di/di.dart';

class MoonScreen extends StatefulWidget {
  const MoonScreen({super.key});

  @override
  State<MoonScreen> createState() => _MoonScreenState();
}

class _MoonScreenState extends State<MoonScreen> {
  late final ScrollController _scrollController;
  String? _lastTrackedDayKey;
  String? _lastTrackedMonthLoadKey;
  MoonScreenState? _latestState;
  AnalyticsRouteObserver? _routeObserver;

  static const _featureParam = {EventParams.featureName: 'moon_calendar'};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    if (di.isRegistered<AnalyticsRouteObserver>()) {
      _routeObserver = di.get<AnalyticsRouteObserver>()
        ..addListener(_scheduleVisibleAnalytics);
    }
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.moonCalendarView,
      params: _featureParam,
    );
    final productAnalytics = di.get<ProductAnalyticsService>();
    productAnalytics.trackMoonStart(entrySurface: EntrySurface.home);
    // The moon screen itself shows the daily lunar calendar; report the
    // implicit "day" tab so funnel analysis aligns with the
    // day/week/month/year taxonomy.
    productAnalytics.trackMoonTabView(contentType: 'day');
  }

  void _maybeTrackSelectedDay(MoonScreenState state) {
    final personalizedDay = state.selectedPersonalizedDayData;
    final sphere = state.selectedSphere;
    if (personalizedDay == null) return;

    final sphereCode = sphere == null ? null : _sphereApiCode(sphere);
    final recommendation = sphereCode == null
        ? null
        : personalizedDay.spheres[sphereCode];
    final date = personalizedDay.date.toIso8601String().substring(0, 10);
    final dayKey =
        '$date:${sphereCode ?? 'phase'}:${personalizedDay.dailyBackground.tone.name}:${recommendation?.status.name ?? 'none'}';
    if (_lastTrackedDayKey == dayKey) return;
    _lastTrackedDayKey = dayKey;
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.moonDayView,
      params: {
        ..._featureParam,
        'day_date': date,
        EventParams.statusContext: sphere == null
            ? 'phase_background'
            : 'sphere',
        EventParams.phaseTone: personalizedDay.dailyBackground.tone.name,
        if (sphere != null) 'sphere': sphere.name,
        if (recommendation != null)
          EventParams.sphereStatus: recommendation.status.name,
      },
    );
  }

  void _maybeTrackMonthLoad(MoonScreenState state) {
    final activeMonth = di.get<ContentProvider>().activeLunarMonth;
    if (activeMonth == null) return;
    final monthKey =
        '${state.focusedDay.year}-${state.focusedDay.month}:${activeMonth.timezone}';
    if (_lastTrackedMonthLoadKey == monthKey) return;
    _lastTrackedMonthLoadKey = monthKey;

    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.moonCalendarMonthLoad,
      params: {
        ..._featureParam,
        EventParams.calculationMode: 'personalized',
        EventParams.resultStatus: 'personalized_remote',
        EventParams.generationSeconds: 0,
        EventParams.rulesVersion: 'current',
        EventParams.schemaVersion: 0,
      },
    );
  }

  void _handleStateAnalytics(MoonScreenState state) {
    _latestState = state;
    _scheduleVisibleAnalytics();
  }

  void _scheduleVisibleAnalytics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = _latestState;
      if (!mounted ||
          state == null ||
          _routeObserver?.visibleScreen != '/home/moon' ||
          ModalRoute.of(context)?.isCurrent != true) {
        return;
      }
      _maybeTrackMonthLoad(state);
      _maybeTrackSelectedDay(state);
    });
  }

  @override
  void dispose() {
    _routeObserver?.removeListener(_scheduleVisibleAnalytics);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.get<MoonScreenCubit>()..loadData(),
      child: Scaffold(
        backgroundColor: MoonDesignTokens.pageBackground,
        body: BlocConsumer<MoonScreenCubit, MoonScreenState>(
          listener: (context, state) => _handleStateAnalytics(state),
          builder: (context, state) {
            _handleStateAnalytics(state);
            final recommendation = _selectedRecommendation(state);
            return Stack(
              fit: StackFit.expand,
              children: [
                _MoonSky(status: state.selectedDayStatus),
                Column(
                  children: [
                    const SafeArea(
                      bottom: false,
                      child: HomeAccountBar(
                        backgroundColor: Colors.transparent,
                      ),
                    ).withEntrance(),
                    Expanded(
                      child: PrimaryScrollController(
                        controller: _scrollController,
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 26),
                                    HomeSectionHeading(
                                      context.l10n.lunarCalendarTitle,
                                    ).withEntrance(),
                                    const SizedBox(height: 16),
                                    AsteriaEntrance(
                                      replayKey: (
                                        state.selectedDate,
                                        state.selectedSphere,
                                        state.selectedPersonalizedDayData !=
                                            null,
                                      ),
                                      child: _MoonScreenAdvice(state: state),
                                    ),
                                    const SizedBox(height: 24),
                                    _CalendarWithPlans(state: state),
                                    const SizedBox(height: 24),
                                    const SphereSelectionWidget(),
                                    const SizedBox(height: 16),
                                    if (recommendation != null) ...[
                                      const SizedBox(height: 16),
                                      LunarRecommendationsWidget(
                                        key: ValueKey(state.selectedSphere),
                                        recommendation: recommendation,
                                      ),
                                    ],
                                    const SizedBox(height: 32),
                                    const CalendarPlanningEntry(),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  SphereRecommendationModel? _selectedRecommendation(MoonScreenState state) {
    final selectedSphere = state.selectedSphere;
    final personalizedDay = state.selectedPersonalizedDayData;
    if (selectedSphere == null || personalizedDay == null) return null;
    return personalizedDay.spheres[_sphereApiCode(selectedSphere)];
  }

  String _sphereApiCode(Sphere sphere) {
    return switch (sphere) {
      Sphere.beauty => 'beauty',
      Sphere.garden => 'gardening',
      Sphere.health => 'health',
      Sphere.workAndRest => 'work_and_rest',
      Sphere.relationships => 'relationships',
    };
  }
}

class _CalendarWithPlans extends StatelessWidget {
  const _CalendarWithPlans({required this.state});

  final MoonScreenState state;

  @override
  Widget build(BuildContext context) => CalendarPlansBuilder(
    compact: true,
    builder: (context, plans) {
      final day = state.selectedDate;
      final inMonth =
          day != null &&
          day.year == state.focusedDay.year &&
          day.month == state.focusedDay.month;
      final selectedPlans = plans.where(
        (plan) => inMonth && DateUtils.isSameDay(plan.day, day),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MoonCalendarWidget(savedPlans: plans).withEntrance(),
          const SizedBox(height: 12),
          CalendarStatusesWidget(
            visible: state.selectedSphere != null,
          ).withEntrance(),
          for (final plan in selectedPlans)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ScenarioTile(
                key: ValueKey('calendar-selected-plan-${plan.id}'),
                title: plan.title,
                subtitle: DateFormat.MMMMEEEEd(
                  Localizations.localeOf(context).toLanguageTag(),
                ).format(plan.day),
                onTap: () => openSavedCalendarPlanFromTab(context, plan),
              ),
            ),
        ],
      );
    },
  );
}

class _MoonScreenAdvice extends StatelessWidget {
  const _MoonScreenAdvice({required this.state});

  final MoonScreenState state;

  @override
  Widget build(BuildContext context) {
    final personalizedDay = state.selectedPersonalizedDayData;
    final day = state.selectedDate ?? state.focusedDay;
    final date = DateFormat.MMMMEEEEd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(day);
    final lunar = personalizedDay?.lunarContext;
    final almanac = LunarAlmanacDay.on(day);
    final phaseName = lunar?.moonPhaseName ?? almanac?.phase.label(context);
    final summary =
        personalizedDay?.dailyBackground.summary ??
        almanac?.describeNextEvent(context) ??
        context.l10n.moonDayDetailsUnavailable;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: AppTypography.text1.copyWith(
            color: AppColors.textInverse.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        HomeGlassSurface(
          key: const ValueKey('calendar-day-context'),
          tint: MoonDesignTokens.calendarSurface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (lunar != null) ...[
                      Image.asset(
                        MoonPhaseDayImage.resolve(lunar.moonAgeDayIndex),
                        width: 56,
                        height: 56,
                        fit: BoxFit.contain,
                        excludeFromSemantics: true,
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phaseName ?? context.l10n.moonPhaseTitle,
                            style: context.textTheme.playfairMedium20.copyWith(
                              color: AppColors.textInverse,
                              height: 1.15,
                            ),
                          ),
                          if (lunar != null) ...[
                            const SizedBox(height: 5),
                            Text(
                              context.l10n.moonDayNumber(lunar.lunarDayNumber),
                              style: AppTypography.text2.copyWith(
                                color: AppColors.textInverse.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  summary,
                  style: AppTypography.text1.copyWith(
                    color: AppColors.textInverse,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state.error != null && !state.isLoading)
          LotusButtons.text(
            onPressed: () => context.read<MoonScreenCubit>().loadMonth(
              state.focusedDay,
              forceRefresh: true,
            ),
            child: Text(context.l10n.retry),
          ),
      ],
    );
  }
}

/// The same sky sits behind the status bar, account controls and calendar.
class _MoonSky extends StatelessWidget {
  const _MoonSky({required this.status});
  final DayStatus status;

  @override
  Widget build(BuildContext context) {
    final tone = switch (status) {
      DayStatus.favorable => const Color(0xFF72B7A0),
      DayStatus.neutral => const Color(0xFFF1B452),
      DayStatus.unfavorable => const Color(0xFFE36A6A),
    };
    final base = MoonDesignTokens.pageBackground;
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(.12, -1.02),
          radius: 1.55,
          colors: [
            Color.alphaBlend(tone.withValues(alpha: .27), base),
            Color.alphaBlend(tone.withValues(alpha: .12), base),
            base,
          ],
          stops: const [0, .55, 1],
        ),
      ),
    );
  }
}
