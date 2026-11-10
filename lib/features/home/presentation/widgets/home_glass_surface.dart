import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The tinted surfaces on the Asteria home canvas share one beveled rim.
class HomeGlassSurface extends StatelessWidget {
  const HomeGlassSurface({
    super.key,
    this.radius = 16,
    this.tint = const Color(0x339A7DB8),
    required this.child,
  });

  final double radius;
  final Color tint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        painter: _HomeGlassPainter(radius, tint),
        child: child,
      ),
    );
  }
}

class _HomeGlassPainter extends CustomPainter {
  const _HomeGlassPainter(this.radius, this.tint);

  final double radius;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final card = RRect.fromRectAndRadius(
      bounds,
      Radius.circular(radius),
    ).scaleRadii();
    canvas.save();
    canvas.clipRRect(card);
    canvas.drawRRect(card, Paint()..color = tint);

    final outer = bounds.inflate(28);
    void insetShadow(Offset offset, Color color) {
      final shadow = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(outer)
        ..addRRect(card.shift(offset));
      canvas.drawPath(
        shadow,
        Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    insetShadow(const Offset(3, 3), const Color(0x36000000));
    insetShadow(const Offset(-3, -3), const Color(0x0FD0C0E5));
    _paintRim(canvas, card.deflate(0.5));
    canvas.restore();
  }

  // At 315° the top-left and bottom-right arcs catch the light. The
  // perpendicular arcs fade into the tint. Straight edges have one normal.
  void _paintRim(Canvas canvas, RRect rim) {
    const topLight = Color(0x50E6D8F4);
    const bottomLight = Color(0x3BE6D8F4);
    const cornerLight = SweepGradient(
      colors: [
        bottomLight,
        Color(0x8AE6D8F4),
        bottomLight,
        Color(0x00E6D8F4),
        Color(0x00E6D8F4),
        topLight,
        Color(0xA4E6D8F4),
        topLight,
        Color(0x00E6D8F4),
        Color(0x00E6D8F4),
        bottomLight,
      ],
      stops: [0, 0.125, 0.25, 0.30, 0.45, 0.5, 0.625, 0.75, 0.80, 0.95, 1],
    );
    final radius = rim.tlRadiusX;
    final topLeft = Offset(rim.left + radius, rim.top + radius);
    final topRight = Offset(rim.right - radius, rim.top + radius);
    final bottomLeft = Offset(rim.left + radius, rim.bottom - radius);
    final bottomRight = Offset(rim.right - radius, rim.bottom - radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = topLight;
    canvas.drawLine(
      Offset(topLeft.dx, rim.top),
      Offset(topRight.dx, rim.top),
      paint,
    );
    canvas.drawLine(
      Offset(rim.left, topLeft.dy),
      Offset(rim.left, bottomLeft.dy),
      paint,
    );
    paint.color = bottomLight;
    canvas.drawLine(
      Offset(bottomLeft.dx, rim.bottom),
      Offset(bottomRight.dx, rim.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rim.right, topRight.dy),
      Offset(rim.right, bottomRight.dy),
      paint,
    );
    paint.color = Colors.white;
    void drawCorner(Offset center, double startAngle) {
      final bounds = Rect.fromCircle(center: center, radius: radius);
      paint.shader = cornerLight.createShader(bounds);
      canvas.drawArc(bounds, startAngle, math.pi / 2, false, paint);
    }

    drawCorner(topRight, -math.pi / 2);
    drawCorner(bottomRight, 0);
    drawCorner(bottomLeft, math.pi / 2);
    drawCorner(topLeft, math.pi);
  }

  @override
  bool shouldRepaint(_HomeGlassPainter oldDelegate) =>
      radius != oldDelegate.radius || tint != oldDelegate.tint;
}
