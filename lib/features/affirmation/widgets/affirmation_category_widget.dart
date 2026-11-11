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
            onTap: !isLocked ? null : () {
              di.get<ProductAnalyticsService>().trackAffirmationLockedView(
                originSurface: 'affirmation_category_$category',
                offerType: OfferType.subscription,
              );
              di.get<ProductAnalyticsService>().trackAffirmationPaywallView(
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
  static const double _stackHeight = 389;
  static const double _cardHeight = 325;
  static const double _swipeThreshold = 80;
  static const double _velocityThreshold = 400;
  static const Duration _animationDuration = Duration(milliseconds: 220);

  int _frontIndex = 0;
  int _deckRevision = 0;
  double _dragOffset = 0;
  double _exitOffset = 0;
  bool _isAnimatingOut = false;
  bool _showHint = false;
  double _lastStackWidth = _designWidth;
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
      _dragOffset = (_dragOffset + details.delta.dx)
          .clamp(-140.0, 140.0)
          .toDouble();
    });
  }

  void _handleDragEnd(DragEndDetails details, double stackWidth) {
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
    _animateSwipe(direction, stackWidth);
  }

  void _resetDrag() {
    if (!mounted) {
      return;
    }

    setState(() => _dragOffset = 0);
  }

  Future<void> _animateSwipe(int direction, double stackWidth) async {
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
        _exitOffset = direction * stackWidth;
        _dragOffset = 0;
        _showHint = false;
      });
      await Future<void>.delayed(_animationDuration);
      if (!mounted || revision != _deckRevision) return;
    }

    setState(() {
      _showHint = false;
      _frontIndex = _wrapIndex(_frontIndex + 1);
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
        _lastStackWidth = stackWidth;

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
                      _animateSwipe(-1, _lastStackWidth);
                    }
                  : null,
              onDecrease: widget.affirmations.length > 1
                  ? () {
                      _animateSwipe(1, _lastStackWidth);
                    }
                  : null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: activate,
                onHorizontalDragUpdate: _handleDragUpdate,
                onHorizontalDragEnd: (details) =>
                    _handleDragEnd(details, stackWidth),
                child: SizedBox(
                  width: stackWidth,
                  height: _stackHeight * scale,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ..._buildLayerCards(context, scale),
                      if (_showHint && widget.affirmations.length > 1)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 210 * scale,
                          child: IgnorePointer(
                            child: SizedBox(
                              height: 32 * scale,
                              child: Center(child: _SwipeHintIcon(scale: scale)),
                            ),
                          ),
                        ),
                    ],
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

    final cards = <Widget>[];
    final length = widget.affirmations.length;

    if (length >= 3) {
      final affirmationIndex = _wrapIndex(_frontIndex + 2);
      cards.add(
        _buildCardLayer(
          affirmation: widget.affirmations[affirmationIndex],
          imageIndex: affirmationIndex,
          metrics: _CardLayerMetrics.back,
          scale: scale,
        ),
      );
    }

    if (length >= 2) {
      final affirmationIndex = _wrapIndex(_frontIndex + 1);
      cards.add(
        _buildCardLayer(
          affirmation: widget.affirmations[affirmationIndex],
          imageIndex: affirmationIndex,
          metrics: _CardLayerMetrics.middle,
          scale: scale,
        ),
      );
    }

    cards.add(
      _buildCardLayer(
        affirmation: widget.affirmations[_frontIndex],
        imageIndex: _frontIndex,
        metrics: _CardLayerMetrics.front,
        scale: scale,
        isFront: true,
      ),
    );

    return cards;
  }

  Widget _buildCardLayer({
    required AffirmationModel affirmation,
    required int imageIndex,
    required _CardLayerMetrics metrics,
    required double scale,
    bool isFront = false,
  }) {
    final double offset = isFront
        ? (_isAnimatingOut ? _exitOffset : _dragOffset)
        : 0;
    final duration =
        !MediaQuery.disableAnimationsOf(context) &&
            isFront &&
            (_isAnimatingOut || _dragOffset == 0)
        ? _animationDuration
        : Duration.zero;

    return Positioned(
      left: metrics.left * scale,
      top: metrics.top * scale,
      width: metrics.width * scale,
      height: _cardHeight * scale,
      child: AnimatedOpacity(
        duration: duration,
        curve: Curves.easeOutCubic,
        opacity: isFront && _isAnimatingOut ? 0 : 1,
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(offset, 0, 0),
          child: AffirmationCardWidget(
            affirmation: affirmation,
            imageIndex: imageIndex,
            borderOpacity: metrics.borderOpacity,
          ),
        ),
      ),
    );
  }
}

class _SwipeHintIcon extends StatelessWidget {
  final double scale;

  const _SwipeHintIcon({required this.scale});

  @override
  Widget build(BuildContext context) {
    final size = 32 * scale;

    return SizedBox.square(
      dimension: size,
      child: ClayAssetIcon(
        'assets/icons/swipe_hand.svg',
        width: size,
        height: size,
        tint: AppColors.white.withValues(alpha: 0.72),
      ),
    );
  }
}

class _CardLayerMetrics {
  final double left;
  final double top;
  final double width;
  final double borderOpacity;

  const _CardLayerMetrics({
    required this.left,
    required this.top,
    required this.width,
    required this.borderOpacity,
  });

  static const back = _CardLayerMetrics(
    left: 64,
    top: 0,
    width: 230,
    borderOpacity: 0.35,
  );

  static const middle = _CardLayerMetrics(
    left: 32,
    top: 32,
    width: 294,
    borderOpacity: 0.35,
  );

  static const front = _CardLayerMetrics(
    left: 0,
    top: 64,
    width: 358,
    borderOpacity: 0.1,
  );
}
