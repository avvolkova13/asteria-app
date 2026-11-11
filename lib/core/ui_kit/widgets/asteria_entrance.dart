import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Reveals a newly visible piece of content without changing layout, hit tests
/// or semantics. Descendants entering together share the outer movement.
class AsteriaEntrance extends SingleChildRenderObjectWidget {
  const AsteriaEntrance({
    super.key,
    required super.child,
    this.replayKey,
    this.animateInitially = true,
  });

  static const duration = Duration(milliseconds: 320);
  static const distance = 3.0;

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
  static List<Widget> sections(List<Widget> children) => [
    for (final child in children)
      if (child is AsteriaEntrance ||
          child is Spacer ||
          child is ParentDataWidget ||
          (child is SizedBox && child.child == null))
        child
      else
        child.withEntrance(),
  ];

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

  static bool _enabled(BuildContext c) =>
      TickerMode.valuesOf(c).enabled && !MediaQuery.disableAnimationsOf(c);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderEntrance(
    enabled: _enabled(context),
    initially: animateInitially,
    replayKey: replayKey,
    scroll: _scrollsOf(context),
  );

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderEntrance).configure(
      _enabled(context),
      replayKey,
      _scrollsOf(context),
    );
  }
}

class _RenderEntrance extends RenderProxyBox {
  _RenderEntrance({
    required bool enabled,
    required bool initially,
    required Object? replayKey,
    required List<ScrollPosition> scroll,
  }) : _enabled = enabled,
       _done = !initially,
       _replayKey = replayKey,
       _scroll = scroll;

  bool _enabled;
  bool _done;
  Object? _replayKey;
  List<ScrollPosition> _scroll;
  bool _waitingForScroll = false;
  VoidCallback? _removeViewportCheck;
  Ticker? _ticker;
  double _progress = 0;

  void configure(bool enabled, Object? replayKey, List<ScrollPosition> scroll) {
    if (scroll.length != _scroll.length ||
        !scroll.asMap().entries.every(
          (entry) => identical(entry.value, _scroll[entry.key]),
        )) {
      _stopWaiting();
      _scroll = scroll;
    }
    if (replayKey != _replayKey) {
      _replayKey = replayKey;
      _finish();
      _done = false;
      _progress = 0;
      markNeedsCompositingBitsUpdate();
      markNeedsPaint();
    }
    if (_enabled != enabled) {
      _enabled = enabled;
      markNeedsCompositingBitsUpdate();
      if (!enabled && _ticker != null) _finish();
      markNeedsPaint();
    }
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

  void _tick(Duration elapsed) {
    _progress =
        (elapsed.inMicroseconds / AsteriaEntrance.duration.inMicroseconds)
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
      _stopWaiting();
      if (_hasAnimatingAncestor()) {
        _finish();
        super.paint(context, offset);
        return;
      }
      _ticker = Ticker(_tick)..start();
    }
    final eased = Curves.easeInOutSine.transform(_progress);
    final alpha = ((.08 + .92 * eased) * 255).round();
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
  Widget withEntrance() => AsteriaEntrance(
    key: key == null ? null : _EntranceKey(key!),
    child: this,
  );
}

class _EntranceKey extends ValueKey<Key> {
  const _EntranceKey(super.value);
}
