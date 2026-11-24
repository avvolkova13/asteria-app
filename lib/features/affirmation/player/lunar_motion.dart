part of 'affirmation_motion_artwork.dart';

class _LunarMotion extends StatelessWidget {
  const _LunarMotion({
    required this.phase,
    required this.motion,
    required this.plate,
  });

  final double phase;
  final PlayerSubjectMotion motion;
  final Widget Function(String suffix) plate;

  @override
  Widget build(BuildContext context) {
    final wave = math.sin(phase);
    final rise = 1 - math.cos(phase);
    return Stack(
      fit: StackFit.expand,
      children: switch (motion) {
        PlayerSubjectMotion.moonClouds => [
          _TexturedPlate(
            asset: _CrescentClouds.asset,
            phase: phase,
            painter: _CrescentClouds.new,
          ),
        ],
        PlayerSubjectMotion.fullMoon => [
          Transform.translate(
            offset: Offset(5 * wave, -6 * rise),
            // The Moon and its hanging star float together so the narrow
            // attachment stays covered throughout the full motion range.
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Shade only existing lunar material, preserving the craters.
                ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: const LinearGradient(
                    colors: [Colors.white, Colors.white],
                  ).createShader,
                  child: CustomPaint(
                    foregroundPainter: _MoonTerminator(phase),
                    child: plate('_a'),
                  ),
                ),
                plate(''),
              ],
            ),
          ),
        ],
        PlayerSubjectMotion.orb => [
          plate(''),
          CustomPaint(painter: _CrystalSky(phase)),
        ],
        _ => [plate('')],
      },
    );
  }
}

/// One continuous surface preserves the outlines where the clouds cross the moon.
class _CrescentClouds extends CustomPainter {
  const _CrescentClouds(this.texture, this.phase);
  static const asset =
      'assets/images/affirmation/motion/subjects/category_moon_whole.png';
  final ui.Image texture;
  final double phase;

  static double _smooth(double value) {
    final t = value.clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  // The crescent moves as one piece. The front curl gradually picks up a
  // separate drift below the contact line, with a little lag across the bank.
  static final _cloudWeights = [
    for (final point in _SubjectMesh.points)
      _smooth((point.dy - 210 - .24 * (point.dx - 95)) / 85),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final sway = math.sin(phase);
    final lift = math.sin(phase - .65);
    final follow = math.sin(phase - .45);
    final posed = [
      for (var i = 0; i < _cloudWeights.length; i++)
        _SubjectMesh.points[i] +
            Offset(-23 * follow, 6 * math.cos(phase)) * _cloudWeights[i],
    ];
    canvas.save();
    canvas.scale(
      size.width / _SubjectMesh.side,
      size.height / _SubjectMesh.side,
    );
    canvas.translate(215 + 16 * sway, 248 + 6 * lift);
    canvas.rotate(.022 * sway);
    canvas.translate(-215, -248);
    _SubjectMesh.draw(canvas, texture, posed);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CrescentClouds old) =>
      old.phase != phase || old.texture != texture;
}

/// The terminator is an inclined great circle projected into the visible disc.
/// Move its penumbra across the original craters so that their relief survives.
class _MoonTerminator extends CustomPainter {
  const _MoonTerminator(this.phase);
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 250, size.height / 250);
    canvas.translate(125, 82.5);
    canvas.scale(74.1, 72.3);
    canvas.rotate(-.19);
    canvas.clipPath(Path()..addOval(const Rect.fromLTWH(-1, -1, 2, 2)));
    // Light takes six orbits to cross all lunar phases.
    final angle = 1.04 + phase / 6;
    final direction = math.sin(angle) < 0 ? -1.0 : 1.0;
    final terminator = math.cos(angle);
    for (var band = 0; band < 10; band++) {
      final softEdge = (band / 9 - .5) * .16 * math.sin(angle).abs();
      final path = Path()..moveTo(0, -1);
      for (var i = 0; i <= 64; i++) {
        final latitude = -math.pi / 2 + math.pi * i / 64;
        path.lineTo(-direction * math.cos(latitude), math.sin(latitude));
      }
      for (var i = 64; i >= 0; i--) {
        final latitude = -math.pi / 2 + math.pi * i / 64;
        path.lineTo(
          -direction *
              (terminator + softEdge).clamp(-1, 1) *
              math.cos(latitude),
          math.sin(latitude),
        );
      }
      canvas.drawPath(
        path..close(),
        Paint()
          ..color = const Color(0x2026163d)
          ..blendMode = BlendMode.srcATop,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MoonTerminator oldDelegate) => oldDelegate.phase != phase;
}

/// A rotating tilted spiral suspended inside the violet glass. Nearby stars
/// cross the core while distant ones recede behind it; the glass rim stays put.
class _CrystalSky extends CustomPainter {
  const _CrystalSky(this.phase);
  final double phase;
  static const _core = Offset(125, 94);
  static const _rim = Rect.fromLTWH(53, 25, 144, 137);
  static const _dust = Color(0xffeabdef);
  static const _warm = Color(0xffffe3ad);

  Offset _project(double radius, double angle) {
    final x = radius * math.cos(angle);
    final y = .51 * radius * math.sin(angle);
    const tilt = -.40;
    return _core +
        Offset(
          x * math.cos(tilt) - y * math.sin(tilt),
          x * math.sin(tilt) + y * math.cos(tilt),
        );
  }

  void _halo(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double opacity,
  ) {
    final bounds = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ).createShader(bounds),
    );
  }

  void _star(Canvas canvas, int index, double bearing) {
    final angle = bearing + phase;
    final depth = (1 + math.sin(angle)) / 2;
    final center = _project(14 + index * 8.0, angle);
    final radius = (index == 4 ? 2.6 : 1.15) * (.72 + depth * .55);
    final color = index.isEven ? _warm : _dust;
    _halo(canvas, center, radius * 4.8, color, .16 + depth * .14);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.4, -.5),
          radius: .91,
          colors: [
            Color.lerp(color, Colors.white, .42)!.withValues(alpha: .90),
            color.withValues(alpha: .84),
            const Color(0xff91689c).withValues(alpha: .82),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 250, size.height / 250);
    canvas.clipPath(Path()..addOval(_rim));
    canvas.saveLayer(_rim, Paint());
    const bearings = [.13, 2.34, 4.12, 2.97, -.76];
    for (var i = 0; i < bearings.length; i++) {
      if (math.sin(bearings[i] + phase) < 0) _star(canvas, i, bearings[i]);
    }
    for (var arm = 0; arm < 2; arm++) {
      final path = Path();
      for (var i = 0; i <= 72; i++) {
        final t = i / 72;
        final radius = 3.5 + 49 * math.pow(t, 1.14);
        final point = _project(
          radius.toDouble(),
          phase + arm * math.pi + 4.2 * t,
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      final color = arm == 0
          ? const Color(0xffecb1c7)
          : const Color(0xffbba9ec);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5.4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.1)
          ..color = color.withValues(alpha: .33),
      );
      // Individual grains form a tapering, broken spiral rather than a solid line.
      for (var i = 0; i < 43; i++) {
        final t = (i + .5) / 43;
        final radius =
            3.5 + 49 * math.pow(t, 1.14) + 2 * math.sin(2.61 * i + arm);
        final point = _project(
          radius.toDouble(),
          phase + arm * math.pi + 4.2 * t + .085 * math.cos(i * .91),
        );
        final alpha =
            (.20 + .30 * math.pow(math.cos(i * 2.4), 2)) * (1 - .58 * t);
        canvas.drawCircle(
          point,
          .45 + .35 * math.pow(math.sin(i * 1.47), 2),
          Paint()..color = color.withValues(alpha: alpha.toDouble()),
        );
      }
    }
    _halo(canvas, _core, 13, _warm, .35);
    _halo(canvas, _core, 5.5, _warm, .54);
    canvas.drawCircle(_core, 1.7, Paint()..color = const Color(0xfff9e2c3));
    for (var i = 0; i < bearings.length; i++) {
      if (math.sin(bearings[i] + phase) >= 0) _star(canvas, i, bearings[i]);
    }
    canvas.drawOval(
      _rim,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = const RadialGradient(
          radius: .51,
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0, .73, 1],
        ).createShader(_rim),
    );
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CrystalSky oldDelegate) => oldDelegate.phase != phase;
}
