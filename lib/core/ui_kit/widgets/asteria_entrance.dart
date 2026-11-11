import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// A tab that still contributes to an interrupted crossfade is already visible.
class AsteriaEntranceReplay extends InheritedWidget {
  const AsteriaEntranceReplay({
    super.key,
    required this.enabled,
    required super.child,
  });

  final bool enabled;

  static bool enabledOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<AsteriaEntranceReplay>()
          ?.enabled ??
      true;

  @override
  bool updateShouldNotify(AsteriaEntranceReplay oldWidget) =>
      enabled != oldWidget.enabled;
}

/// Reveals a newly visible piece of content without changing layout, hit tests
/// or semantics. Descendants entering together share the outer movement.
class AsteriaEntrance extends SingleChildRenderObjectWidget {
  const AsteriaEntrance({
    super.key,
    required super.child,
    this.replayKey,
    this.animateInitially = true,
    this.order,
  });

  static const duration = Duration(milliseconds: 480);
  static const distance = 16.0;

  /// Override the natural top-to-bottom reading order, e.g. in a small grid.
  /// The default uses this group's position in the visible page.
  final int? order;

  /// Change only for a newly displayed page or item, never for a repaint.
  final Object? replayKey;
  final bool animateInitially;

  /// Wait for the first decoded image frame. Cached images are already ready.
  static Widget imageFrame(
    BuildContext context,
    Widget child,
    int? frame,
    bool synchronous,
  ) => synchronous || frame == null ? child : AsteriaEntrance(child: child);

  /// For ordinary children of a section list. Keep layout-only children and
  /// parent-data widgets (such as Expanded and Positioned) in their slots.
  static List<Widget> sections(List<Widget> children) {
    var index = 0;
    return children.map((child) {
      if (child is Spacer ||
          child is ParentDataWidget ||
          (child is SizedBox && child.child == null)) {
        return child;
      }
      // The first screenful gets distinct beats even for short text rows.
      // Longer lists use the visible position, including after scroll restore.
      final order = index < 5 ? index : null;
      index++;
      if (child is AsteriaEntrance) {
        return AsteriaEntrance(
          key: child.key,
          replayKey: child.replayKey,
          animateInitially: child.animateInitially,
          order: child.order ?? order,
          child: child.child,
        );
      }
      return child.withEntrance(order: order);
    }).toList();
  }

  static List<ScrollPosition> _scrollsOf(BuildContext context) {
    final positions = <ScrollPosition>[];
    context.visitAncestorElements((element) {
      if (element is StatefulElement && element.state is ScrollableState) {
        positions.add((element.state as ScrollableState).position);
      }
      return true;
    });
    return positions;
  }

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderEntrance(
    active: TickerMode.valuesOf(context).enabled,
    reduced: MediaQuery.disableAnimationsOf(context),
    order: order,
    initially: animateInitially,
    replayKey: replayKey,
    scroll: _scrollsOf(context),
  );

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderEntrance).configure(
      active: TickerMode.valuesOf(context).enabled,
      reduced: MediaQuery.disableAnimationsOf(context),
      allowReplay:
          AsteriaEntranceReplay.enabledOf(context) &&
          !(Navigator.maybeOf(context)?.userGestureInProgress ?? false),
      order: order,
      replayKey: replayKey,
      scroll: _scrollsOf(context),
    );
  }
}

class _RenderEntrance extends RenderProxyBox {
  _RenderEntrance({
    required bool active,
    required bool reduced,
    required int? order,
    required bool initially,
    required Object? replayKey,
    required List<ScrollPosition> scroll,
  }) : _active = active,
       _reduced = reduced,
       _order = order,
       _done = !initially,
       _replayKey = replayKey,
       _scroll = scroll;

  bool _active;
  bool _reduced;
  int? _order;
  bool get _enabled => _active && !_reduced;
  Duration _delay = Duration.zero;
  bool _done;
  Object? _replayKey;
  List<ScrollPosition> _scroll;
  bool _waitingForScroll = false;
  VoidCallback? _removeViewportCheck;
  Ticker? _ticker;
  double _progress = 0;
  double _initialOpacity = .06;

  void configure({
    required bool active,
    required bool reduced,
    required bool allowReplay,
    required int? order,
    required Object? replayKey,
    required List<ScrollPosition> scroll,
  }) {
    _order = order;
    if (scroll.length != _scroll.length ||
        !scroll.asMap().entries.every(
          (entry) => identical(entry.value, _scroll[entry.key]),
        )) {
      _stopWaiting();
      _scroll = scroll;
    }
    final returned = !_active && active && allowReplay;
    final replay = replayKey != _replayKey || returned;
    if (!replay && active == _active && reduced == _reduced) return;
    _active = active;
    _reduced = reduced;
    _replayKey = replayKey;
    _finish();
    if (_enabled && replay) {
      // The previous page is fading away. Keep a visual foothold on the
      // returning page while its individual groups rise into place.
      _initialOpacity = returned ? .28 : .06;
      _done = false;
      _progress = 0;
    }
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  void _stopWaiting() {
    _removeViewportCheck?.call();
    _removeViewportCheck = null;
    if (!_waitingForScroll) return;
    for (final position in _scroll) {
      position.removeListener(markNeedsPaint);
    }
    _waitingForScroll = false;
  }

  void _waitForViewport(PaintingContext context) {
    if (!_waitingForScroll) {
      for (final position in _scroll) {
        position.addListener(markNeedsPaint);
      }
      _waitingForScroll = true;
    }
    // A cached layer can enter the viewport without scrolling or repainting
    // the child, e.g. when a keyboard closes or the section above collapses.
    _removeViewportCheck?.call();
    _removeViewportCheck = context.addCompositionCallback((layer) {
      if (layer.attached && attached && _inViewport()) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (attached && _waitingForScroll) markNeedsPaint();
        });
      }
    });
  }

  void _finish() {
    _done = true;
    if (attached) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (attached) markNeedsCompositingBitsUpdate();
      });
    }
    _progress = 1;
    _stopWaiting();
    _ticker?.dispose();
    _ticker = null;
  }

  bool _hasAnimatingAncestor() {
    for (RenderObject? p = parent; p != null; p = p.parent) {
      if (p is _RenderEntrance && p._enabled && !p._done) return true;
    }
    return false;
  }

  bool _inViewport() {
    if (_scroll.isEmpty) return true;
    for (
      RenderObject? viewport = parent;
      viewport != null;
      viewport = viewport.parent
    ) {
      if (viewport is RenderAbstractViewport) {
        final rect = MatrixUtils.transformRect(
          getTransformTo(viewport),
          paintBounds,
        );
        if (!rect.overlaps(viewport.paintBounds)) return false;
      }
    }
    return true;
  }

  Duration _staggerDelay() {
    final order = _order;
    if (order != null) {
      return Duration(milliseconds: order.clamp(0, 4) * 48);
    }
    // Resolve only once, after layout. Using the visible position instead of
    // the list index also works when returning to a deeply scrolled screen.
    RenderObject root = this;
    while (root.parent != null) {
      root = root.parent!;
    }
    if (root is! RenderView || root.size.isEmpty) return Duration.zero;
    final origin = localToGlobal(Offset.zero, ancestor: root);
    if (!origin.isFinite) return Duration.zero;
    final row = (origin.dy / root.size.height).clamp(0.0, 1.0);
    final column = (origin.dx / root.size.width).clamp(0.0, 1.0);
    return Duration(milliseconds: (row * 170 + column * 42).round());
  }

  void _tick(Duration elapsed) {
    _progress =
        ((elapsed - _delay).inMicroseconds /
                AsteriaEntrance.duration.inMicroseconds)
            .clamp(0, 1);
    if (_progress >= 1) _finish();
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_enabled && !_done) _finish();
    if (_done || child == null || size.isEmpty) {
      layer = null;
      super.paint(context, offset);
      return;
    }
    if (_ticker == null) {
      if (!_inViewport()) {
        _waitForViewport(context);
        return;
      }
      // New rows discovered by scrolling should respond as they cross the
      // viewport edge. Stagger siblings when a page is presented together.
      _delay = _waitingForScroll ? Duration.zero : _staggerDelay();
      _stopWaiting();
      if (_hasAnimatingAncestor()) {
        _finish();
        super.paint(context, offset);
        return;
      }
      _ticker = Ticker(_tick)..start();
    }
    final eased = const Cubic(.22, .68, .18, 1).transform(_progress);
    final alpha = ((_initialOpacity + (1 - _initialOpacity) * eased) * 255)
        .round();
    layer = context.pushOpacity(
      offset + Offset(0, AsteriaEntrance.distance * (1 - eased)),
      alpha,
      super.paint,
      oldLayer: layer as OpacityLayer?,
    );
  }

  // An ancestor may paint into an opacity layer on the very first frame.
  @override
  bool get alwaysNeedsCompositing => child != null && _enabled && !_done;

  @override
  void detach() {
    _stopWaiting();
    if (_ticker != null) _finish();
    super.detach();
  }
}

/// Preserve the logical identity of a moving item without assigning its
/// GlobalKey to a second widget. Unkeyed items keep Flutter's usual identity.
extension AsteriaEntranceWidget on Widget {
  Widget withEntrance({int? order}) => AsteriaEntrance(
    order: order,
    key: key == null ? null : _EntranceKey(key!),
    child: this,
  );
}

class _EntranceKey extends ValueKey<Key> {
  const _EntranceKey(super.value);
}
