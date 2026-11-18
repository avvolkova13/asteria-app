import 'package:asteria_app/features/affirmation/affirmation_detail_screen.dart';
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

class _AffirmationCardStackState extends State<AffirmationCardStack>
    with SingleTickerProviderStateMixin {
  static const double _designWidth = 358;
  static const double _swipeThreshold = 80;
  static const double _velocityThreshold = 400;
  // One point of drag advances the same fraction of the card transition
  // whether the finger moves forward, reverses, or returns to its start.
  static const double _swipeTravel = 200;
  late final _motion = AnimationController.unbounded(vsync: this);

  int _frontIndex = 0;
  bool _committing = false;
  bool _showHint = false;
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
      _motion.value = 0;
      _frontIndex = 0;
      _trackedContentId = null;
      _committing = false;
    }

    if (signatureChanged || oldWidget.showSwipeHint != widget.showSwipeHint) {
      _showHint = widget.showSwipeHint && _motion.value == 0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _trackFrontCard());
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
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
    if (_committing || widget.affirmations.length < 2) return;
    if (_showHint) setState(() => _showHint = false);
    _motion.value = (_motion.value + details.delta.dy / _swipeTravel)
        .clamp(-1.0, 1.0)
        .toDouble();
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_committing || widget.affirmations.length < 2) return;
    final velocity = details.primaryVelocity ?? 0;
    final drag = _motion.value * _swipeTravel;
    if (drag.abs() < _swipeThreshold && velocity.abs() < _velocityThreshold) {
      _resetDrag();
      return;
    }
    _animateSwipe((drag == 0 ? velocity : drag).isNegative ? -1 : 1);
  }

  void _resetDrag() {
    if (_committing || _motion.value == 0) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = 0;
    } else {
      _motion.animateTo(
        0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _animateSwipe(int direction) async {
    if (_committing || widget.affirmations.length < 2) return;
    _committing = true;
    if (_showHint) setState(() => _showHint = false);
    LotusFeedback.selection();
    final contentId = widget.affirmations[_frontIndex].id;

    di.get<ProductAnalyticsService>().trackAffirmationEngagement(
      actionType: 'swipe',
      contentId: contentId,
    );

    if (!MediaQuery.disableAnimationsOf(context)) {
      final remaining = (direction - _motion.value).abs();
      try {
        await _motion
            .animateTo(
              direction.toDouble(),
              duration: Duration(milliseconds: (110 + 150 * remaining).round()),
              curve: Curves.easeOutCubic,
            )
            .orCancel;
      } on TickerCanceled {
        // The owner disposed the controller or replaced the deck.
        return;
      }
    }
    if (!mounted) return;
    setState(() {
      _frontIndex = _wrapIndex(_frontIndex - direction);
      _committing = false;
      _motion.value = 0;
    });
    _trackFrontCard();
  }

  int _wrapIndex(int index) {
    final length = widget.affirmations.length;
    return (index % length + length) % length;
  }

  bool _playerOpen = false;

  Future<void> _openPlayer() async {
    if (_playerOpen || _committing || widget.affirmations.isEmpty) return;
    _playerOpen = true;
    try {
      await AffirmationPlayerRoute.push(
        context,
        selection: AffirmationSelection(
          affirmation: widget.affirmations[_frontIndex],
          imageIndex: _frontIndex,
        ),
      );
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
                  child: AnimatedBuilder(
                    animation: _motion,
                    builder: (context, _) => Stack(
                      clipBehavior: Clip.none,
                      children: _buildLayerCards(context, scale),
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
    final step = 12.0 * scale;
    final frontTop = (count - 1) * step;
    final value = MediaQuery.disableAnimationsOf(context) ? 0.0 : _motion.value;
    final progress = value.abs();
    final target = _wrapIndex(_frontIndex + (value < 0 ? 1 : -1));
    final origin = <int, int>{
      for (var d = 1; d < count; d++) _wrapIndex(_frontIndex + d): d,
    };
    final destination = <int, int>{
      if (progress > 0)
        for (var d = 0; d < count; d++) _wrapIndex(target + d): d,
    };
    final layers = <({int index, double depth, double opacity})>[];
    for (final index in {...origin.keys, ...destination.keys}) {
      final from = origin[index] ?? count;
      final to = destination[index] ?? count;
      final opacity = !origin.containsKey(index)
          ? progress
          : progress > 0 && !destination.containsKey(index)
          ? 1 - progress
          : 1.0;
      layers.add((
        index: index,
        depth: from + (to - from) * progress,
        opacity: opacity,
      ));
    }
    layers.sort((a, b) => b.depth.compareTo(a.depth));
    final cards = <Widget>[];
    for (final layer in layers) {
      // A full-size face is scaled as one sheet. Its caption and corners arrive
      // with its artwork instead of growing from a clipped preview.
      final incoming = layer.index == target && progress > 0;
      cards.add(
        Positioned(
          key: ValueKey('deck-layer-${layer.index}'),
          top: frontTop - layer.depth.clamp(0.0, (count - 1).toDouble()) * step,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: Transform.scale(
                alignment: Alignment.topCenter,
                scale: 1 - layer.depth * (56 / _designWidth),
                child: Opacity(
                  opacity: layer.opacity,
                  child: RepaintBoundary(
                    child: AffirmationCardWidget(
                      affirmation: widget.affirmations[layer.index],
                      imageIndex: layer.index,
                      deck: incoming ? widget.affirmations : null,
                      isFront: incoming,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Turn the outgoing sheet towards its thin edge. Translation and tilt
    // follow the same signed progress through drag, cancellation and release.
    final angle = value * 1.48;
    final fade =
        1 -
        Curves.easeInOut.transform(((progress - .72) / .28).clamp(0.0, 1.0));
    final hasChoices = count > 1;
    cards.add(
      Padding(
        key: const ValueKey('deck-turning-sheet'),
        padding: EdgeInsets.only(top: frontTop),
        child: FractionalTranslation(
          translation: Offset(0, value * .30),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, .0008)
              ..rotateX(-angle),
            child: Opacity(
              opacity: fade,
              child: RepaintBoundary(
                child: AffirmationCardWidget(
                  affirmation: widget.affirmations[_frontIndex],
                  imageIndex: _frontIndex,
                  deck: widget.affirmations,
                  showSwipeHint: hasChoices && _showHint,
                  onSwipe: hasChoices ? _handleDragUpdate : null,
                  onSwipeEnd: hasChoices ? _handleDragEnd : null,
                  onSwipeCancel: hasChoices ? _resetDrag : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return cards;
  }
}
