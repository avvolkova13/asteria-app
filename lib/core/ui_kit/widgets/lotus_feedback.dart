import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
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
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: LotusMotionScope.duration,
  );
  late final _contactController = AnimationController(
    vsync: this,
    duration: LotusMotionScope.pressDuration,
  );
  late final _contact = _contactController.drive(
    CurveTween(curve: Curves.easeOut),
  );
  late final _motion = Listenable.merge([_contact, _pulse]);

  // Hit testing dispatches to the inner surface first. Only its press scales.
  static final _owners = <int, _LotusFeedbackState>{};
  int? _pointer;
  Offset? _origin;
  bool _showFocus = false;
  bool _reduceMotion = false;
  Timer? _acknowledgement;

  void _clearAcknowledgement() {
    _acknowledgement?.cancel();
    _acknowledgement = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion != reduced) {
      _reduceMotion = reduced;
      _clearAcknowledgement();
      _release();
      _contactController.reset();
      _pulse.reset();
    }
  }

  @override
  void didUpdateWidget(LotusFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onActivate == null) {
      _clearAcknowledgement();
      _release();
      _contactController.reset();
      _pulse.reset();
    }
  }

  void _down(PointerDownEvent event) {
    if (_pointer != null ||
        _owners.containsKey(event.pointer) ||
        event.buttons != kPrimaryButton) {
      return;
    }
    _owners[event.pointer] = this;
    _pointer = event.pointer;
    _origin = event.position;
    _clearAcknowledgement();
    if (_reduceMotion) {
      _contactController.value = 1;
    } else {
      _contactController.forward();
    }
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
  }

  void _end(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _release();
    if (_reduceMotion) {
      if (_acknowledgement == null) _contactController.reset();
    } else {
      _contactController.reverse();
    }
  }

  void _activate() {
    final callback = widget.onActivate;
    if (callback == null) return;
    LotusFeedback.selection();
    if (_reduceMotion) {
      // A fast tap may finish between frames. Keep a stationary cue visible.
      _clearAcknowledgement();
      _contactController.value = 1;
      _acknowledgement = Timer(const Duration(milliseconds: 110), () {
        _acknowledgement = null;
        if (_pointer == null) _contactController.reset();
      });
    } else {
      _pulse.forward(from: 0);
    }
    callback();
  }

  @override
  void dispose() {
    _clearAcknowledgement();
    _release();
    _contactController.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onActivate != null;
    final control = widget.builder(enabled ? _activate : null);
    return AsteriaEntrance(
      child: Listener(
        onPointerDown: enabled ? _down : null,
        onPointerMove: _move,
        onPointerUp: _end,
        onPointerCancel: _end,
        child: AnimatedBuilder(
          animation: _motion,
          builder: (context, surface) {
            final pressScale =
                1 - (1 - LotusMotionScope.pressedScale) * _contact.value;
            // A quick tap or keyboard activation may finish before the first press frame.
            final phase = (_pulse.value / .45).clamp(0.0, 1.0);
            final activationScale = 1 - .018 * math.sin(math.pi * phase);
            return Transform.scale(
              scale: _reduceMotion ? 1 : math.min(pressScale, activationScale),
              transformHitTests: false,
              child: Opacity(
                opacity: _reduceMotion && _contact.value > 0 ? .76 : 1,
                child: surface,
              ),
            );
          },
          child: LotusMotionScope(
            contact: _contact,
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
                      ButtonActivateIntent:
                          CallbackAction<ButtonActivateIntent>(
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
