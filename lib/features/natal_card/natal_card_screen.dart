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
import 'package:asteria_app/core/ui_kit/widgets/gradient_circular_progress_painter.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_card_empty_screen.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_card_loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';

class NatalCardScreen extends StatefulWidget {
  const NatalCardScreen({Key? key}) : super(key: key);

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
      body: DecoratedBox(
        decoration: const BoxDecoration(
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
        child: CustomScrollView(
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
                      TextButton(
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
                      const _NatalCardContent(),
                    const SizedBox(height: 100),
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
  const _NatalCardContent({Key? key}) : super(key: key);

  @override
  State<_NatalCardContent> createState() => _NatalCardContentState();
}

class _NatalCardContentState extends State<_NatalCardContent> {
  _NatalCardTab _selectedTab = _NatalCardTab.positions;

  @override
  Widget build(BuildContext context) {
    final userProvider = di.get<UserProvider>();
    final currentUser = userProvider.currentUser;
    final natalCard = currentUser?.natalCard;
    final personalInfo = currentUser?.personalInfo;
    final birthTime = personalInfo?.birthDate?.birthTime;
    final locale = Localizations.localeOf(context);
    final language = locale.languageCode == 'ru' ? 'ru' : 'en';
    final interpretation = natalCard?.tryInterpretationFor(language);
    final planetsHousesData = currentUser?.planetsHousesData;
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
          birthTime: LocaleFormatters.timeOfDay(
            context,
            birthTime == null
                ? const TimeOfDay(hour: 0, minute: 0)
                : TimeOfDay.fromDateTime(birthTime),
          ),
          birthPlace: personalInfo?.birthPlace?.location ?? '',
        ),
        const SizedBox(height: 24),
        _NatalCardSegmentedPicker(
          selectedTab: _selectedTab,
          onChanged: (tab) => setState(() {
            _selectedTab = tab;
          }),
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: switch (_selectedTab) {
            _NatalCardTab.positions => _PositionsTab(
              key: const ValueKey(_NatalCardTab.positions),
              planets: _calculatedPlanetCards(
                context,
                planetsHousesData,
                interpretation,
              ),
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
              elements: planetsHousesData?.elements,
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
    NatalCardInterpretationModel? interpretation,
  ) {
    if (data == null) return const [];
    return [
      for (final position in data.positions)
        NatalCardPlanetDisplayModel(
          code: position.code,
          description: _placementDescription(
            context,
            position,
            interpretation?.planetInterpretations[position.code] ?? '',
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
    String interpretation,
  ) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final sign = position.signCode.isEmpty
        ? position.sign
        : context.l10n.zodiacSignName(position.signCode);
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

  const _GeneralInfoSection({
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.natalGeneralData,
          style: context.textTheme.inversePlayfairSemiBold32.copyWith(
            fontFamily: 'Lora',
            letterSpacing: 0,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 114,
              child: Column(
                children: [
                  _GeneralInfoItem(
                    title: context.l10n.birthDateLabel,
                    value: birthDate,
                  ),
                  const SizedBox(height: 4),
                  _GeneralInfoItem(
                    title: context.l10n.birthTimeLabel,
                    value: birthTime,
                  ),
                  const SizedBox(height: 4),
                  _GeneralInfoItem(
                    title: context.l10n.birthPlaceLabel,
                    value: birthPlace.split(',').first.trim(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Image.asset(
                'assets/images/home/natal_card_banner_wheel.webp',
                fit: BoxFit.contain,
                height: 232,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GeneralInfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _GeneralInfoItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Figma's 114 px card contains a 100 px label starting 8 px from the left.
      padding: const EdgeInsets.fromLTRB(8, 8, 6, 8),
      decoration: BoxDecoration(
        color: _NatalCardColors.figmaPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
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
              height: 0.9,
            ),
          ),
          const SizedBox(height: 4),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: _NatalCardColors.goldGradient.createShader,
            child: Text(
              value,
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

class _NatalCardSegmentedPicker extends StatelessWidget {
  final _NatalCardTab selectedTab;
  final ValueChanged<_NatalCardTab> onChanged;

  const _NatalCardSegmentedPicker({
    required this.selectedTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = _NatalCardTab.values;

    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _NatalCardColors.segmentBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          for (var index = 0; index < tabs.length; index++)
            Expanded(
              child: _NatalCardSegment(
                title: tabs[index].title(context),
                isSelected: selectedTab == tabs[index],
                showSeparator:
                    selectedTab != tabs[index] &&
                    index < tabs.length - 1 &&
                    selectedTab != tabs[index + 1],
                onTap: () => onChanged(tabs[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _NatalCardSegment extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool showSeparator;
  final VoidCallback onTap;

  const _NatalCardSegment({
    required this.title,
    required this.isSelected,
    required this.showSeparator,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 28),
        decoration: BoxDecoration(
          color: isSelected ? _NatalCardColors.selectedSegment : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: AppColors.uiDisabled.withValues(alpha: 0.4),
                  width: 0.5,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 0.5,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showSeparator)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 1,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.uiDisabled.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.urbanistRegular16.copyWith(
                fontFamily: 'Onest',
                color: isSelected
                    ? _NatalCardColors.gold
                    : AppColors.textTertiary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                height: 1.2,
                letterSpacing: -0.08,
              ),
            ),
          ],
        ),
      ),
    );
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

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          _PlanetCardsRow(planets: group.planets),
          const SizedBox(height: 16),
        ],
      ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

  const _PlanetPositionCard({required this.planet});

  @override
  Widget build(BuildContext context) {
    final imageCrop = _PlanetImageCrop.forCode(planet.code);

    return Container(
      width: 325,
      constraints: const BoxConstraints(minHeight: 104),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _NatalCardColors.figmaPurple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: SizedBox(
                width: 99,
                height: 104,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    maxWidth: imageCrop.width,
                    maxHeight: imageCrop.height,
                    child: Transform.translate(
                      offset: imageCrop.offset,
                      child: Image.asset(
                        imageCrop.assetPath,
                        width: imageCrop.width,
                        height: imageCrop.height,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 202,
                  child: Text(
                    context.l10n.planetName(planet.code),
                    style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                      fontFamily: 'Lora',
                      letterSpacing: 0,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 210,
                  child: Text(
                    planet.description,
                    style: context.textTheme.inverseUrbanistRegular16.copyWith(
                      fontFamily: 'Onest',
                      height: 1.2,
                      letterSpacing: -0.408,
                    ),
                  ),
                ),
              ],
            ),
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
      children: [
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
      ],
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
      decoration: BoxDecoration(
        color: _NatalCardColors.cardSolid,
        borderRadius: BorderRadius.circular(16),
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
              style: context.textTheme.inverseUrbanistSemiBold16.copyWith(
                fontFamily: 'Onest',
                height: 1.2,
                letterSpacing: -0.408,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              description,
              style: context.textTheme.inversePlayfairMedium20.copyWith(
                fontFamily: 'Lora',
                letterSpacing: 0,
                height: 1.1,
              ),
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
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.natalElementsModalities,
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            height: 1,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth / 4).clamp(64.0, 76.0);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ElementMetric(
                  width: itemWidth,
                  value: _elementValue(elements?.fire),
                  label: context.l10n.elementFire,
                ),
                _ElementMetric(
                  width: itemWidth,
                  value: _elementValue(elements?.water),
                  label: context.l10n.elementWater,
                ),
                _ElementMetric(
                  width: itemWidth,
                  value: _elementValue(elements?.air),
                  label: context.l10n.elementAir,
                ),
                _ElementMetric(
                  width: itemWidth,
                  value: _elementValue(elements?.earth),
                  label: context.l10n.elementEarth,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
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
      ],
    );
  }

  int _elementValue(String? value) {
    return int.tryParse(value ?? '') ?? 0;
  }
}

class _ElementMetric extends StatelessWidget {
  final double width;
  final int value;
  final String label;

  const _ElementMetric({
    required this.width,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final circleSize = width.clamp(64.0, 71.0);
    final innerSize = circleSize - 17;

    return SizedBox(
      width: width,
      child: Column(
        children: [
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.36),
                    shape: BoxShape.circle,
                  ),
                ),
                CustomPaint(
                  size: Size.square(circleSize),
                  painter: GradientCircularProgressPainter(
                    progress: (value / 8).clamp(0.0, 1.0),
                    strokeWidth: circleSize >= 70 ? 9 : 8,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _NatalCardColors.goldLight,
                        Color(0xFF8A6BFF),
                        Color(0xFF5A3FD1),
                      ],
                    ),
                  ),
                ),
                Text(
                  '$value',
                  style: context.textTheme.inversePlayfairMedium20.copyWith(
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.inverseUrbanistSemiBold16.copyWith(
              height: 1.2,
              letterSpacing: -0.408,
            ),
          ),
        ],
      ),
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
      decoration: BoxDecoration(
        color: _NatalCardColors.cardSolid,
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage(_backgroundAsset),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: ClipRect(
                child: SizedBox(
                  width: 78,
                  height: 192,
                  child: Image.asset(
                    _imageAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 94),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.natalMagicSummary,
                  style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                    height: 1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: context.textTheme.inverseUrbanistRegular16.copyWith(
                    height: 1.2,
                    letterSpacing: -0.408,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanetImageCrop {
  final String assetPath;
  final double width;
  final double height;
  final Offset offset;

  const _PlanetImageCrop({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.offset,
  });

  static const _sun = _PlanetImageCrop(
    assetPath: 'assets/images/home/natal_card_position_sun.webp',
    width: 181,
    height: 272,
    offset: Offset(-28, -87),
  );

  static const _venus = _PlanetImageCrop(
    assetPath: 'assets/images/home/natal_card_position_venus.webp',
    width: 172,
    height: 258,
    offset: Offset(-24, -79),
  );

  static const _jupiter = _PlanetImageCrop(
    assetPath: 'assets/images/home/natal_card_position_jupiter.webp',
    width: 169,
    height: 254,
    offset: Offset(-25, -77),
  );

  static const _chiron = _PlanetImageCrop(
    assetPath: 'assets/images/home/natal_card_position_chiron.webp',
    width: 172,
    height: 258,
    offset: Offset(-25, -78),
  );

  static _PlanetImageCrop forCode(String code) {
    return switch (code) {
      'mars' => _venus,
      'venus' => _venus,
      'saturn' => _jupiter,
      'jupiter' => _jupiter,
      'lilith' => _chiron,
      'chiron' => _chiron,
      _ => _sun,
    };
  }
}

abstract final class _NatalCardColors {
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
    stops: [0, 0.50032, 1],
  );
  static const Color background = Color(0xFF0F0A1A);
  static const Color figmaPurple = Color(0xFF9A7DB8);
  static const Color gold = Color(0xFFF3B76A);
  static const Color goldLight = Color(0xFFFFD28A);
  static const Color segmentBackground = Color(0xCC0A0615);
  static const Color selectedSegment = Color(0xB8140C15);
  static const Color cardSolid = Color(0xE60B041C);

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF6E4BFF), Color(0xFF5A3FD1)],
  );
}
