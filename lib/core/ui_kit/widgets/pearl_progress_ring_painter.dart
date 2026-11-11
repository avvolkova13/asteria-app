import 'dart:math' as math;

import 'package:flutter/material.dart';

class PearlProgressRingPainter extends CustomPainter {
  const PearlProgressRingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;
    final track = Rect.fromCircle(center: center, radius: radius - 6);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.46, -0.6),
          radius: 1.05,
          colors: [Color(0xFF58435B), Color(0xFF34273F), Color(0xFF241B31)],
        ).createShader(rect),
    );
    canvas.drawOval(track, trackPaint..color = const Color(0xFF503C56));

    if (progress <= 0) return;
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      track.shift(const Offset(0, 1.4)),
      start,
      sweep,
      false,
      trackPaint..color = const Color(0xAA26172F),
    );
    canvas.drawArc(
      track,
      start,
      sweep,
      false,
      trackPaint
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5C6C1),
            Color(0xFFE5ABD9),
            Color(0xFFB09ADD),
            Color(0xFF8968B7),
          ],
        ).createShader(rect),
    );
    canvas.drawArc(
      track,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.4
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xBBFFF3EB), Color(0x33FFFFFF), Color(0x00FFFFFF)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(PearlProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
