import 'package:asteria_app/core/ui_kit/widgets/artwork_unavailable.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';

import 'dart:async';

import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';

import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/subscription_widget.dart';
import 'package:asteria_app/features/article/presentation/article_card_title.dart';
import 'package:asteria_app/features/home/presentation/widgets/articles_section_widget.dart';
import 'package:asteria_app/features/balance/presentation/provider/rewards_provider.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class _ArticlePageColors {
  static const background = AppColors.textPrimary;
  static const cardBackground = AppColors.deepPurple;
  static const navHeight = 105.0;
}

class ArticleScreen extends StatefulWidget {
  final String articleId;

  const ArticleScreen({Key? key, required this.articleId}) : super(key: key);

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _articleEndKey = GlobalKey();
  bool _readEventSent = false;
  bool _viewEventSent = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_trackReadAtBottom);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_trackReadAtBottom)
      ..dispose();
    super.dispose();
  }

  void _trackReadAtBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkReadAtBottom());
  }

  void _checkReadAtBottom() {
    if (!mounted || ModalRoute.of(context)?.isCurrent == false) return;
    if (_readEventSent || !_scrollController.hasClients) return;
    final endContext = _articleEndKey.currentContext;
    final renderBox = endContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final endOffset = renderBox.localToGlobal(Offset.zero).dy;
    if (endOffset > MediaQuery.sizeOf(context).height) return;
    _readEventSent = true;
    unawaited(di.get<AnalyticsFacade>().trackEvent('article_read'));
    unawaited(di.get<RewardsProvider>().recordArticleRead(widget.articleId));
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = di.get<ContentProvider>();
    final article = contentProvider.getArticleById(widget.articleId);

    if (article == null) {
      return BaseScaffold(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: const _ArticleTopBarDelegate(),
            ),
            SliverFillRemaining(
              child: Center(
                child: Text(context.l10n.articleNotFound).withEntrance(),
              ),
            ),
          ],
        ),
      );
    }

    final pairedLead =
        MediaQuery.sizeOf(context).shortestSide >= 600 &&
        MediaQuery.sizeOf(context).width >= 720 &&
        MediaQuery.textScalerOf(context).scale(16) <= 24;
    if (!_viewEventSent) {
      _viewEventSent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || ModalRoute.of(context)?.isCurrent == false) return;
        unawaited(di.get<AnalyticsFacade>().trackEvent('article_opened'));
        _checkReadAtBottom();
      });
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _ArticlePageColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _ArticlePageColors.background,
        body: CustomScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: const _ArticleTopBarDelegate(),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: pairedLead ? 820 : 720),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 22),
                        if (pairedLead)
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _ArticleHero(article: article),
                              ),
                              const SizedBox(width: 28),
                              Expanded(
                                flex: 3,
                                child: _ArticleIntro(article: article),
                              ),
                            ],
                          ).withEntrance()
                        else
                          _ArticleHero(article: article).withEntrance(),
                        const SizedBox(height: 16),
                        _ArticleContentCard(
                          article: article,
                          includeIntro: !pairedLead,
                        ).withEntrance(),
                        SizedBox(key: _articleEndKey, height: 24),
                        ArticlesSectionWidget(excludeArticleId: article.id),
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
      ),
    );
  }
}

class _ArticleTopBarDelegate extends SliverPersistentHeaderDelegate {
  const _ArticleTopBarDelegate();

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return const _ArticleTopBar();
  }

  @override
  double get maxExtent => _ArticlePageColors.navHeight;

  @override
  double get minExtent => _ArticlePageColors.navHeight;

  @override
  bool shouldRebuild(covariant _ArticleTopBarDelegate oldDelegate) => false;
}

class _ArticleTopBar extends StatelessWidget {
  const _ArticleTopBar();

  @override
  Widget build(BuildContext context) {
    final navTextStyle = AppTypography.navTitle.copyWith(
      color: AppColors.white,
    );

    return ColoredBox(
      color: _ArticlePageColors.background,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
        child: SizedBox(
          height: _ArticlePageColors.navHeight - 32,
          child: Row(
            children: [
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -2),
                  child: Row(
                    children: [
                      Semantics(
                        button: true,
                        enabled: true,
                        label: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                        onTap: LotusFeedback.action(
                          () => Navigator.of(context).pop(),
                        ),
                        excludeSemantics: true,
                        child: LotusTap(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).pop(),
                          child: const SizedBox.square(
                            dimension: LotusArrowBubble.hitExtent,
                            child: Center(child: LotusArrowBubble(back: true)),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          context.l10n.articlesTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: navTextStyle,
                        ).withEntrance(),
                      ),
                    ],
                  ),
                ),
              ),
              Semantics(
                button: true,
                enabled: true,
                label: context.l10n.balanceStarsLabel(
                  MonetizationProvider.maybeOf(context)?.balance ?? 0,
                ),
                onTap: LotusFeedback.action(() => BalanceRoute.push(context)),
                excludeSemantics: true,
                child: LotusTap(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => BalanceRoute.push(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${MonetizationProvider.maybeOf(context)?.balance ?? 0} ',
                              style: navTextStyle,
                            ).withEntrance(),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: LotusRasterIcon(
                          'assets/icons/star_coin_icon.png',
                          height: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const SubscriptionWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleHero extends StatelessWidget {
  const _ArticleHero({required this.article});

  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 358 / 398,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                'assets/images/articles/${article.id}.webp',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ArtworkUnavailable(radius: 32),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 6,
              children: [
                _ArticleTag(text: article.category, accent: true),
                _ArticleTag(
                  text:
                      '${article.timeToRead} ${context.l10n.readingTimeMinutes}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleIntro extends StatelessWidget {
  const _ArticleIntro({required this.article});
  final ArticleModel article;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          articleCardTitle(article, Localizations.localeOf(context)),
          style: AppTypography.h2.copyWith(color: AppColors.white, height: 1.2),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 16),
        _ArticleParagraphs(
          text: article.intro,
          style: AppTypography.text1SemiBold.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}

class _ArticleContentCard extends StatelessWidget {
  const _ArticleContentCard({
    required this.article,
    required this.includeIntro,
  });
  final bool includeIntro;

  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: CardLensDecoration(
        color: _ArticlePageColors.cardBackground,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (includeIntro) ...[
              _ArticleIntro(article: article),
              const SizedBox(height: 8),
            ],
            _ArticleParagraphs(
              text: article.text,
              style: AppTypography.text1.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 8),
            _ArticleParagraphs(
              text: article.conclusion,
              style: AppTypography.text1SemiBold.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleParagraphs extends StatelessWidget {
  const _ArticleParagraphs({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final paragraphs = text
        .split('\n')
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .toList();

    if (paragraphs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < paragraphs.length; index++) ...[
          Text(paragraphs[index], style: style),
          if (index != paragraphs.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ArticleTag extends StatelessWidget {
  const _ArticleTag({required this.text, this.accent = false});

  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: CardLensDecoration.button(
        color: AppColorsDark.modal,
        borderRadius: BorderRadius.circular(AsteriaCardRadii.compact),
      ),
      child: Text(
        text,
        style: AppTypography.label14.copyWith(
          color: accent ? AppColorsDark.linkGold : AppColors.white,
        ),
      ),
    );
  }
}
