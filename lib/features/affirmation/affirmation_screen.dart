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
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
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
              delegate: const _AffirmationTopNavBarDelegate(),
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
  const _AffirmationTopNavBarDelegate();

  static const double _height = 105;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return const ColoredBox(
      color: _affirmationSurface,
      child: _AffirmationTopNavBar(),
    );
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class _AffirmationTopNavBar extends StatelessWidget {
  const _AffirmationTopNavBar();

  @override
  Widget build(BuildContext context) {
    final userProvider = di.get<UserProvider>();

    return SizedBox(
      height: _AffirmationTopNavBarDelegate._height,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 60),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
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
      child: Container(
        width: 76,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: isActive ? null : AppColors.textSecondary,
          image: isActive
              ? const DecorationImage(
                  image: AssetImage('assets/background/pro_gradient.webp'),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: LotusTap(
          behavior: HitTestBehavior.opaque,
          onTap: isActive ? null : () => _openSubscriptionFromProBadge(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'PRO',
                style: context.textTheme.inversePlayfairSemiBold17.copyWith(
                  height: 1.2,
                  letterSpacing: -0.408,
                ),
              ),
              if (!isActive) ...[
                const SizedBox(width: 4),
                const ClayIcon(
                  Icons.lock_outline,
                  size: 12,
                  color: AppColors.textInverse,
                ),
              ],
            ],
          ),
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
