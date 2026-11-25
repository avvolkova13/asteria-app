import 'dart:math' as math;

import 'package:flutter/material.dart';

class PaperWritingArtwork extends StatelessWidget {
  const PaperWritingArtwork({
    super.key,
    required this.asset,
    required this.seconds,
  });

  final String asset;
  final double seconds;

  static const _tip = Offset(79, 215);
  static final _stroke =
      (Path()
            ..moveTo(_tip.dx, _tip.dy)
            ..relativeCubicTo(4, -1, 7, -12, 9, -10)
            ..relativeCubicTo(2, 2, -5, 12, 0, 8)
            ..relativeCubicTo(5, -6, 7, -10, 6, -5)
            ..relativeCubicTo(-1, 5, 3, 1, 6, -3)
            ..relativeCubicTo(2, -3, 2, 3, 5, 1)
            ..relativeLineTo(7, -4))
          .computeMetrics()
          .first;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Image.asset(asset, fit: BoxFit.contain);
    }
    final directory = asset.substring(0, asset.lastIndexOf('/'));
    final phase = seconds % 5 / 5;
    final progress = Curves.easeInOut.transform((phase / .64).clamp(0, 1));
    final distance = _stroke.length * progress;
    final end = _stroke.getTangentForOffset(distance)!.position;
    final returning = ((phase - .70) / .30).clamp(0.0, 1.0);
    final lift = math.sin(math.pi * returning);
    final tip = Offset.lerp(
      end,
      _tip,
      Curves.easeInOut.transform(returning),
    )!.translate(0, -9 * lift);
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox.square(
        dimension: 350,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('$directory/thoughts-paper.webp'),
            CustomPaint(
              painter: _Graphite(
                _stroke.extractPath(0, distance),
                1 - returning,
              ),
            ),
            Transform.translate(
              offset: tip - _tip,
              child: Transform.rotate(
                origin: _tip - const Offset(175, 175),
                angle: -.085 * math.sin(math.pi * progress) - .07 * lift,
                child: Image.asset('$directory/thoughts-pencil.webp'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Graphite extends CustomPainter {
  const _Graphite(this.stroke, this.opacity);
  final Path stroke;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      stroke,
      Paint()
        ..color = const Color(0xff543d44).withValues(alpha: .83 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.45,
    );
  }

  @override
  bool shouldRepaint(_Graphite oldDelegate) =>
      stroke != oldDelegate.stroke || opacity != oldDelegate.opacity;
}
