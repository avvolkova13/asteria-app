import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// One timeline per activated control, shared by the artwork inside it.
class LotusMotionScope extends InheritedWidget {
  const LotusMotionScope({
    super.key,
    required this.pulse,
    required super.child,
  });

  static const duration = Duration(milliseconds: 400);
  static const pressDuration = Duration(milliseconds: 90);
  static const pressedScale = .96;
  final Animation<double> pulse;

  static Animation<double>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LotusMotionScope>()?.pulse;

  @override
  bool updateShouldNotify(LotusMotionScope oldWidget) =>
      oldWidget.pulse != pulse;
}

/// The original player glyphs can supply their 16 illustrated poses. Other
/// pictograms lift slightly and settle, without disturbing the control's layout.
class LotusGlyphMotion extends StatelessWidget {
  const LotusGlyphMotion({super.key, required this.child, this.frameBuilder});

  final Widget child;
  final Widget Function(int frame)? frameBuilder;

  @override
  Widget build(BuildContext context) {
    final pulse = LotusMotionScope.maybeOf(context);
    if (pulse == null || MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedBuilder(
      animation: pulse,
      child: child,
      builder: (context, art) {
        final progress = pulse.value;
        if (progress <= 0 || progress >= 1) return art!;
        final sprite = frameBuilder;
        if (sprite != null) return sprite((progress * 15).round());
        final lift = math.sin(math.pi * progress);
        return Transform.translate(
          offset: Offset(0, -1.5 * lift),
          transformHitTests: false,
          child: Transform.scale(
            scale: 1 + .055 * lift,
            transformHitTests: false,
            child: art,
          ),
        );
      },
    );
  }
}
