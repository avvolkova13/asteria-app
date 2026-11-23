part of 'affirmation_motion_artwork.dart';

class _CreativeMotion extends StatelessWidget {
  const _CreativeMotion({
    required this.phase,
    required this.motion,
    required this.plate,
  });

  final double phase;
  final PlayerSubjectMotion motion;
  final Widget Function(String) plate;

  @override
  Widget build(BuildContext context) {
    final layers = <Widget>[];
    switch (motion) {
      case PlayerSubjectMotion.palette:
        layers.addAll([
          plate(''),
          _TexturedPlate(
            asset: _roseAsset, phase: phase, painter: _OpeningRose.new,
          ),
        ]);
      case PlayerSubjectMotion.quill:
        final time = ((phase / (math.pi * 2) + .045) % 1);
        final tip = _QuillStroke.tipAt(time);
        final reach = (tip.dx - 138) / 106;
        const nib = Alignment(138 / 215 - 1, 282 / 215 - 1);
        layers.addAll([
          plate(''),
          CustomPaint(painter: _QuillStroke(time)),
          Transform.translate(
            offset: (tip - const Offset(138, 282)) * (250 / 430),
            child: Transform.rotate(
              alignment: nib,
              angle: .20 - .24 * reach,
              child: Transform.scale(
                alignment: nib,
                scale: .80,
                child: plate('_a'),
              ),
            ),
          ),
          plate('_b'),
        ]);
      case PlayerSubjectMotion.book:
        final lift = (1 + math.sin(phase - .55)) / 2;
        layers.addAll([
          Transform.translate(
            offset: Offset(7.3 * math.sin(phase), 12 - 25 * lift),
            child: Transform.rotate(
              angle: .23 * math.sin(phase + .28),
              alignment: const Alignment(0, -.48),
              child: plate('_a'),
            ),
          ),
          plate(''),
        ]);
      default:
        layers.add(plate(''));
    }
    return Stack(fit: StackFit.expand, children: layers);
  }
}

const _roseAsset = 'assets/images/affirmation/motion/subjects/category_creative_a.webp';

class _OpeningRose extends CustomPainter {
  _OpeningRose(this.texture, this.phase);
  final ui.Image texture;
  final double phase;
  static const _columns = 28;
  static const _rows = 24;
  static final _uv = <Offset>[
    for (var row = 0; row <= _rows; row++)
      for (var col = 0; col <= _columns; col++)
        Offset(42 + 182 * col / _columns, 82 + 152 * row / _rows),
  ];
  static final _triangles = <int>[
    for (var row = 0; row < _rows; row++)
      for (var col = 0; col < _columns; col++)
        ..._cell(row * (_columns + 1) + col),
  ];
  static List<int> _cell(int i) => [
    i,
    i + 1,
    i + _columns + 1,
    i + 1,
    i + _columns + 2,
    i + _columns + 1,
  ];

  // Each influence falls off towards its hinge deep inside the blossom.
  static double _influence(Offset p, double x, double y, double w, double h) {
    final dx = (p.dx - x) / w;
    final dy = (p.dy - y) / h;
    return math.exp(-(dx * dx + dy * dy));
  }

  static final _weights = [
    for (final p in _uv)
      (
        _influence(p, 58, 148, 42, 51),
        _influence(p, 202, 152, 44, 50),
        _influence(p, 140, 215, 53, 32),
        _influence(p, 136, 98, 49, 30),
        _influence(p, 140, 139, 30, 31),
      ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final left = .5 + .5 * math.sin(phase);
    final right = .5 + .5 * math.sin(phase - .48);
    final lower = .5 + .5 * math.sin(phase - .75);
    final upper = .5 + .5 * math.sin(phase + .36);
    final swirl = .31 * math.sin(phase + .3);
    final posed = <Offset>[];
    for (var i = 0; i < _uv.length; i++) {
      final p = _uv[i];
      final (l, r, b, t, c) = _weights[i];
      posed.add(
        Offset(
          p.dx -
              l * 24 * left +
              r * 21 * right +
              b * 3 * lower -
              t * 5 * upper -
              (p.dy - 139) * c * swirl,
          p.dy -
              l * 7 * left -
              r * 9 * right +
              b * 21 * lower -
              t * 18 * upper +
              (p.dx - 140) * c * swirl,
        ),
      );
    }
    canvas.save();
    canvas.scale(size.width / 430, size.height / 430);
    final mesh = ui.Vertices(
      ui.VertexMode.triangles,
      posed,
      textureCoordinates: _uv,
      indices: _triangles,
    );
    final shader = ui.ImageShader(
      texture,
      TileMode.clamp,
      TileMode.clamp,
      Matrix4.identity().storage,
      filterQuality: FilterQuality.medium,
    );
    canvas.drawVertices(mesh, BlendMode.srcOver, Paint()..shader = shader);
    mesh.dispose();
    shader.dispose();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OpeningRose old) =>
      old.phase != phase || old.texture != texture;
}

class _QuillStroke extends CustomPainter {
  const _QuillStroke(this.time);
  final double time;
  static const _start = Offset(161, 246);
  static const _end = Offset(243, 244);
  static const _rest = Offset(144, 269);

  static Offset _curve(Offset a, Offset b, Offset c, Offset d, double t) {
    final u = 1 - t;
    return a * (u * u * u) +
        b * (3 * u * u * t) +
        c * (3 * u * t * t) +
        d * (t * t * t);
  }

  static Path _ink() => Path()
    ..moveTo(_start.dx, _start.dy)
    ..cubicTo(179, 244, 202, 220, 214, 223)
    ..cubicTo(232, 228, 187, 261, 190, 248)
    ..cubicTo(194, 236, 215, 241, 223, 247)
    ..cubicTo(230, 252, 237, 248, _end.dx, _end.dy);
  static final _metric = _ink().computeMetrics().first;
  static double _ease(double t) => t * t * (3 - 2 * t);

  static Offset tipAt(double time) {
    if (time < .21) {
      final t = _ease(time / .21);
      return _curve(
        _rest,
        const Offset(145, 253),
        const Offset(150, 247),
        _start,
        t,
      );
    }
    if (time <= .74) {
      final distance = _ease((time - .21) / .53) * _metric.length;
      return _metric.getTangentForOffset(distance)!.position;
    }
    final t = _ease((time - .74) / .26);
    return _curve(
      _end,
      const Offset(227, 212),
      const Offset(151, 228),
      _rest,
      t,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final amount = _ease(((time - .21) / .53).clamp(0, 1).toDouble());
    if (amount == 0) return;
    final fade = 1 - _ease(((time - .77) / .20).clamp(0, 1).toDouble());
    canvas.save();
    canvas.scale(size.width / 430, size.height / 430);
    canvas.drawPath(
      _metric.extractPath(0, _metric.length * amount),
      Paint()
        ..color = const Color(0xffffd89a).withValues(alpha: .89 * fade)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_QuillStroke old) => old.time != time;
}
