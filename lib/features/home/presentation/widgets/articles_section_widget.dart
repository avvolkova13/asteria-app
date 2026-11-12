import 'package:asteria_app/core/ui_kit/widgets/artwork_unavailable.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class ArticlesSectionWidget extends StatefulWidget {
  final String? excludeArticleId;
  const ArticlesSectionWidget({Key? key, this.excludeArticleId})
    : super(key: key);

  @override
  State<ArticlesSectionWidget> createState() => _ArticlesSectionWidgetState();
}

class _ArticlesSectionWidgetState extends State<ArticlesSectionWidget> {
  static const double _baseCardWidth = 201;
  static const double _articleCardGap = 16;

  final ScrollController _articlesScrollController = ScrollController();

  @override
  void dispose() {
    _articlesScrollController.dispose();
    super.dispose();
  }

  void _onArticleTap(BuildContext context, String articleId) {
    ArticleRoute.push(context, articleId: articleId);
  }

  void _scrollArticlesForward(double cardWidth) {
    if (!_articlesScrollController.hasClients) {
      return;
    }

    final maxScrollExtent = _articlesScrollController.position.maxScrollExtent;
    if (maxScrollExtent <= 0) {
      return;
    }

    final nextOffset =
        _articlesScrollController.offset + cardWidth + _articleCardGap;
    final targetOffset = _articlesScrollController.position.extentAfter < 1
        ? 0.0
        : nextOffset.clamp(0.0, maxScrollExtent).toDouble();

    _articlesScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMainSection = widget.excludeArticleId == null;
    final isDarkSection = !isMainSection;
    final sectionTitle = isMainSection
        ? context.l10n.articlesTitle
        : context.l10n.articlesReadMore;
    var articles = di.get<ContentProvider>().articles;
    if (widget.excludeArticleId != null) {
      articles = articles
          .where((article) => article.id != widget.excludeArticleId)
          .toList();
    }
    if (articles.isEmpty) return const SizedBox.shrink();
    final scale = MediaQuery.textScalerOf(context).scale(20) / 20;
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = (_baseCardWidth * scale)
        .clamp(_baseCardWidth, width > 245 ? width - 44 : _baseCardWidth)
        .toDouble();
    return Container(
      width: double.infinity,
      color: isMainSection ? AppColors.textPrimary : null,
      padding: EdgeInsets.symmetric(horizontal: isMainSection ? 16 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sectionTitle,
                  style: context.textTheme.playfairSemiBold24.copyWith(
                    color: AppColors.white,
                    height: 1,
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: context.l10n.articlesScrollLabel,
                child: LotusTap(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _scrollArticlesForward(cardWidth),
                  child: SizedBox(
                    width: 48,
                    height: 44,
                    child: Align(
                      alignment: Alignment.center,
                      child: LotusArrowBubble(),
                    ),
                  ),
                ),
              ),
            ],
          ).withEntrance(),
          const SizedBox(height: 16),
          SingleChildScrollView(
            controller: _articlesScrollController,
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < articles.length; index++) ...[
                    Semantics(
                      button: true,
                      label: context.l10n.openArticleLabel(
                        articles[index].title,
                      ),
                      child: LotusTap(
                        onTap: () => _onArticleTap(context, articles[index].id),
                        child: _ArticleCard(
                          width: cardWidth,
                          title: articles[index].title,
                          category: articles[index].category,
                          timeToRead: articles[index].timeToRead,
                          imageName: articles[index].id,
                          isRedesigned: isMainSection,
                          isDarkSection: isDarkSection,
                        ),
                      ),
                    ),
                    if (index != articles.length - 1) const SizedBox(width: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final double width;
  final String title;
  final String category;
  final int timeToRead;
  final String imageName;
  final bool isRedesigned;
  final bool isDarkSection;

  const _ArticleCard({
    Key? key,
    required this.title,
    required this.category,
    required this.timeToRead,
    required this.imageName,
    required this.isRedesigned,
    required this.width,
    required this.isDarkSection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 252),
      foregroundDecoration: CardLensDecoration(
        borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
      ),
      decoration: BoxDecoration(
        color: isRedesigned || isDarkSection
            ? AppColors.deepPurple
            : AppColors.cardTinted,
        borderRadius: BorderRadius.circular(AsteriaCardRadii.tile),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AsteriaCardRadii.tile),
              topRight: Radius.circular(AsteriaCardRadii.tile),
            ),
            child: Image.asset(
              'assets/images/articles/$imageName.webp',
              width: width,
              height: 167,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  ArtworkUnavailable(width: width, height: 167, radius: 0),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              style: context.textTheme.playfairMedium20.copyWith(
                color: isRedesigned || isDarkSection
                    ? AppColors.white
                    : AppColors.textPrimary,
                height: 1.1,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: _ArticleMetadata(category: category, timeToRead: timeToRead),
          ),
        ],
      ),
    );
  }
}

class _ArticleMetadata extends StatelessWidget {
  final String category;
  final int timeToRead;

  const _ArticleMetadata({
    Key? key,
    required this.category,
    required this.timeToRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = context.textTheme.tertiaryUrbanistMedium14.copyWith(
      letterSpacing: 0,
      height: 0.9,
    );

    return Row(
      children: [
        Flexible(
          child: Text(
            category,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 1, height: 10, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text(
          '$timeToRead ${context.l10n.readingTimeMinutes}',
          style: textStyle,
        ),
      ],
    );
  }
}
