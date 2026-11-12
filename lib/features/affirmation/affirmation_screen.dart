import 'package:asteria_app/core/ui_kit/widgets/top_bar_geometry.dart';
import 'package:asteria_app/core/ui_kit/widgets/pro_badge_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/dictionaries/entry_surface.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_category_widget.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';

const Set<String> freeAffirmationCategoryIds = {'love', 'abundance'};
const Color _affirmationSurface = Color(0xFF0E031F);

class AffirmationScreen extends StatefulWidget {
  const AffirmationScreen({super.key});

  @override
  State<AffirmationScreen> createState() => _AffirmationScreenState();
}

class _AffirmationScreenState extends State<AffirmationScreen> {
  @override
  void initState() {
    super.initState();
    di.get<ProductAnalyticsService>().trackAffirmationsStart(
      entrySurface: EntrySurface.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider = di.get<ContentProvider>();
    final userProvider = di.get<UserProvider>();
    final categories = contentProvider.affirmationCategories;

    return BaseScaffold(
      child: ColoredBox(
        color: _affirmationSurface,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: _AffirmationTopNavBarDelegate(
                topInset: MediaQuery.paddingOf(context).top,
                toolbarHeight: AsteriaTopBarMetrics.heightOf(context),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 34),
              sliver: SliverToBoxAdapter(
                child: ListenableBuilder(
                  listenable: Listenable.merge([userProvider, contentProvider]),
                  builder: (context, _) {
                    final hasSubscription =
                        MonetizationProvider.maybeOf(context)?.effectivePro ??
                        false;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final category in categories) ...[
                          AffirmationCategoryWidget(
                            key: ValueKey('affirmation_category_$category'),
                            category: category,
                            affirmations: contentProvider
                                .getAffirmationsByCategory(category),
                            showAffirmations:
                                hasSubscription ||
                                freeAffirmationCategoryIds.contains(category),
                            showSwipeHint: category == categories.first,
                          ),
                          if (category != categories.last)
                            const SizedBox(height: 24),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AffirmationTopNavBarDelegate extends SliverPersistentHeaderDelegate {
  const _AffirmationTopNavBarDelegate({
    required this.topInset,
    required this.toolbarHeight,
  });

  final double topInset;
  final double toolbarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: _affirmationSurface,
      child: _AffirmationTopNavBar(
        topInset: topInset,
        toolbarHeight: toolbarHeight,
      ),
    );
  }

  @override
  double get maxExtent => topInset + toolbarHeight;

  @override
  double get minExtent => topInset + toolbarHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate is! _AffirmationTopNavBarDelegate ||
        oldDelegate.topInset != topInset ||
        oldDelegate.toolbarHeight != toolbarHeight;
  }
}

class _AffirmationTopNavBar extends StatelessWidget {
  const _AffirmationTopNavBar({
    required this.topInset,
    required this.toolbarHeight,
  });
  final double topInset;
  final double toolbarHeight;

  @override
  Widget build(BuildContext context) {
    final userProvider = di.get<UserProvider>();

    return SizedBox(
      height: topInset + toolbarHeight,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: AsteriaTopBarFrame(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: context.l10n.commonBack,
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
                        context.l10n.affirmationsTitle,
                        style: context.textTheme.inversePlayfairSemiBold17
                            .copyWith(height: 1.2, letterSpacing: -0.408),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).withEntrance(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ListenableBuilder(
                listenable: userProvider,
                builder: (context, _) {
                  final balance =
                      MonetizationProvider.maybeOf(context)?.balance ?? 0;
                  final hasSubscription =
                      MonetizationProvider.maybeOf(context)?.effectivePro ??
                      false;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        button: true,
                        label: context.l10n.balanceStarsLabel(balance),
                        child: LotusTap(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => BalanceRoute.push(context),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$balance ',
                                  style: context
                                      .textTheme
                                      .inversePlayfairSemiBold17
                                      .copyWith(
                                        height: 1.2,
                                        letterSpacing: -0.408,
                                      ),
                                ).withEntrance(),
                                LotusRasterIcon(
                                  'assets/icons/star_coin_icon.png',
                                  width: 14,
                                  height: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _AffirmationProBadge(isActive: hasSubscription),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AffirmationProBadge extends StatelessWidget {
  final bool isActive;

  const _AffirmationProBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: !isActive,
      label: isActive
          ? context.l10n.subscriptionActive
          : context.l10n.offerProTitle,
      child: LotusTap(
        behavior: HitTestBehavior.opaque,
        onTap: isActive ? null : () => _openSubscriptionFromProBadge(context),
        child: ProBadgeSurface(
          isActive: isActive,
          labelStyle: context.textTheme.inversePlayfairSemiBold17,
        ),
      ),
    );
  }

  void _openSubscriptionFromProBadge(BuildContext context) {
    di.get<ProductAnalyticsService>().trackAffirmationPaywallView(
      originSurface: 'affirmation_top_nav_pro',
      offerType: OfferType.subscription,
      paywallVariant: 'top_nav_pro',
    );
    SubscriptionRoute.push(context);
  }
}
