import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// One timeline per activated control, shared by the artwork inside it.
class LotusMotionScope extends InheritedWidget {
  const LotusMotionScope({
    super.key,
    required this.pulse,
    this.contact,
    required super.child,
  });

  static const duration = Duration(milliseconds: 400);
  static const pressDuration = Duration(milliseconds: 90);
  static const pressedScale = .96;
  final Animation<double> pulse;
  final Animation<double>? contact;

  static Animation<double>? maybeOf(BuildContext context) =>
      _scopeOf(context)?.pulse;

  static LotusMotionScope? _scopeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LotusMotionScope>();

  @override
  bool updateShouldNotify(LotusMotionScope oldWidget) =>
      oldWidget.pulse != pulse || oldWidget.contact != contact;
}

/// The original player glyphs can supply their 16 illustrated poses. Other
/// pictograms lift slightly and settle, without disturbing the control's layout.
class LotusGlyphMotion extends StatelessWidget {
  const LotusGlyphMotion({super.key, required this.child, this.frameBuilder});

  final Widget child;
  final Widget Function(int frame)? frameBuilder;

  @override
  Widget build(BuildContext context) {
    final scope = LotusMotionScope._scopeOf(context);
    if (scope == null || MediaQuery.disableAnimationsOf(context)) return child;
    final contact = scope.contact;
    return AnimatedBuilder(
      animation: contact == null
          ? scope.pulse
          : Listenable.merge([scope.pulse, contact]),
      child: child,
      builder: (context, art) {
        final progress = scope.pulse.value;
        final pressure = contact?.value ?? 0;
        final animating = progress > 0 && progress < 1;
        if (!animating && pressure == 0) return art!;
        final sprite = frameBuilder;
        final hasPose = animating && sprite != null;
        final glyph = hasPose ? sprite((progress * 15).round()) : art!;
        if (hasPose && pressure == 0) return glyph;
        final lift = animating && !hasPose ? math.sin(math.pi * progress) : 0.0;
        return Transform.translate(
          offset: Offset(0, .7 * pressure - 1.5 * lift),
          transformHitTests: false,
          child: Transform.scale(
            scaleX: 1 + .035 * pressure + .055 * lift,
            scaleY: 1 - .09 * pressure + .055 * lift,
            transformHitTests: false,
            child: glyph,
          ),
        );
      },
    );
  }
}
