import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lotus_glyph_motion.dart';

/// Couples the pressed surface and its artwork to the control that owns the action.
class LotusFeedback extends StatefulWidget {
  const LotusFeedback({
    super.key,
    required this.onActivate,
    required this.builder,
    this.keyboard = false,
  });

  final VoidCallback? onActivate;
  final bool keyboard;
  final Widget Function(VoidCallback? activate) builder;

  static void selection() => unawaited(HapticFeedback.selectionClick());

  /// For text spans or accessibility actions rendered separately from the control.
  static VoidCallback action(VoidCallback callback) => () {
    selection();
    callback();
  };

  @override
  State<LotusFeedback> createState() => _LotusFeedbackState();
}

class _LotusFeedbackState extends State<LotusFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: LotusMotionScope.duration,
  );
  // Hit testing dispatches to the inner surface first. Only its press scales.
  static final _owners = <int, _LotusFeedbackState>{};
  int? _pointer;
  Offset? _origin;
  bool _pressed = false;
  bool _showFocus = false;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _release();
      if (_pulse.isAnimating) _pulse.reset();
    }
  }

  @override
  void didUpdateWidget(LotusFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onActivate == null) {
      _release();
      _pulse.reset();
    }
  }

  void _down(PointerDownEvent event) {
    if (_reduceMotion ||
        _pointer != null ||
        _owners.containsKey(event.pointer) ||
        event.buttons != kPrimaryButton) {
      return;
    }
    _owners[event.pointer] = this;
    _pointer = event.pointer;
    _origin = event.position;
    setState(() => _pressed = true);
  }

  void _move(PointerMoveEvent event) {
    if (event.pointer == _pointer &&
        (event.position - _origin!).distance > kTouchSlop) {
      _end(event);
    }
  }

  void _release() {
    if (_pointer != null) _owners.remove(_pointer);
    _pointer = null;
    _origin = null;
    _pressed = false;
  }

  void _end(PointerEvent event) {
    if (event.pointer == _pointer) setState(_release);
  }

  void _activate() {
    final callback = widget.onActivate;
    if (callback == null) return;
    LotusFeedback.selection();
    if (!_reduceMotion) _pulse.forward(from: 0);
    callback();
  }

  @override
  void dispose() {
    _release();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onActivate != null;
    final control = widget.builder(enabled ? _activate : null);
    return Listener(
      onPointerDown: enabled ? _down : null,
      onPointerMove: _move,
      onPointerUp: _end,
      onPointerCancel: _end,
      child: TweenAnimationBuilder<double>(
        tween: Tween(
          end: _pressed && !_reduceMotion ? LotusMotionScope.pressedScale : 1,
        ),
        duration: _reduceMotion
            ? Duration.zero
            : LotusMotionScope.pressDuration,
        curve: Curves.easeOut,
        builder: (context, pressScale, child) => AnimatedBuilder(
          animation: _pulse,
          child: child,
          builder: (context, surface) {
            // A quick tap or keyboard activation can finish before the first press frame.
            final phase = (_pulse.value / .45).clamp(0.0, 1.0);
            final activationScale = _reduceMotion
                ? 1.0
                : 1 - .018 * math.sin(math.pi * phase);
            return Transform.scale(
              scale: math.min(pressScale, activationScale),
              transformHitTests: false,
              child: surface,
            );
          },
        ),
        child: LotusMotionScope(
          pulse: _pulse,
          child: widget.keyboard
              ? FocusableActionDetector(
                  enabled: enabled,
                  includeFocusSemantics: false,
                  onShowFocusHighlight: (show) =>
                      setState(() => _showFocus = show),
                  actions: {
                    ActivateIntent: CallbackAction<ActivateIntent>(
                      onInvoke: (_) {
                        _activate();
                        return null;
                      },
                    ),
                    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
                      onInvoke: (_) {
                        _activate();
                        return null;
                      },
                    ),
                  },
                  child: DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                      border: enabled && _showFocus
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 1.5,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: control,
                  ),
                )
              : control,
        ),
      ),
    );
  }
}

/// The original hit testing, scroll arena and semantics remain with GestureDetector.
class LotusTap extends StatelessWidget {
  const LotusTap({
    super.key,
    required this.onTap,
    required this.child,
    this.behavior,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
  });
  final VoidCallback? onTap;
  final Widget child;
  final HitTestBehavior? behavior;
  final GestureDragUpdateCallback? onHorizontalDragUpdate;
  final GestureDragEndCallback? onHorizontalDragEnd;

  @override
  Widget build(BuildContext context) => LotusFeedback(
    onActivate: onTap,
    keyboard: true,
    builder: (activate) => GestureDetector(
      onTap: activate,
      behavior: behavior,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      child: child,
    ),
  );
}

class LotusInkTap extends StatelessWidget {
  const LotusInkTap({
    super.key,
    required this.onTap,
    required this.child,
    this.borderRadius,
  });
  final VoidCallback? onTap;
  final Widget child;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => LotusFeedback(
    onActivate: onTap,
    builder: (activate) => InkWell(
      onTap: activate,
      borderRadius: borderRadius,
      enableFeedback: false,
      child: child,
    ),
  );
}

/// Keeps native focus, shortcuts, tooltips, hit targets and disabled styling.
abstract final class LotusButtons {
  static Widget text({
    required VoidCallback? onPressed,
    required Widget child,
    ButtonStyle? style,
  }) => LotusFeedback(
    onActivate: onPressed,
    builder: (activate) =>
        TextButton(onPressed: activate, style: style, child: child),
  );

  static Widget textIcon({
    required VoidCallback? onPressed,
    required Widget icon,
    required Widget label,
    ButtonStyle? style,
  }) => LotusFeedback(
    onActivate: onPressed,
    builder: (activate) => TextButton.icon(
      onPressed: activate,
      style: style,
      icon: icon,
      label: label,
    ),
  );

  static Widget elevated({
    required VoidCallback? onPressed,
    required Widget child,
    ButtonStyle? style,
  }) => LotusFeedback(
    onActivate: onPressed,
    builder: (activate) =>
        ElevatedButton(onPressed: activate, style: style, child: child),
  );

  static Widget outlined({
    required VoidCallback? onPressed,
    required Widget child,
    ButtonStyle? style,
  }) => LotusFeedback(
    onActivate: onPressed,
    builder: (activate) =>
        OutlinedButton(onPressed: activate, style: style, child: child),
  );

  static Widget icon({
    required VoidCallback? onPressed,
    required Widget icon,
    String? tooltip,
    ButtonStyle? style,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? padding,
    AlignmentGeometry? alignment,
  }) => LotusFeedback(
    onActivate: onPressed,
    builder: (activate) => IconButton(
      onPressed: activate,
      icon: icon,
      tooltip: tooltip,
      style: style,
      constraints: constraints,
      padding: padding,
      alignment: alignment,
      enableFeedback: false,
    ),
  );
}
