import 'dart:math' as math;

import 'package:asteria_app/features/scenarios/scenario_sky.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/features/horoscope/presentation/horoscope_core_position_assets.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/app/data/models/natal_card/natal_card_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/entry_surface.dart';
import 'package:asteria_app/core/analytics/dictionaries/generation_status.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/feature_names.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/const/purchase_products_const.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/localization/localized_display_names.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/localization/locale_formatters.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/pearl_metric_row.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_card_empty_screen.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_card_loading_overlay.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_wheel.dart';
import 'package:flutter/material.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';

class NatalCardScreen extends StatefulWidget {
  const NatalCardScreen({super.key});

  @override
  State<NatalCardScreen> createState() => _NatalCardScreenState();
}

class _NatalCardScreenState extends State<NatalCardScreen> {
  final ContentProvider _contentProvider = di.get<ContentProvider>();
  final UserProvider _userProvider = di.get<UserProvider>();
  MonetizationProvider? _monetizationProvider;
  bool _isGenerating = false;
  bool _isCheckingAccess = false;
  bool _generationFailed = false;
  bool _isLoading = true;
  bool _hasNatalCard = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _monetizationProvider = di.isRegistered<MonetizationProvider>()
        ? di.get<MonetizationProvider>()
        : MonetizationProvider.maybeOf(context, listen: false);
    _monetizationProvider?.addListener(_handleMonetizationChanged);
    _loadNatalCard();
  }

  @override
  void dispose() {
    _monetizationProvider?.removeListener(_handleMonetizationChanged);
    super.dispose();
  }

  bool get _accessReady =>
      _monetizationProvider?.state?.uid == _userProvider.currentUser?.id &&
      _monetizationProvider?.state != null;

  void _handleMonetizationChanged() {
    if (!mounted) return;
    setState(() {
      if (_accessReady && _error == 'access_unavailable') _error = null;
    });
  }

  Future<void> _loadNatalCard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final natalCard = _userProvider.currentUser?.natalCard;
      final language = di.get<AppLocaleService>().contentLanguage;
      if (natalCard != null &&
          natalCard.hasAnyInterpretation &&
          !natalCard.hasLanguage(language)) {
        try {
          await _contentProvider.translateNatalCardIfNeeded();
        } catch (_) {
          if (mounted) setState(() => _error = 'translation_unavailable');
          return;
        }
        if (!mounted) return;
        if (!(_userProvider.currentUser?.natalCard?.hasLanguage(language) ??
            false)) {
          // An existing chart must not become a new purchase if translation
          // returns without the requested language.
          setState(() => _error = 'translation_unavailable');
          return;
        }
      }
      _hasNatalCard =
          _userProvider.currentUser?.natalCard?.hasLanguage(language) ?? false;
      if (!_hasNatalCard) {
        // Reuse the application's subscription state; fetch only if not loaded.
        await Future<void>.value();
        await _monetizationProvider?.ensureLoaded();
        if (!mounted) return;
        if (!_accessReady) {
          setState(() => _error = 'access_unavailable');
          return;
        }
      }
      if (!mounted) return;
      final facade = di.get<AnalyticsFacade>();
      final productAnalytics = di.get<ProductAnalyticsService>();
      final featureParam = {
        EventParams.featureName: FeatureName.natalChart.eventValue,
      };
      // ast_natal_start — funnel entry; emitted regardless of whether the
      // chart already exists. Result vs input-start branching follows below.
      productAnalytics.trackNatalStart(entrySurface: EntrySurface.home);
      if (_hasNatalCard) {
        facade.trackEvent(
          AnalyticsEvents.natalChartResultView,
          params: featureParam,
        );
        productAnalytics.trackNatalResultView();
        // The full chart is rendered immediately after this load, so the
        // result surface counts as the first "section view" for engagement.
        productAnalytics.trackNatalSectionView(contentType: 'overview');
      } else {
        facade.trackEvent(
          AnalyticsEvents.natalChartInputStarted,
          params: featureParam,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'load_unavailable';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openNatalCard() async {
    if (_isGenerating || _isCheckingAccess || !_accessReady || _hasNatalCard) {
      return;
    }
    _isCheckingAccess = true;
    final uid = _monetizationProvider!.state?.uid;
    try {
      await _monetizationProvider!.refreshForAccess();
      if (!mounted ||
          uid == null ||
          !_monetizationProvider!.isCurrentUser(uid) ||
          ModalRoute.of(context)?.isCurrent != true) {
        return;
      }
      if (!_monetizationProvider!.isFeatureEnabled('natal_chart')) {
        showAccessError(context);
        return;
      }
      if (_monetizationProvider!.effectivePro) {
        await _generateWithPro();
      } else {
        _showPurchaseModal();
      }
    } catch (_) {
      if (mounted) showAccessError(context);
    } finally {
      _isCheckingAccess = false;
    }
  }

  Future<void> _generateWithPro() async {
    if (_isGenerating) return;
    setState(() {
      _isGenerating = true;
      _generationFailed = false;
    });
    di.get<ProductAnalyticsService>().trackNatalBirthDataComplete();
    try {
      await _generateNatalCard(requirePro: true);
      if (mounted) _showGeneratedResult();
    } catch (_) {
      if (mounted) setState(() => _generationFailed = true);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateNatalCard({bool requirePro = false}) async {
    final facade = di.get<AnalyticsFacade>();
    final productAnalytics = di.get<ProductAnalyticsService>();
    final featureParam = {
      EventParams.featureName: FeatureName.natalChart.eventValue,
    };
    facade.trackEvent(AnalyticsEvents.calculationStarted, params: featureParam);
    final stopwatch = Stopwatch()..start();
    try {
      await _contentProvider.buyNatalCard(requirePro: requirePro);
      stopwatch.stop();
      facade.trackEvent(
        AnalyticsEvents.natalChartCalculationCompleted,
        params: featureParam,
      );
      productAnalytics.trackNatalGenerationComplete(
        generationStatus: GenerationStatus.success,
        generationSeconds: stopwatch.elapsed.inSeconds,
      );
    } catch (_) {
      stopwatch.stop();
      productAnalytics.trackNatalGenerationComplete(
        generationStatus: GenerationStatus.failed,
        generationSeconds: stopwatch.elapsed.inSeconds,
      );
      rethrow;
    }
  }

  void _showGeneratedResult() {
    final productAnalytics = di.get<ProductAnalyticsService>();
    productAnalytics.trackNatalResultView();
    productAnalytics.trackNatalSectionView(contentType: 'overview');
    if (!mounted) return;
    setState(() {
      final language = di.get<AppLocaleService>().contentLanguage;
      _hasNatalCard =
          _userProvider.currentUser?.natalCard?.hasLanguage(language) ?? false;
    });
  }

  void _showPurchaseModal() {
    final facade = di.get<AnalyticsFacade>();
    final productAnalytics = di.get<ProductAnalyticsService>();
    final featureParam = {
      EventParams.featureName: FeatureName.natalChart.eventValue,
    };
    facade.trackEvent(
      AnalyticsEvents.natalChartPaywallView,
      params: {
        ...featureParam,
        EventParams.paywallVariant: 'one_time_purchase',
        EventParams.price: PurchaseProductsConst.natalCard.price,
        EventParams.currency: 'coins',
      },
    );
    productAnalytics.trackNatalPaywallView(
      originSurface: 'natal_card_empty',
      offerType: OfferType.oneOffUnlock,
      paywallVariant: 'one_time_purchase',
    );
    // birth_data_complete is emitted at the moment the user accepts the
    // unlock — at this point we already have user.personalInfo.birthDate
    // available and the generation is about to start.
    productAnalytics.trackNatalBirthDataComplete();
    showFeaturePurchaseModal(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SharedPurchaseModal(
        featureKey: 'natal_chart',
        purchaseTitle: context.l10n.natalBuy,
        price: PurchaseProductsConst.natalCard.price,
        loaderType: GlobalLoaderType.natalCard,
        originSurface: 'natal',
        offerType: OfferType.oneOffUnlock,
        onAccessPurchase: (requirePro, _) async {
          facade.trackEvent(
            AnalyticsEvents.natalChartUnlockClick,
            params: featureParam,
          );
          productAnalytics.trackNatalPaywallClick(
            originSurface: 'natal_card_paywall_modal',
            offerType: OfferType.oneOffUnlock,
            ctaName: 'unlock_natal_card',
            paywallVariant: 'one_time_purchase',
          );
          try {
            await _generateNatalCard(requirePro: requirePro);
          } catch (e) {
            facade.trackPurchaseFailed(
              feature: FeatureName.natalChart,
              productId: 'natal_card',
              failureStage: 'buy_natal_card',
              failureReason: e.toString(),
            );
            rethrow;
          }
        },
        onSuccess: () {
          facade.trackEvent(
            AnalyticsEvents.natalChartPurchaseSuccess,
            params: {
              ...featureParam,
              EventParams.productId: 'natal_card',
              EventParams.price: PurchaseProductsConst.natalCard.price,
              EventParams.currency: 'coins',
              EventParams.purchaseType: 'one_time',
            },
          );
          _showGeneratedResult();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading ||
        _isGenerating ||
        (!_hasNatalCard && (_monetizationProvider?.isLoading ?? false))) {
      return const NatalCardLoadingOverlay();
    }
    final useCompactHeader = _hasNatalCard || _error != null;

    return Scaffold(
      backgroundColor: _NatalCardColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (ScenarioSkyScope.of(context))
            const ScenarioSky()
          else
            const DecoratedBox(
              decoration: BoxDecoration(
                color: _NatalCardColors.background,
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/home/natal_card_figma_background.webp',
                  ),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  opacity: 0.3,
                ),
              ),
            ),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: TopNavBarDelegate(
                  canPop: true,
                  userName: context.l10n.natalChartTitle,
                  type: useCompactHeader
                      ? TopNavBarType.onlyCollapsed
                      : TopNavBarType.transparent,
                  birthDate: _userProvider
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
                      SizedBox(height: useCompactHeader ? 22 : 30),
                      if (_error != null) ...[
                        Text(
                          _error == 'translation_unavailable'
                              ? context.l10n.contentTranslationUnavailable
                              : _error == 'access_unavailable'
                              ? context.l10n.natalAccessUnavailable
                              : context.l10n.natalLoadError,
                          style: context.textTheme.inverseUrbanistRegular16,
                        ),
                        LotusButtons.text(
                          onPressed: _loadNatalCard,
                          child: Text(context.l10n.retry),
                        ),
                      ] else if (!_hasNatalCard) ...[
                        if (_generationFailed) ...[
                          Text(
                            context.l10n.natalGenerationFailed,
                            style: context.textTheme.inverseUrbanistRegular16,
                          ),
                          const SizedBox(height: 16),
                        ],
                        NatalCardEmptyScreen(
                          isPro: _monetizationProvider?.effectivePro ?? false,
                          onBuyPressed: _openNatalCard,
                        ),
                      ] else
                        ListenableBuilder(
                          listenable: _userProvider,
                          builder: (context, _) {
                            final user = _userProvider.currentUser;
                            if (user == null ||
                                !(user.natalCard?.hasAnyInterpretation ??
                                    false)) {
                              return const SizedBox.shrink();
                            }
                            final birth = user.personalInfo?.birthDate;
                            final place = user.personalInfo?.birthPlace;
                            return _NatalCardContent(
                              key: ValueKey((
                                user.id,
                                birth?.birthDate,
                                birth?.birthTime,
                                birth?.hasExactBirthTime,
                                place?.latitude,
                                place?.longitude,
                              )),
                              user: user,
                            );
                          },
                        ),
                      SizedBox(
                        height: MediaQuery.paddingOf(context).bottom + 24,
                      ),
                    ],
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

enum _NatalCardTab { positions, houses, elements }

extension on _NatalCardTab {
  String title(BuildContext context) {
    return switch (this) {
      _NatalCardTab.positions => context.l10n.natalPositionsTab,
      _NatalCardTab.houses => context.l10n.natalHousesThemes,
      _NatalCardTab.elements => context.l10n.natalElementsTab,
    };
  }
}

class _NatalCardContent extends StatefulWidget {
  const _NatalCardContent({super.key, required this.user});

  final UserModel user;

  @override
  State<_NatalCardContent> createState() => _NatalCardContentState();
}

class _NatalCardContentState extends State<_NatalCardContent> {
  _NatalCardTab _selectedTab = _NatalCardTab.positions;

  late Future<PlanetsHousesDataModel?> _geometry;

  @override
  void initState() {
    super.initState();
    _geometry = di.get<ContentProvider>().loadPurchasedNatalGeometry();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlanetsHousesDataModel?>(
      future: _geometry,
      builder: (context, snapshot) => _buildChart(
        context,
        snapshot.data ?? widget.user.planetsHousesData,
        loading: snapshot.connectionState == ConnectionState.waiting,
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    PlanetsHousesDataModel planetsHousesData, {
    required bool loading,
  }) {
    final natalCard = widget.user.natalCard;
    final personalInfo = widget.user.personalInfo;
    final birthTime = personalInfo?.birthDate?.birthTime;
    final locale = Localizations.localeOf(context);
    final language = locale.languageCode == 'ru' ? 'ru' : 'en';
    final interpretation = natalCard?.tryInterpretationFor(language);
    final exactTime = personalInfo?.birthDate?.hasExactBirthTime ?? false;
    if (interpretation == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GeneralInfoSection(
          birthDate:
              personalInfo?.birthDate?.birthDate.toLocalizedShortDate(locale) ??
              '',
          birthTime: exactTime && birthTime != null
              ? LocaleFormatters.timeOfDay(
                  context,
                  TimeOfDay.fromDateTime(birthTime),
                )
              : context.l10n.natalTimeUnknown,
          chart: NatalWheel.hasPlanets(planetsHousesData)
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: NatalWheel(
                      data: planetsHousesData,
                      hasKnownBirthTime: exactTime,
                      planetCardBuilder: (planet, placement) {
                        final house = planet.house;
                        final showHouse =
                            exactTime && house >= 1 && house <= 12;
                        final location = showHouse
                            ? language == 'ru'
                                  ? '$placement · $house дом'
                                  : '$placement · house $house'
                            : placement;
                        final interpretationText = exactTime
                            ? interpretation.planetInterpretations[planet.code]
                                  ?.trim()
                            : null;
                        return SizedBox(
                          width: double.infinity,
                          child: _PlanetPositionCard(
                            key: ValueKey(
                              'selected-planet-card-${planet.code}',
                            ),
                            planet: NatalCardPlanetDisplayModel(
                              code: planet.code,
                              description: [
                                location,
                                if (interpretationText != null &&
                                    interpretationText.isNotEmpty)
                                  interpretationText,
                              ].join('\n'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              : loading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : Column(
                  children: [
                    Text(
                      context.l10n.natalWheelUnavailable,
                      style: context.textTheme.inverseUrbanistRegular16,
                    ),
                    LotusButtons.text(
                      onPressed: () => setState(() {
                        _geometry = di
                            .get<ContentProvider>()
                            .loadPurchasedNatalGeometry();
                      }),
                      child: Text(context.l10n.retry),
                    ),
                  ],
                ),
          approximate: !exactTime,
          birthPlace: personalInfo?.birthPlace?.location ?? '',
        ),
        const SizedBox(height: 16),
        SegmentedPicker<_NatalCardTab>(
          options: _NatalCardTab.values,
          surfaceBrightness: Brightness.dark,
          labelBuilder: (tab) => tab.title(context),
          selectedValue: _selectedTab,
          onChanged: (tab) => setState(() {
            _selectedTab = tab;
          }),
        ).withEntrance(),
        const SizedBox(height: 9),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: switch (_selectedTab) {
            _NatalCardTab.positions => _PositionsTab(
              key: const ValueKey(_NatalCardTab.positions),
              planets: _calculatedPlanetCards(
                context,
                planetsHousesData,
                interpretation,
                exactTime: exactTime,
              ),
            ),
            _NatalCardTab.houses when !exactTime => Text(
              context.l10n.natalHousesNeedTime,
              style: context.textTheme.inverseUrbanistRegular16,
            ),
            _NatalCardTab.houses => _HousesTab(
              key: const ValueKey(_NatalCardTab.houses),
              houses: _calculatedHouseCards(
                context,
                planetsHousesData,
                interpretation,
              ),
            ),
            _NatalCardTab.elements => _ElementsTab(
              key: const ValueKey(_NatalCardTab.elements),
              elements: planetsHousesData.elements,
              elementsDescription:
                  interpretation.elementsInterpretation.isNotEmpty
                  ? interpretation.elementsInterpretation
                  : interpretation.energyArea,
              finalConclusion: interpretation.finalConclusion,
            ),
          },
        ),
      ],
    );
  }

  List<NatalCardPlanetDisplayModel> _calculatedPlanetCards(
    BuildContext context,
    PlanetsHousesDataModel? data,
    NatalCardInterpretationModel? interpretation, {
    required bool exactTime,
  }) {
    if (data == null || data.positions.isEmpty) {
      if (!exactTime || interpretation == null) return const [];
      return [
        for (final entry in interpretation.planetInterpretations.entries)
          if (entry.value.trim().isNotEmpty)
            NatalCardPlanetDisplayModel(
              code: entry.key,
              description: entry.value,
            ),
      ];
    }
    return [
      for (final position in data.positions)
        NatalCardPlanetDisplayModel(
          code: position.code,
          description: _placementDescription(
            context,
            position,
            interpretation?.planetInterpretations[position.code] ?? '',
            exactTime: exactTime,
          ),
        ),
    ];
  }

  List<NatalCardHouseDisplayModel> _calculatedHouseCards(
    BuildContext context,
    PlanetsHousesDataModel? data,
    NatalCardInterpretationModel? interpretation,
  ) {
    final summary = data?.houseSummary;
    if (summary == null) return const [];
    final descriptions = interpretation?.houseInterpretations ?? const {};

    return [
      NatalCardHouseDisplayModel(
        houseNumber: summary.strongHouse.houseNumber,
        description: _houseInterpretation(
          context,
          descriptions['strong_house'],
          summary.strongHouse,
        ),
      ),
      NatalCardHouseDisplayModel(
        houseNumber: summary.weakHouse.houseNumber,
        description: _houseInterpretation(
          context,
          descriptions['weak_house'],
          summary.weakHouse,
        ),
      ),
      NatalCardHouseDisplayModel(
        houseNumber: summary.accentHouse.houseNumber,
        description: _houseInterpretation(
          context,
          descriptions['accent_house'],
          summary.accentHouse,
        ),
      ),
    ];
  }

  String _placementDescription(
    BuildContext context,
    PlanetHousePositionModel position,
    String interpretation, {
    required bool exactTime,
  }) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final sign = position.signCode.isEmpty
        ? position.sign
        : context.l10n.zodiacSignName(position.signCode);
    if (!exactTime) return sign;
    final placement = isRu
        ? '$sign, ${position.house} дом'
        : '$sign, house ${position.house}';
    if (interpretation.trim().isEmpty) return placement;
    return '$placement\n${interpretation.trim()}';
  }

  String _houseInterpretation(
    BuildContext context,
    String? interpretation,
    HouseSummaryEntryModel house,
  ) {
    if (interpretation != null && interpretation.trim().isNotEmpty) {
      return interpretation.trim();
    }
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final count = house.objectCount;
    if (count == null) {
      return isRu
          ? 'Расчетный акцент этого дома задан натальной картой.'
          : 'This house emphasis is defined by the calculated chart.';
    }
    if (isRu) {
      return count == 0
          ? 'В расчетной карте нет объектов в этом доме.'
          : 'В расчетной карте в этом доме объектов: $count.';
    }
    return count == 0
        ? 'The calculated chart has no objects in this house.'
        : 'Calculated objects in this house: $count.';
  }
}

class _GeneralInfoSection extends StatelessWidget {
  final String birthDate;
  final String birthTime;
  final String birthPlace;
  final Widget chart;
  final bool approximate;

  const _GeneralInfoSection({
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.chart,
    required this.approximate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.natalGeneralData,
          style: context.textTheme.inversePlayfairSemiBold32.copyWith(
            fontFamily: 'Lora',
            letterSpacing: 0,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        chart,
        if (approximate)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              context.l10n.natalWheelApproximate,
              style: context.textTheme.inverseUrbanistRegular14,
            ),
          ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final items = [
              _GeneralInfoItem(
                title: context.l10n.birthDateLabel,
                value: birthDate,
              ),
              _GeneralInfoItem(
                title: context.l10n.birthTimeLabel,
                value: birthTime,
              ),
              _GeneralInfoItem(
                title: context.l10n.birthPlaceLabel,
                value: birthPlace.split(',').first.trim(),
                valueMaxLines: 1,
              ),
            ];
            final columnWidth = (constraints.maxWidth - 12) / items.length;
            if (columnWidth < MediaQuery.textScalerOf(context).scale(98)) {
              return Column(spacing: 6, children: items);
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 6,
                children: [for (final item in items) Expanded(child: item)],
              ),
            );
          },
        ),
      ]),
    );
  }
}

class _GeneralInfoItem extends StatelessWidget {
  final String title;
  final String value;

  final int? valueMaxLines;

  const _GeneralInfoItem({
    required this.title,
    required this.value,
    this.valueMaxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 8, 6, 8),
      decoration: CardLensDecoration(
        color: _NatalCardColors.figmaPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AsteriaCardRadii.compact),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GeneralInfoTitle(
            title: title,
            style: context.textTheme.tertiaryPlayfairMedium20.copyWith(
              fontFamily: 'Lora',
              letterSpacing: 0,
              color: const Color(0xFFB5AAB8),
              fontSize: 20,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: _NatalCardColors.goldGradient.createShader,
            child: Text(
              value,
              maxLines: valueMaxLines,
              overflow: valueMaxLines == null ? null : TextOverflow.ellipsis,
              style: context.textTheme.urbanistRegular16.copyWith(
                fontFamily: 'Onest',
                color: Colors.white,
                height: 1.2,
                letterSpacing: -0.408,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralInfoTitle extends StatelessWidget {
  final String title;
  final TextStyle style;

  const _GeneralInfoTitle({required this.title, required this.style});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: style);
  }
}

class _PositionsTab extends StatelessWidget {
  final List<NatalCardPlanetDisplayModel> planets;

  const _PositionsTab({super.key, required this.planets});

  @override
  Widget build(BuildContext context) {
    final groups = <_PlanetGroup>[
      _PlanetGroup(
        context.l10n.natalPersonalityFoundation,
        _filterPlanets(planets, const ['sun', 'moon']),
      ),
      _PlanetGroup(
        context.l10n.natalRelationshipsExpression,
        _filterPlanets(planets, const ['venus', 'mars']),
      ),
      _PlanetGroup(
        context.l10n.natalGrowthLife,
        _filterPlanets(planets, const ['jupiter', 'saturn']),
      ),
      _PlanetGroup(
        context.l10n.natalDestinyDepth,
        _filterPlanets(planets, const ['chiron', 'lilith']),
      ),
    ].where((group) => group.planets.isNotEmpty).toList();

    final cardHeight = _PlanetPositionCard.tallestHeight(
      context,
      groups.expand((group) => group.planets),
    );

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.natalMainPositions,
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            fontFamily: 'Lora',
            letterSpacing: 0,
            height: 1,
          ),
        ),
        const SizedBox(height: 16),
        for (final group in groups) ...[
          Text(
            group.title,
            style: context.textTheme.inversePlayfairMedium20.copyWith(
              fontFamily: 'Lora',
              letterSpacing: 0,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: cardHeight,
            child: _PlanetCardsRow(planets: group.planets),
          ),
          const SizedBox(height: 16),
        ],
      ]),
    );
  }

  List<NatalCardPlanetDisplayModel> _filterPlanets(
    List<NatalCardPlanetDisplayModel> planets,
    List<String> codes,
  ) {
    return [
      for (final code in codes)
        for (final planet in planets)
          if (planet.code == code) planet,
    ];
  }
}

class _PlanetGroup {
  final String title;
  final List<NatalCardPlanetDisplayModel> planets;

  const _PlanetGroup(this.title, this.planets);
}

class _PlanetCardsRow extends StatelessWidget {
  final List<NatalCardPlanetDisplayModel> planets;

  const _PlanetCardsRow({required this.planets});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < planets.length; index++) ...[
            _PlanetPositionCard(planet: planets[index]),
            if (index < planets.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _PlanetPositionCard extends StatelessWidget {
  final NatalCardPlanetDisplayModel planet;

  static const _width = 325.0;
  static const _padding = 16.0;
  static const _artSize = 72.0;
  static const _artGap = 10.0;
  static const _textGap = 8.0;

  static TextStyle _titleStyle(BuildContext context) => context
      .textTheme
      .inversePlayfairSemiBold24
      .copyWith(fontFamily: 'Lora', letterSpacing: 0, height: 1);

  static TextStyle _bodyStyle(BuildContext context) => context
      .textTheme
      .inverseUrbanistRegular16
      .copyWith(fontFamily: 'Onest', height: 1.2, letterSpacing: -0.408);

  static double tallestHeight(
    BuildContext context,
    Iterable<NatalCardPlanetDisplayModel> planets,
  ) {
    const textWidth = _width - 2 * _padding - _artSize - _artGap;
    final painter = TextPainter(
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.localeOf(context),
    );
    final defaults = DefaultTextStyle.of(context).style;
    final bold = MediaQuery.boldTextOf(context);
    final boldStyle = bold
        ? const TextStyle(fontWeight: FontWeight.bold)
        : null;
    final title = defaults.merge(_titleStyle(context)).merge(boldStyle);
    final body = defaults.merge(_bodyStyle(context)).merge(boldStyle);
    double measure(String text, TextStyle style) {
      painter.text = TextSpan(text: text, style: style);
      painter.layout(maxWidth: textWidth);
      return painter.height;
    }

    var height = _artSize;
    for (final planet in planets) {
      final textHeight =
          measure(context.l10n.planetName(planet.code), title) +
          _textGap +
          measure(planet.description, body);
      height = math.max(height, textHeight);
    }
    painter.dispose();
    return (height + 2 * _padding).ceilToDouble();
  }

  const _PlanetPositionCard({super.key, required this.planet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      clipBehavior: Clip.antiAlias,
      decoration: CardLensDecoration(
        color: _NatalCardColors.figmaPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
      ),
      padding: const EdgeInsets.all(_padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.planetName(planet.code),
                  style: _titleStyle(context),
                ),
                const SizedBox(height: _textGap),
                Text(planet.description, style: _bodyStyle(context)),
              ],
            ),
          ),
          const SizedBox(width: _artGap),
          Image.asset(
            horoscopeCorePositionAssetFor(planet.code),
            width: _artSize,
            height: _artSize,
            fit: BoxFit.contain,
            frameBuilder: AsteriaEntrance.imageFrame,
            excludeFromSemantics: true,
          ),
        ],
      ),
    );
  }
}

class _HousesTab extends StatelessWidget {
  final List<NatalCardHouseDisplayModel> houses;

  const _HousesTab({super.key, required this.houses});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.natalHousesThemes,
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            fontFamily: 'Lora',
            letterSpacing: 0,
            height: 1,
          ),
        ),
        const SizedBox(height: 16),
        if (houses.length >= 3) ...[
          _HouseThemeCard(
            title: context.l10n.natalStrongHouse(houses[0].houseNumber),
            description: houses[0].description,
          ),
          const SizedBox(height: 16),
          _HouseThemeCard(
            title: context.l10n.natalWeakHouse(houses[1].houseNumber),
            description: houses[1].description,
          ),
          const SizedBox(height: 16),
          _HouseThemeCard(
            title: context.l10n.natalAccentHouse(houses[2].houseNumber),
            description: houses[2].description,
          ),
        ],
      ]),
    );
  }
}

class _HouseThemeCard extends StatelessWidget {
  final String title;
  final String description;

  const _HouseThemeCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: CardLensDecoration(
        color: _NatalCardColors.cardSolid,
        borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 166),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            decoration: const BoxDecoration(
              gradient: _NatalCardColors.purpleGradient,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
            ),
            child: Text(
              title,
              style: AppTypography.h4.copyWith(color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              description,
              style: AppTypography.text1.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ElementsTab extends StatelessWidget {
  final Elements? elements;
  final String elementsDescription;
  final String finalConclusion;

  const _ElementsTab({
    super.key,
    required this.elements,
    required this.elementsDescription,
    required this.finalConclusion,
  });

  @override
  Widget build(BuildContext context) {
    final quantities = [
      (int.tryParse(elements?.fire ?? ''), context.l10n.elementFire),
      (int.tryParse(elements?.water ?? ''), context.l10n.elementWater),
      (int.tryParse(elements?.air ?? ''), context.l10n.elementAir),
      (int.tryParse(elements?.earth ?? ''), context.l10n.elementEarth),
    ];
    final total = quantities.fold<int>(0, (sum, item) => sum + (item.$1 ?? 0));
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.natalElementsModalities,
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            height: 1,
          ),
        ),
        const SizedBox(height: 16),
        if (total > 0 && quantities.every((item) => (item.$1 ?? -1) >= 0)) ...[
          PearlMetricRow(
            metrics: [
              for (final (value, label) in quantities)
                PearlMetric(label, '$value', (value ?? 0) / total),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Text(
          elementsDescription,
          textAlign: TextAlign.center,
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            height: 1.2,
            letterSpacing: -0.408,
          ),
        ),
        const SizedBox(height: 24),
        _MagicConclusionCard(description: finalConclusion),
      ]),
    );
  }
}

class _MagicConclusionCard extends StatelessWidget {
  final String description;

  const _MagicConclusionCard({required this.description});

  static const _backgroundAsset = 'assets/images/home/natal_magic_card.webp';
  static const _imageAsset = 'assets/images/home/natal_magic_image.webp';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 224),
      padding: const EdgeInsets.all(16),
      decoration: CardLensDecoration(
        color: _NatalCardColors.cardSolid,
        borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
        image: const DecorationImage(
          image: AssetImage(_backgroundAsset),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.natalMagicSummary,
            style: context.textTheme.inversePlayfairSemiBold24.copyWith(
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            spacing: 12,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  description,
                  style: context.textTheme.inverseUrbanistRegular16.copyWith(
                    height: 1.2,
                    letterSpacing: -0.408,
                  ),
                ),
              ),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: AspectRatio(
                    aspectRatio: 453 / 680,
                    child: ClipRect(
                      // The artwork occupies the central 60% of its canvas.
                      child: Transform.scale(
                        scale: 1.55,
                        child: Image.asset(
                          _imageAsset,
                          frameBuilder: AsteriaEntrance.imageFrame,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                        ),
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

abstract final class _NatalCardColors {
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
    stops: [0, 0.50032, 1],
  );
  static const Color background = Color(0xFF0F0A1A);
  static const Color figmaPurple = Color(0xFF9A7DB8);
  static const Color cardSolid = Color(0xE60B041C);

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF6E4BFF), Color(0xFF5A3FD1)],
  );
}
