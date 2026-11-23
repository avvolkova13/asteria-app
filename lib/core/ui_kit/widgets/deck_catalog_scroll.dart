import 'package:flutter/material.dart';

/// Allows a fresh swipe to reach a card while its catalog is still coasting.
class DeckCatalogScroll extends StatefulWidget {
  const DeckCatalogScroll({super.key, required this.child});

  final Widget child;

  static bool touchStoppedScroll(BuildContext context) {
    final position = Scrollable.maybeOf(context)?.position;
    return position is _DeckScrollPosition && position.stoppedByTouch;
  }

  @override
  State<DeckCatalogScroll> createState() => _DeckCatalogScrollState();
}

class _DeckCatalogScrollState extends State<DeckCatalogScroll> {
  final _controller = _DeckScrollController();
  static final _platforms = TargetPlatform.values.toSet();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PrimaryScrollController(
    controller: _controller,
    automaticallyInheritForPlatforms: _platforms,
    child: widget.child,
  );
}

class _DeckScrollController extends ScrollController {
  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) => _DeckScrollPosition(
    physics: physics,
    context: context,
    oldPosition: oldPosition,
  );
}

class _DeckScrollPosition extends ScrollPositionWithSingleContext {
  _DeckScrollPosition({
    required super.physics,
    required super.context,
    super.oldPosition,
  });

  // Flutter normally carries the drag's IgnorePointer into its ballistic
  // activity. Keep the coasting cards hit-testable for the very next gesture.
  @override
  bool get shouldIgnorePointer => false;

  bool stoppedByTouch = false;

  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    stoppedByTouch = activity is BallisticScrollActivity;
    return super.hold(holdCancelCallback);
  }
}
