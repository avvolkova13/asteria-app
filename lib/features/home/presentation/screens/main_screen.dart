import 'package:asteria_app/features/scenarios/scenario_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_route_observer.dart';
import 'package:asteria_app/core/analytics/dictionaries/funnel_type.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/closed_content_modal.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_state.dart';
import 'package:asteria_app/features/home/presentation/widgets/widgets_index.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final ContentProvider _contentProvider;
  AnalyticsRouteObserver? _routeObserver;
  bool _analyticsScheduled = false;
  bool _hasTrackedTarotCardView = false;
  bool _hasTrackedAffirmationCardView = false;
  bool _hasTrackedRuneCardView = false;

  @override
  void initState() {
    super.initState();
    _contentProvider = di.get<ContentProvider>();
    _contentProvider.resetTarotAndRuneOpenState();
    context.read<HomeCubit>().resetTarotAndRuneOpenState();
    _contentProvider.addListener(_onContentProviderChanged);
    if (di.isRegistered<AnalyticsRouteObserver>()) {
      _routeObserver = di.get<AnalyticsRouteObserver>()
        ..addListener(_scheduleVisibleAnalytics);
    }
    context.read<HomeCubit>().loadDailySelection();
    _scheduleVisibleAnalytics();
  }

  bool get _isVisible =>
      mounted &&
      _routeObserver?.visibleScreen == '/home' &&
      ModalRoute.of(context)?.isCurrent == true;

  void _scheduleVisibleAnalytics() {
    if (!mounted || _analyticsScheduled) return;
    _analyticsScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analyticsScheduled = false;
      if (!_isVisible) return;
      _trackHomeCardImpressions();
      _trackAffirmationCardViewOnce();
    });
  }

  /// Fires one `ast_home_card_view` per funnel card present on the home
  /// scroll. Entry-point ids are stable strings — never derive from copy.
  void _trackHomeCardImpressions() {
    if (!_isVisible || _hasTrackedTarotCardView) return;
    _hasTrackedTarotCardView = true;
    final analytics = di.get<ProductAnalyticsService>();
    analytics.trackHomeCardView(
      funnelType: FunnelType.tarot,
      entryPointId: 'home_tarot_card',
      position: 1,
    );
  }

  void _trackAffirmationCardViewOnce() {
    if (!_isVisible || _hasTrackedAffirmationCardView) return;

    _hasTrackedAffirmationCardView = true;
    di.get<ProductAnalyticsService>().trackHomeCardView(
      funnelType: FunnelType.affirmations,
      entryPointId: 'home_affirmation_card',
      position: 0,
    );
  }

  void _trackRuneCardViewOnce() {
    if (!_isVisible || _hasTrackedRuneCardView) {
      return;
    }

    _hasTrackedRuneCardView = true;
    di.get<ProductAnalyticsService>().trackHomeCardView(
      funnelType: FunnelType.runes,
      entryPointId: 'home_rune_card',
      position: 2,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<HomeCubit>().syncTarotCard();
    context.read<HomeCubit>().syncRune();
  }

  @override
  void dispose() {
    _routeObserver?.removeListener(_scheduleVisibleAnalytics);
    _contentProvider.removeListener(_onContentProviderChanged);
    super.dispose();
  }

  void _onContentProviderChanged() {
    if (mounted) {
      _scheduleVisibleAnalytics();
      context.read<HomeCubit>().syncTarotCard();
      context.read<HomeCubit>().syncRune();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.dark,
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColorsDark.homeCanvas,
              image: DecorationImage(
                image: AssetImage('assets/images/home/home_sky.webp'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                scrollBehavior: ScrollConfiguration.of(
                  context,
                ).copyWith(overscroll: false),
                slivers: [
                  SliverLayoutBuilder(
                    builder: (context, constraints) => PinnedHeaderSliver(
                      child: ColoredBox(
                        color: AppColorsDark.homeCanvas.withValues(
                          alpha: (constraints.scrollOffset / 32).clamp(0, 1),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: HomeAccountBar(
                            backgroundColor: Colors.transparent,
                            accountLabelStyle: context
                                .textTheme
                                .inversePlayfairSemiBold17
                                .copyWith(fontFamily: 'Lora'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ListenableBuilder(
                      listenable: _contentProvider,
                      builder: (context, child) {
                        return Column(
                          children: [
                            const SizedBox(height: 26),
                            const MoonPhaseWidget(),
                            const SizedBox(height: 24),
                            AsteriaEntrance(child: _buildAffirmationCard()),
                            const SizedBox(height: 24),
                            _buildDailySymbolWidget(state),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: ScenarioTile(
                                key: const ValueKey('today-scenario-entry'),
                                title:
                                    Localizations.localeOf(
                                          context,
                                        ).languageCode ==
                                        'ru'
                                    ? 'Что вам сейчас нужно?'
                                    : 'What do you need right now?',
                                subtitle:
                                    Localizations.localeOf(
                                          context,
                                        ).languageCode ==
                                        'ru'
                                    ? 'Выбрать сценарий'
                                    : 'Choose a path',
                                art: 'assets/images/scenarios/compass.webp',
                                onTap: () => context.push('/first-session'),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
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

  Widget _buildAffirmationCard() {
    void track(String action) =>
        di.get<ProductAnalyticsService>().trackHomeCardClick(
          funnelType: FunnelType.affirmations,
          entryPointId: 'home_affirmation_card',
          position: 0,
          ctaName: action,
        );

    return AffirmationOfTheDayWidget(
      onPlay: () => track('play_affirmation'),
      onOpenCollection: () async {
        if (_contentProvider.affirmations.isEmpty) {
          await _contentProvider.loadContent();
          if (!mounted ||
              !(ModalRoute.isCurrentOf(context) ?? true) ||
              !TickerMode.valuesOf(context).enabled) {
            return;
          }
          if (_contentProvider.affirmations.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.affirmationLoadError)),
            );
            return;
          }
        }
        track('open_affirmation');
        if (mounted) AffirmationRoute.push(context);
      },
    );
  }

  Widget _buildDailySymbolWidget(HomeState state) {
    return ListenableBuilder(
      listenable: _contentProvider,
      builder: (context, _) {
        return Builder(
          builder: (context) {
            final userProvider = di.get<UserProvider>();
            final hasProSubscription =
                userProvider.currentUser != null &&
                di.get<MonetizationProvider>().effectivePro;

            void handleTarotRefresh() {
              if (hasProSubscription) {
                context.read<HomeCubit>().refreshTarotCard();
              } else {
                ClosedContentModal.show(
                  context,
                  description: context.l10n.tarotRefreshSubscriptionRequired,
                );
              }
            }

            void handleRuneRefresh() {
              if (hasProSubscription) {
                context.read<HomeCubit>().refreshRune();
              } else {
                ClosedContentModal.show(
                  context,
                  description: context.l10n.runeRefreshSubscriptionRequired,
                );
              }
            }

            if (state is HomeLoaded) {
              var tarotCard = state.tarotCard;
              var rune = state.runeOfDay;

              try {
                tarotCard = _contentProvider.getTodayTarotCard();
              } catch (e) {
                // Keep HomeState fallback when ContentProvider is still warming up.
              }

              try {
                rune = _contentProvider.getTodayRune();
              } catch (e) {
                // Keep HomeState fallback when ContentProvider is still warming up.
              }

              return DailySymbolOfTheDayWidget(
                tarotCard: tarotCard,
                rune: rune,
                isTarotLoading: false,
                isRuneLoading: false,
                isTarotOpened: _contentProvider.isDailySymbolTarotOpened(),
                isRuneOpened: _contentProvider.isDailySymbolRuneOpened(),
                onTarotRefresh: handleTarotRefresh,
                onRuneRefresh: handleRuneRefresh,
                onRuneTabSelected: _trackRuneCardViewOnce,
                onCardTap: tarotCard == null
                    ? null
                    : () {
                        _contentProvider.setDailySymbolTarotOpened();
                        di.get<ProductAnalyticsService>().trackHomeCardClick(
                          funnelType: FunnelType.tarot,
                          entryPointId: 'home_tarot_card',
                          position: 1,
                          ctaName: 'reveal_tarot_card',
                        );
                        context.read<HomeCubit>().onTarotCardTapped();
                      },
                onRuneTap: rune == null
                    ? null
                    : () {
                        _contentProvider.setDailySymbolRuneOpened();
                        di.get<ProductAnalyticsService>().trackHomeCardClick(
                          funnelType: FunnelType.runes,
                          entryPointId: 'home_rune_card',
                          position: 2,
                          ctaName: 'reveal_rune',
                        );
                        context.read<HomeCubit>().onRuneTapped();
                      },
              );
            }

            return DailySymbolOfTheDayWidget(
              tarotCard: null,
              rune: null,
              isTarotLoading: true,
              isRuneLoading: true,
              isTarotOpened: false,
              isRuneOpened: false,
              onTarotRefresh: handleTarotRefresh,
              onRuneRefresh: handleRuneRefresh,
              onRuneTabSelected: _trackRuneCardViewOnce,
            );
          },
        );
      },
    );
  }
}
