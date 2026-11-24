import 'package:asteria_app/core/ui_kit/widgets/deck_catalog_scroll.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef SwipeStackCardBuilder =
    Widget Function(
      BuildContext context,
      int index,
      bool isFront,
      bool showSwipeHint,
    );

class SwipeCardStack<T> extends StatefulWidget {
  const SwipeCardStack({
    super.key,
    required this.items,
    required this.idOf,
    required this.label,
    required this.onOpen,
    required this.cardBuilder,
    this.showSwipeHint = false,
    this.onView,
    this.belowCard,
    this.onSwipe,
  });

  static const artworkHeight = 216.0;
  static const artworkGestureKey = ValueKey('practice-deck-artwork-gesture');

  final List<T> items;
  final String Function(T) idOf;
  final String Function(BuildContext, T) label;
  final Future<void> Function(BuildContext, T, int) onOpen;
  final SwipeStackCardBuilder cardBuilder;
  final Widget Function(BuildContext context, T selected)? belowCard;
  final bool showSwipeHint;
  final ValueChanged<T>? onView, onSwipe;

  @override
  State<SwipeCardStack<T>> createState() => _SwipeCardStackState<T>();
}

class _SwipeCardStackState<T> extends State<SwipeCardStack<T>>
    with SingleTickerProviderStateMixin {
  static const double _designWidth = 358;
  static const double _velocityThreshold = 400;
  static const Duration _animationDuration = Duration(milliseconds: 220);

  int _frontIndex = 0;
  late final _release = AnimationController(
    vsync: this,
    duration: _animationDuration,
  )..addStatusListener(_onReleaseStatus);
  Offset _travel = Offset.zero;
  double get _dragOffset => _axis == Axis.horizontal ? _travel.dx : _travel.dy;
  int? _outgoingIndex;
  Axis _axis = Axis.vertical;
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
  void didUpdateWidget(covariant SwipeCardStack<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final signatureChanged =
        _signature(oldWidget.items) != _signature(widget.items);

    if (_frontIndex >= widget.items.length) {
      _frontIndex = 0;
    }

    if (signatureChanged) {
      _release.reset();
      _frontIndex = 0;
      _trackedContentId = null;
      _travel = Offset.zero;
      _outgoingIndex = null;
    }

    if (signatureChanged || oldWidget.showSwipeHint != widget.showSwipeHint) {
      _showHint = widget.showSwipeHint && _dragOffset == 0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _trackFrontCard());
    }
  }

  @override
  void dispose() {
    _release.dispose();
    super.dispose();
  }

  String _signature(List<T> items) {
    return items.map(widget.idOf).join('|');
  }

  void _trackFrontCard() {
    if (!mounted || widget.items.isEmpty) {
      return;
    }

    final contentId = widget.idOf(widget.items[_frontIndex]);
    if (_trackedContentId == contentId) {
      return;
    }

    _trackedContentId = contentId;
    widget.onView?.call(widget.items[_frontIndex]);
  }

  void _startDrag(DragStartDetails details) {
    // A fresh contact can take over before the departing card finishes fading.
    _release.stop();
    setState(() {
      _outgoingIndex = null;
      _travel = Offset.zero;
      _showHint = false;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _travel += details.delta;
      _axis = _travel.dx.abs() >= _travel.dy.abs()
          ? Axis.horizontal
          : Axis.vertical;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final speed = _axis == Axis.horizontal ? velocity.dx : velocity.dy;
    if (_travel.distance < kTouchSlop && speed.abs() < _velocityThreshold) {
      _resetDrag();
      return;
    }
    final delta = _dragOffset == 0 ? speed : _dragOffset;
    _animateSwipe(delta.isNegative ? -1 : 1);
  }

  void _resetDrag() {
    if (mounted && _outgoingIndex == null && _travel != Offset.zero) {
      setState(() => _travel = Offset.zero);
    }
  }

  void _onReleaseStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _outgoingIndex != null) {
      setState(() {
        _outgoingIndex = null;
        _travel = Offset.zero;
      });
    }
  }

  void _animateSwipe(int direction) {
    if (widget.items.length < 2) return;
    final previous = _frontIndex;
    final reduced = MediaQuery.disableAnimationsOf(context);
    LotusFeedback.selection();
    widget.onSwipe?.call(widget.items[previous]);

    // Selection belongs to the completed gesture, independently of how long
    // its visual transition takes. A tap or a second swipe sees this item.
    setState(() {
      _showHint = false;
      _transitionDirection = direction;
      _frontIndex = _wrapIndex(previous - direction);
      _outgoingIndex = reduced ? null : previous;
      if (reduced) _travel = Offset.zero;
    });
    if (reduced) {
      _release.stop();
    } else {
      _release.forward(from: 0);
    }
    _trackFrontCard();
  }

  int _wrapIndex(int index) {
    final length = widget.items.length;
    return (index % length + length) % length;
  }

  bool _playerOpen = false;

  Future<void> _openPlayer() async {
    if (_playerOpen || widget.items.isEmpty) return;
    _playerOpen = true;
    try {
      await widget.onOpen(context, widget.items[_frontIndex], _frontIndex);
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

        final hasChoices = widget.items.length > 1;
        final peek = (widget.items.length.clamp(1, 3) - 1) * 12 * scale;
        final deck = Align(
          alignment: Alignment.center,
          child: LotusFeedback(
            onActivate: widget.items.isEmpty ? null : _openPlayer,
            keyboard: true,
            builder: (activate) => Semantics(
              button: widget.items.isNotEmpty,
              excludeSemantics: true,
              onTap: activate,
              label: _semanticLabel(context),
              hint: widget.items.length > 1
                  ? context.l10n.affirmationSwipeHint
                  : null,
              onIncrease: widget.items.length > 1
                  ? () {
                      _animateSwipe(-1);
                    }
                  : null,
              onDecrease: widget.items.length > 1
                  ? () {
                      _animateSwipe(1);
                    }
                  : null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (!DeckCatalogScroll.touchStoppedScroll(context)) {
                    activate?.call();
                  }
                },
                dragStartBehavior: DragStartBehavior.down,
                onHorizontalDragStart: hasChoices ? _startDrag : null,
                onHorizontalDragUpdate: hasChoices ? _handleDragUpdate : null,
                onHorizontalDragEnd: hasChoices ? _handleDragEnd : null,
                child: SizedBox(
                  width: stackWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedBuilder(
                        animation: _release,
                        builder: (context, _) => Stack(
                          clipBehavior: Clip.none,
                          children: _buildLayerCards(context, scale),
                        ),
                      ),
                      if (hasChoices)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: peek + SwipeCardStack.artworkHeight,
                          child: RawGestureDetector(
                            key: SwipeCardStack.artworkGestureKey,
                            behavior: HitTestBehavior.translucent,
                            excludeFromSemantics: true,
                            gestures: {
                              _ArtworkPan:
                                  GestureRecognizerFactoryWithHandlers<
                                    _ArtworkPan
                                  >(
                                    _ArtworkPan.new,
                                    (pan) => pan
                                      ..dragStartBehavior =
                                          DragStartBehavior.down
                                      ..gestureSettings =
                                          MediaQuery.gestureSettingsOf(context)
                                      ..onStart = _startDrag
                                      ..onUpdate = _handleDragUpdate
                                      ..onEnd = _handleDragEnd,
                                  ),
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        final below = widget.belowCard;
        if (below == null || widget.items.isEmpty) return deck;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            deck,
            SizedBox(
              width: stackWidth,
              child: below(context, widget.items[_frontIndex]),
            ),
          ],
        );
      },
    );
  }

  String _semanticLabel(BuildContext context) {
    return widget.items.isEmpty
        ? ''
        : widget.label(context, widget.items[_frontIndex]);
  }

  List<Widget> _buildLayerCards(BuildContext context, double scale) {
    if (widget.items.isEmpty) {
      return const [];
    }

    final count = widget.items.length.clamp(1, 3);
    final topStep = 12.0 * scale;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final transitioning = _outgoingIndex != null;
    final visualFront = _outgoingIndex ?? _frontIndex;
    final direction = transitioning
        ? _transitionDirection
        : (_dragOffset > 0 ? 1 : -1);
    final release = transitioning && !reduced ? _release.value : 0.0;
    final travel = Curves.easeOutCubic.transform(release);
    final frontTop = (count - 1) * topStep;
    final cards = <Widget>[];
    for (var depth = count - 1; depth > 0; depth--) {
      final index = _wrapIndex(visualFront - direction * depth);
      final nextFace =
          depth == 1 && !reduced && (transitioning || _dragOffset != 0);
      final remainingDepth = depth - travel;
      final top = frontTop - remainingDepth * topStep;
      cards.add(
        Positioned(
          top: top,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: Transform.scale(
                scale: 1 - remainingDepth * 56 / _designWidth,
                alignment: Alignment.topCenter,
                child: widget.cardBuilder(context, index, nextFace, false),
              ),
            ),
          ),
        ),
      );
    }
    final held = _dragOffset * .28;
    final travelOffset = held + (direction * 58 - held) * travel;
    // Ease the last few points of travel into the space between categories.
    // The card keeps its rounded edge while the neighbouring title stays clear.
    final limit = _axis == Axis.horizontal
        ? 18.0
        : (travelOffset < 0 ? frontTop + 14 : 22.0);
    final freeTravel = limit * .65;
    final excess = travelOffset.abs() - freeTravel;
    final offset = excess <= 0
        ? travelOffset
        : travelOffset.sign *
              (freeTravel + excess / (1 + excess / (limit - freeTravel)));
    cards.add(
      Padding(
        padding: EdgeInsets.only(top: (count - 1) * topStep),
        child: Transform.translate(
          offset: Offset(
            !reduced && _axis == Axis.horizontal ? offset : 0,
            !reduced && _axis == Axis.vertical ? offset : 0,
          ),
          child: Opacity(
            opacity: 1 - Curves.easeInOut.transform(release),
            child: widget.cardBuilder(
              context,
              visualFront,
              true,
              widget.items.length > 1 && _showHint,
            ),
          ),
        ),
      ),
    );
    return cards;
  }
}

/// An artwork pan competes with the vertical catalog scroll. Use the same
/// touch slop as that scroll so it cannot claim a slow swipe on the picture.
class _ArtworkPan extends PanGestureRecognizer {
  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind kind,
    double? deviceTouchSlop,
  ) => globalDistanceMoved.abs() > computeHitSlop(kind, gestureSettings);
}
