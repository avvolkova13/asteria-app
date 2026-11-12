import 'package:asteria_app/features/taro_cards/widgets/tarot_sphere_chip.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/love_deck/love_deck_access.dart';
import 'package:asteria_app/app/data/models/user/tarot_deck_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/entry_surface.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/feature_names.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/const/purchase_products_const.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/closed_content_modal.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_request_helper.dart';
import 'package:asteria_app/features/home/presentation/widgets/tarot_card_of_the_day_widget.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/taro_cards/widgets/all_cards_tab.dart';
import 'package:asteria_app/features/taro_cards/widgets/how_to_use_taro_cards.dart';
import 'package:asteria_app/features/taro_cards/widgets/special_decks.dart';
import 'package:asteria_app/features/taro_cards/widgets/tarot_layout.dart';
import 'package:flutter/material.dart';

enum TaroCardsTab {
  day,
  layout,
  allCards;

  String title(BuildContext context) => switch (this) {
    TaroCardsTab.day => context.l10n.tarotTabDay,
    TaroCardsTab.layout => context.l10n.tarotTabSpread,
    TaroCardsTab.allCards => context.l10n.tarotTabAllCards,
  };
}

class _TaroCardsColors {
  static const background = Color(0xFF0F0A1A);
  static const descriptionText = Color(0xFFEEEAFD);
  static const gold = Color(0xFFF3B76A);
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );
}

class TaroCardsScreen extends StatelessWidget {
  const TaroCardsScreen({super.key, this.initialTab = TaroCardsTab.day});

  final TaroCardsTab initialTab;

  @override
  Widget build(BuildContext context) {
    final contentProvider = di.get<ContentProvider>();
    final userProvider = di.get<UserProvider>();

    return Scaffold(
      backgroundColor: _TaroCardsColors.background,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: TopNavBarDelegate(
              canPop: true,
              userName: context.l10n.tarotCardsTitle,
              type: TopNavBarType.moon,
              birthDate:
                  userProvider.currentUser?.personalInfo?.birthDate?.birthDate,
            ),
          ),
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 358),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      ListenableBuilder(
                        listenable: contentProvider,
                        builder: (context, _) {
                          try {
                            final tarotCard = contentProvider
                                .getTodayTarotCard();
                            return _TaroCardsContent(
                              tarotCard: tarotCard,
                              initialTab: initialTab,
                            );
                          } catch (e) {
                            return ErrorScreenWidget(
                              error: context.l10n.tarotLoadError,
                              onRetry: () => contentProvider.loadContent(),
                            );
                          }
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.paddingOf(context).bottom + 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaroCardsContent extends StatefulWidget {
  final dynamic tarotCard;
  final TaroCardsTab initialTab;

  const _TaroCardsContent({required this.tarotCard, required this.initialTab});

  @override
  _TaroCardsContentState createState() => _TaroCardsContentState();
}

class _TaroCardsContentState extends State<_TaroCardsContent> {
  late int _selectedTabIndex;
  bool _isRefreshingDeck = false;
  final ContentProvider _contentProvider = di.get<ContentProvider>();

  static const _featureParam = {EventParams.featureName: 'tarot'};

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTab.index;
    _contentProvider.resetTarotOpenState();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.tarotDeckOpen,
      params: _featureParam,
    );
    di.get<ProductAnalyticsService>().trackTarotStart(
      entrySurface: EntrySurface.home,
    );
  }

  Widget _buildTabContent(
    Widget childDay,
    Widget childLayout,
    Widget childAll,
  ) {
    switch (_selectedTabIndex) {
      case 0: // Карта дня
        return childDay;
      case 1: // Расклад
        return childLayout;
      case 2: // Все карты
        return childAll;
      default:
        return const SizedBox.shrink();
    }
  }

  void _showHowToUseCardsModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const HowToUseTaroCards();
      },
    );
  }

  bool _hasDeck(UserProvider userProvider, DeckType deckType) {
    return switch (deckType) {
      DeckType.love =>
        userProvider.currentUser?.loveDeck?.loveDeckCards.isNotEmpty ?? false,
      DeckType.kelt =>
        userProvider.currentUser?.keltDeck?.keltDeckCards.isNotEmpty ?? false,
    };
  }

  Future<bool> _loadExistingDeck(
    UserProvider userProvider,
    DeckType deckType,
  ) async {
    di.get<GlobalLoaderService>().show();
    try {
      return await userProvider.loadLatestDeck(deckType);
    } finally {
      di.get<GlobalLoaderService>().hide();
    }
  }

  Future<void> _onBuyLoveDeckPressed() =>
      openLoveDeck(context, onOpen: () => LoveDeckRoute.push(context));

  Future<void> _onBuyKeltDeckPressed() async {
    final userProvider = di.get<UserProvider>();
    final navigatorContext = context;
    final facade = di.get<AnalyticsFacade>();
    final keltFeatureParam = {
      EventParams.featureName: FeatureName.keltDeck.eventValue,
    };
    if (!_hasDeck(userProvider, DeckType.kelt)) {
      final loaded = await _loadExistingDeck(userProvider, DeckType.kelt);
      if (!mounted) return;
      if (loaded) {
        facade.trackEvent(
          AnalyticsEvents.keltDeckOpen,
          params: keltFeatureParam,
        );
        KeltDeckRoute.push(context);
        return;
      }
      facade.trackEvent(
        AnalyticsEvents.paywallView,
        params: {
          ...keltFeatureParam,
          EventParams.paywallVariant: 'one_time_purchase',
          EventParams.price: PurchaseProductsConst.keltDeck.price,
          EventParams.currency: 'coins',
        },
      );
      showFeaturePurchaseModal(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (modalContext) => SharedPurchaseModal(
          featureKey: 'tarot_spread',
          loaderType: GlobalLoaderType.insight,
          purchaseTitle: context.l10n.keltDeckTitle,
          price: PurchaseProductsConst.keltDeck.price,
          originSurface: 'tarot',
          offerType: OfferType.oneOffUnlock,
          onAccessPurchase: (requirePro, idempotencyKey) async {
            facade.trackEvent(
              AnalyticsEvents.paywallCtaClick,
              params: keltFeatureParam,
            );
            try {
              await facade.runFeatureAction(
                'kelt_deck',
                () => userProvider.buyKeltDeck(
                  idempotencyKey: idempotencyKey,
                  requirePro: requirePro,
                ),
              );
              if (!di.get<MonetizationProvider>().effectivePro) {
                facade.trackPurchaseSuccess(
                  feature: FeatureName.keltDeck,
                  productId: 'kelt_deck',
                  price: PurchaseProductsConst.keltDeck.price,
                  currency: 'coins',
                  purchaseType: 'one_time',
                );
              }
            } catch (e) {
              if (!di.get<MonetizationProvider>().effectivePro) {
                facade.trackPurchaseFailed(
                  feature: FeatureName.keltDeck,
                  productId: 'kelt_deck',
                  failureStage: 'buy_kelt_deck',
                  failureReason: e.toString(),
                );
              }
              rethrow;
            }
          },
          onSuccess: () {
            if (navigatorContext.mounted) {
              KeltDeckRoute.push(navigatorContext);
            }
          },
        ),
      );
    } else {
      facade.trackEvent(AnalyticsEvents.keltDeckOpen, params: keltFeatureParam);
      KeltDeckRoute.push(context);
    }
  }

  Future<void> _onGetInsightPressed() async {
    final userProvider = di.get<UserProvider>();
    final hasProSubscription =
        userProvider.currentUser != null &&
        di.get<MonetizationProvider>().effectivePro;
    final facade = di.get<AnalyticsFacade>();
    final productAnalytics = di.get<ProductAnalyticsService>();

    facade.trackEvent(
      AnalyticsEvents.tarotSpreadCompleted,
      params: _featureParam,
    );
    productAnalytics.trackTarotCardReveal();

    if (!hasProSubscription) {
      facade.trackEvent(
        AnalyticsEvents.lockedContentView,
        params: {..._featureParam, EventParams.offerType: 'tarot_insight'},
      );
      facade.trackEvent(
        AnalyticsEvents.paywallView,
        params: {
          ..._featureParam,
          EventParams.paywallVariant: 'tarot_insight_lock',
        },
      );
      productAnalytics.trackTarotLockedView(
        originSurface: 'tarot_spread',
        offerType: OfferType.subscription,
      );
      productAnalytics.trackTarotPaywallView(
        originSurface: 'tarot_spread',
        offerType: OfferType.subscription,
        paywallVariant: 'tarot_insight_lock',
      );
      ClosedContentModal.show(
        context,
        description: context.l10n.tarotInsightSubscriptionRequired,
      );
      return;
    }

    try {
      di.get<GlobalLoaderService>().showWithSpheres(GlobalLoaderType.insight);
      await facade.runFeatureAction(
        'tarot',
        _contentProvider.getTarotDeckLayoutInsight,
      );
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(content: Text(context.l10n.insightLoadError)),
            );
          }
        });
      }
    } finally {
      di.get<GlobalLoaderService>().hide();
    }
  }

  Future<void> _onRefreshTarotDeckLayout() async {
    setState(() => _isRefreshingDeck = true);
    try {
      final success = await di.get<AnalyticsFacade>().runFeatureAction(
        'tarot',
        _contentProvider.refreshTarotDeckLayout,
      );
      if (!success && mounted) {
        ClosedContentModal.show(
          context,
          title: context.l10n.dailyLimitTitle,
          description: context.l10n.tarotSpreadDailyLimit,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshingDeck = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SegmentedPicker.indexed(
          surfaceBrightness: Brightness.dark,
          titles: [
            TaroCardsTab.day.title(context),
            TaroCardsTab.layout.title(context),
            TaroCardsTab.allCards.title(context),
          ],
          selectedIndex: _selectedTabIndex,
          onTabSelected: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ).withEntrance(),
        const SizedBox(height: 24),
        _buildTabContent(
          // Карта дня
          Builder(
            builder: (context) {
              final userProvider = di.get<UserProvider>();
              final hasProSubscription =
                  userProvider.currentUser != null &&
                  di.get<MonetizationProvider>().effectivePro;

              void handleRefresh() {
                if (hasProSubscription) {
                  _contentProvider.refreshTarotCard();
                } else {
                  ClosedContentModal.show(
                    context,
                    description: context.l10n.tarotRefreshSubscriptionRequired,
                  );
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListenableBuilder(
                    listenable: _contentProvider,
                    builder: (context, _) {
                      try {
                        final tarotCard = _contentProvider.getTodayTarotCard();
                        return TarotCardOfTheDayWidget(
                          tarotCard: tarotCard,
                          isLoading: false,
                          isOpened: _contentProvider.isTodayTarotCardOpened(),
                          showMoreButton: false,
                          isDarkLayout: true,
                          margin: EdgeInsets.zero,
                          onRefresh: handleRefresh,
                          onCardTap: () =>
                              _contentProvider.setTodayTarotCardOpened(),
                        );
                      } catch (e) {
                        return TarotCardOfTheDayWidget(
                          tarotCard: widget.tarotCard,
                          isLoading: false,
                          isOpened: _contentProvider.isTodayTarotCardOpened(),
                          showMoreButton: false,
                          isDarkLayout: true,
                          margin: EdgeInsets.zero,
                          onRefresh: handleRefresh,
                          onCardTap: () =>
                              _contentProvider.setTodayTarotCardOpened(),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SpecialDecks(
                    onBuyLoveDeckPressed: _onBuyLoveDeckPressed,
                    onBuyKeltDeckPressed: _onBuyKeltDeckPressed,
                  ).withEntrance(),
                ],
              );
            },
          ),
          // Расклад
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AsteriaEntrance.sections([
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: LotusArrowBubble.hitExtent,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.tarotSpreadTitle,
                        style: context.textTheme.playfairSemiBold32.copyWith(
                          color: AppColors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      button: true,
                      enabled: !_isRefreshingDeck,
                      label: context.l10n.refreshTarotSpreadLabel,
                      onTap: _isRefreshingDeck
                          ? null
                          : _onRefreshTarotDeckLayout,
                      child: ExcludeSemantics(
                        child: LotusTap(
                          behavior: HitTestBehavior.opaque,
                          onTap: _isRefreshingDeck
                              ? null
                              : _onRefreshTarotDeckLayout,
                          child: Opacity(
                            opacity: _isRefreshingDeck ? 0.5 : 1,
                            child: SizedBox(
                              width: LotusArrowBubble.hitExtent,
                              height: LotusArrowBubble.hitExtent,
                              child: Center(
                                child: LotusRefreshBubble(
                                  tint: _TaroCardsColors.gold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.tarotSpreadDescription,
                style: context.textTheme.urbanistRegular16.copyWith(
                  color: _TaroCardsColors.descriptionText,
                  height: 1.2,
                  letterSpacing: -0.408,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
              if (_isRefreshingDeck)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else
                ListenableBuilder(
                  listenable: di.get<UserProvider>(),
                  builder: (context, child) {
                    final tarotDeck = di
                        .get<UserProvider>()
                        .currentUser
                        ?.tarotDeck;
                    final allCardsOpened =
                        tarotDeck != null &&
                        tarotDeck.cards.length >= 3 &&
                        tarotDeck.cards.every((c) => c.id.isNotEmpty) &&
                        _contentProvider.areAllTarotDeckCardsOpened();
                    final interpretation = tarotDeck?.interpretation;
                    final hasLocalizedInterpretation =
                        interpretation != null &&
                        isAiContentLocalized(
                          interpretation.toJson(),
                          Localizations.localeOf(context).languageCode,
                        );
                    final hasOpenedInsight =
                        allCardsOpened && hasLocalizedInterpretation;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: AsteriaEntrance.sections([
                        if (!hasOpenedInsight) ...[
                          Center(
                            child: _GradientUnderlineButton(
                              text: context.l10n.deckHowToUse,
                              onPressed: _showHowToUseCardsModal,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const AsteriaEntrance(child: TarotLayout()),
                        if (!hasOpenedInsight) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              context.l10n.tarotTapToFlip,
                              style: context.textTheme.urbanistRegular16
                                  .copyWith(
                                    color: _TaroCardsColors.descriptionText,
                                    height: 1.2,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        if (allCardsOpened) ...[
                          SizedBox(height: hasOpenedInsight ? 10 : 16),
                          if (hasLocalizedInterpretation)
                            _TarotInsightBlock(
                              interpretation: interpretation,
                            ).withEntrance()
                          else
                            CustomButton(
                              text: context.l10n.deckGetInsight,
                              isFullWidth: true,
                              onPressed: _onGetInsightPressed,
                            ),
                        ],
                      ]),
                    );
                  },
                ),
              const SizedBox(height: 32),
              SpecialDecks(
                onBuyLoveDeckPressed: _onBuyLoveDeckPressed,
                onBuyKeltDeckPressed: _onBuyKeltDeckPressed,
              ),
            ]),
          ),
          // Все карты
          const AllCardsTab(),
        ),
        const SizedBox(height: 64),
      ],
    );
  }
}

class _GradientUnderlineButton extends StatelessWidget {
  const _GradientUnderlineButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.urbanistRegular16.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: -0.408,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.white,
      decorationThickness: 1,
    );

    return Semantics(
      button: true,
      label: text,
      onTap: LotusFeedback.action(onPressed),
      child: ExcludeSemantics(
        child: LotusTap(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) =>
                  _TaroCardsColors.goldGradient.createShader(bounds),
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style.copyWith(color: AppColors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _TarotInsightSphere {
  love('ic_heart'),
  selfRealization('ic_award'),
  spirituality('ic_education'),
  health('ic_cup_of_tea'),
  family('ic_map'),
  career('ic_education');

  const _TarotInsightSphere(this.iconName);

  final String iconName;

  String title(BuildContext context) => switch (this) {
    _TarotInsightSphere.love => context.l10n.tarotSphereLove,
    _TarotInsightSphere.selfRealization =>
      context.l10n.tarotSphereSelfRealization,
    _TarotInsightSphere.spirituality => context.l10n.tarotSphereSpirituality,
    _TarotInsightSphere.health => context.l10n.tarotSphereHealth,
    _TarotInsightSphere.family => context.l10n.tarotSphereFamily,
    _TarotInsightSphere.career => context.l10n.tarotSphereCareer,
  };
}

class _TarotInsightBlock extends StatefulWidget {
  const _TarotInsightBlock({required this.interpretation});

  final InterpretationModel interpretation;

  @override
  State<_TarotInsightBlock> createState() => _TarotInsightBlockState();
}

class _TarotInsightBlockState extends State<_TarotInsightBlock> {
  _TarotInsightSphere _selectedSphere = _TarotInsightSphere.love;

  String _textForSphere(_TarotInsightSphere sphere) {
    return switch (sphere) {
      _TarotInsightSphere.love => widget.interpretation.love,
      _TarotInsightSphere.selfRealization =>
        widget.interpretation.selfRealization,
      _TarotInsightSphere.spirituality => widget.interpretation.spirituality,
      _TarotInsightSphere.health => widget.interpretation.health,
      _TarotInsightSphere.family => widget.interpretation.family,
      _TarotInsightSphere.career => widget.interpretation.career,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.tarotChooseSphere,
          style: context.textTheme.playfairMedium20.copyWith(
            color: AppColors.white,
            height: 1.1,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _TarotInsightSphere.values.map((sphere) {
            final isSelected = _selectedSphere == sphere;
            return TarotSphereChip(
              title: sphere.title(context),
              iconName: sphere.iconName,
              selected: isSelected,
              onTap: () => setState(() => _selectedSphere = sphere),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          _textForSphere(_selectedSphere),
          style: context.textTheme.urbanistRegular16.copyWith(
            color: _TaroCardsColors.descriptionText,
            height: 1.2,
            letterSpacing: -0.408,
          ),
        ),
      ]),
    );
  }
}
