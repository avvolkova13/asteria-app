part of 'body_motion_artwork.dart';

extension _BreathPractice on BodyMotionArtwork {
  List<Widget> _breathingLayers() {
    // The two nacre shells unfold about their lower lips, making room for
    // the rising pearl. Its polish turns independently as it settles back.
    final open = .5 + .5 * math.sin(phase);
    final rise = .5 + .5 * math.sin(phase - .26);
    return [
      _layer(
        'pearl',
        const Rect.fromLTRB(200, 227, 390, 416),
        offset: Offset(4 * math.sin(phase - .7), 8 - 60 * rise),
        angle: -.31 * math.sin(phase - .42),
      ),
      _layer(
        'breath-left',
        const Rect.fromLTRB(41, 120, 284, 474),
        offset: Offset(-7 * open, 4 * open),
        angle: .026 - .25 * open,
        pivot: const Offset(207, 437),
      ),
      _layer(
        'breath-right',
        const Rect.fromLTRB(315, 120, 556, 476),
        offset: Offset(7 * open, 4 * open),
        angle: -.026 + .25 * open,
        pivot: const Offset(389, 438),
      ),
    ];
  }

  List<Widget> _featherLayers() => [
    Positioned(
      left: 0,
      top: 30,
      width: 600,
      height: 549,
      child: _ExhaleFeather(phase: phase),
    ),
  ];
}

class _ExhaleFeather extends StatefulWidget {
  const _ExhaleFeather({required this.phase});
  final double phase;

  @override
  State<_ExhaleFeather> createState() => _ExhaleFeatherState();
}

class _ExhaleFeatherState extends State<_ExhaleFeather> {
  static const _asset = AssetImage(
    'assets/images/practices/gentle-exhale.webp',
  );
  ImageInfo? _image;
  ImageStream? _stream;
  ui.ImageShader? _shader;
  late final _listener = ImageStreamListener(_receive);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stream = _asset.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  void _receive(ImageInfo next, bool synchronous) {
    void replace() {
      _shader?.dispose();
      _image?.dispose();
      _image = next;
      _shader = ui.ImageShader(
        next.image,
        TileMode.clamp,
        TileMode.clamp,
        Matrix4.diagonal3Values(
          600 / next.image.width,
          549 / next.image.height,
          1,
        ).storage,
        filterQuality: FilterQuality.medium,
      );
    }

    if (synchronous) {
      replace();
    } else {
      setState(replace);
    }
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _shader?.dispose();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texture = _shader;
    if (texture == null) {
      return const Image(
        image: _asset,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      );
    }
    return CustomPaint(painter: _FeatherInAir(texture, widget.phase));
  }
}

/// Three overlapping hinges along the gold shaft transmit a gust from the
/// quill to the tip. The illustrated airflow curls have their own pivots.
class _FeatherInAir extends CustomPainter {
  const _FeatherInAir(this.texture, this.phase);
  final ui.ImageShader texture;
  final double phase;
  static const _cols = 38, _rows = 33;
  static final _uv = [
    for (var r = 0; r <= _rows; r++)
      for (var c = 0; c <= _cols; c++) Offset(600 * c / _cols, 549 * r / _rows),
  ];
  static List<int> _quad(int i) => [
    i,
    i + 1,
    i + _cols + 1,
    i + 1,
    i + _cols + 2,
    i + _cols + 1,
  ];
  // The translucent fringe in the source reaches both side edges. Taper its
  // final few texels before posing it so no rectangular border can travel.
  static final _edgeAlpha = [
    for (final p in _uv)
      Colors.white.withValues(alpha: _smooth(math.min(p.dx, 600 - p.dx) / 18)),
  ];
  static final _indices = [
    for (var r = 0; r < _rows; r++)
      for (var c = 0; c < _cols; c++) ..._quad(r * (_cols + 1) + c),
  ];
  static double _smooth(double value) {
    final t = value.clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  static final _bones = [for (final p in _uv) _weightsAt(p)];
  static (double, double, double, double) _weightsAt(Offset p) {
    final u = ((p.dx - 124) * 411 - (p.dy - 419) * 325) / 274546;
    final leftCurl = _smooth((185 - p.dx) / 50) * _smooth((387 - p.dy) / 40);
    final rightCurl = _smooth((p.dx - 476) / 71) * _smooth((p.dy - 265) / 46);
    return (
      _smooth((u - .27) / .58),
      _smooth((u - .64) / .34),
      leftCurl,
      rightCurl,
    );
  }

  // Displacement induced by rotating a point around a joint.
  static Offset _bend(Offset delta, double sine, double cosine) => Offset(
    (cosine - 1) * delta.dx - sine * delta.dy,
    sine * delta.dx + (cosine - 1) * delta.dy,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final gust = phase * 2;
    final bend = -.17 * math.sin(gust - .52);
    final flick = -.12 * math.sin(gust - .97);
    final curlLeft = .29 * math.sin(gust + .82);
    final curlRight = -.24 * math.sin(gust - .74);
    final bs = math.sin(bend), bc = math.cos(bend);
    final fs = math.sin(flick), fc = math.cos(flick);
    final ls = math.sin(curlLeft), lc = math.cos(curlLeft);
    final rs = math.sin(curlRight), rc = math.cos(curlRight);
    const root = Offset(126, 416);
    final positions = <Offset>[];
    for (var i = 0; i < _uv.length; i++) {
      final p = _uv[i];
      final (middle, tip, left, right) = _bones[i];
      positions.add(
        p +
            _bend(p - const Offset(239, 353), bs, bc) * middle +
            _bend(p - const Offset(392, 267), fs, fc) * tip +
            _bend(p - const Offset(163, 365), ls, lc) * left +
            _bend(p - const Offset(475, 311), rs, rc) * right,
      );
    }
    canvas.save();
    canvas.scale(size.width / 600, size.height / 549);
    canvas.translate(
      root.dx + 5 * math.sin(gust),
      root.dy - 9 * math.sin(gust + .25),
    );
    canvas.rotate(-.048 * math.sin(gust));
    canvas.translate(-root.dx, -root.dy);
    final mesh = ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: _uv,
      colors: _edgeAlpha,
      indices: _indices,
    );
    canvas.drawVertices(mesh, BlendMode.modulate, Paint()..shader = texture);
    mesh.dispose();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FeatherInAir old) =>
      texture != old.texture || phase != old.phase;
}
