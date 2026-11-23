part of 'body_motion_artwork.dart';

extension _ContactPractice on BodyMotionArtwork {
  List<Widget> _massageLayers() {
    const radius = 76.0;
    final stroke = math.sin(phase);
    final travel = 48 * stroke;
    final footX = .40 * travel;
    final angle = .066 * stroke;
    const pivot = Offset(244, 401);
    final ball = Offset(244 - .60 * travel, 468);

    // The ball stays on its baseline while the arch rolls over it. Lift the
    // foot to the tangent of the actual sole, including its heel and forefoot.
    final sine = math.sin(angle), cosine = math.cos(angle);
    var contact = -double.infinity;
    for (final p in _SoleOutline.contactPoints) {
      final v = p - pivot;
      final x = pivot.dx + footX + v.dx * cosine - v.dy * sine;
      final y = pivot.dy + v.dx * sine + v.dy * cosine;
      final dx = x - ball.dx;
      if (dx.abs() < radius) {
        contact = math.max(contact, y + math.sqrt(radius * radius - dx * dx));
      }
    }

    return [
      Positioned.fill(
        child: CustomPaint(painter: _MassageBall(ball, radius, stroke)),
      ),
      // Extract the warm inlay from the original purple roller texture. Its
      // bevels, fine gold arcs and pearls rotate as one registered surface.
      _layer(
        'roller',
        Rect.fromCenter(center: ball, width: 111, height: 111),
        angle: travel / radius,
        finish: (image) => ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            1,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
            0,
            0,
            0,
            0,
            1,
            0,
            0,
            7,
            0,
            -7,
            0,
            -50,
          ]),
          child: image,
        ),
      ),
      _layer(
        'foot',
        const Rect.fromLTWH(0, 0, 600, 600),
        pivot: pivot,
        angle: angle,
        offset: Offset(footX, ball.dy - contact + 1.8),
      ),
    ];
  }

  List<Widget> _boardLayers() {
    // Both boards have the same engravings. The front board in the master is
    // intact, including its side wall; use it to uncover both wood edges.
    final spread = .5 + .5 * math.sin(phase);
    final glide = math.cos(phase);
    Widget board(Offset offset, double angle) => _layer(
      'sadhu-board',
      const Rect.fromLTWH(0, 0, 600, 600),
      original: true,
      offset: offset,
      angle: angle,
      pivot: const Offset(425, 195),
      finish: (image) => ClipPath(clipper: const _WholeBoard(), child: image),
    );
    return [
      board(
        Offset(-182 - 9 * spread - 3 * glide, -63 - 11 * glide),
        .078 * spread,
      ),
      board(Offset(3 + 13 * spread + 4 * glide, 13 * glide), -.085 * spread),
    ];
  }
}

/// Lower edge of the restored foot in the 600 × 600 illustration.
abstract final class _SoleOutline {
  static final _metric = (Path()
        ..moveTo(99, 436.7)
        ..cubicTo(136, 437.5, 165, 415, 213, 415)
        ..cubicTo(254, 415, 282, 425, 319, 441.2)
        ..cubicTo(336, 449, 346, 455.3, 361, 454.9)
        ..cubicTo(370, 454.9, 377, 452, 385, 451))
      .computeMetrics()
      .first;
  static final contactPoints = [
    for (double d = 0; d < _metric.length; d += 2)
      _metric.getTangentForOffset(d)!.position,
  ];
}

class _WholeBoard extends CustomClipper<Path> {
  const _WholeBoard();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(381, 115)
    ..lineTo(600, 115)
    ..lineTo(600, 600)
    ..lineTo(192, 600)
    ..lineTo(202, 453)
    ..cubicTo(205, 443, 204.5, 435, 206, 424)
    ..cubicTo(207.5, 410, 214.5, 397, 224.5, 385)
    ..cubicTo(258, 338, 322, 246, 376.5, 175)
    ..lineTo(381, 168)
    ..close();

  @override
  bool shouldReclip(_WholeBoard oldClipper) => false;
}

/// The relief follows the rolling surface; the incident light stays in the room.
class _MassageBall extends CustomPainter {
  const _MassageBall(this.center, this.radius, this.stroke);
  final Offset center;
  final double radius, stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.31, -.48),
          radius: .92,
          colors: [
            Color(0xffefc3de),
            Color(0xffd8a8d2),
            Color(0xffbd87bd),
            Color(0xff925698),
            Color(0xff82528b),
          ],
          stops: [0, .31, .57, .83, 1],
        ).createShader(bounds),
    );
    final pressure = Offset(-.54 * stroke, -1);
    final shadowCenter = center + pressure * (radius / pressure.distance);
    canvas.save();
    canvas.clipPath(Path()..addOval(bounds));
    canvas.drawCircle(
      shadowCenter,
      radius * .61,
      Paint()
        ..shader =
            const RadialGradient(
              colors: [Color(0x99432858), Color(0x44573870), Color(0x00573870)],
              stops: [0, .28, 1],
            ).createShader(
              Rect.fromCircle(center: shadowCenter, radius: radius * .61),
            ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MassageBall old) =>
      old.center != center || old.stroke != stroke || old.radius != radius;
}
