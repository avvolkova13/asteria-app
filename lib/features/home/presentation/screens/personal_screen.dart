import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'dart:math' as math;
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';

import 'package:asteria_app/app/data/entities/zodiac_info_entity.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_day_model.dart';
import 'package:asteria_app/app/data/models/horoscope/horoscope_shared_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_route_observer.dart';
import 'package:asteria_app/core/analytics/dictionaries/funnel_type.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/extensions/string_extensions.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_request_helper.dart';
import 'package:asteria_app/features/compatibility/presentation/provider/compatibility_provider.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_state.dart';
import 'package:asteria_app/features/home/presentation/widgets/card_advertisement_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _pageBackground = Color(0xFF090612);
const _cardTint = Color(0x339A7DB8);
const _selectedTabBackground = Color(0xFF171026);
const _accentPurple = Color(0xFF6E4BFF);
const _accentPurpleDark = Color(0xFF5A3FD1);
const _goldGradient = LinearGradient(
  colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
);
const _buttonGradient = LinearGradient(
  colors: [_accentPurple, Color(0xFF8A6BFF), _accentPurpleDark],
);
const _forecastButtonGradient = LinearGradient(
  colors: [_accentPurple, _accentPurpleDark],
);
const _personalBackgroundImage =
    'assets/images/home/personal_horoscope_background.webp';
const _dayLoveRelationshipsImage =
    'assets/images/home/personal_day_love_relationships.webp';
const _dayWeaknessImage = 'assets/images/home/personal_day_weakness.webp';
const _weekForecastImage =
    'assets/images/home/personal_horoscope_week_unlock.webp';
const _monthForecastImage =
    'assets/images/home/personal_horoscope_month_unlock.webp';
const _weekBalanceHarmonyImage =
    'assets/images/home/personal_week_balance_harmony.webp';
const _weekLoveRelationshipsImage =
    'assets/images/home/personal_week_love_relationships.webp';
const _weekFinancialStabilityImage =
    'assets/images/home/personal_week_financial_stability.webp';
const _monthKeyTopicsBackground =
    'assets/images/home/personal_month_key_topics_bg.webp';
const _monthKeyTopicsSpiral =
    'assets/images/home/personal_month_key_topics_spiral.webp';
const _compatibilityBackgroundImage =
    'assets/images/home/compatibility_background.webp';
const _compatibilityVector51 = 'assets/icons/compatibility_vector_51.svg';
const _compatibilityVector52 = 'assets/icons/compatibility_vector_52.svg';

/// Экран гороскопа
class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  int _selectedTabIndex = 0;
  bool _hasTrackedPersonalCardViews = false;
  AnalyticsRouteObserver? _routeObserver;
  bool _analyticsScheduled = false;
  String? _lastContentLanguage;

  @override
  void initState() {
    super.initState();
    if (di.isRegistered<AnalyticsRouteObserver>()) {
      _routeObserver = di.get<AnalyticsRouteObserver>()
        ..addListener(_scheduleVisibleAnalytics);
    }
    _scheduleVisibleAnalytics();
  }

  void _scheduleVisibleAnalytics() {
    if (!mounted || _analyticsScheduled) return;
    _analyticsScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analyticsScheduled = false;
      if (!mounted) return;
      _trackPersonalCardViewsOnce();
    });
  }

  @override
  void dispose() {
    _routeObserver?.removeListener(_scheduleVisibleAnalytics);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (_lastContentLanguage == language) return;
    _lastContentLanguage = language;
  }

  void _onHoroscopePressed() {
    HoroscopeRoute.push(context);
  }

  void _onNatalCardPressed() {
    di.get<ProductAnalyticsService>().trackHomeCardClick(
      funnelType: FunnelType.natalChart,
      entryPointId: 'home_natal_card',
      position: 0,
      ctaName: 'open_natal_chart',
    );
    NatalCardRoute.push(context);
  }

  void _trackPersonalCardViewsOnce() {
    if (_hasTrackedPersonalCardViews ||
        _routeObserver?.visibleScreen != '/home/personal' ||
        ModalRoute.of(context)?.isCurrent != true) {
      return;
    }

    _hasTrackedPersonalCardViews = true;
    final analytics = di.get<ProductAnalyticsService>();
    analytics.trackHomeCardView(
      funnelType: FunnelType.natalChart,
      entryPointId: 'home_natal_card',
      position: 0,
    );
    analytics.trackHomeCardView(
      funnelType: FunnelType.compatibility,
      entryPointId: 'home_compatibility_card',
      position: 1,
    );
  }

  Future<void> _onCompatibilityPressed() async {
    di.get<ProductAnalyticsService>().trackHomeCardClick(
      funnelType: FunnelType.compatibility,
      entryPointId: 'home_compatibility_card',
      position: 1,
      ctaName: 'open_compatibility',
    );
    if (di.get<CompatibilityProvider>().selectedCompatibility != null) {
      CreateCompatibilityLoadedRoute.push(context);
    } else {
      CreateCompatibilityInitialRoute.push(context);
    }
  }

  Future<void> _onBuyHoroscopePressed(HoroscopeTypeEnum horoscopeType) async {
    di.get<GlobalLoaderService>().show();
    try {
      switch (horoscopeType) {
        case HoroscopeTypeEnum.day:
          await di.get<ContentProvider>().buyHoroscope(HoroscopeTypeEnum.day);
          break;
        case HoroscopeTypeEnum.week:
          await di.get<ContentProvider>().buyHoroscope(HoroscopeTypeEnum.week);
          break;
        case HoroscopeTypeEnum.month:
          await di.get<ContentProvider>().buyHoroscope(HoroscopeTypeEnum.month);
          break;
        case HoroscopeTypeEnum.year:
          break;
      }
    } catch (e) {
      debugPrint('Ошибка покупки гороскопа: $e');
    } finally {
      di.get<GlobalLoaderService>().hide();
    }
  }

  void _showPurchaseModalSheet(HoroscopeTypeEnum horoscopeType) {
    showFeaturePurchaseModal(
      context: context,
      builder: (context) => SharedPurchaseModal(
        featureKey: switch (horoscopeType) {
          HoroscopeTypeEnum.week => 'weekly_horoscope',
          HoroscopeTypeEnum.month => 'monthly_horoscope',
          HoroscopeTypeEnum.year => 'yearly_personal_horoscope',
          HoroscopeTypeEnum.day => null,
        },
        purchaseTitle: switch (horoscopeType) {
          HoroscopeTypeEnum.day => context.l10n.purchaseDayHoroscope,
          HoroscopeTypeEnum.week => context.l10n.purchaseWeekHoroscope,
          HoroscopeTypeEnum.month => context.l10n.purchaseMonthHoroscope,
          _ => context.l10n.purchaseYearHoroscope,
        },
        price: horoscopeType.price,
        originSurface: 'moon',
        offerType: OfferType.oneOffUnlock,
        onAccessPurchase: (requirePro, _) => di
            .get<ContentProvider>()
            .buyHoroscope(horoscopeType, requirePro: requirePro),
      ),
    );
  }

  String _natalCardDescription(UserProvider userProvider) {
    final natalCard = userProvider.currentUser?.natalCard;
    final language = Localizations.localeOf(context).languageCode;
    if (natalCard != null && natalCard.hasLanguage(language)) {
      final personality = natalCard.interpretationFor(language).personality;
      if (personality.isEmpty) return context.l10n.personalDefaultDescription;
      return personality;
    }

    return context.l10n.personalDefaultDescription;
  }

  bool _isLocalizedHoroscope(Object? json) {
    return isAiContentLocalized(
      json,
      Localizations.localeOf(context).languageCode,
    );
  }

  Widget _localizedContentPlaceholder() {
    return _LockedPeriodCard(
      title: context.l10n.contentTranslationUnavailable,
      description: context.l10n.genericCheckConnection,
      buttonText: context.l10n.commonRetry,
      onPressed: () => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = di.get<UserProvider>();
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (_, current) =>
          current is HomeLoaded && current.currentTabIndex == 1,
      listener: (_, __) => _scheduleVisibleAnalytics(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: _pageBackground,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: _pageBackground,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    const Positioned.fill(child: _PersonalBackground()),
                    Column(
                      children: [
                        const SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: HomeAccountBar(
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ).withEntrance(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListenableBuilder(
                            listenable: userProvider,
                            builder: (context, _) =>
                                _buildContent(context, userProvider),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserProvider userProvider) {
    final locale = Localizations.localeOf(context);
    final birthDate =
        userProvider.currentUser?.personalInfo?.birthDate?.birthDate ??
        DateTime.now();
    final zodiacInfo = ZodiacInfoEntity(
      zodiacAsset: birthDate.getZodiacSignAsset(),
      birthDate: birthDate,
      elementString: birthDate.getElement(languageCode: locale.languageCode),
      planetString: birthDate.getPlanet(languageCode: locale.languageCode),
      characterString: birthDate.getCharacter(
        languageCode: locale.languageCode,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.personalYourHoroscope,
          style: context.textTheme.inversePlayfairSemiBold32.copyWith(
            height: 1.2,
          ),
        ).withEntrance(),
        const SizedBox(height: 14),
        _ZodiacInfoCards(zodiacInfo: zodiacInfo).withEntrance(),
        const SizedBox(height: 24),
        _PersonalSegmentedPicker(
          selectedIndex: _selectedTabIndex,
          onSelected: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ).withEntrance(),
        const SizedBox(height: 16),
        KeyedSubtree(
          key: ValueKey(_selectedTabIndex),
          child: _buildTabContent(
            _buildTodayContent(context, userProvider),
            _buildWeekContent(context, userProvider),
            _buildMonthContent(context, userProvider),
          ),
        ),
        const SizedBox(height: 16),
        _PersonalGradientButton(
          text: context.l10n.personalYearForecast,
          onPressed: _onHoroscopePressed,
        ).withEntrance(),
        const SizedBox(height: 24),
        CardAdvertisementWidget(
          horizontalMargin: 0,
          variant: CardAdvertisementVariant.natalCardBanner,
          title: context.l10n.natalChartTitle,
          description: _natalCardDescription(userProvider),
          buttonText: context.l10n.personalOpenChart,
          onPressed: _onNatalCardPressed,
        ).withEntrance(),
        const SizedBox(height: 24),
        _PersonalCompatibilitySection(
          onPressed: _onCompatibilityPressed,
        ).withEntrance(),
        const SizedBox(height: 124),
      ],
    );
  }

  Widget _buildTodayContent(BuildContext context, UserProvider userProvider) {
    final day = userProvider.currentUser?.horoscopeDay;
    if (!userProvider.showHoroscope(HoroscopeTypeEnum.day)) {
      return _LockedPeriodCard(
        title: context.l10n.personalOpenForecast,
        description: context.l10n.personalTodayFree,
        buttonText: context.l10n.personalOpenFree,
        onPressed: () => _onBuyHoroscopePressed(HoroscopeTypeEnum.day),
      );
    }
    if (!_isLocalizedHoroscope(day?.toJson())) {
      return _localizedContentPlaceholder();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.personalImpactAreas,
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            height: 1,
          ),
        ),
        const SizedBox(height: 12),
        _HoroscopeImpactMetrics(
          lovePercentage: day?.loveAreaPercentage ?? '0%',
          financesPercentage: day?.financeAreaPercentage ?? '0%',
          energyPercentage: day?.personalAreaPercentage ?? '0%',
        ),
        const SizedBox(height: 18),
        Text(
          context.l10n.personalAdviceDay,
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        _GradientText(
          day?.spotlight ?? '',
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            height: 1.2,
            letterSpacing: -0.408,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${day?.focus ?? ''} ${day?.risk ?? ''}'.trim(),
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            height: 1.2,
            letterSpacing: -0.408,
          ),
        ),
        if (day != null) ...[
          const SizedBox(height: 18),
          AsteriaEntrance(child: _buildDayKeyThemeContent(context, day)),
          const SizedBox(height: 12),
          AsteriaEntrance(child: _buildDayWeaknessesContent(context, day)),
        ],
      ]),
    );
  }

  Widget _buildDayKeyThemeContent(BuildContext context, HoroscopeDayModel day) {
    return _DailyAddonCard(
      label: context.l10n.personalLoveRelationships,
      imageAsset: _dayLoveRelationshipsImage,
      imageKey: const ValueKey('personal-day-love-image'),
      panelKey: const ValueKey('personal-day-love-panel'),
      description: day.loveArea.description,
    );
  }

  Widget _buildDayWeaknessesContent(
    BuildContext context,
    HoroscopeDayModel day,
  ) {
    final points = <HoroscopeWeakPointModel>[
      ...day.personalWeakPoints,
      ...day.loveWeakPoints,
      ...day.financeWeakPoints,
    ];
    final point = points.firstWhere(
      (point) => point.title.isNotEmpty || point.description.isNotEmpty,
      orElse: () => const HoroscopeWeakPointModel(title: '', description: ''),
    );

    return _DailyAddonCard(
      label: context.l10n.horoscopeWeakPoints.split('\n').first,
      imageAsset: _dayWeaknessImage,
      imageKey: const ValueKey('personal-day-weakness-image'),
      panelKey: const ValueKey('personal-day-weakness-panel'),
      title: point.title,
      description: point.description,
    );
  }

  Widget _buildWeekContent(BuildContext context, UserProvider userProvider) {
    final week = userProvider.currentUser?.horoscopeWeek;
    if (!userProvider.showHoroscope(HoroscopeTypeEnum.week)) {
      return _ForecastUnlockBanner(
        title: context.l10n.personalForecastPrice(HoroscopeTypeEnum.week.price),
        description: context.l10n.personalWeekPurchaseDescription,
        imageAsset: _weekForecastImage,
        onPressed: () => _showPurchaseModalSheet(HoroscopeTypeEnum.week),
      );
    }
    if (!_isLocalizedHoroscope(week?.toJson())) {
      return _localizedContentPlaceholder();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.personalImpactAreas,
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        _HoroscopeImpactMetrics(
          lovePercentage: week?.loveAreaPercentage ?? '0%',
          financesPercentage: week?.financeAreaPercentage ?? '0%',
          energyPercentage: week?.personalAreaPercentage ?? '0%',
        ),
        const SizedBox(height: 16),
        _WeeklyAdviceBlock(description: week?.advice ?? ''),
        const SizedBox(height: 16),
        _WeeklyAreaCardsRail(
          cards: [
            _WeeklyAreaCardData(
              title: context.l10n.personalHarmony,
              description: week?.personalArea.description ?? '',
              imageAsset: _weekBalanceHarmonyImage,
            ),
            _WeeklyAreaCardData(
              title: context.l10n.personalLoveRelationships,
              description: week?.loveArea.description ?? '',
              imageAsset: _weekLoveRelationshipsImage,
            ),
            _WeeklyAreaCardData(
              title: context.l10n.personalFinancialStability,
              description: week?.financeArea.description ?? '',
              imageAsset: _weekFinancialStabilityImage,
            ),
          ],
        ),
      ]),
    );
  }

  Widget _buildMonthContent(BuildContext context, UserProvider userProvider) {
    final month = userProvider.currentUser?.horoscopeMonth;
    if (!userProvider.showHoroscope(HoroscopeTypeEnum.month)) {
      return _ForecastUnlockBanner(
        title: context.l10n.personalForecastPrice(
          HoroscopeTypeEnum.month.price,
        ),
        description: context.l10n.personalMonthPurchaseDescription,
        imageAsset: _monthForecastImage,
        onPressed: () => _showPurchaseModalSheet(HoroscopeTypeEnum.month),
      );
    }
    if (!_isLocalizedHoroscope(month?.toJson())) {
      return _localizedContentPlaceholder();
    }

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: AppColors.white,
          displayColor: AppColors.white,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AsteriaEntrance.sections([
          _MonthFavourablePeriodsBlock(
            items: [
              _MonthPeriodData(
                dates: month?.periods.bestDaysForWork.dates ?? '',
                text: month?.periods.bestDaysForWork.text ?? '',
              ),
              _MonthPeriodData(
                dates: month?.periods.bestDaysForSelfFocus.dates ?? '',
                text: month?.periods.bestDaysForSelfFocus.text ?? '',
              ),
              _MonthPeriodData(
                dates: month?.periods.bestDaysForRelationships.dates ?? '',
                text: month?.periods.bestDaysForRelationships.text ?? '',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MonthAdviceBlock(description: month?.advice ?? ''),
          const SizedBox(height: 16),
          _MonthKeyTopicsCard(description: month?.keyTopic ?? ''),
        ]),
      ),
    );
  }

  Widget _buildTabContent(
    Widget childToday,
    Widget childWeek,
    Widget childMonth,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return childToday;
      case 1:
        return childWeek;
      case 2:
        return childMonth;
      default:
        return const SizedBox.shrink();
    }
  }
}

class _PersonalBackground extends StatelessWidget {
  const _PersonalBackground();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _pageBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 168,
            left: 0,
            right: 0,
            height: 453,
            child: ClipRect(
              child: Opacity(
                opacity: 0.35,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final imageHeight = constraints.maxWidth * (1846 / 852);
                    return Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Positioned(
                          top: -(453 * 0.0717),
                          left: 0,
                          right: 0,
                          height: imageHeight,
                          child: Image.asset(
                            _personalBackgroundImage,
                            key: const ValueKey(
                              'personal-horoscope-background-art',
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 273,
            child: DecoratedBox(
              key: ValueKey('personal-horoscope-background-top-gradient'),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F0A1A),
                    Color(0xFF210746),
                    Color(0x001D0F3F),
                  ],
                  stops: [0, 0.61303, 1],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 348,
            left: 0,
            right: 0,
            height: 273,
            child: DecoratedBox(
              key: ValueKey('personal-horoscope-background-bottom-gradient'),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFF0F0A1A),
                    Color(0xFF210746),
                    Color(0x001D0F3F),
                  ],
                  stops: [0, 0.61303, 1],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZodiacInfoCards extends StatelessWidget {
  final ZodiacInfoEntity zodiacInfo;

  const _ZodiacInfoCards({required this.zodiacInfo});

  @override
  Widget build(BuildContext context) {
    final attributes = [
      (context.l10n.personalElement, zodiacInfo.elementString),
      (context.l10n.personalPlanet, zodiacInfo.planetString),
      (context.l10n.personalCharacter, zodiacInfo.characterString),
    ];
    final titleStyle = context.textTheme.tertiaryPlayfairMedium20.copyWith(
      height: 1.1,
    );
    final valueStyle = context.textTheme.inverseUrbanistRegular16.copyWith(
      height: 1.2,
      letterSpacing: -0.408,
    );
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ConstellationCard(assetName: zodiacInfo.zodiacAsset),
              ),
              const SizedBox(width: 8),
              Expanded(child: _ZodiacSignCard(birthDate: zodiacInfo.birthDate)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _FittingTileRow(
          gap: 8,
          minTileWidth:
              attributes
                  .map(
                    (attribute) => math.max(
                      _labelWidth(context, attribute.$1, titleStyle),
                      _labelWidth(context, attribute.$2, valueStyle),
                    ),
                  )
                  .reduce(math.max) +
              10, // 4 pt padding and 1 pt border per edge.
          children: [
            for (final (title, value) in attributes)
              _ZodiacAttributeCard(
                title: title,
                value: value,
                titleStyle: titleStyle,
                valueStyle: valueStyle,
              ),
          ],
        ),
      ],
    );
  }
}

double _labelWidth(BuildContext context, String label, TextStyle style) {
  return TextPainter.computeWidth(
    text: TextSpan(
      text: label,
      style: DefaultTextStyle.of(context).style.merge(style),
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    locale: Localizations.localeOf(context),
  ).ceilToDouble();
}

/// Keeps equal-width tiles together only while their labels fit in full.
class _FittingTileRow extends StatelessWidget {
  const _FittingTileRow({
    required this.minTileWidth,
    required this.children,
    this.gap = 0,
    this.useIntermediateColumns = true,
  });

  final double minTileWidth;
  final double gap;
  final bool useIntermediateColumns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final capacity = ((constraints.maxWidth + gap) / (minTileWidth + gap))
            .floor()
            .clamp(1, children.length);
        final columns = useIntermediateColumns || capacity == children.length
            ? capacity
            : 1;
        return Column(
          children: [
            for (var start = 0; start < children.length; start += columns) ...[
              if (start > 0) SizedBox(height: gap),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (
                      var i = start;
                      i < math.min(start + columns, children.length);
                      i++
                    ) ...[
                      if (i > start) SizedBox(width: gap),
                      Expanded(child: children[i]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ConstellationCard extends StatelessWidget {
  final String assetName;

  const _ConstellationCard({required this.assetName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 67,
      clipBehavior: Clip.antiAlias,
      decoration: CardLensDecoration(
        color: _cardTint,
        borderRadius: BorderRadius.circular(AsteriaCardRadii.compact),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Image.asset(
          'assets/images/zodiacs/constellation_foreground/$assetName.webp',
          fit: BoxFit.contain,
          alignment: Alignment.center,
          opacity: const AlwaysStoppedAnimation<double>(0.92),
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _ZodiacSignCard extends StatelessWidget {
  final DateTime birthDate;

  const _ZodiacSignCard({required this.birthDate});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 67),
      padding: const EdgeInsets.all(4),
      decoration: _zodiacCardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GradientText(
            birthDate.getZodiacSignName(languageCode: locale.languageCode),
            textAlign: TextAlign.center,
            style: context.textTheme.inversePlayfairSemiBold24.copyWith(
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            birthDate.toLocalizedDate(locale),
            textAlign: TextAlign.center,
            style: context.textTheme.inverseUrbanistRegular16.copyWith(
              height: 1.2,
              letterSpacing: -0.408,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZodiacAttributeCard extends StatelessWidget {
  final String title;
  final String value;

  final TextStyle titleStyle;
  final TextStyle valueStyle;

  const _ZodiacAttributeCard({
    required this.title,
    required this.value,
    required this.titleStyle,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 67),
      padding: const EdgeInsets.all(4),
      decoration: _zodiacCardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, textAlign: TextAlign.center, style: titleStyle),
          const SizedBox(height: 4),
          Text(value, textAlign: TextAlign.center, style: valueStyle),
        ],
      ),
    );
  }
}

final _zodiacCardDecoration = CardLensDecoration(
  color: _cardTint,
  borderRadius: BorderRadius.circular(AsteriaCardRadii.compact),
  border: Border.all(color: AppColors.white.withValues(alpha: 0.18)),
);

class _PersonalSegmentedPicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _PersonalSegmentedPicker({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final labels = [
      context.l10n.personalTodayTab,
      context.l10n.personalWeekTab,
      context.l10n.personalMonthTab,
    ];
    final labelStyle = context.textTheme.urbanistSemiBold12.copyWith(
      fontSize: 13,
      height: 1.2,
      letterSpacing: -0.08,
    );
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _selectedTabBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _FittingTileRow(
        useIntermediateColumns: false,
        minTileWidth:
            labels
                .map((label) => _labelWidth(context, label, labelStyle))
                .reduce(math.max) +
            14, // 6 pt padding and 1 pt selected border per edge.
        children: [
          for (var index = 0; index < labels.length; index++)
            _SegmentedOption(
              label: labels[index],
              isSelected: selectedIndex == index,
              onTap: () => onSelected(index),
            ),
        ],
      ),
    );
  }
}

class _SegmentedOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentedOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style:
          (isSelected
                  ? context.textTheme.urbanistSemiBold12
                  : context.textTheme.tertiaryUrbanistRegular12)
              .copyWith(fontSize: 13, height: 1.2, letterSpacing: -0.08),
    );

    return Semantics(
      button: true,
      selected: isSelected,
      child: LotusTap(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white.withValues(alpha: 0.08) : null,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: AppColors.white.withValues(alpha: 0.12))
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: isSelected
                ? _GradientText(
                    label,
                    style: text.style!,
                    textAlign: TextAlign.center,
                  )
                : text,
          ),
        ),
      ),
    );
  }
}

class _HoroscopeImpactMetrics extends StatelessWidget {
  final String lovePercentage;
  final String financesPercentage;
  final String energyPercentage;

  const _HoroscopeImpactMetrics({
    required this.lovePercentage,
    required this.financesPercentage,
    required this.energyPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ImpactMetric(
          percentage: lovePercentage,
          label: context.l10n.personalLove,
          metricId: 'love',
        ),
        _ImpactMetric(
          percentage: financesPercentage,
          label: context.l10n.personalFinances,
          metricId: 'finances',
        ),
        _ImpactMetric(
          percentage: energyPercentage,
          label: context.l10n.personalEnergy,
          metricId: 'energy',
        ),
      ],
    );
  }
}

class _ImpactMetric extends StatelessWidget {
  final String percentage;
  final String label;
  final String metricId;

  const _ImpactMetric({
    required this.percentage,
    required this.label,
    required this.metricId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75,
      child: Column(
        children: [
          SizedBox(
            width: 71,
            height: 71,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  key: ValueKey('personal-impact-ring-$metricId'),
                  size: const Size.square(71),
                  painter: _PersonalImpactRingPainter(
                    progress: _progressValue(percentage),
                  ),
                ),
                Text(
                  percentage,
                  textAlign: TextAlign.center,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  double _progressValue(String value) {
    final parsed = double.tryParse(value.replaceAll('%', '').trim()) ?? 0;
    return (parsed / 100).clamp(0, 1);
  }
}

class _PersonalImpactRingPainter extends CustomPainter {
  static const _backgroundDiameter = 62.125;
  static const _outerRadius = 35.5;
  static const _innerRadius = 24.85;

  final double progress;

  const _PersonalImpactRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final backgroundRect = Rect.fromCenter(
      center: center,
      width: _backgroundDiameter,
      height: _backgroundDiameter,
    );
    final backgroundGradient = const LinearGradient(
      colors: [Color(0x33E6994D), Color(0x33F3B76A), Color(0x33E6994D)],
      stops: [0, 0.500323, 1],
    );

    canvas.drawOval(
      backgroundRect,
      Paint()..shader = backgroundGradient.createShader(backgroundRect),
    );
    canvas.drawOval(
      backgroundRect,
      Paint()
        ..color = const Color(0x33EEEAFD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    if (progress <= 0) {
      return;
    }

    final sweepAngle = math.pi * 2 * progress;
    final segment = _buildSegment(
      center: center,
      startAngle: -math.pi / 2,
      sweepAngle: sweepAngle,
    );
    final ringRect = Rect.fromCircle(center: center, radius: _outerRadius);
    final activeGradient = const LinearGradient(
      colors: [Color(0xFFF3B76A), Color(0xFF8A6BFF), Color(0xFF5A3FD1)],
      stops: [0, 0.500323, 1],
    );

    canvas.drawPath(
      segment,
      Paint()..shader = activeGradient.createShader(ringRect),
    );

    canvas.save();
    canvas.clipPath(segment);
    canvas.translate(0, 4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: _innerRadius),
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.butt
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.restore();
  }

  Path _buildSegment({
    required Offset center,
    required double startAngle,
    required double sweepAngle,
  }) {
    final outerRect = Rect.fromCircle(center: center, radius: _outerRadius);
    final innerRect = Rect.fromCircle(center: center, radius: _innerRadius);
    if (sweepAngle >= math.pi * 2) {
      return Path()
        ..fillType = PathFillType.evenOdd
        ..addOval(outerRect)
        ..addOval(innerRect);
    }

    final endAngle = startAngle + sweepAngle;
    final outerStart =
        center +
        Offset(
          math.cos(startAngle) * _outerRadius,
          math.sin(startAngle) * _outerRadius,
        );
    final innerEnd =
        center +
        Offset(
          math.cos(endAngle) * _innerRadius,
          math.sin(endAngle) * _innerRadius,
        );

    return Path()
      ..moveTo(outerStart.dx, outerStart.dy)
      ..arcTo(outerRect, startAngle, sweepAngle, false)
      ..lineTo(innerEnd.dx, innerEnd.dy)
      ..arcTo(innerRect, endAngle, -sweepAngle, false)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _PersonalImpactRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _DailyAddonCard extends StatelessWidget {
  final String label;
  final String imageAsset;
  final Key imageKey;
  final Key panelKey;
  final String? title;
  final String description;

  const _DailyAddonCard({
    required this.label,
    required this.imageAsset,
    required this.imageKey,
    required this.panelKey,
    required this.description,
    this.title,
  });

  bool get _isWeakness => imageAsset == _dayWeaknessImage;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 129),
        padding: const EdgeInsets.all(8),
        decoration: CardLensDecoration(
          color: _cardTint,
          borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _isWeakness
                ? Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      key: panelKey,
                      width: 112,
                      height: 112,
                      child: _DailyAddonPanel(
                        label: label,
                        imageAsset: imageAsset,
                        imageKey: imageKey,
                        isWeakness: _isWeakness,
                      ),
                    ),
                  )
                : SizedBox(
                    key: panelKey,
                    width: 112,
                    child: _DailyAddonPanel(
                      label: label,
                      imageAsset: imageAsset,
                      imageKey: imageKey,
                      isWeakness: _isWeakness,
                    ),
                  ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: title?.isNotEmpty == true ? 4 : 0,
                ),
                child: Column(
                  mainAxisAlignment: title?.isNotEmpty == true
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title?.isNotEmpty == true) ...[
                      Text(
                        title!,
                        style: context.textTheme.inversePlayfairMedium20
                            .copyWith(height: 1.1),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      description,
                      style: context.textTheme.inverseUrbanistRegular16
                          .copyWith(height: 1.2, letterSpacing: -0.408),
                    ),
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

class _DailyAddonPanel extends StatelessWidget {
  final String label;
  final String imageAsset;
  final Key imageKey;
  final bool isWeakness;

  const _DailyAddonPanel({
    required this.label,
    required this.imageAsset,
    required this.imageKey,
    required this.isWeakness,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: CardLensDecoration(
        color: const Color(0x8021183D),
        borderRadius: BorderRadius.circular(AsteriaCardRadii.compact),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _DailyAddonImage(
              asset: imageAsset,
              imageKey: imageKey,
              isWeakness: isWeakness,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.inverseUrbanistMedium14.copyWith(
                height: 0.9,
                letterSpacing: -0.41,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyAddonImage extends StatelessWidget {
  final String asset;
  final Key imageKey;
  final bool isWeakness;

  const _DailyAddonImage({
    required this.asset,
    required this.imageKey,
    required this.isWeakness,
  });

  @override
  Widget build(BuildContext context) {
    final frameSize = isWeakness ? const Size(66, 65) : const Size(80, 75.45);
    return Image.asset(
      asset,
      key: imageKey,
      width: frameSize.width,
      height: frameSize.height,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}

class _PersonalGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _PersonalGradientButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return LotusFeedback(
      onActivate: onPressed,
      builder: (activate) => Semantics(
        button: true,
        label: text,
        onTap: activate,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: _buttonGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: activate,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textTheme.inverseUrbanistRegular16.copyWith(
                      height: 1.2,
                      letterSpacing: -0.408,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LockedPeriodCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onPressed;

  const _LockedPeriodCard({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _DarkContentCard(
      title: title,
      description: description,
      footer: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _PersonalGradientButton(text: buttonText, onPressed: onPressed),
      ),
    ).withEntrance();
  }
}

class _WeeklyAdviceBlock extends StatelessWidget {
  final String description;

  const _WeeklyAdviceBlock({required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.personalAdviceWeek,
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            height: 1.2,
            letterSpacing: -0.408,
          ),
        ),
      ],
    );
  }
}

class _WeeklyAreaCardsRail extends StatelessWidget {
  static const double _cardMaxWidth = 325;
  static const double _cardMinWidth = 240;
  static const double _visibleNextCardWidth = 33;

  final List<_WeeklyAreaCardData> cards;

  const _WeeklyAreaCardsRail({required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = math.min(
          _cardMaxWidth,
          math.max(_cardMinWidth, constraints.maxWidth - _visibleNextCardWidth),
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                _WeeklyAreaCard(data: cards[index], width: cardWidth),
                if (index != cards.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _WeeklyAreaCard extends StatelessWidget {
  static const double _imageWidth = 72;
  static const double _horizontalPadding = 32;
  static const double _titleMaxWidth = 213;

  final _WeeklyAreaCardData data;
  final double width;

  const _WeeklyAreaCard({required this.data, required this.width});

  @override
  Widget build(BuildContext context) {
    final titleWidth = math.min(
      _titleMaxWidth,
      math.max(0.0, width - _horizontalPadding - _imageWidth),
    );

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: CardLensDecoration(
        color: _cardTint,
        borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.18)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: titleWidth,
                height: 72,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                      height: 1,
                    ),
                  ),
                ),
              ),
              Image.asset(
                data.imageAsset,
                width: _imageWidth,
                height: 82,
                fit: BoxFit.contain,
                cacheWidth: 260,
                excludeFromSemantics: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            style: context.textTheme.inverseUrbanistRegular16.copyWith(
              height: 1.2,
              letterSpacing: -0.408,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyAreaCardData {
  final String title;
  final String description;
  final String imageAsset;

  const _WeeklyAreaCardData({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}

class _MonthFavourablePeriodsBlock extends StatelessWidget {
  final List<_MonthPeriodData> items;

  const _MonthFavourablePeriodsBlock({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.personalFavorablePeriods,
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            height: 1,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: AsteriaEntrance.sections([
            for (var index = 0; index < items.length; index++) ...[
              _MonthPeriodItem(data: items[index]),
              if (index != items.length - 1) const SizedBox(height: 8),
            ],
          ]),
        ),
      ],
    );
  }
}

class _MonthPeriodItem extends StatelessWidget {
  final _MonthPeriodData data;

  const _MonthPeriodItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: CardLensDecoration(
        color: AppColors.deepPurple.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MonthPeriodDateBadge(text: data.dates),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Text(
              data.text,
              style: AppTypography.text1.copyWith(color: AppColors.textInverse),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthPeriodDateBadge extends StatelessWidget {
  final String text;

  const _MonthPeriodDateBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 166, maxWidth: 358),
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          decoration: const BoxDecoration(
            gradient: _forecastButtonGradient,
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: context.textTheme.inverseUrbanistSemiBold16.copyWith(
              height: 1.2,
              letterSpacing: -0.408,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthAdviceBlock extends StatelessWidget {
  final String description;

  const _MonthAdviceBlock({required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.personalAdviceMonth,
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
    );
  }
}

class _MonthKeyTopicsCard extends StatelessWidget {
  final String description;

  const _MonthKeyTopicsCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 191),
      padding: const EdgeInsets.all(16),
      decoration: CardLensDecoration(
        borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
        color: AppColors.deepPurple,
        image: const DecorationImage(
          image: AssetImage(_monthKeyTopicsBackground),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const imageRight = 7.0;
          const imageWidth = 64.0;
          const minImageGap = 23.0;
          final imageLeft = constraints.maxWidth - imageRight - imageWidth;
          final textWidth = math.min(
            232.0,
            math.max(140.0, imageLeft - minImageGap),
          );

          return Stack(
            children: [
              const Positioned(
                top: 0,
                right: imageRight,
                width: imageWidth,
                height: 159,
                child: _MonthKeyTopicsImage(),
              ),
              SizedBox(
                width: textWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.personalMonthKeyThemes,
                      style: context.textTheme.inversePlayfairSemiBold24
                          .copyWith(height: 1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: context.textTheme.inverseUrbanistRegular16
                          .copyWith(height: 1.2, letterSpacing: -0.408),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MonthKeyTopicsImage extends StatelessWidget {
  const _MonthKeyTopicsImage();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _monthKeyTopicsSpiral,
      cacheWidth: 240,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}

class _MonthPeriodData {
  final String dates;
  final String text;

  const _MonthPeriodData({required this.dates, required this.text});
}

class _ForecastUnlockBanner extends StatelessWidget {
  final String title;
  final String description;
  final String imageAsset;
  final VoidCallback onPressed;

  const _ForecastUnlockBanner({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final clampedTextScale = textScale.clamp(1.0, 1.35);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 330;
        final imageWidth = isCompact ? math.min(128.0, width * 0.38) : 143.0;
        final imageHeight = imageWidth * 158 / 143;
        final availableTextWidth = width - 32 - imageWidth + 24;
        final titleWidth = isCompact
            ? math.min(192.0, math.max(132.0, availableTextWidth))
            : math.min(230.0, width - 32);
        final descriptionWidth = math.min(
          199.0,
          math.max(144.0, availableTextWidth),
        );
        final titleFontSize = math
            .min(24.0, titleWidth / 212.0 * 24.0)
            .clamp(14.0, 24.0)
            .toDouble();
        final minHeight =
            216.0 + ((clampedTextScale - 1.0).clamp(0.0, 1.0) * 64);

        return Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: minHeight),
          decoration: CardLensDecoration(
            color: _cardTint,
            borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.18)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 4,
                width: imageWidth,
                height: imageHeight,
                child: Image.asset(
                  imageAsset,
                  cacheWidth: 430,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: titleWidth,
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.inversePlayfairSemiBold24
                            .copyWith(height: 1, fontSize: titleFontSize),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: descriptionWidth,
                      child: Text(
                        description,
                        style: context.textTheme.inverseUrbanistRegular16
                            .copyWith(height: 1.2, letterSpacing: -0.408),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ForecastUnlockButton(onPressed: onPressed),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ForecastUnlockButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ForecastUnlockButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: Material(
        color: Colors.transparent,
        child: LotusInkTap(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _accentPurple),
            ),
            child: Center(
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return _forecastButtonGradient.createShader(
                    Offset.zero & bounds.size,
                  );
                },
                child: Text(
                  context.l10n.personalOpenChart,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.textTheme.inverseUrbanistRegular17.copyWith(
                    color: AppColors.textInverse,
                    height: 1.2,
                    letterSpacing: -0.408,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkContentCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget? footer;

  const _DarkContentCard({
    required this.title,
    required this.description,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: CardLensDecoration(
        color: AppColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            _GradientText(
              title,
              style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            description,
            style: context.textTheme.inverseUrbanistRegular16.copyWith(
              height: 1.2,
              letterSpacing: -0.408,
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class _PersonalCompatibilitySection extends StatelessWidget {
  final VoidCallback onPressed;

  const _PersonalCompatibilitySection({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final compatibilityProvider = di.get<CompatibilityProvider>();
    return ListenableBuilder(
      listenable: compatibilityProvider,
      builder: (context, _) {
        final compatibility = compatibilityProvider.selectedCompatibility;
        if (compatibility == null) {
          return _EmptyCompatibilityCard(onPressed: onPressed);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AsteriaEntrance.sections([
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.compatibilityTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                      height: 1,
                    ),
                  ),
                ),
                LotusTap(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    try {
                      await compatibilityProvider.clear();
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.genericRefreshError),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: ClayAssetIcon(
                      'assets/icons/repeat_icon.svg',
                      width: 24,
                      height: 24,
                      tint: Color(0xFFE6994D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CompatibilityHistoryCard(
              firstBirthdate: compatibility.firstBirthdate,
              secondBirthdate: compatibility.secondBirthdate,
              firstZodiacSign: compatibility.firstBirthdate.getZodiacSignName(
                languageCode: Localizations.localeOf(context).languageCode,
              ),
              secondZodiacSign: compatibility.secondBirthdate.getZodiacSignName(
                languageCode: Localizations.localeOf(context).languageCode,
              ),
              compatibilityPercentage:
                  compatibility.compatibilityData.percentage.getPercentage,
              compatibilityDescription:
                  compatibility.compatibilityData.introduction,
              phrase: compatibility.compatibilityData.phrase,
              onPressed: onPressed,
            ),
          ]),
        );
      },
    );
  }
}

class _EmptyCompatibilityCard extends StatelessWidget {
  final VoidCallback onPressed;

  const _EmptyCompatibilityCard({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bodyStyle = context.textTheme.inverseUrbanistRegular16.copyWith(
      fontFamily: 'Onest',
      height: 1.2,
      letterSpacing: -0.408,
    );

    return Semantics(
      button: true,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: CardLensDecoration(
          borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
        ),
        child: Material(
          // Figma Compatibility / Empty: Surface/card-tinted.
          color: const Color(0xFF1B1433),
          borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
          clipBehavior: Clip.antiAlias,
          child: LotusInkTap(
            onTap: onPressed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 358 / 224,
                  child: Image.asset(
                    'assets/images/home/compatibility_intro_figma.webp',
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 21),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.compatibilityAboutPair,
                        style: context.textTheme.inversePlayfairSemiBold24
                            .copyWith(fontFamily: 'Lora', height: 1),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.compatibilityAboutPairDescription,
                        style: bodyStyle,
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _GradientText(
                                context.l10n.compatibilityCheck,
                                style: bodyStyle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Transform.rotate(
                              angle: -math.pi / 4,
                              child: ClayAssetIcon(
                                'assets/icons/affirmation_arrow_figma.svg',
                                width: 20,
                                height: 20,
                                excludeFromSemantics: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _CompatibilityHistoryCard extends StatelessWidget {
  final DateTime firstBirthdate;
  final DateTime secondBirthdate;
  final String firstZodiacSign;
  final String secondZodiacSign;
  final int compatibilityPercentage;
  final String compatibilityDescription;
  final String phrase;
  final VoidCallback onPressed;

  const _CompatibilityHistoryCard({
    required this.firstBirthdate,
    required this.secondBirthdate,
    required this.firstZodiacSign,
    required this.secondZodiacSign,
    required this.compatibilityPercentage,
    required this.compatibilityDescription,
    required this.phrase,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey('personal-compatibility-card'),
      button: true,
      label: context.l10n.compatibilityDetailsLabel,
      child: LotusTap(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: CardLensDecoration(
                borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      _compatibilityBackgroundImage,
                      key: const ValueKey('personal-compatibility-background'),
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, 0.08),
                      opacity: const AlwaysStoppedAnimation(0.5),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            child: Column(
                              children: [
                                const SizedBox(height: 200),
                                _GradientText(
                                  phrase,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: context
                                      .textTheme
                                      .inverseUrbanistRegular16
                                      .copyWith(
                                        height: 1.2,
                                        letterSpacing: -0.408,
                                      ),
                                ),
                                Text(
                                  compatibilityDescription,
                                  textAlign: TextAlign.center,
                                  style: context
                                      .textTheme
                                      .inverseUrbanistRegular16
                                      .copyWith(
                                        height: 1.2,
                                        letterSpacing: -0.408,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                _GradientText(
                                  context.l10n.compatibilityReadMore,
                                  style: context
                                      .textTheme
                                      .inverseUrbanistSemiBold16
                                      .copyWith(
                                        height: 1.2,
                                        letterSpacing: -0.408,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 16,
                            top: 24,
                            width: 110,
                            child: _CompatibilityPerson(
                              name: firstZodiacSign,
                              birthdate: firstBirthdate.toLocalizedShortDate(
                                Localizations.localeOf(context),
                              ),
                              assetName: firstBirthdate.getZodiacSignAsset(),
                              angle: -20,
                            ),
                          ),
                          Positioned(
                            right: 16,
                            top: 24,
                            width: 110,
                            child: _CompatibilityPerson(
                              name: secondZodiacSign,
                              birthdate: secondBirthdate.toLocalizedShortDate(
                                Localizations.localeOf(context),
                              ),
                              assetName: secondBirthdate.getZodiacSignAsset(),
                              angle: 20,
                            ),
                          ),
                          Positioned(
                            left: width / 2 - 3.49,
                            top: 83,
                            width: 55,
                            height: 30,
                            child: SvgPicture.asset(
                              _compatibilityVector51,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Positioned(
                            left: 118.51,
                            top: 128,
                            width: 62.35,
                            height: 49.105,
                            child: Transform.rotate(
                              alignment: Alignment.center,
                              angle: 157 * math.pi / 180,
                              child: Transform.scale(
                                scaleY: -1,
                                child: Center(
                                  child: SizedBox(
                                    width: 55,
                                    height: 30,
                                    child: SvgPicture.asset(
                                      _compatibilityVector52,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 118,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: _GradientText(
                                '$compatibilityPercentage%',
                                style: context
                                    .textTheme
                                    .inversePlayfairSemiBold24
                                    .copyWith(height: 1),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompatibilityPerson extends StatelessWidget {
  final String name;
  final String birthdate;
  final String assetName;
  final double angle;

  const _CompatibilityPerson({
    required this.name,
    required this.birthdate,
    required this.assetName,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GradientText(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.textTheme.inversePlayfairMedium20.copyWith(
            height: 1.1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          birthdate,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.textTheme.inverseUrbanistRegular16.copyWith(
            height: 1.2,
            letterSpacing: -0.408,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 110,
          height: 110,
          child: Center(
            child: Transform.rotate(
              angle: angle * math.pi / 180,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.white.withValues(alpha: 0.15),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/zodiacs/compatibility_round/$assetName.webp',
                    key: ValueKey('personal-compatibility-zodiac-$assetName'),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const _GradientText(
    this.text, {
    required this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => _goldGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        style: style.copyWith(color: AppColors.white),
      ),
    );
  }
}
