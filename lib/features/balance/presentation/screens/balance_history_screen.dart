import 'package:asteria_app/core/ui_kit/widgets/asteria_activity_indicator.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_bar_geometry.dart';
import 'package:asteria_app/features/monetization/domain/purchase_visibility.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/locale_formatters.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/static_glass_surface.dart';
import 'package:asteria_app/features/balance/presentation/balance_history_controller.dart';
import 'package:asteria_app/features/balance/presentation/widgets/balance_history_style.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BalanceHistoryScreen extends StatefulWidget {
  const BalanceHistoryScreen({super.key});

  @override
  State<BalanceHistoryScreen> createState() => _BalanceHistoryScreenState();
}

class _BalanceHistoryScreenState extends State<BalanceHistoryScreen> {
  late final _history = BalanceHistoryController(
    loadPage: ({required filter, beforeSequence}) => di
        .get<MonetizationApi>()
        .getWalletHistoryPage(filter: filter, beforeSequence: beforeSequence),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _history.setAccount(context.watch<UserProvider>().currentUser?.id);
  }

  @override
  void dispose() {
    _history.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monetization = MonetizationProvider.maybeOf(context);
    return BalanceHistoryView(
      key: ValueKey(context.watch<UserProvider>().currentUser?.id),
      controller: _history,
      balance: monetization?.balance ?? 0,
      hasPro: monetization?.effectivePro ?? false,
      onBack: () => Navigator.of(context).pop(),
    );
  }
}

class BalanceHistoryView extends StatefulWidget {
  const BalanceHistoryView({
    super.key,
    required this.controller,
    required this.balance,
    required this.hasPro,
    required this.onBack,
  });
  final BalanceHistoryController controller;
  final int balance;
  final bool hasPro;
  final VoidCallback onBack;

  @override
  State<BalanceHistoryView> createState() => _BalanceHistoryViewState();
}

class _BalanceHistoryViewState extends State<BalanceHistoryView> {
  final _scroll = ScrollController();
  final _presentedEntries = <String>{};
  bool _checkScheduled = false;
  bool _pullReady = false;

  void _updatePull(RefreshIndicatorStatus? status) {
    final ready =
        status == RefreshIndicatorStatus.armed ||
        status == RefreshIndicatorStatus.snap ||
        status == RefreshIndicatorStatus.refresh;
    if (_pullReady != ready) setState(() => _pullReady = ready);
  }

  BalanceHistoryController get history => widget.controller;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_loadMore);
  }

  void _loadMore() {
    if (_scroll.hasClients &&
        _scroll.position.extentAfter < 300 &&
        history.pageError == null) {
      history.loadMore();
    }
  }

  void _checkNextPage() {
    if (_checkScheduled) return;
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      if (mounted) _loadMore();
    });
  }

  void _selectFilter(WalletHistoryFilter value) {
    if (value == history.filter) return;
    if (_scroll.hasClients) _scroll.jumpTo(0);
    history.selectFilter(value);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      backgroundColor: BalanceHistoryStyle.background,
      body: StaticGlassBackdrop(
        asset: 'assets/images/home/profile_background.webp',
        paintBackdrop: BalanceHistoryStyle.paintBackground,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: AsteriaEntrance.sections([
              _HistoryHeader(
                balance: widget.balance,
                hasPro: widget.hasPro,
                onBack: widget.onBack,
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: history,
                  builder: (context, _) {
                    _checkNextPage();
                    return Column(
                      children: [
                        _HistoryRefreshRow(
                          visible: _pullReady || history.isRefreshing,
                        ),
                        Expanded(
                          child: RefreshIndicator.noSpinner(
                            onRefresh: history.refresh,
                            onStatusChange: _updatePull,
                            notificationPredicate: (notification) =>
                                !history.isLoading &&
                                defaultScrollNotificationPredicate(
                                  notification,
                                ),
                            child: CustomScrollView(
                              key: const Key('history-scroll'),
                              controller: _scroll,
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                if (!history.isGloballyEmpty)
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      18,
                                      16,
                                      18,
                                    ),
                                    sliver: SliverToBoxAdapter(
                                      child: _FilterTabs(
                                        selectedFilter: history.filter,
                                        onFilterChanged: _selectFilter,
                                      ),
                                    ),
                                  ),
                                if (history.isLoading)
                                  const SliverToBoxAdapter(
                                    child: _LoadingHistory(),
                                  )
                                else if (history.error != null)
                                  SliverToBoxAdapter(
                                    child: _HistoryError(
                                      key: const Key('history-error'),
                                      message:
                                          context.l10n.balanceHistoryLoadError,
                                      onRetry: history.refresh,
                                    ),
                                  )
                                else ...[
                                  if (history.refreshError != null)
                                    SliverToBoxAdapter(
                                      child: _HistoryError(
                                        message: context
                                            .l10n
                                            .balanceHistoryRefreshError,
                                        onRetry: history.refresh,
                                      ),
                                    ),
                                  if (history.isGloballyEmpty)
                                    const SliverPadding(
                                      padding: EdgeInsets.fromLTRB(
                                        16,
                                        24,
                                        16,
                                        24,
                                      ),
                                      sliver: SliverToBoxAdapter(
                                        child: AsteriaEntrance(
                                          child: _EmptyState(),
                                        ),
                                      ),
                                    )
                                  else if (history.items.isEmpty)
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: AsteriaEntrance(
                                          replayKey: history.filter,
                                          child: Text(
                                            history.filter ==
                                                    WalletHistoryFilter
                                                        .withdrawals
                                                ? context
                                                      .l10n
                                                      .balanceHistoryNoWithdrawals
                                                : context
                                                      .l10n
                                                      .balanceHistoryNoDeposits,
                                            textAlign: TextAlign.center,
                                            style: BalanceHistoryStyle.body
                                                .copyWith(
                                                  color:
                                                      BalanceHistoryStyle.muted,
                                                ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    SliverPadding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      sliver: SliverList.builder(
                                        addRepaintBoundaries: false,
                                        itemCount: history.items.length,
                                        itemBuilder: (context, index) {
                                          final item = history.items[index];
                                          return AsteriaEntrance(
                                            key: ValueKey(item.entryId),
                                            animateInitially: _presentedEntries
                                                .add(item.entryId),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: _HistoryItem(item: item),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  if (history.isLoadingMore)
                                    const SliverToBoxAdapter(
                                      child: _LoadingHistory(),
                                    ),
                                  if (history.pageError != null)
                                    SliverToBoxAdapter(
                                      child: _HistoryError(
                                        key: const Key('history-page-error'),
                                        message: context
                                            .l10n
                                            .balanceHistoryLoadError,
                                        onRetry: history.loadMore,
                                      ),
                                    ),
                                ],
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    height:
                                        MediaQuery.paddingOf(context).bottom +
                                        24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    ),
  );
}

class _HistoryRefreshRow extends StatelessWidget {
  const _HistoryRefreshRow({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 160),
    curve: Curves.easeOutCubic,
    child: visible
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Center(
              child: SizedBox.square(
                dimension: 36,
                child: LotusIconSurface(
                  diameter: 36,
                  child: Center(
                    child: AsteriaActivityIndicator(
                      size: 24,
                      color: AppColors.cardTinted,
                      semanticsLabel: MaterialLocalizations.of(
                        context,
                      ).refreshIndicatorSemanticLabel,
                    ),
                  ),
                ),
              ),
            ),
          )
        : const SizedBox(width: double.infinity),
  );
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({
    required this.balance,
    required this.hasPro,
    required this.onBack,
  });
  final int balance;
  final bool hasPro;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final title = Text(
      context.l10n.balanceHistoryTitle,
      style: BalanceHistoryStyle.title,
    );
    final wallet = Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$balance'),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: LotusRasterIcon(
                    'assets/icons/star_coin_icon.png',
                    width: 13,
                    height: 13,
                  ),
                ),
              ),
            ],
          ),
          style: BalanceHistoryStyle.title,
        ),
        ProfileProPill(isActive: hasPro),
      ],
    );
    return AsteriaTopBarFrame(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final large =
              MediaQuery.textScalerOf(context).scale(17) > 22 ||
              balance.toString().length > 7;
          final titleRow = Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: LotusButtons.icon(
                  onPressed: onBack,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: const LotusArrowBubble(back: true),
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              Expanded(child: title),
              if (!large) ...[const SizedBox(width: 8), wallet],
            ],
          );
          if (!large) return titleRow;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleRow,
              Padding(
                padding: const EdgeInsets.only(left: 44, top: 4),
                child: wallet,
              ),
            ],
          );
        },
      ),
    );
  }
}

double _textWidth(BuildContext context, String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.item});
  final WalletHistoryEntryModel item;

  @override
  Widget build(BuildContext context) {
    final date = LocaleFormatters.shortDate(
      item.createdAt,
      Localizations.localeOf(context),
    );
    final amount = '${item.isDeposit ? '+' : '-'}${item.amount}';
    final amountStyle = BalanceHistoryStyle.body.copyWith(
      fontWeight: FontWeight.w600,
      color: item.isDeposit
          ? BalanceHistoryStyle.credit
          : BalanceHistoryStyle.debit,
    );
    return StaticGlassSurface(
      radius: AsteriaCardRadii.compact,
      tint: BalanceHistoryStyle.card,
      light: 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dateWidth = _textWidth(
              context,
              date,
              BalanceHistoryStyle.body,
            ).ceilToDouble();
            final amountWidth = _textWidth(
              context,
              amount,
              amountStyle,
            ).ceilToDouble();
            final dateText = Text(date, style: BalanceHistoryStyle.body);
            final amountText = Text(amount, style: amountStyle);
            final description = Text(
              isHiddenHoroscopePurchase(item.description)
                  ? context.l10n.balanceLegacyOperation
                  : item.description,
              style: BalanceHistoryStyle.body,
            );
            final groupWidth = (dateWidth + amountWidth + 16).clamp(
              180.0,
              double.infinity,
            );
            if (groupWidth + 30 + 80 <= constraints.maxWidth) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: groupWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [dateText, amountText],
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(child: description),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 30,
                  runSpacing: 8,
                  children: [dateText, amountText],
                ),
                const SizedBox(height: 8),
                description,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.selectedFilter,
    required this.onFilterChanged,
  });
  final WalletHistoryFilter selectedFilter;
  final ValueChanged<WalletHistoryFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final labels = [
      context.l10n.balanceDeposits,
      context.l10n.balanceWithdrawals,
      context.l10n.balanceAllOperations,
    ];
    return SegmentedPicker<WalletHistoryFilter>(
      key: const Key('history-filters'),
      options: WalletHistoryFilter.values,
      surfaceBrightness: Brightness.dark,
      selectedValue: selectedFilter,
      labelBuilder: (filter) => labels[filter.index],
      onChanged: onFilterChanged,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => StaticGlassSurface(
    key: const Key('history-empty'),
    radius: AsteriaCardRadii.tile,
    tint: BalanceHistoryStyle.card,
    light: 0.8,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.balanceHistoryEmpty,
              style: BalanceHistoryStyle.emptyTitle,
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/balance/history_empty.png',
            key: const Key('history-empty-art'),
            width: 74,
            height: 85,
            excludeFromSemantics: true,
          ),
        ],
      ),
    ),
  );
}

class _LoadingHistory extends StatelessWidget {
  const _LoadingHistory();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(24),
    child: Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: AsteriaEntrance(child: AsteriaActivityIndicator()),
      ),
    ),
  );
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: AsteriaEntrance.sections([
        Text(
          message,
          textAlign: TextAlign.center,
          style: BalanceHistoryStyle.body,
        ),
        LotusButtons.textIcon(
          onPressed: onRetry,
          icon: const ClayIcon(Icons.refresh),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFF3B76A)),
          label: Text(context.l10n.retry),
        ),
      ]),
    ),
  );
}
