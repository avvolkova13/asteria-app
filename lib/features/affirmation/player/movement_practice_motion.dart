part of 'body_motion_artwork.dart';

extension _MovementPractice on BodyMotionArtwork {
  List<Widget> _shakingLayers() {
    final beat = phase + .87 * math.pi;
    return [
      for (final (name, fingertip, extent, delay, drift) in const [
        ('drop-small', Offset(415, 281), Size(41, 49), .03, 40.0),
        ('drop-middle', Offset(479, 264), Size(52, 66), .16, 55.0),
        ('drop-large', Offset(375, 294), Size(58, 71), .29, 74.0),
      ])
        _releasedDrop(name, fingertip, extent, beat, delay, drift),
      Positioned.fill(child: _FlickingHand(beat)),
    ];
  }

  Widget _releasedDrop(
    String name,
    Offset fingertip,
    Size extent,
    double beat,
    double delay,
    double drift,
  ) {
    final age = (beat / (2 * math.pi) - delay - .04) % 1;
    const detach = .20;
    final forming = Curves.easeInOutSine.transform(
      (age / detach).clamp(0.0, 1.0),
    );
    final flight = ((age - detach) / (1 - detach)).clamp(0.0, 1.0);
    final releaseBeat = beat + (detach - age) * 2 * math.pi;
    final origin = Offset.lerp(
      _HandFlickPose.map(fingertip, beat),
      _HandFlickPose.map(fingertip, releaseBeat),
      forming,
    )!;
    final size = extent * (.18 + .75 * forming);
    final center =
        origin +
        Offset(
          size.width * .08 + drift * Curves.easeInOutSine.transform(flight),
          size.height * .39 + 155 * flight * flight,
        );
    final fade = Curves.easeInOutSine.transform(
      ((1 - age) / .38).clamp(0.0, 1.0),
    );
    return _layer(
      name,
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      angle: -.33 + .39 * age,
      finish: (image) => Opacity(opacity: forming * fade, child: image),
    );
  }

  List<Widget> _cloudLayers() {
    final transfer = math.sin(phase);
    final cradle = math.cos(phase);
    return [
      _layer(
        'upper-hand',
        const Rect.fromLTRB(21, 52, 426, 317),
        offset: Offset(22 * transfer, -12 * cradle),
        pivot: const Offset(76, 227),
        angle: .10 * math.sin(phase - .56),
      ),
      Transform.translate(
        offset: Offset(31 * math.sin(phase - .26), 11 * cradle),
        child: Transform.rotate(
          angle: -.040 * transfer,
          alignment: const Alignment(.01, .01),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _CloudPearl(phase, front: false)),
              _layer('cloud', const Rect.fromLTRB(106, 169, 493, 422)),
              const Positioned(
                left: 106,
                top: 169,
                width: 387,
                height: 253,
                child: RepaintBoundary(
                  child: CustomPaint(painter: _RestoredWire()),
                ),
              ),
              CustomPaint(painter: _CloudPearl(phase, front: true)),
            ],
          ),
        ),
      ),
      _layer(
        'lower-hand',
        const Rect.fromLTRB(157, 386, 585, 547),
        offset: Offset(18 * math.sin(phase + .38), 12 * math.cos(phase + .40)),
        pivot: const Offset(512, 443),
        angle: .095 * math.sin(phase + .45),
      ),
    ];
  }
}

class _HandFlickPose {
  static Offset map(Offset p, double beat) {
    const joint = Offset(119, 292);
    final progress = ((p.dx - 118) / 164 + (300 - p.dy) / 135).clamp(0.0, 1.0);
    final blend = progress * progress * (3 - 2 * progress);
    final angle = .088 * math.sin(beat) * blend;
    final finger = ((p.dx - 292) / 175).clamp(0.0, 1.0);
    final curl = finger * finger * math.sin(beat - .66);
    final dx = p.dx - joint.dx, dy = p.dy - joint.dy;
    return joint +
        Offset(
          dx * math.cos(angle) - dy * math.sin(angle) - 4 * curl,
          dx * math.sin(angle) + dy * math.cos(angle) + 8 * curl,
        );
  }
}

class _FlickingHand extends StatefulWidget {
  const _FlickingHand(this.beat);
  final double beat;
  @override
  State<_FlickingHand> createState() => _FlickingHandState();
}

class _FlickingHandState extends State<_FlickingHand> {
  static const _asset = AssetImage('assets/images/practices/motion-wrist.webp');
  ImageStream? _stream;
  late final _listener = ImageStreamListener(_receive);
  ImageInfo? _image;
  ui.ImageShader? _texture;
  void _receive(ImageInfo image, bool synchronous) {
    void replace() {
      _texture?.dispose();
      _image?.dispose();
      _image = image;
      _texture = ui.ImageShader(
        image.image,
        TileMode.clamp,
        TileMode.clamp,
        Matrix4.identity().storage,
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = _asset.resolve(createLocalImageConfiguration(context));
    if (_stream?.key == next.key) return;
    _stream?.removeListener(_listener);
    _stream = next..addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _texture?.dispose();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texture = _texture;
    if (texture == null) {
      return Stack(
        children: [
          Positioned(
            left: 24,
            top: 101,
            width: 518,
            height: 381,
            child: const Image(image: _asset, excludeFromSemantics: true),
          ),
        ],
      );
    }
    return CustomPaint(painter: _HandFlickPaint(texture, widget.beat));
  }
}

class _HandFlickPaint extends CustomPainter {
  const _HandFlickPaint(this.texture, this.beat);
  final ui.ImageShader texture;
  final double beat;
  static const columns = 24, rows = 18;
  static final uv = [
    for (var r = 0; r <= rows; r++)
      for (var c = 0; c <= columns; c++)
        Offset(518 * c / columns, 381 * r / rows),
  ];
  static final indices = [
    for (var r = 0; r < rows; r++)
      for (var c = 0; c < columns; c++) ..._cell(r * (columns + 1) + c),
  ];
  static List<int> _cell(int i) => [
    i,
    i + 1,
    i + columns + 1,
    i + 1,
    i + columns + 2,
    i + columns + 1,
  ];
  @override
  void paint(Canvas canvas, Size size) {
    final mesh = ui.Vertices(
      ui.VertexMode.triangles,
      [for (final p in uv) _HandFlickPose.map(p + const Offset(24, 101), beat)],
      textureCoordinates: uv,
      indices: indices,
    );
    canvas.drawVertices(mesh, BlendMode.srcOver, Paint()..shader = texture);
    mesh.dispose();
  }

  @override
  bool shouldRepaint(_HandFlickPaint old) =>
      old.beat != beat || old.texture != texture;
}

/// The small section of lavender and gold normally under the moving pearl.
class _RestoredWire extends CustomPainter {
  const _RestoredWire();
  @override
  void paint(Canvas canvas, Size size) {
    const patch = Rect.fromLTRB(257, 141, 309, 195);
    canvas.saveLayer(patch, Paint());
    final fill = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xffcea9e2),
        Color(0xffc399d4),
        Color(0xffb383bf),
        Color(0xffaf7dbb),
      ],
      stops: [0, .49, .82, 1],
    ).createShader(patch);
    canvas.drawRect(patch, Paint()..shader = fill);
    fill.dispose();
    final wire = Path()
      ..moveTo(253, 179.8)
      ..quadraticBezierTo(283, 170.2, 311, 160);
    for (final (width, color, dy) in const [
      (5.7, Color(0xffab7080), .9),
      (4.7, Color(0xffce966b), .0),
      (2.5, Color(0xffffdcac), -.95),
      (.85, Color(0xffffedcb), -1.65),
    ]) {
      canvas.drawPath(
        wire.shift(Offset(0, dy)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..color = color,
      );
    }
    final fade = const RadialGradient(
      radius: .51,
      colors: [Colors.white, Colors.white, Colors.transparent],
      stops: [0, .77, 1],
    ).createShader(patch);
    canvas.drawRect(
      patch,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = fade,
    );
    fade.dispose();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RestoredWire old) => false;
}

class _CloudPearl extends CustomPainter {
  const _CloudPearl(this.phase, {required this.front});
  final double phase;
  final bool front;
  static final _near =
      (Path()
            ..moveTo(5.5, 203)
            ..cubicTo(4, 225, 61, 223, 100, 216)
            ..cubicTo(157, 208, 238, 187, 285, 168.5)
            ..cubicTo(345, 148, 379, 121, 379, 99))
          .computeMetrics()
          .first;
  static final _far =
      (Path()
            ..moveTo(379, 99)
            ..cubicTo(379, 72, 342, 66, 302, 74)
            ..cubicTo(212, 79, 16, 151, 5.5, 203))
          .computeMetrics()
          .first;
  @override
  void paint(Canvas canvas, Size size) {
    final total = _near.length + _far.length;
    final distance = ((phase / (2 * math.pi) + .35) % 1) * total;
    if ((distance < _near.length) != front) return;
    final path = front ? _near : _far;
    final position = path
        .getTangentForOffset(front ? distance : distance - _near.length)!
        .position;
    final at = position + const Offset(106, 169);
    final depth = math.sin(
      math.pi * (front ? distance : distance - _near.length) / path.length,
    );
    final r = 14 + (front ? 2.5 : -2.5) * depth;
    final rect = Rect.fromCircle(center: at, radius: r);
    final shine = const RadialGradient(
      center: Alignment(-.43, -.49),
      radius: .95,
      colors: [
        Color(0xfffff9df),
        Color(0xfffbe1b4),
        Color(0xffe7b783),
        Color(0xffb98262),
        Color(0xffdfac78),
      ],
      stops: [0, .18, .50, .81, 1],
    ).createShader(rect);
    canvas.drawCircle(at, r, Paint()..shader = shine);
    shine.dispose();
  }

  @override
  bool shouldRepaint(_CloudPearl old) =>
      old.phase != phase || old.front != front;
}
