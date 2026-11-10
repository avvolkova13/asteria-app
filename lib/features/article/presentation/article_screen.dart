import 'dart:async';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';

import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/subscription_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/articles_section_widget.dart';
import 'package:asteria_app/features/balance/presentation/provider/rewards_provider.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class _ArticlePageColors {
  static const tagGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );

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
              child: Center(child: Text(context.l10n.articleNotFound)),
            ),
          ],
        ),
      );
    }

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),
                    _ArticleHero(article: article),
                    const SizedBox(height: 16),
                    _ArticleContentCard(article: article),
                    SizedBox(key: _articleEndKey, height: 24),
                    ArticlesSectionWidget(excludeArticleId: article.id),
                    const SizedBox(height: 64),
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
    final navTextStyle = context.textTheme.urbanistSemiBold17.copyWith(
      color: AppColors.white,
      height: 1,
      letterSpacing: 0,
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
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClayAssetIcon(
                            'assets/icons/back_icon.svg',
                            tint: AppColors.textSecondary,
                            height: 24,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          context.l10n.articlesTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: navTextStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
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
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Image.asset(
                        'assets/icons/star_coin_icon.png',
                        height: 16,
                      ),
                    ),
                  ],
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
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 24,
            child: _ArticleCategoryTag(text: article.category),
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: _ArticleTimeTag(timeToRead: article.timeToRead),
          ),
        ],
      ),
    );
  }
}

class _ArticleContentCard extends StatelessWidget {
  const _ArticleContentCard({required this.article});

  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _ArticlePageColors.cardBackground,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                article.title,
                style: context.textTheme.playfairSemiBold32.copyWith(
                  color: AppColors.white,
                  height: 1.2,
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            _ArticleParagraphs(
              text: article.intro,
              style: context.textTheme.urbanistSemiBold16.copyWith(
                color: AppColors.white,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            _ArticleParagraphs(
              text: article.text,
              style: context.textTheme.urbanistRegular16.copyWith(
                color: AppColors.white,
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            _ArticleParagraphs(
              text: article.conclusion,
              style: context.textTheme.urbanistSemiBold16.copyWith(
                color: AppColors.white,
                height: 1.2,
                letterSpacing: 0,
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

class _ArticleCategoryTag extends StatelessWidget {
  const _ArticleCategoryTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 33,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: _ArticlePageColors.tagGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: context.textTheme.tertiaryUrbanistMedium14.copyWith(
          color: AppColors.white,
          height: 0.9,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _ArticleTimeTag extends StatelessWidget {
  const _ArticleTimeTag({required this.timeToRead});

  final int timeToRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 33,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.deepPurple,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        '$timeToRead ${context.l10n.readingTimeMinutes}',
        style: context.textTheme.tertiaryUrbanistMedium14.copyWith(
          color: AppColors.white,
          height: 0.9,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
