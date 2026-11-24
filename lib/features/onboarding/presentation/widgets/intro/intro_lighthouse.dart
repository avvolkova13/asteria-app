import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The dream's moving light, its reflection and the sea share one clock.
class IntroLighthouse extends CustomPainter {
  IntroLighthouse({required this.time});
  final double time;

  static const _night = Color(0xFF17132F);
  static const _water = Color(0xFF263B55);
  static const _glow = Color(0xFFFFD798);
  static const _horizon = Color(0xFFC390A4);
  static const _rock = Color(0xFF28233C);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 380, size.height / 180);
    final brush = Paint()..isAntiAlias = true;
    const bounds = Rect.fromLTWH(0, 0, 380, 180);
    const sea = Rect.fromLTRB(0, 106, 380, 180);
    brush.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_night, Color(0xFF484261), _horizon],
      stops: [0, .59, 1],
    ).createShader(const Rect.fromLTWH(0, 0, 380, 109));
    canvas.drawRect(bounds, brush);
    brush.shader = null;

    // Quiet stars and a small moon sit behind the headlands.
    for (var i = 0; i < 44; i++) {
      final x = (i * 113 + 17) % 380, y = (i * i * 19 + i * 7 + 2) % 82;
      brush.color = Color.fromRGBO(250, 232, 214, .23 + .29 * (1 - y / 82));
      canvas.drawCircle(
        Offset(x.toDouble(), y.toDouble()),
        i % 7 == 0 ? 1.0 : .58,
        brush,
      );
    }
    const moon = Offset(73, 31);
    brush.shader = RadialGradient(
      colors: [_glow.withValues(alpha: .26), _glow.withValues(alpha: 0)],
    ).createShader(Rect.fromCircle(center: moon, radius: 20));
    canvas.drawCircle(moon, 20, brush);
    brush.shader = null;
    brush.color = const Color(0xFFF3D6C3);
    canvas.drawCircle(moon, 5.8, brush);
    final distant = Path()
      ..moveTo(0, 99)
      ..cubicTo(30, 93, 47, 102, 73, 96)
      ..cubicTo(95, 93, 110, 89, 133, 96)
      ..cubicTo(159, 103, 178, 90, 199, 94)
      ..cubicTo(241, 104, 269, 97, 295, 82)
      ..cubicTo(323, 74, 339, 83, 380, 67)
      ..lineTo(380, 112)
      ..lineTo(0, 112)
      ..close();
    brush.color = const Color(0xFF61536C);
    canvas.drawPath(distant, brush);
    brush.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF827488), _water, _night],
      stops: [0, .52, 1],
    ).createShader(sea);
    canvas.drawRect(sea, brush);
    brush.shader = null;

    final beamHeight = 22 + 13 * math.sin(time * .77);
    final beamReach = 85 + 19 * math.cos(time * .77);
    const lamp = Offset(278, 43);
    final beam = Path()
      ..moveTo(lamp.dx, lamp.dy)
      ..lineTo(-8, beamReach - beamHeight)
      ..lineTo(-8, beamReach + beamHeight)
      ..close();
    brush.shader = LinearGradient(
      colors: [
        _glow.withValues(alpha: 0),
        _glow.withValues(alpha: .10),
        _glow.withValues(alpha: .57),
      ],
      stops: const [0, .64, 1],
    ).createShader(const Rect.fromLTWH(0, 0, 278, 110));
    canvas.drawPath(beam, brush);
    brush.shader = null;
    // Ripples break the reflection into narrow, irregular bands.
    brush.strokeCap = StrokeCap.round;
    for (var i = 0; i < 75; i++) {
      final unit = i / 75, y = 108 + unit * 70;
      final x = (i * 83.0) % 386 + math.sin(time * .7 + i * .93) * 4;
      final length = 2 + unit * 10 + (i % 4) * 2;
      brush
        ..color = Color.lerp(
          const Color(0xFFA1A3BA),
          _water,
          unit,
        )!.withValues(alpha: .48)
        ..strokeWidth = .64 + unit * .55;
      canvas.drawLine(Offset(x, y), Offset(x + length, y), brush);
    }
    for (var i = 0; i < 19; i++) {
      final x = 203 - i * 3.8 + math.sin(i * 1.9 + time * .65) * (4 + i * .55);
      final y = 109 + i * 3.3;
      brush
        ..color = _glow.withValues(alpha: (.50 - i * .018))
        ..strokeWidth = .9 + i * .045;
      canvas.drawLine(Offset(x, y), Offset(x + 4 + i * .9, y), brush);
    }

    final island = Path()
      ..moveTo(178, 123)
      ..lineTo(200, 118)
      ..lineTo(209, 111)
      ..lineTo(230, 107)
      ..lineTo(242, 101)
      ..lineTo(250, 97)
      ..lineTo(279, 95)
      ..lineTo(294, 90)
      ..lineTo(317, 85)
      ..lineTo(335, 77)
      ..lineTo(353, 75)
      ..lineTo(380, 67)
      ..lineTo(380, 129)
      ..lineTo(348, 127)
      ..lineTo(330, 125)
      ..lineTo(287, 128)
      ..lineTo(247, 122)
      ..lineTo(222, 125)
      ..close();
    brush.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF6D5260), _rock],
    ).createShader(const Rect.fromLTRB(200, 70, 380, 128));
    canvas.drawPath(island, brush);
    brush.shader = null;
    final slope = Path()
      ..moveTo(229, 114)
      ..quadraticBezierTo(245, 104, 266, 104)
      ..quadraticBezierTo(311, 105, 297, 95);
    canvas.drawPath(
      slope,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFAA8390).withValues(alpha: .55)
        ..strokeWidth = 1.1,
    );

    // The keeper's cottage and lantern room give the silhouette scale.
    brush.color = const Color(0xFFB49395);
    canvas.drawRect(const Rect.fromLTWH(294, 82, 22, 12), brush);
    brush.color = const Color(0xFF583546);
    canvas.drawPath(
      Path()
        ..moveTo(291, 83)
        ..lineTo(301, 74)
        ..lineTo(317, 76)
        ..lineTo(321, 83)
        ..close(),
      brush,
    );
    brush.color = _glow;
    canvas.drawRect(const Rect.fromLTWH(298, 85, 3, 4), brush);
    final tower = Path()
      ..moveTo(273, 50)
      ..lineTo(283, 50)
      ..lineTo(288, 97)
      ..quadraticBezierTo(278, 100, 267, 98)
      ..close();
    brush.shader = const LinearGradient(
      colors: [Color(0xFFF3C4AB), Color(0xFFD4A8AD), Color(0xFF9A7C94)],
      stops: [0, .54, 1],
    ).createShader(const Rect.fromLTWH(267, 50, 21, 50));
    canvas.drawPath(tower, brush);
    brush.shader = null;
    canvas.save();
    canvas.clipPath(tower);
    brush.color = const Color(0xFFAB6877);
    canvas.drawPath(
      Path()
        ..moveTo(263, 66)
        ..lineTo(286, 62)
        ..lineTo(287, 70)
        ..lineTo(263, 75)
        ..close(),
      brush,
    );
    canvas.restore();
    brush.color = const Color(0xFF4D425B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(275, 88, 4, 10),
        const Radius.circular(2),
      ),
      brush,
    );
    canvas.drawRect(const Rect.fromLTWH(277, 76, 2, 4), brush);
    brush.color = const Color(0xFF372F48);
    canvas.drawRect(const Rect.fromLTWH(269, 49, 18, 2.1), brush);
    canvas.drawRect(const Rect.fromLTWH(272, 39, 12, 10), brush);
    brush.color = _glow;
    canvas.drawRect(const Rect.fromLTWH(273, 40, 4, 7), brush);
    canvas.drawRect(const Rect.fromLTWH(278, 40, 4, 7), brush);
    brush.color = const Color(0xFF583844);
    canvas.drawPath(
      Path()
        ..moveTo(270, 39)
        ..lineTo(277, 33)
        ..lineTo(279, 32)
        ..lineTo(286, 39)
        ..close(),
      brush,
    );
    brush.color = const Color(0xFF322638);
    brush.strokeWidth = 1.1;
    canvas.drawLine(const Offset(278, 33), const Offset(278, 29), brush);
    brush.shader = RadialGradient(
      colors: [_glow.withValues(alpha: .72), _glow.withValues(alpha: 0)],
    ).createShader(Rect.fromCircle(center: lamp, radius: 11));
    canvas.drawCircle(lamp, 11, brush);

    brush.shader = null;
    brush.color = const Color(0xFF18182D);
    canvas.drawPath(
      Path()
        ..moveTo(0, 142)
        ..lineTo(12, 144)
        ..lineTo(29, 150)
        ..lineTo(41, 151)
        ..lineTo(68, 160)
        ..lineTo(89, 164)
        ..lineTo(98, 171)
        ..lineTo(140, 180)
        ..lineTo(0, 180)
        ..close(),
      brush,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(IntroLighthouse old) => old.time != time;
}
