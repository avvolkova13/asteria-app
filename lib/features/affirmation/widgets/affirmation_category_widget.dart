import 'package:asteria_app/core/ui_kit/widgets/swipe_card_stack.dart';
import 'package:asteria_app/features/affirmation/selected_affirmation_player.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/closed_content_modal.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_card_widget.dart';
import 'package:flutter/material.dart';

const Color _affirmationGold = Color(0xFFF3B76A);

class AffirmationCategoryWidget extends StatelessWidget {
  final String category;
  final List<AffirmationModel> affirmations;
  final bool showAffirmations;
  final bool showSwipeHint;

  const AffirmationCategoryWidget({
    super.key,
    required this.category,
    required this.affirmations,
    this.showAffirmations = true,
    this.showSwipeHint = false,
  });

  String getIconPath() {
    switch (category) {
      case 'love':
        return 'assets/icons/sphere_icon/ic_heart.svg';
      case 'abundance':
        return 'assets/icons/sub/key.svg';
      case 'strength':
        return 'assets/icons/sub/shield.svg';
      case 'creativity':
        return 'assets/icons/sub/palette.svg';
      case 'lunar':
        return 'assets/icons/sub/moon_icon.svg';
      case 'calm':
        return 'assets/icons/sub/voice.svg';
      default:
        return 'assets/icons/sphere_icon/ic_heart.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = !showAffirmations;
    final categoryName = _localizedCategoryName(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: isLocked,
          label: isLocked
              ? context.l10n.affirmationCategoryLocked(categoryName)
              : categoryName,
          child: LotusTap(
            behavior: HitTestBehavior.opaque,
            onTap: !isLocked
                ? null
                : () {
                    di
                        .get<ProductAnalyticsService>()
                        .trackAffirmationLockedView(
                          originSurface: 'affirmation_category_$category',
                          offerType: OfferType.subscription,
                        );
                    di
                        .get<ProductAnalyticsService>()
                        .trackAffirmationPaywallView(
                          originSurface: 'affirmation_category_$category',
                          offerType: OfferType.subscription,
                          paywallVariant: 'category_lock',
                        );
                    ClosedContentModal.show(
                      context,
                      description: context.l10n.affirmationSubscriptionRequired,
                    );
                  },
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: isLocked ? 44 : 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      categoryName,
                      style: context.textTheme.playfairSemiBold24.copyWith(
                        color: AppColors.textInverse,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CategoryIcon(path: getIconPath(), isLocked: isLocked),
                ],
              ),
            ),
          ),
        ).withEntrance(),
        if (showAffirmations && affirmations.isNotEmpty) ...[
          const SizedBox(height: 16),
          AffirmationCardStack(
            key: ValueKey('affirmation_card_stack_$category'),
            affirmations: affirmations,
            showSwipeHint: showSwipeHint,
          ),
        ],
      ],
    );
  }

  String _localizedCategoryName(BuildContext context) {
    return switch (category) {
      'love' => context.l10n.affirmationCategoryLove,
      'abundance' => context.l10n.affirmationCategoryAbundance,
      'strength' => context.l10n.affirmationCategoryStrength,
      'creativity' => context.l10n.affirmationCategoryCreativity,
      'lunar' => context.l10n.affirmationCategoryLunar,
      'calm' => context.l10n.affirmationCategoryCalm,
      _ => category,
    };
  }
}

class _CategoryIcon extends StatelessWidget {
  final String path;
  final bool isLocked;

  const _CategoryIcon({required this.path, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    final icon = ClayAssetIcon(
      path,
      width: 24,
      height: 24,
      tint: _affirmationGold.withValues(alpha: isLocked ? 0.7 : 1),
    );

    if (!isLocked) {
      return icon;
    }

    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.cardTinted,
                shape: BoxShape.circle,
              ),
              child: const ClayIcon(
                Icons.lock_outline,
                size: 8,
                color: AppColors.textInverse,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AffirmationCardStack extends StatelessWidget {
  const AffirmationCardStack({
    super.key,
    required this.affirmations,
    this.showSwipeHint = false,
  });

  final List<AffirmationModel> affirmations;
  final bool showSwipeHint;

  @override
  Widget build(BuildContext context) => SwipeCardStack<AffirmationModel>(
    items: affirmations,
    idOf: (item) => item.id,
    label: (context, item) => context.l10n.affirmationSemantics(item.text),
    showSwipeHint: showSwipeHint,
    onView: (item) => di
        .get<ProductAnalyticsService>()
        .trackAffirmationCardView(contentId: item.id),
    onSwipe: (item) => di
        .get<ProductAnalyticsService>()
        .trackAffirmationEngagement(actionType: 'swipe', contentId: item.id),
    onOpen: (context, item, index) async {
      await AffirmationPlayerRoute.push(
        context,
        selection: AffirmationSelection(
          affirmation: item,
          imageIndex: AffirmationCardWidget.coverIndex(
            index,
            affirmations.length,
          ),
        ),
      );
    },
    cardBuilder: (context, index, front, hint) => AffirmationCardWidget(
      affirmation: affirmations[index],
      imageIndex: index,
      isFront: front,
      deck: affirmations,
      showSwipeHint: hint,
    ),
  );
}
