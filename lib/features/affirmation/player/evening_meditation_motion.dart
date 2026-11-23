part of 'body_motion_artwork.dart';

/// Two streams of vapour rise from the coffee surface. The base is anchored;
/// curvature and width travel upward and individual wisps fade into the air.
class _Steam extends CustomPainter {
  const _Steam(this.phase);
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final time = phase / (2 * math.pi);
    for (var strand = 0; strand < 2; strand++) {
      final rhythm = 2 * math.pi * (time * 2 - strand * .32);
      final height = 147.0 + 13 * math.sin(rhythm - .4) - 18 * strand;
      final left = <Offset>[], right = <Offset>[];
      for (var step = 0; step <= 48; step++) {
        final h = step / 48;
        final bend = math.sin(7.6 * h - rhythm);
        final curl = math.sin(11.5 * h - 2 * rhythm + .8 * strand);
        final center =
            450 +
            19 * strand +
            h * (-9 + 10 * strand + (22 + 14 * h) * bend + 8 * h * curl);
        final y = 356 - height * h;
        final billow = .5 + .5 * math.sin(9 * h - rhythm + strand);
        final halfWidth = (2.2 + 8 * h + 5 * billow * h) * (1 - .35 * strand);
        left.add(Offset(center - halfWidth, y));
        right.add(Offset(center + halfWidth, y));
      }
      final plume = Path()..addPolygon([...left, ...right.reversed], true);
      final gradient = ui.Gradient.linear(
        Offset(0, 356),
        Offset(0, 356 - height),
        [
          const Color(0x00fff0d8),
          Color(strand == 0 ? 0x9dffdfc9 : 0x81fff1df),
          Color(strand == 0 ? 0x91ffebdc : 0x75ffeddd),
          const Color(0x48ffe8e1),
          const Color(0x00fff0e7),
        ],
        const [0, .12, .37, .69, 1],
      );
      canvas.drawPath(
        plume,
        Paint()
          ..shader = gradient
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.8),
      );
      gradient.dispose();
    }
  }

  @override
  bool shouldRepaint(_Steam old) => old.phase != phase;
}

/// The trim, folds and metal ornament share one rigid pose. A broad pool of
/// reflected light moves across the satin as the cushion rocks.
class _SleepCushion extends StatelessWidget {
  const _SleepCushion({required this.phase});
  final double phase;

  @override
  Widget build(BuildContext context) {
    final sway = math.sin(phase);
    final lift = math.sin(phase - .35);
    return Transform.translate(
      offset: Offset(2.5 * sway, -8 * lift),
      child: Transform.rotate(
        angle: .032 * sway,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) {
                return RadialGradient(
                  center: Alignment(.24 + .27 * sway, -.37 + .08 * lift),
                  radius: .57,
                  colors: const [
                    Color(0x2cffe5c5),
                    Color(0x15ffdacb),
                    Color(0x00ffdacb),
                  ],
                  stops: const [0, .5, 1],
                ).createShader(bounds);
              },
              child: Image.asset(
                'assets/images/practices/time-for-sleep.webp',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
              ),
            ),
            CustomPaint(painter: _Moonlight(phase)),
          ],
        ),
      ),
    );
  }
}

/// Glints lift from the crescent into the space above the pillow.
class _Moonlight extends CustomPainter {
  const _Moonlight(this.phase);
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final t = (phase / (2 * math.pi) + i / 3) % 1;
      final envelope = math.sin(math.pi * t);
      final opacity = envelope * envelope;
      final x = 387 - (35 + 13 * i) * t + 5 * math.sin(2 * math.pi * t);
      final y = 132 - (77 + 7 * i) * t;
      final radius = (i == 1 ? 5.1 : 3.8) * (.65 + .35 * envelope);
      final shape = Path()
        ..moveTo(x, y - radius * 1.45)
        ..quadraticBezierTo(x, y, x + radius, y)
        ..quadraticBezierTo(x, y, x, y + radius * 1.45)
        ..quadraticBezierTo(x, y, x - radius, y)
        ..quadraticBezierTo(x, y, x, y - radius * 1.45)
        ..close();
      canvas.drawPath(
        shape,
        Paint()
          ..color = const Color(0xffffe4ad).withValues(alpha: .85 * opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_Moonlight old) => old.phase != phase;
}
