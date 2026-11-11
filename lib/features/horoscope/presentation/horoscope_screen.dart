import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'dart:math' as math;
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';

import 'package:asteria_app/app/data/models/horoscope/horoscope_year_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/entry_surface.dart';
import 'package:asteria_app/core/analytics/dictionaries/generation_status.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/feature_names.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/subscription_widget.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_request_helper.dart';
import 'package:asteria_app/features/horoscope/presentation/horoscope_core_position_assets.dart';
import 'package:asteria_app/features/horoscope/presentation/widgets/horoscope_empty_screen.dart';
import 'package:asteria_app/features/horoscope/presentation/widgets/horoscrope_creating_screen.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  bool _isLoading = true;
  bool _isCreating = false;
  bool _hasHoroscope = false;
  String? _error;
  DateTime? _generationStartedAt;

  static const _featureParam = {EventParams.featureName: 'horoscope'};

  @override
  void initState() {
    super.initState();
    final productAnalytics = di.get<ProductAnalyticsService>();
    productAnalytics.trackMoonStart(entrySurface: EntrySurface.home);
    // Annual horoscope = the "year" tab in the moon/horoscope funnel taxonomy.
    productAnalytics.trackMoonTabView(contentType: 'year');
    _loadHoroscope();
  }

  Future<void> _loadHoroscope() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userProvider = di.get<UserProvider>();
      final horoscope = userProvider.currentUser?.horoscopeYear;
      final language = di.get<AppLocaleService>().contentLanguage;

      final has =
          horoscope != null &&
          isAiContentLocalized(horoscope.toJson(), language);
      setState(() {
        _isLoading = false;
        _isCreating = false;
        _hasHoroscope = has;
      });
      di.get<AnalyticsFacade>().trackEvent(
        AnalyticsEvents.horoscopeView,
        params: {
          ..._featureParam,
          EventParams.resultStatus: has ? 'unlocked' : 'locked',
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isCreating = false;
        _error = context.l10n.contentTranslationUnavailable;
      });
    }
  }

  Future<void> _createHoroscope({bool requirePro = false}) async {
    final facade = di.get<AnalyticsFacade>();
    final productAnalytics = di.get<ProductAnalyticsService>();
    facade.trackEvent(
      AnalyticsEvents.calculationStarted,
      params: _featureParam,
    );
    _generationStartedAt = DateTime.now();
    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      await di.get<ContentProvider>().buyHoroscope(
        HoroscopeTypeEnum.year,
        requirePro: requirePro,
      );
      setState(() {
        _isCreating = false;
        _hasHoroscope = true;
      });
      facade.trackEvent(
        AnalyticsEvents.calculationCompleted,
        params: {..._featureParam, EventParams.resultStatus: 'success'},
      );
      facade.trackEvent(
        AnalyticsEvents.horoscopeView,
        params: {..._featureParam, EventParams.resultStatus: 'unlocked'},
      );
      productAnalytics.trackMoonGenerationComplete(
        generationStatus: GenerationStatus.success,
        generationSeconds: _generationStartedAt != null
            ? DateTime.now().difference(_generationStartedAt!).inSeconds
            : null,
      );
      // T21 scope-creep flag: coin-purchased horoscope currently shares
      // the `trackPurchaseSuccess` facade with real-money flows and emits
      // `currency: 'coins'`. This is NOT real money revenue. The proper
      // fix is to switch to `ast_coin_spend_success` (covered by a
      // follow-up to T15), but that requires re-wiring the horoscope
      // purchase plumbing. Deferred — see analytics plan.
      if (!di.get<MonetizationProvider>().effectivePro) {
        facade.trackPurchaseSuccess(
          feature: FeatureName.horoscope,
          productId: 'horoscope_year',
          price: HoroscopeTypeEnum.year.price,
          currency: 'coins',
          purchaseType: 'one_time',
        );
      }
    } catch (e) {
      facade.trackEvent('feature_action_failed', params: _featureParam);
      if (!di.get<MonetizationProvider>().effectivePro) {
        facade.trackPurchaseFailed(
          feature: FeatureName.horoscope,
          productId: 'horoscope_year',
          failureStage: 'buy_horoscope',
          failureReason: e.toString(),
        );
      }
      setState(() {
        _isCreating = false;
        _error = context.l10n.horoscopeCreateError;
      });
      rethrow;
    }
  }

  void _showPurchaseModalSheet() {
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.paywallView,
      params: {
        ..._featureParam,
        EventParams.paywallVariant: 'one_time_purchase',
        EventParams.price: HoroscopeTypeEnum.year.price,
        EventParams.currency: 'coins',
      },
    );
    di.get<ProductAnalyticsService>().trackMoonPaywallView(
      originSurface: 'horoscope',
      offerType: OfferType.oneOffUnlock,
      paywallVariant: 'one_time_purchase',
    );
    showFeaturePurchaseModal(
      context: context,
      builder: (context) => SharedPurchaseModal(
        featureKey: 'yearly_personal_horoscope',
        purchaseTitle: context.l10n.purchaseYearHoroscope,
        price: HoroscopeTypeEnum.year.price,
        originSurface: 'moon',
        offerType: OfferType.oneOffUnlock,
        onAccessPurchase: (requirePro, _) {
          di.get<AnalyticsFacade>().trackEvent(
            AnalyticsEvents.horoscopeUnlockClick,
            params: _featureParam,
          );
          return _createHoroscope(requirePro: requirePro);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _HoroscopeDesign.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _HoroscopeBackground()),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      MediaQuery.paddingOf(context).top + 68,
                      16,
                      100 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_error != null)
                          _HoroscopeStateCard(message: _error!)
                        else if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 96),
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        else if (_isCreating)
                          const HoroscropeCreatingScreen()
                        else if (!_hasHoroscope)
                          HoroscopeEmptyScreen(
                            onBuyPressed: _showPurchaseModalSheet,
                          )
                        else
                          const _HoroscopeContent(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const _HoroscopeTopBar(),
          ],
        ),
      ),
    );
  }
}

class _HoroscopeContent extends StatefulWidget {
  const _HoroscopeContent();

  @override
  State<_HoroscopeContent> createState() => _HoroscopeContentState();
}

class _HoroscopeContentState extends State<_HoroscopeContent> {
  int _selectedTabIndex = 0;

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return const _HoroscopeYourEssence();
      case 1:
        return const _HoroscopeLifeSpheres();
      case 2:
        return const _HoroscopeYourEvolution();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SegmentedPicker.indexed(
          surfaceBrightness: Brightness.dark,
          titles: [
            context.l10n.horoscopeEssence,
            context.l10n.horoscopeLifeAreas,
            context.l10n.horoscopeEvolution,
          ],
          selectedIndex: _selectedTabIndex,
          onTabSelected: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ).withEntrance(),
        const SizedBox(height: 24),
        _buildTabContent(),
      ],
    );
  }
}

class _HoroscopeYourEssence extends StatelessWidget {
  const _HoroscopeYourEssence();

  @override
  Widget build(BuildContext context) {
    final horoscopeYear = di.get<UserProvider>().currentUser?.horoscopeYear;

    if (horoscopeYear == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.horoscopeEssence,
          style: _HoroscopeDesign.h1(context),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.horoscopeGeneral,
          style: _HoroscopeDesign.h2(context),
        ),
        const SizedBox(height: 16),
        _CoreDescriptionCards(horoscopeYear: horoscopeYear),
        const SizedBox(height: 24),
        Text(
          context.l10n.horoscopeWeakPoints,
          style: _HoroscopeDesign.h2(context),
        ),
        const SizedBox(height: 16),
        _HorizontalLabeledCards(
          items: horoscopeYear.weakPoints
              .map(
                (point) => _LabeledCardData(
                  title: point.title,
                  description: point.description,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        _HoroscopeInfoCard(
          title: context.l10n.horoscopeEmotions,
          description: horoscopeYear.emotionalWorld,
          imagePath: 'assets/images/horoscope/year_emotional_world.webp',
          imageWidth: 124,
          imageHeight: 142,
        ),
        const SizedBox(height: 24),
        _TagSection(
          title: context.l10n.horoscopeAdvice,
          tags: horoscopeYear.recommendations,
        ),
        const SizedBox(height: 24),
        _MetaphorCard(description: horoscopeYear.astroMetaphor),
      ]),
    );
  }
}

class _HoroscopeLifeSpheres extends StatelessWidget {
  const _HoroscopeLifeSpheres();

  @override
  Widget build(BuildContext context) {
    final horoscopeYear = di.get<UserProvider>().currentUser?.horoscopeYear;

    if (horoscopeYear == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.horoscopeLifeAreas,
          style: _HoroscopeDesign.h1(context),
        ),
        const SizedBox(height: 16),
        _HoroscopeInfoCard(
          title: context.l10n.horoscopeLove,
          description: horoscopeYear.love.general,
          imagePath: 'assets/images/horoscope/year_love.webp',
        ),
        const SizedBox(height: 18),
        _LabeledCard(
          title: context.l10n.horoscopeWellbeing,
          description: horoscopeYear.love.lesson,
          fullWidth: true,
        ),
        const SizedBox(height: 18),
        _HoroscopeInfoCard(
          title: context.l10n.horoscopeWork,
          description: horoscopeYear.work.general,
          imagePath: 'assets/images/horoscope/year_work.webp',
        ),
        const SizedBox(height: 24),
        _TagSection(
          title: context.l10n.horoscopeExamples,
          description: horoscopeYear.work.important,
          tags: horoscopeYear.work.successExamples,
        ),
        const SizedBox(height: 18),
        _HoroscopeInfoCard(
          title: context.l10n.horoscopeFinances,
          description: horoscopeYear.finance.general,
          imagePath: 'assets/images/horoscope/year_finance.webp',
        ),
      ]),
    );
  }
}

class _HoroscopeYourEvolution extends StatelessWidget {
  const _HoroscopeYourEvolution();

  @override
  Widget build(BuildContext context) {
    final horoscopeYear = di.get<UserProvider>().currentUser?.horoscopeYear;

    if (horoscopeYear == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.horoscopeEvolution,
          style: _HoroscopeDesign.h1(context),
        ),
        const SizedBox(height: 18),
        _HoroscopeInfoCard(
          title: context.l10n.horoscopePowerPeriods,
          description: horoscopeYear.transformation.general,
          imagePath: 'assets/images/horoscope/year_transformation.webp',
          imageWidth: 144,
          imageHeight: 98,
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.horoscopeTransits,
          style: _HoroscopeDesign.h2(context),
        ),
        const SizedBox(height: 16),
        _HorizontalLabeledCards(
          items: horoscopeYear.transformation.transits
              .map(
                (transit) => _LabeledCardData(
                  title: transit.planet,
                  description: transit.description,
                ),
              )
              .toList(),
        ),
      ]),
    );
  }
}

class _HoroscopeDesign {
  static const background = Color(0xFF0F0A1A);
  static const card = Color(0xFF3A2355);
  static const cardAlt = Color(0xFF10051F);
  static const cardBorder = Color(0x66FFFFFF);
  static const accentStart = Color(0xFFE6994D);
  static const accentMid = Color(0xFFF3B76A);
  static const accentPurple = Color(0xFF6E4BFF);
  static const accentPurpleEnd = Color(0xFF5A3FD1);

  static const orangeGradient = LinearGradient(
    colors: [accentStart, accentMid, accentStart],
    stops: [0, 0.5, 1],
  );

  static const purpleGradient = LinearGradient(
    colors: [accentPurple, accentPurpleEnd],
  );

  static TextStyle h1(BuildContext context) =>
      context.textTheme.inversePlayfairSemiBold32;

  static TextStyle h2(BuildContext context) =>
      context.textTheme.inversePlayfairSemiBold24;

  static TextStyle body(BuildContext context) =>
      context.textTheme.inverseUrbanistRegular16;
}

class _HoroscopeBackground extends StatelessWidget {
  const _HoroscopeBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: _HoroscopeDesign.background),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/horoscope/year_background.webp',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.62),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x4D0F0A1A),
                  Color(0x260F0A1A),
                  Color(0xD90F0A1A),
                ],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoroscopeTopBar extends StatelessWidget {
  const _HoroscopeTopBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        color: _HoroscopeDesign.background,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                LotusFeedback(
                  onActivate: () => Navigator.of(context).pop(),
                  keyboard: true,
                  builder: (activate) => Semantics(
                    button: true,
                    label: context.l10n.commonBack,
                    onTap: activate,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: activate,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: LotusIconSurface(
                            diameter: 27,
                            child: ClayAssetIcon(
                              'assets/icons/back_icon.svg',
                              height: 24,
                              tint: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  context.l10n.horoscopeTitle,
                  style: context.textTheme.inversePlayfairSemiBold17,
                ).withEntrance(),
                const Spacer(),
                LotusFeedback(
                  onActivate: () => BalanceRoute.push(context),
                  keyboard: true,
                  builder: (activate) => Semantics(
                    button: true,
                    label: context.l10n.balanceLabel,
                    onTap: activate,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: activate,
                      child: SizedBox(
                        height: 44,
                        child: Center(
                          child: Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              return Row(
                                children: [
                                  Text(
                                    '${MonetizationProvider.maybeOf(context)?.balance ?? 0} ',
                                    style: context
                                        .textTheme
                                        .inverseUrbanistSemiBold17,
                                  ).withEntrance(),
                                  LotusRasterIcon(
                                    'assets/icons/star_coin_icon.png',
                                    width: 16,
                                    height: 16,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 76,
                  height: 44,
                  child: Center(
                    child: SizedBox(
                      width: 76,
                      height: 28,
                      child: SubscriptionWidget(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoreDescriptionCards extends StatelessWidget {
  final HoroscopeYearModel horoscopeYear;

  const _CoreDescriptionCards({required this.horoscopeYear});

  @override
  Widget build(BuildContext context) {
    final items = [
      _IllustratedCardData(
        title: horoscopeYear.coreDescription.sunInSign.planetInSign,
        description: horoscopeYear.coreDescription.sunInSign.description,
        imagePath: horoscopeCorePositionAssetFor(
          horoscopeYear.coreDescription.sunInSign.planetInSign,
        ),
      ),
      _IllustratedCardData(
        title: horoscopeYear.coreDescription.moonInSign.planetInSign,
        description: horoscopeYear.coreDescription.moonInSign.description,
        imagePath: horoscopeCorePositionAssetFor(
          horoscopeYear.coreDescription.moonInSign.planetInSign,
        ),
      ),
      _IllustratedCardData(
        title: horoscopeYear.coreDescription.ascendantInSign.planetInSign,
        description: horoscopeYear.coreDescription.ascendantInSign.description,
        imagePath: horoscopeCorePositionAssetFor(
          horoscopeYear.coreDescription.ascendantInSign.planetInSign,
        ),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 325,
                maxWidth: 325,
                minHeight: 252,
              ),
              child: _IllustratedCard(data: item),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _IllustratedCardData {
  final String title;
  final String description;
  final String imagePath;

  const _IllustratedCardData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class _IllustratedCard extends StatelessWidget {
  final _IllustratedCardData data;

  const _IllustratedCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return HoroscopeCorePositionCard(
      title: data.title,
      description: data.description,
      imagePath: data.imagePath,
    );
  }
}

@visibleForTesting
class HoroscopeCorePositionCard extends StatelessWidget {
  static const _horizontalPadding = 16.0;
  static const _topPadding = 28.0;
  static const _bottomPadding = 16.0;
  static const _imageSize = 96.0;
  static const _imageRight = 14.0;
  static const _imageTop = 16.0;
  static const _imageReserve = 124.0;

  final String title;
  final String description;
  final String imagePath;

  const HoroscopeCorePositionCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      containerKey: const ValueKey('horoscope-core-card'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textWidth = math
              .max(0, constraints.maxWidth - _horizontalPadding - _imageReserve)
              .toDouble();

          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 252),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    _horizontalPadding,
                    _topPadding,
                    _horizontalPadding,
                    _bottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: textWidth,
                        child: Text(title, style: _HoroscopeDesign.h2(context)),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: textWidth,
                        child: Text(
                          description,
                          style: _HoroscopeDesign.body(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: _imageRight,
                  top: _imageTop,
                  child: _CorePositionImage(
                    imagePath: imagePath,
                    size: _imageSize,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CorePositionImage extends StatelessWidget {
  final String imagePath;
  final double size;

  const _CorePositionImage({required this.imagePath, this.size = 104});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      key: const ValueKey('horoscope-core-card-image'),
      frameBuilder: AsteriaEntrance.imageFrame,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

class _HoroscopeInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final double imageWidth;
  final double imageHeight;

  const _HoroscopeInfoCard({
    required this.title,
    required this.description,
    required this.imagePath,
    this.imageWidth = 72,
    this.imageHeight = 82,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: _HoroscopeDesign.h2(context)),
                ),
                const SizedBox(width: 12),
                Image.asset(
                  imagePath,
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.contain,
                  frameBuilder: AsteriaEntrance.imageFrame,
                  excludeFromSemantics: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description, style: _HoroscopeDesign.body(context)),
          ],
        ),
      ),
    );
  }
}

class _HorizontalLabeledCards extends StatelessWidget {
  final List<_LabeledCardData> items;

  const _HorizontalLabeledCards({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      physics: const BouncingScrollPhysics(),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in items) ...[
              _LabeledCard(title: item.title, description: item.description),
              const SizedBox(width: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _LabeledCardData {
  final String title;
  final String description;

  const _LabeledCardData({required this.title, required this.description});
}

class _LabeledCard extends StatelessWidget {
  final String title;
  final String description;
  final bool fullWidth;

  const _LabeledCard({
    required this.title,
    required this.description,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : 293,
      constraints: const BoxConstraints(minHeight: 74),
      decoration: CardLensDecoration(
        color: _HoroscopeDesign.cardAlt,
        borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 126, maxWidth: 245),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            decoration: const BoxDecoration(
              gradient: _HoroscopeDesign.purpleGradient,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
            ),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.h4.copyWith(color: AppColors.textInverse),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 16),
            child: Text(description, style: _HoroscopeDesign.body(context)),
          ),
        ],
      ),
    );
  }
}

class _TagSection extends StatelessWidget {
  final String title;
  final String? description;
  final List<String> tags;

  const _TagSection({
    required this.title,
    required this.tags,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _HoroscopeDesign.h2(context)),
        if (description != null && description!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(description!, style: _HoroscopeDesign.body(context)),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 6,
          runSpacing: 8,
          children: [
            for (final tag in tags)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: _HoroscopeDesign.orangeGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 33),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Text(
                        tag,
                        textAlign: TextAlign.center,
                        style: context.textTheme.inverseUrbanistMedium14
                            .copyWith(
                              color: _HoroscopeDesign.cardAlt,
                              height: 1,
                              letterSpacing: -0.41,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MetaphorCard extends StatelessWidget {
  final String description;

  const _MetaphorCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: CardLensDecoration(
        color: const Color(0xFF151028),
        borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
        image: const DecorationImage(
          image: AssetImage(
            'assets/images/horoscope/year_astro_metaphor_bg.webp',
          ),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textWidth = (constraints.maxWidth - 126).clamp(160.0, 232.0);

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: textWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.horoscopeMetaphor,
                        style: _HoroscopeDesign.h2(context),
                      ),
                      const SizedBox(height: 16),
                      Text(description, style: _HoroscopeDesign.body(context)),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 16,
                child: Image.asset(
                  'assets/images/horoscope/year_astro_metaphor.webp',
                  frameBuilder: AsteriaEntrance.imageFrame,
                  width: 78,
                  height: 117,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final Key? containerKey;

  const _GlassCard({required this.child, this.containerKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: containerKey,
      width: double.infinity,
      decoration: CardLensDecoration(
        color: _HoroscopeDesign.card.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
        border: Border.all(color: _HoroscopeDesign.cardBorder, width: 0.7),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _HoroscopeStateCard extends StatelessWidget {
  final String message;

  const _HoroscopeStateCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, style: _HoroscopeDesign.body(context)),
      ),
    );
  }
}
