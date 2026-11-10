import 'package:flutter/material.dart';

/// The pearlescent surface used by the lotus player, behind a standalone glyph.
/// The control retains its original layout, gestures and accessibility target.
class LotusIconSurface extends StatelessWidget {
  const LotusIconSurface({super.key, required this.child, this.diameter = 34});

  final Widget child;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: Radius.elliptical(diameter * .49, diameter * .56),
      topRight: Radius.elliptical(diameter * .51, diameter * .54),
      bottomRight: Radius.elliptical(diameter * .45, diameter * .46),
      bottomLeft: Radius.elliptical(diameter * .55, diameter * .44),
    );
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: OverflowBox(
              minWidth: diameter,
              maxWidth: diameter,
              minHeight: diameter,
              maxHeight: diameter,
              child: CustomPaint(
                painter: LotusSurfacePainter(radius, false, false),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class LotusSurfacePainter extends CustomPainter {
  const LotusSurfacePainter(this.radius, this.active, this.focused);
  final BorderRadius radius;
  final bool active;
  final bool focused;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = radius.toRRect(rect);
    void fill(Gradient gradient) =>
        canvas.drawRRect(shape, Paint()..shader = gradient.createShader(rect));
    fill(
      const LinearGradient(
        begin: Alignment(-.5, -1),
        end: Alignment(.5, 1),
        colors: [Color(0x25fbdeef), Color(0x0cfae3ec), Color(0x26c4b4dd)],
      ),
    );
    fill(
      const RadialGradient(
        center: Alignment(-.5, -.84),
        radius: .73,
        colors: [Color(0x34fff5f5), Color(0x00fff5f5)],
      ),
    );
    fill(
      const RadialGradient(
        center: Alignment(.66, .8),
        radius: .76,
        colors: [Color(0x34cbbde7), Color(0x00cbbde7)],
      ),
    );
    if (active) {
      fill(
        const RadialGradient(
          center: Alignment(-.18, -.12),
          radius: .72,
          colors: [Color(0x66fff5ee), Color(0x20f4d8ec), Color(0x00f4d8ec)],
          stops: [0, .6, 1],
        ),
      );
    }
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.1);
    canvas.drawRRect(
      shape.shift(const Offset(0, .75)),
      stroke
        ..color = const Color(0x5efff8f5)
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x9afff8f5), Color(0x30f9e0f1), Color(0x335e4766)],
        ).createShader(rect),
    );
    // A narrow directional rim follows the upper edge of the clay surface.
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .85
      ..shader = const LinearGradient(
        begin: Alignment(-.55, -1),
        end: Alignment(.4, 1),
        colors: [
          Color(0xa8fff8f5),
          Color(0x48f9e0f1),
          Color(0x115e4766),
          Color(0x355e4766),
        ],
        stops: [0, .32, .72, 1],
      ).createShader(rect);
    canvas.drawRRect(shape.deflate(.45), rim);
    if (focused) {
      canvas.drawRRect(
        shape.deflate(1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xfff3cbab),
      );
    }
  }

  @override
  bool shouldRepaint(LotusSurfacePainter old) =>
      radius != old.radius || active != old.active || focused != old.focused;
}
