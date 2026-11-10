import 'package:asteria_app/features/scenarios/first_session.dart';
import 'package:go_router/go_router.dart';
import 'package:asteria_app/features/scenarios/calendar_scenario.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_route_observer.dart';
import 'package:asteria_app/core/analytics/dictionaries/funnel_type.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
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
  bool _hasTrackedSubscriptionPromoCardView = false;

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
      _trackSubscriptionPromoCardViewOnce();
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
    if (!_isVisible ||
        _hasTrackedAffirmationCardView ||
        _contentProvider.affirmations.isEmpty) {
      return;
    }

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

  void _trackSubscriptionPromoCardViewOnce() {
    if (!_isVisible ||
        _hasTrackedSubscriptionPromoCardView ||
        context.read<UserProvider>().currentUser == null ||
        (MonetizationProvider.maybeOf(context, listen: false)?.effectivePro ??
            false)) {
      return;
    }

    _hasTrackedSubscriptionPromoCardView = true;
    di.get<ProductAnalyticsService>().trackHomeCardView(
      funnelType: FunnelType.subscription,
      entryPointId: 'home_pro_promo_card',
      position: 3,
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
          child: ColoredBox(
            color: AppColorsDark.homeCanvas,
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
                  PinnedHeaderSliver(
                    child: HomeAccountBar(
                      accountLabelStyle: context
                          .textTheme
                          .inversePlayfairSemiBold17
                          .copyWith(fontFamily: 'Lora'),
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
                            const CalendarPlanHomeEntry(),
                            const SizedBox(height: 24),
                            TextButton.icon(
                              onPressed: () => context.push(FirstSession.path),
                              icon: const Icon(Icons.auto_awesome_outlined, size: 18, color: AppColors.cardTinted),
                              label: Text(context.l10n.scenarioStartTitle, style:context.textTheme.inversePlayfairSemiBold16),
                            ),
                            _buildSubscriptionPromoSection(),
                            _buildAffirmationCard(),
                            const SizedBox(height: 24),
                            _buildDailySymbolWidget(state),
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
    if (_contentProvider.affirmations.isEmpty) {
      return AffirmationUnavailableWidget(
        isLoading: _contentProvider.isLoadingContent,
        onRetry: _contentProvider.isLoadingContent
            ? null
            : () {
                _contentProvider.loadContent();
              },
      );
    }

    // Affirmation widget owns its own onTap (navigates to AffirmationRoute
    // internally). Wrap in a passive Listener so analytics doesn't hijack the
    // gesture from the child.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        di.get<ProductAnalyticsService>().trackHomeCardClick(
          funnelType: FunnelType.affirmations,
          entryPointId: 'home_affirmation_card',
          position: 0,
          ctaName: 'open_affirmation',
        );
      },
      child: AffirmationOfTheDayWidget(
        text: _contentProvider.getTodayAffirmation().text,
      ),
    );
  }

  Widget _buildSubscriptionPromoSection() {
    final userProvider = context.watch<UserProvider>();
    final monetizationProvider = MonetizationProvider.maybeOf(context);
    final user = userProvider.currentUser;
    if (user == null || (monetizationProvider?.effectivePro ?? false)) {
      return const SizedBox.shrink();
    }

    _scheduleVisibleAnalytics();

    return Column(
      children: [
        HomeProSubscriptionCard(
          compactHome: true,
          onPressed: () {
            di.get<ProductAnalyticsService>().trackHomeCardClick(
              funnelType: FunnelType.subscription,
              entryPointId: 'home_pro_promo_card',
              position: 3,
              ctaName: 'try_7_days_free',
            );
            SubscriptionRoute.push(
              context,
              params: SubscriptionRouteParams(
                originSurface: 'home_pro_promo_card',
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
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
