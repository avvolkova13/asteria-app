import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/features/scenarios/calendar_scenario.dart';
import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/analytics_route_observer.dart';
import 'package:asteria_app/core/analytics/dictionaries/entry_surface.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_state.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_section_heading.dart';
import 'package:asteria_app/features/home/presentation/widgets/advice_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/calendar_statuses_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/lunar_recommendations_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_calendar_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/phase_background_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/sphere_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/build_context_extensions.dart';

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
            return PrimaryScrollController(
              controller: _scrollController,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  const PinnedHeaderSliver(
                    child: ColoredBox(
                      color: MoonDesignTokens.pageBackground,
                      child: SafeArea(
                        bottom: false,
                        child: HomeAccountBar(
                          backgroundColor: MoonDesignTokens.pageBackground,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          top: -(MediaQuery.viewPaddingOf(context).top + 44),
                          child: ExcludeSemantics(
                            child: SvgPicture.asset(
                              'assets/background/lunar_calendar_${state.selectedDayStatus.name}.svg',
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: AsteriaEntrance.sections([
                              const SizedBox(height: 26),
                              HomeSectionHeading(
                                context.l10n.lunarCalendarTitle,
                              ),
                              const SizedBox(height: 16),
                              const CalendarPlanningEntry(),
                              const SizedBox(height: 16),
                              AsteriaEntrance(
                                replayKey: (
                                  state.selectedDate,
                                  state.selectedSphere,
                                  state.selectedPersonalizedDayData != null,
                                ),
                                child: _MoonScreenAdvice(
                                  state: state,
                                  recommendation: recommendation,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const SphereSelectionWidget(),
                              const SizedBox(height: 24),
                              const MoonCalendarWidget(),
                              const SizedBox(height: 16),
                              CalendarStatusesWidget(
                                visible: state.selectedSphere != null,
                              ),
                              if (recommendation != null) ...[
                                const SizedBox(height: 16),
                                AsteriaEntrance(
                                  replayKey: (
                                    state.selectedDate,
                                    state.selectedSphere,
                                  ),
                                  child: LunarRecommendationsWidget(
                                    key: ValueKey(state.selectedSphere),
                                    recommendation: recommendation,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

class _MoonScreenAdvice extends StatelessWidget {
  const _MoonScreenAdvice({required this.state, required this.recommendation});
  final SphereRecommendationModel? recommendation;

  final MoonScreenState state;

  @override
  Widget build(BuildContext context) {
    final personalizedDay = state.selectedPersonalizedDayData;
    if (personalizedDay == null) {
      return AdviceWidget(
        title: context.l10n.moonCalendarLoadingDayTitle,
        text: context.l10n.moonCalendarLoadingDayDescription,
        status: state.selectedDayStatus,
      );
    }

    return PhaseBackgroundWidget(
      background: personalizedDay.dailyBackground,
      recommendation: recommendation,
    );
  }
}
