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
            child: SizedBox(
              height: 24,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class AffirmationCardStack extends StatefulWidget {
  final List<AffirmationModel> affirmations;
  final bool showSwipeHint;

  const AffirmationCardStack({
    super.key,
    required this.affirmations,
    this.showSwipeHint = false,
  });

  @override
  State<AffirmationCardStack> createState() => _AffirmationCardStackState();
}

class _AffirmationCardStackState extends State<AffirmationCardStack> {
  static const double _designWidth = 358;
  static const double _swipeThreshold = 80;
  static const double _velocityThreshold = 400;
  static const Duration _animationDuration = Duration(milliseconds: 220);

  int _frontIndex = 0;
  int _deckRevision = 0;
  double _dragOffset = 0;
  double _exitOffset = 0;
  bool _isAnimatingOut = false;
  bool _showHint = false;
  int _transitionDirection = -1;
  String? _trackedContentId;

  @override
  void initState() {
    super.initState();
    _showHint = widget.showSwipeHint;
    WidgetsBinding.instance.addPostFrameCallback((_) => _trackFrontCard());
  }

  @override
  void didUpdateWidget(covariant AffirmationCardStack oldWidget) {
    super.didUpdateWidget(oldWidget);

    final signatureChanged =
        _affirmationSignature(oldWidget.affirmations) !=
        _affirmationSignature(widget.affirmations);

    if (_frontIndex >= widget.affirmations.length) {
      _frontIndex = 0;
    }

    if (signatureChanged) {
      _deckRevision++;
      _frontIndex = 0;
      _trackedContentId = null;
      _dragOffset = 0;
      _exitOffset = 0;
      _isAnimatingOut = false;
    }

    if (signatureChanged || oldWidget.showSwipeHint != widget.showSwipeHint) {
      _showHint = widget.showSwipeHint && _dragOffset == 0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _trackFrontCard());
    }
  }

  String _affirmationSignature(List<AffirmationModel> affirmations) {
    return affirmations.map((affirmation) => affirmation.id).join('|');
  }

  void _trackFrontCard() {
    if (!mounted || widget.affirmations.isEmpty) {
      return;
    }

    final contentId = widget.affirmations[_frontIndex].id;
    if (_trackedContentId == contentId) {
      return;
    }

    _trackedContentId = contentId;
    di.get<ProductAnalyticsService>().trackAffirmationCardView(
      contentId: contentId,
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_isAnimatingOut || widget.affirmations.length < 2) {
      return;
    }

    setState(() {
      _showHint = false;
      _dragOffset = (_dragOffset + details.delta.dy)
          .clamp(-140.0, 140.0)
          .toDouble();
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isAnimatingOut || widget.affirmations.length < 2) {
      _resetDrag();
      return;
    }

    final velocity = details.primaryVelocity ?? 0;
    final shouldSwipe =
        _dragOffset.abs() >= _swipeThreshold ||
        velocity.abs() >= _velocityThreshold;

    if (!shouldSwipe) {
      _resetDrag();
      return;
    }

    final direction = _dragOffset == 0
        ? (velocity < 0 ? -1 : 1)
        : (_dragOffset < 0 ? -1 : 1);
    _animateSwipe(direction);
  }

  void _resetDrag() {
    if (!mounted) {
      return;
    }

    setState(() => _dragOffset = 0);
  }

  Future<void> _animateSwipe(int direction) async {
    if (_isAnimatingOut || widget.affirmations.length < 2) {
      return;
    }

    LotusFeedback.selection();
    final contentId = widget.affirmations[_frontIndex].id;

    di.get<ProductAnalyticsService>().trackAffirmationEngagement(
      actionType: 'swipe',
      contentId: contentId,
    );

    if (!MediaQuery.disableAnimationsOf(context)) {
      final revision = _deckRevision;
      setState(() {
        _isAnimatingOut = true;
        _transitionDirection = direction;
        _exitOffset = direction * 58;
        _dragOffset = 0;
        _showHint = false;
      });
      await Future<void>.delayed(_animationDuration);
      if (!mounted || revision != _deckRevision) return;
    }

    setState(() {
      _showHint = false;
      _frontIndex = _wrapIndex(_frontIndex - direction);
      _isAnimatingOut = false;
      _exitOffset = 0;
    });
    _trackFrontCard();
  }

  int _wrapIndex(int index) {
    final length = widget.affirmations.length;
    return (index % length + length) % length;
  }

  bool _playerOpen = false;

  Future<void> _openPlayer() async {
    if (_playerOpen || _isAnimatingOut || widget.affirmations.isEmpty) return;
    _playerOpen = true;
    try {
      await AffirmationPlayerRoute.push(context);
    } finally {
      _playerOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackWidth = constraints.maxWidth
            .clamp(0.0, _designWidth)
            .toDouble();
        final scale = stackWidth / _designWidth;

        return Align(
          alignment: Alignment.center,
          child: LotusFeedback(
            onActivate: widget.affirmations.isEmpty ? null : _openPlayer,
            keyboard: true,
            builder: (activate) => Semantics(
              button: widget.affirmations.isNotEmpty,
              excludeSemantics: true,
              onTap: activate,
              onTapHint: widget.affirmations.isEmpty
                  ? null
                  : context.l10n.affirmationOpenPlayer,
              label: _semanticLabel(context),
              hint: widget.affirmations.length > 1
                  ? context.l10n.affirmationSwipeHint
                  : null,
              onIncrease: widget.affirmations.length > 1
                  ? () {
                      _animateSwipe(-1);
                    }
                  : null,
              onDecrease: widget.affirmations.length > 1
                  ? () {
                      _animateSwipe(1);
                    }
                  : null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: activate,
                child: SizedBox(
                  width: stackWidth,
                  child: ClipRect(
                    child: AnimatedSize(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : _animationDuration,
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: Stack(children: _buildLayerCards(context, scale)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _semanticLabel(BuildContext context) {
    if (widget.affirmations.isEmpty) {
      return context.l10n.affirmationsTitle;
    }

    final affirmation = widget.affirmations[_frontIndex];
    return context.l10n.affirmationSemantics(affirmation.text);
  }

  List<Widget> _buildLayerCards(BuildContext context, double scale) {
    if (widget.affirmations.isEmpty) {
      return const [];
    }

    final count = widget.affirmations.length.clamp(1, 3);
    final step = 9.0 * scale;
    final hasChoices = widget.affirmations.length > 1;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final direction = _isAnimatingOut
        ? _transitionDirection
        : (_dragOffset > 0 ? 1 : -1);
    final cards = <Widget>[];
    for (var depth = count - 1; depth > 0; depth--) {
      final index = _wrapIndex(_frontIndex - direction * depth);
      cards.add(
        Positioned(
          top: (count - depth - 1) * step,
          left: depth * step,
          right: depth * step,
          child: IgnorePointer(
            child: AffirmationCardWidget(
              affirmation: widget.affirmations[index],
              imageIndex: index,
              isFront: false,
            ),
          ),
        ),
      );
    }
    final duration = reduced || (_dragOffset != 0 && !_isAnimatingOut)
        ? Duration.zero
        : _animationDuration;
    cards.add(
      Padding(
        padding: EdgeInsets.only(top: (count - 1) * step),
        child: TweenAnimationBuilder<double>(
          key: ValueKey(widget.affirmations[_frontIndex].id),
          tween: Tween(begin: reduced ? 1.0 : 0.0, end: 1.0),
          duration: reduced ? Duration.zero : _animationDuration,
          curve: Curves.easeOutCubic,
          builder: (_, progress, child) => Transform.translate(
            offset: Offset(0, -_transitionDirection * 12 * (1 - progress)),
            child: child,
          ),
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(
              0,
              reduced ? 0 : (_isAnimatingOut ? _exitOffset : _dragOffset * .28),
              0,
            ),
            child: AnimatedOpacity(
              duration: duration,
              opacity: _isAnimatingOut ? 0 : 1,
              child: AffirmationCardWidget(
                affirmation: widget.affirmations[_frontIndex],
                imageIndex: _frontIndex,
                showSwipeHint: hasChoices && _showHint,
                onSwipe: hasChoices ? _handleDragUpdate : null,
                onSwipeEnd: hasChoices ? _handleDragEnd : null,
                onSwipeCancel: hasChoices ? _resetDrag : null,
              ),
            ),
          ),
        ),
      ),
    );
    return cards;
  }
}
