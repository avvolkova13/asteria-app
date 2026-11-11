import 'package:asteria_app/features/scenarios/scenario_sky.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/feature_names.dart';
import 'package:asteria_app/core/const/purchase_products_const.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_request_helper.dart';
import 'package:asteria_app/features/love_deck/widgets/how_to_use_love_deck.dart';
import 'package:asteria_app/features/love_deck/widgets/love_layout.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';

class _LoveDeckColors {
  static const background = Color(0xFF0F0A1A);
  static const descriptionText = Color(0xFFEEEAFD);
  static const gold = Color(0xFFF3B76A);
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );
}

class LoveDeckScreen extends StatefulWidget {
  const LoveDeckScreen({super.key, this.afterReading});

  final Widget? afterReading;

  @override
  State<LoveDeckScreen> createState() => _LoveDeckScreenState();
}

class _LoveDeckScreenState extends State<LoveDeckScreen> {
  bool _isRefreshing = false;

  static const _featureParam = {EventParams.featureName: 'love_deck'};

  @override
  void initState() {
    super.initState();
    final userProvider = di.get<UserProvider>();
    userProvider.resetDeckOpenState(DeckType.love);
    if (userProvider.currentUser?.loveDeck?.loveDeckCards.isEmpty ?? true) {
      _isRefreshing = true;
      userProvider.loadLatestDeck(DeckType.love).whenComplete(() {
        if (mounted) {
          setState(() => _isRefreshing = false);
        }
      });
    }
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.loveDeckOpen,
      params: _featureParam,
    );
  }

  void onRefreshPressed() {
    final facade = di.get<AnalyticsFacade>();
    final messenger = ScaffoldMessenger.of(context);
    final refreshError = context.l10n.genericRefreshError;
    facade.trackEvent(
      AnalyticsEvents.paywallView,
      params: {
        ..._featureParam,
        EventParams.paywallVariant: 'refresh_deck',
        EventParams.price: PurchaseProductsConst.loveDeck.price,
        EventParams.currency: 'coins',
      },
    );
    showFeaturePurchaseModal(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SharedPurchaseModal(
        featureKey: 'tarot_spread',
        loaderType: GlobalLoaderType.insight,
        purchaseTitle: context.l10n.loveDeckTitle,
        price: PurchaseProductsConst.loveDeck.price,
        originSurface: 'tarot',
        offerType: OfferType.oneOffUnlock,
        onAccessPurchase: (requirePro, idempotencyKey) async {
          facade.trackEvent(
            AnalyticsEvents.paywallCtaClick,
            params: _featureParam,
          );
          setState(() => _isRefreshing = true);
          try {
            await facade.runFeatureAction(
              'love_deck',
              () => di.get<UserProvider>().buyLoveDeck(
                requirePro: requirePro,
                idempotencyKey: idempotencyKey,
              ),
            );
            if (!di.get<MonetizationProvider>().effectivePro) {
              facade.trackPurchaseSuccess(
                feature: FeatureName.loveDeck,
                productId: 'love_deck_refresh',
                price: PurchaseProductsConst.loveDeck.price,
                currency: 'coins',
                purchaseType: 'refresh',
              );
            }
          } catch (e) {
            if (!di.get<MonetizationProvider>().effectivePro) {
              facade.trackPurchaseFailed(
                feature: FeatureName.loveDeck,
                productId: 'love_deck_refresh',
                failureStage: 'buy_love_deck',
                failureReason: e.toString(),
              );
            }
            if (mounted) {
              messenger.showSnackBar(SnackBar(content: Text(refreshError)));
            }
          } finally {
            if (mounted) {
              setState(() => _isRefreshing = false);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = di.get<UserProvider>();

    return Scaffold(
      backgroundColor: _LoveDeckColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (ScenarioSkyScope.of(context)) const ScenarioSky(),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: TopNavBarDelegate(
                  canPop: true,
                  userName: context.l10n.loveDeckTitle,
                  type: TopNavBarType.moon,
                  birthDate: userProvider
                      .currentUser
                      ?.personalInfo
                      ?.birthDate
                      ?.birthDate,
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
                          if (_isRefreshing)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: AsteriaEntrance(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            )
                          else
                            _LoveDeckContent(
                              onRefresh: onRefreshPressed,
                              afterReading: widget.afterReading,
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
        ],
      ),
    );
  }
}

class _LoveDeckContent extends StatelessWidget {
  final VoidCallback onRefresh;

  const _LoveDeckContent({required this.onRefresh, this.afterReading});

  final Widget? afterReading;

  void _showHowToUseCardsModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const HowToUseLoveDeck();
      },
    );
  }

  Future<void> _onGetDeckInsightPressed(BuildContext context) async {
    final userProvider = di.get<UserProvider>();
    if (userProvider.isAllCardsOpened('love_deck')) {
      try {
        di.get<GlobalLoaderService>().showWithSpheres(GlobalLoaderType.insight);
        await di.get<ContentProvider>().getDeckInsight('love_deck');
      } catch (e) {
        debugPrint('[LoveDeck] Failed to load deck insight: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.insightLoadError)),
          );
        }
      } finally {
        di.get<GlobalLoaderService>().hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = di.get<UserProvider>();

    return ListenableBuilder(
      listenable: userProvider,
      builder: (context, _) {
        final interpretation =
            userProvider.currentUser?.loveDeck?.interpretation;
        final hasLocalizedInterpretation =
            interpretation != null &&
            isAiContentLocalized(
              interpretation,
              Localizations.localeOf(context).languageCode,
            );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AsteriaEntrance.sections([
            _LoveDeckHeader(onRefresh: onRefresh),
            const SizedBox(height: 12),
            _GradientText(
              text: context.l10n.loveDeckTagline,
              gradient: _LoveDeckColors.goldGradient,
              style: context.textTheme.playfairMedium20.copyWith(
                height: 1.1,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.loveDeckDescription,
              style: context.textTheme.urbanistRegular16.copyWith(
                color: _LoveDeckColors.descriptionText,
                height: 1.2,
                letterSpacing: 0,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 24),
            const LoveLayout(),
            const SizedBox(height: 16),
            Center(
              child: _GradientUnderlineButton(
                text: context.l10n.deckHowToUse,
                onPressed: () => _showHowToUseCardsModal(context),
              ),
            ),
            const SizedBox(height: 16),
            if (userProvider.isAllCardsOpened('love_deck') &&
                !hasLocalizedInterpretation)
              CustomButton(
                text: context.l10n.deckGetInsight,
                onPressed: () => _onGetDeckInsightPressed(context),
                height: 50,
                isFullWidth: true,
              )
            else
              AsteriaEntrance(
                replayKey: interpretation,
                animateInitially: interpretation?.isNotEmpty ?? false,
                child: Text(
                  interpretation ?? '',
                  style: context.textTheme.urbanistRegular16.copyWith(
                    color: _LoveDeckColors.descriptionText,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              ),
            if (afterReading != null &&
                userProvider.isAllCardsOpened('love_deck'))
              afterReading!,
            const SizedBox(height: 16),
          ]),
        );
      },
    );
  }
}

class _LoveDeckHeader extends StatelessWidget {
  const _LoveDeckHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 39,
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.loveDeckTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.playfairSemiBold32.copyWith(
                color: AppColors.white,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          LotusTap(
            behavior: HitTestBehavior.opaque,
            onTap: onRefresh,
            child: SizedBox(
              width: LotusArrowBubble.hitExtent,
              height: LotusArrowBubble.hitExtent,
              child: Center(
                child: LotusRefreshBubble(tint: _LoveDeckColors.gold),
              ),
            ),
          ),
        ],
      ),
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
      letterSpacing: 0,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.white,
      decorationThickness: 1,
    );

    return LotusTap(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) =>
              _LoveDeckColors.goldGradient.createShader(bounds),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText({
    required this.text,
    required this.gradient,
    required this.style,
  });

  final String text;
  final Gradient gradient;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        style: style.copyWith(color: AppColors.white),
        textAlign: TextAlign.left,
      ),
    );
  }
}
