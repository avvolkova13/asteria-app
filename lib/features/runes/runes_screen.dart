import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'dart:async';

import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/entry_surface.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/const/keys_const.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/utils/horoscope_parsers/horoscope_request_helper.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/closed_content_modal.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/home/presentation/widgets/rune_of_the_day_widget.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/runes/widgets/all_runes_tab.dart';
import 'package:asteria_app/features/runes/widgets/how_to_use_runes.dart';
import 'package:asteria_app/features/runes/widgets/rune_interpretation_block.dart';
import 'package:asteria_app/features/runes/widgets/runes_block.dart';
import 'package:flutter/material.dart';

enum RunesTab {
  day,
  layout,
  allRunes;

  String title(BuildContext context) => switch (this) {
    RunesTab.day => context.l10n.runesTabDay,
    RunesTab.layout => context.l10n.runesTabSpread,
    RunesTab.allRunes => context.l10n.runesTabAll,
  };
}

class _RunesColors {
  static const background = Color(0xFF0F0A1A);
  static const descriptionText = Color(0xFFEEEAFD);
  static const gold = Color(0xFFF3B76A);
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );
}

class RunesScreen extends StatelessWidget {
  const RunesScreen({super.key, this.initialTab = RunesTab.day});

  final RunesTab initialTab;

  @override
  Widget build(BuildContext context) {
    final contentProvider = di.get<ContentProvider>();
    final userProvider = di.get<UserProvider>();

    return Scaffold(
      backgroundColor: _RunesColors.background,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: TopNavBarDelegate(
              canPop: true,
              userName: context.l10n.runesTitle,
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
                            final rune = contentProvider.getTodayRune();
                            return _RunesContent(
                              rune: rune,
                              initialTab: initialTab,
                            );
                          } catch (e) {
                            return ErrorScreenWidget(
                              error: context.l10n.runesLoadError,
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

class _RunesContent extends StatefulWidget {
  final dynamic rune;
  final RunesTab initialTab;

  const _RunesContent({required this.rune, required this.initialTab});

  @override
  _RunesContentState createState() => _RunesContentState();
}

class _RunesContentState extends State<_RunesContent> {
  late int _selectedTabIndex;
  bool _isRefreshingDeck = false;
  final ContentProvider _contentProvider = di.get<ContentProvider>();

  static const _featureParam = {EventParams.featureName: 'runes'};

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTab.index;
    _contentProvider.resetRuneOpenState();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.runeView,
      params: _featureParam,
    );
    di.get<ProductAnalyticsService>().trackRunesStart(
      entrySurface: EntrySurface.home,
    );
  }

  Widget _buildTabContent(
    Widget childDay,
    Widget childLayout,
    Widget childAll,
  ) {
    switch (_selectedTabIndex) {
      case 0: // Руна дня
        return childDay;
      case 1: // Расклад
        return childLayout;
      case 2: // Все руны
        return childAll;
      default:
        return const SizedBox.shrink();
    }
  }

  void _showHowToUseRunesModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const HowToUseRunes();
      },
    );
  }

  Future<void> _onGetInsightPressed() async {
    final userProvider = di.get<UserProvider>();
    final hasProSubscription =
        userProvider.currentUser != null &&
        di.get<MonetizationProvider>().effectivePro;
    final facade = di.get<AnalyticsFacade>();
    final productAnalytics = di.get<ProductAnalyticsService>();

    if (!hasProSubscription) {
      facade.trackEvent(
        AnalyticsEvents.lockedContentView,
        params: {..._featureParam, EventParams.offerType: 'rune_insight'},
      );
      facade.trackEvent(
        AnalyticsEvents.paywallView,
        params: {
          ..._featureParam,
          EventParams.paywallVariant: 'rune_insight_lock',
        },
      );
      productAnalytics.trackRunesLockedView(
        originSurface: 'runes_spread',
        offerType: OfferType.subscription,
      );
      productAnalytics.trackRunesPaywallView(
        originSurface: 'runes_spread',
        offerType: OfferType.subscription,
        paywallVariant: 'rune_insight_lock',
      );
      ClosedContentModal.show(
        context,
        description: context.l10n.runesInsightSubscriptionRequired,
      );
      return;
    }

    try {
      di.get<GlobalLoaderService>().showWithSpheres(GlobalLoaderType.insight);
      await facade.runFeatureAction(
        'runes',
        _contentProvider.getRuneDeckLayoutInsight,
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

  Future<void> _onRefreshRuneDeckLayout() async {
    setState(() => _isRefreshingDeck = true);
    try {
      final success = await di.get<AnalyticsFacade>().runFeatureAction(
        'runes',
        _contentProvider.refreshRuneDeckLayout,
      );
      if (!success && mounted) {
        ClosedContentModal.show(
          context,
          title: context.l10n.dailyLimitTitle,
          description: context.l10n.runesSpreadDailyLimit,
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
    final contentProvider = di.get<ContentProvider>();

    return ListenableBuilder(
      listenable: contentProvider,
      builder: (context, child) {
        return Column(
          children: [
            SegmentedPicker.indexed(
              surfaceBrightness: Brightness.dark,
              titles: [
                RunesTab.day.title(context),
                RunesTab.layout.title(context),
                RunesTab.allRunes.title(context),
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
              // Руна дня
              Builder(
                builder: (context) {
                  final userProvider = di.get<UserProvider>();
                  final hasProSubscription =
                      userProvider.currentUser != null &&
                      di.get<MonetizationProvider>().effectivePro;

                  void handleRefresh() {
                    if (hasProSubscription) {
                      contentProvider.refreshRune();
                      setState(() {});
                    } else {
                      ClosedContentModal.show(
                        context,
                        description:
                            context.l10n.runeRefreshSubscriptionRequired,
                      );
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListenableBuilder(
                        listenable: contentProvider,
                        builder: (context, _) {
                          try {
                            final rune = contentProvider.getTodayRune();
                            return RuneOfTheDayWidget(
                              rune: rune,
                              isLoading: false,
                              isOpened: contentProvider.isTodayRuneOpened(),
                              showMoreButton: false,
                              isDarkLayout: true,
                              margin: EdgeInsets.zero,
                              onRefresh: handleRefresh,
                              onRuneTap: () =>
                                  contentProvider.setTodayRuneOpened(),
                            );
                          } catch (e) {
                            return RuneOfTheDayWidget(
                              rune: widget.rune,
                              isLoading: false,
                              isOpened: contentProvider.isTodayRuneOpened(),
                              showMoreButton: false,
                              isDarkLayout: true,
                              margin: EdgeInsets.zero,
                              onRefresh: handleRefresh,
                              onRuneTap: () =>
                                  contentProvider.setTodayRuneOpened(),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 48),
                    ],
                  );
                },
              ),
              // Расклад
              _RuneLayoutTab(
                contentProvider: contentProvider,
                showHowToUseRunesModal: _showHowToUseRunesModal,
                onRefreshRuneDeckLayout: _onRefreshRuneDeckLayout,
                onGetInsightPressed: _onGetInsightPressed,
                isRefreshingDeck: _isRefreshingDeck,
              ),
              // Все руны
              const AllRunesTab(),
            ),
            const SizedBox(height: 64),
          ],
        );
      },
    );
  }
}

class _RuneLayoutTab extends StatefulWidget {
  final ContentProvider contentProvider;
  final VoidCallback showHowToUseRunesModal;
  final VoidCallback onRefreshRuneDeckLayout;
  final VoidCallback onGetInsightPressed;
  final bool isRefreshingDeck;

  const _RuneLayoutTab({
    Key? key,
    required this.contentProvider,
    required this.showHowToUseRunesModal,
    required this.onRefreshRuneDeckLayout,
    required this.onGetInsightPressed,
    required this.isRefreshingDeck,
  }) : super(key: key);

  @override
  State<_RuneLayoutTab> createState() => _RuneLayoutTabState();
}

class _RuneLayoutTabState extends State<_RuneLayoutTab> {
  final Set<int> _openingRuneIndexes = <int>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      di.get<ContentProvider>().ensureRuneDeckLayoutReady();
    });
  }

  Future<void> _openRune(int positionIndex, String hiveKey) async {
    if (_openingRuneIndexes.contains(positionIndex)) return;
    setState(() => _openingRuneIndexes.add(positionIndex));
    try {
      await widget.contentProvider.openRuneInDeck(hiveKey);
    } catch (error) {
      debugPrint('[ERROR] Ошибка открытия руны: $error');
    } finally {
      if (mounted) {
        setState(() => _openingRuneIndexes.remove(positionIndex));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        SizedBox(
          height: 38,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.runesSpreadTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.playfairSemiBold32.copyWith(
                    color: AppColors.white,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Semantics(
                button: true,
                enabled: !widget.isRefreshingDeck,
                label: context.l10n.refreshRuneSpreadLabel,
                child: ExcludeSemantics(
                  child: LotusTap(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.isRefreshingDeck
                        ? null
                        : widget.onRefreshRuneDeckLayout,
                    child: Opacity(
                      opacity: widget.isRefreshingDeck ? 0.5 : 1,
                      child: SizedBox(
                        width: LotusArrowBubble.hitExtent,
                        height: LotusArrowBubble.hitExtent,
                        child: Center(
                          child: LotusRefreshBubble(tint: _RunesColors.gold),
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
          context.l10n.runesSpreadDescription,
          style: context.textTheme.urbanistRegular16.copyWith(
            color: _RunesColors.descriptionText,
            height: 1.2,
            letterSpacing: -0.408,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 4),
        _RuneSpreadSection(
          number: '1',
          title: context.l10n.runesPast,
          description: context.l10n.runesPastDescription,
          textTheme: context.textTheme,
        ),
        _RuneSpreadSection(
          number: '2',
          title: context.l10n.runesPresent,
          description: context.l10n.runesPresentDescription,
          textTheme: context.textTheme,
        ),
        _RuneSpreadSection(
          number: '3',
          title: context.l10n.runesFuture,
          description: context.l10n.runesFutureDescription,
          textTheme: context.textTheme,
        ),
        const SizedBox(height: 14),
        Center(
          child: _GradientUnderlineButton(
            text: context.l10n.runesHowToUse,
            onPressed: widget.showHowToUseRunesModal,
          ),
        ),
        const SizedBox(height: 16),
        if (widget.isRefreshingDeck)
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
              final runeDeck = di.get<UserProvider>().currentUser?.runeDeck;
              final allRunesOpened =
                  runeDeck != null &&
                  runeDeck.cards.length >= 3 &&
                  runeDeck.cards.every((c) => c.id.isNotEmpty) &&
                  widget.contentProvider.areAllRuneDeckCardsOpened();
              final interpretation = runeDeck?.interpretation;
              final hasLocalizedInterpretation =
                  interpretation != null &&
                  isAiContentLocalized(
                    interpretation,
                    Localizations.localeOf(context).languageCode,
                  );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AsteriaEntrance.sections([
                  RunesBlock(
                    rune1: widget.contentProvider.getRuneInDeck(
                      KeysConst.runeDeckLeftKey,
                    ),
                    rune2: widget.contentProvider.getRuneInDeck(
                      KeysConst.runeDeckCenterKey,
                    ),
                    rune3: widget.contentProvider.getRuneInDeck(
                      KeysConst.runeDeckRightKey,
                    ),
                    onOpenRuneLeft: _openingRuneIndexes.contains(0)
                        ? null
                        : () => unawaited(
                            _openRune(0, KeysConst.runeDeckLeftKey),
                          ),
                    onOpenRuneCenter: _openingRuneIndexes.contains(1)
                        ? null
                        : () => unawaited(
                            _openRune(1, KeysConst.runeDeckCenterKey),
                          ),
                    onOpenRuneRight: _openingRuneIndexes.contains(2)
                        ? null
                        : () => unawaited(
                            _openRune(2, KeysConst.runeDeckRightKey),
                          ),
                    isRuneLeftOpened: widget.contentProvider.isRuneInDeckOpened(
                      KeysConst.runeDeckLeftKey,
                    ),
                    isRuneCenterOpened: widget.contentProvider
                        .isRuneInDeckOpened(KeysConst.runeDeckCenterKey),
                    isRuneRightOpened: widget.contentProvider
                        .isRuneInDeckOpened(KeysConst.runeDeckRightKey),
                  ).withEntrance(),
                  if (allRunesOpened) ...[
                    const SizedBox(height: 16),
                    if (hasLocalizedInterpretation)
                      RuneInterpretationBlock(
                        interpretation: interpretation,
                      ).withEntrance()
                    else
                      CustomButton(
                        text: context.l10n.deckGetInsight,
                        isFullWidth: true,
                        onPressed: widget.onGetInsightPressed,
                      ),
                  ] else ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        context.l10n.runesTapToFlip,
                        style: context.textTheme.urbanistRegular16.copyWith(
                          color: _RunesColors.descriptionText,
                          height: 1.2,
                          letterSpacing: -0.408,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ]),
              );
            },
          ),
        const SizedBox(height: 32),
      ]),
    );
  }
}

class _RuneSpreadSection extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final TextThemeData textTheme;

  const _RuneSpreadSection({
    required this.number,
    required this.title,
    required this.description,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number. ',
          style: textTheme.urbanistRegular16.copyWith(
            color: _RunesColors.descriptionText,
            height: 1.2,
            letterSpacing: -0.408,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: textTheme.urbanistRegular16.copyWith(
                color: _RunesColors.descriptionText,
                height: 1.2,
                letterSpacing: -0.408,
              ),
              children: [
                TextSpan(
                  text: '$title\n',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
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
      child: ExcludeSemantics(
        child: LotusTap(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) =>
                  _RunesColors.goldGradient.createShader(bounds),
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
