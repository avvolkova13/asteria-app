import 'package:asteria_app/core/ui_kit/widgets/asteria_activity_indicator.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_bar_geometry.dart';
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
import 'package:asteria_app/features/kelt_deck/widgets/celtic_cross_layout.dart';
import 'package:asteria_app/features/kelt_deck/widgets/how_to_use_kelt_deck.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _KeltDeckColors {
  static const background = Color(0xFF080110);
  static const text = Color(0xFFEEEAFD);
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );
}

class KeltDeckScreen extends StatefulWidget {
  const KeltDeckScreen({Key? key}) : super(key: key);

  @override
  State<KeltDeckScreen> createState() => _KeltDeckScreenState();
}

class _KeltDeckScreenState extends State<KeltDeckScreen> {
  bool _isRefreshing = false;

  static const _featureParam = {EventParams.featureName: 'kelt_deck'};

  @override
  void initState() {
    super.initState();
    final userProvider = di.get<UserProvider>();
    userProvider.resetDeckOpenState(DeckType.kelt);
    if (userProvider.currentUser?.keltDeck?.keltDeckCards.isEmpty ?? true) {
      _restoreSavedDeck();
    }
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.keltDeckOpen,
      params: _featureParam,
    );
  }

  Future<void> _restoreSavedDeck() async {
    setState(() => _isRefreshing = true);
    try {
      await di.get<UserProvider>().loadLatestDeck(DeckType.kelt);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
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
        EventParams.price: PurchaseProductsConst.keltDeck.price,
        EventParams.currency: 'coins',
      },
    );
    showFeaturePurchaseModal(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SharedPurchaseModal(
        featureKey: 'tarot_spread',
        loaderType: GlobalLoaderType.insight,
        purchaseTitle: context.l10n.keltDeckTitle,
        price: PurchaseProductsConst.keltDeck.price,
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
              'kelt_deck',
              () => di.get<UserProvider>().buyKeltDeck(
                requirePro: requirePro,
                idempotencyKey: idempotencyKey,
              ),
            );
            if (!di.get<MonetizationProvider>().effectivePro) {
              facade.trackPurchaseSuccess(
                feature: FeatureName.keltDeck,
                productId: 'kelt_deck_refresh',
                price: PurchaseProductsConst.keltDeck.price,
                currency: 'coins',
                purchaseType: 'refresh',
              );
            }
          } catch (e) {
            if (!di.get<MonetizationProvider>().effectivePro) {
              facade.trackPurchaseFailed(
                feature: FeatureName.keltDeck,
                productId: 'kelt_deck_refresh',
                failureStage: 'buy_kelt_deck',
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _KeltDeckColors.background,
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: TopNavBarDelegate(
                topInset: MediaQuery.paddingOf(context).top,
                toolbarHeight: AsteriaTopBarMetrics.heightOf(context),
                canPop: true,
                userName: context.l10n.keltDeckTitle,
                type: TopNavBarType.transparent,
                birthDate: userProvider
                    .currentUser
                    ?.personalInfo
                    ?.birthDate
                    ?.birthDate,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),
                    if (_isRefreshing)
                      const Center(
                        child: AsteriaEntrance(
                          child: AsteriaActivityIndicator(),
                        ),
                      )
                    else if (userProvider
                            .currentUser
                            ?.keltDeck
                            ?.keltDeckCards
                            .isNotEmpty !=
                        true)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(context.l10n.loadingDataError),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: context.l10n.retry,
                            onPressed: _restoreSavedDeck,
                          ),
                        ],
                      )
                    else
                      _KeltDeckContent(onRefresh: onRefreshPressed),
                    SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeltDeckContent extends StatelessWidget {
  final VoidCallback onRefresh;

  const _KeltDeckContent({Key? key, required this.onRefresh}) : super(key: key);

  void _showHowToUseCardsModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const HowToUseKeltDeck();
      },
    );
  }

  Future<void> _onGetDeckInsightPressed() async {
    final userProvider = di.get<UserProvider>();
    if (userProvider.isAllCardsOpened('kelt_deck')) {
      try {
        di.get<GlobalLoaderService>().showWithSpheres(GlobalLoaderType.insight);
        await di.get<ContentProvider>().getDeckInsight('kelt_deck');
      } catch (e) {
        debugPrint('[KeltDeck] Failed to load deck insight: $e');
      } finally {
        di.get<GlobalLoaderService>().hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: di.get<UserProvider>(),
      builder: (context, _) {
        final userProvider = di.get<UserProvider>();
        final isAllOpened = userProvider.isAllCardsOpened('kelt_deck');
        final interpretation =
            userProvider.currentUser?.keltDeck?.interpretation;
        final hasLocalizedInterpretation =
            interpretation != null &&
            isAiContentLocalized(
              interpretation,
              Localizations.localeOf(context).languageCode,
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AsteriaEntrance.sections([
            _KeltDeckTitle(onRefresh: onRefresh),
            const SizedBox(height: 16),
            if (isAllOpened) ...[
              const _KeltDeckOpenedInfo(),
              const SizedBox(height: 24),
            ] else ...[
              Text(
                context.l10n.keltDeckDescription,
                style: _bodyStyle(context),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
            ],
            const CelticCrossLayout(),
            const SizedBox(height: 16),
            Center(
              child: _GradientLink(
                text: context.l10n.deckHowToUse,
                onTap: () => _showHowToUseCardsModal(context),
              ),
            ),
            if (isAllOpened) ...[
              const SizedBox(height: 24),
              if (!hasLocalizedInterpretation)
                CustomButton(
                  text: context.l10n.deckGetInsight,
                  onPressed: _onGetDeckInsightPressed,
                  height: 50,
                  isFullWidth: true,
                )
              else
                Text(interpretation, style: _bodyStyle(context)).withEntrance(),
            ],
            const SizedBox(height: 64),
          ]),
        );
      },
    );
  }

  static TextStyle _bodyStyle(BuildContext context) {
    return context.textTheme.urbanistRegular16.copyWith(
      color: _KeltDeckColors.text,
      height: 1.2,
      letterSpacing: -0.408,
    );
  }
}

class _KeltDeckTitle extends StatelessWidget {
  const _KeltDeckTitle({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.l10n.keltDeckTitle,
            style: context.textTheme.playfairSemiBold32.copyWith(
              color: _KeltDeckColors.text,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
        Semantics(
          button: true,
          label: context.l10n.refreshReadingLabel,
          child: LotusTap(
            behavior: HitTestBehavior.opaque,
            onTap: onRefresh,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Align(
                alignment: Alignment.center,
                child: const LotusRefreshBubble(
                  shuffle: true,
                  tint: Color(0xFFF3B76A),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KeltDeckOpenedInfo extends StatelessWidget {
  const _KeltDeckOpenedInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GradientText(
          text: context.l10n.readingComplete,
          gradient: _KeltDeckColors.goldGradient,
          style: context.textTheme.playfairMedium20.copyWith(
            height: 1.1,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.keltDeckCompletedDescription,
          style: _KeltDeckContent._bodyStyle(context),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}

class _GradientLink extends StatelessWidget {
  const _GradientLink({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: text,
      child: LotusTap(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: _GradientText(
              text: text,
              gradient: _KeltDeckColors.goldGradient,
              style: context.textTheme.urbanistRegular16.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.408,
                decoration: TextDecoration.underline,
                decorationThickness: 1,
              ),
            ),
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
      child: Text(text, style: style.copyWith(color: AppColors.white)),
    );
  }
}
