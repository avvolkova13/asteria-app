import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'player_subject_motion.dart';

part 'calm_motion.dart';
part 'creative_motion.dart';
part 'lunar_motion.dart';
part 'pomegranate_motion.dart';
part 'rose_reflection.dart';
part 'abacus.dart';
part 'fig_leaves.dart';
part 'linked_stones.dart';
part 'strength_lion.dart';
part 'strength_sun.dart';

/// Registered transparent plates. Their pivots and paths use a 250-unit square.
class AffirmationMotionArtwork extends StatelessWidget {
  const AffirmationMotionArtwork({
    super.key,
    required this.motion,
    required this.phase,
  });

  final PlayerSubjectMotion motion;
  final double phase;
  static const _directory = 'assets/images/affirmation/motion/subjects';

  @override
  Widget build(BuildContext context) {
    final path = '$_directory/${motion.assetName}';
    final wave = math.sin(phase);
    final opening = (1 - math.cos(phase)) / 2;

    Widget plate(String suffix) => Image.asset(
      '$path$suffix.webp',
      fit: BoxFit.contain,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      filterQuality: FilterQuality.medium,
    );

    final base = plate('');
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox.square(
            dimension: 250,
            child: Stack(
              fit: StackFit.expand,
              children: switch (motion) {
                PlayerSubjectMotion.mountain ||
                PlayerSubjectMotion.sunInHand => [
                  _StrengthSun(
                    phase: phase,
                    mountain: motion == PlayerSubjectMotion.mountain,
                    plate: plate,
                  ),
                ],
                PlayerSubjectMotion.lion => [
                  _TexturedPlate(
                    asset: _LionMane.asset,
                    phase: phase,
                    painter: _LionMane.new,
                  ),
                ],
                PlayerSubjectMotion.hearts => [
                  CustomPaint(painter: _HeartOrbit(phase, front: false)),
                  Transform.translate(
                    offset: Offset(1.15 * wave, -3.8 * opening),
                    child: Transform.rotate(
                      alignment: const Alignment(0, .22),
                      angle: .028 * wave,
                      child: base,
                    ),
                  ),
                  CustomPaint(painter: _HeartOrbit(phase, front: true)),
                ],
                PlayerSubjectMotion.birds => [
                  base,
                  for (final left in [true, false])
                    _PerchedBird(
                      phase: phase,
                      left: left,
                      body: plate(left ? '_a' : '_b'),
                      wing: plate(left ? '_c' : '_d'),
                    ),
                ],
                PlayerSubjectMotion.key => [
                  _KeyCharm(phase: phase, metal: base, feathers: plate('_a')),
                ],
                PlayerSubjectMotion.coins => [
                  base,
                  ClipPath(
                    clipper: const _PurseOpening(),
                    child: Stack(
                      children: [
                        for (final (center, size, delay, tilt, drift, rise)
                            in const [
                              (Offset(89, 93), 71.0, .0, -.16, -3.0, 30.0),
                              (Offset(163, 91), 71.0, 2.13, .18, 3.5, 25.0),
                              (Offset(126, 127), 75.0, 4.22, -.04, 2.0, 22.0),
                            ])
                          _RisingCoin(
                            phase: phase - delay,
                            center: center,
                            diameter: size,
                            tilt: tilt,
                            drift: drift,
                            rise: rise,
                            face: plate('_a'),
                          ),
                      ],
                    ),
                  ),
                ],
                PlayerSubjectMotion.pomegranate => [
                  _TexturedPlate(
                    asset: _Pomegranate.asset,
                    phase: phase,
                    painter: _Pomegranate.new,
                  ),
                ],
                PlayerSubjectMotion.envelope => [
                  _WaxEnvelope(phase: phase, body: base, flap: plate('_a')),
                ],
                PlayerSubjectMotion.palette ||
                PlayerSubjectMotion.quill ||
                PlayerSubjectMotion.book => [
                  _CreativeMotion(motion: motion, phase: phase, plate: plate),
                ],
                PlayerSubjectMotion.moonClouds ||
                PlayerSubjectMotion.fullMoon ||
                PlayerSubjectMotion.orb => [
                  _LunarMotion(motion: motion, phase: phase, plate: plate),
                ],
                PlayerSubjectMotion.lotus ||
                PlayerSubjectMotion.stones ||
                PlayerSubjectMotion.lunarRibbons => [
                  _CalmMotion(motion: motion, phase: phase, plate: plate),
                ],
                _ => [base],
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// A square texture stays continuous as its registered vertices move.
abstract final class _SubjectMesh {
  static const side = 430.0;
  static const divisions = 32;
  static const stride = divisions + 1;
  static final points = <Offset>[
    for (var y = 0; y <= divisions; y++)
      for (var x = 0; x <= divisions; x++)
        Offset(side * x / divisions, side * y / divisions),
  ];
  static final triangles = <int>[
    for (var y = 0; y < divisions; y++)
      for (var x = 0; x < divisions; x++) ..._cell(y * stride + x),
  ];
  static List<int> _cell(int i) => [
    i,
    i + 1,
    i + stride,
    i + 1,
    i + stride + 1,
    i + stride,
  ];

  static void draw(
    Canvas canvas,
    ui.Image texture,
    List<Offset> posed, {
    List<Offset>? textureCoordinates,
  }) {
    final mesh = ui.Vertices(
      ui.VertexMode.triangles,
      posed,
      textureCoordinates: textureCoordinates ?? points,
      indices: triangles,
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
  }
}

class _TexturedPlate extends StatefulWidget {
  const _TexturedPlate({
    required this.asset,
    required this.phase,
    required this.painter,
  });
  final String asset;
  final CustomPainter Function(ui.Image, double) painter;
  final double phase;

  @override
  State<_TexturedPlate> createState() => _TexturedPlateState();
}

class _TexturedPlateState extends State<_TexturedPlate> {
  ImageStream? _stream;
  ImageInfo? _image;
  late final ImageStreamListener _listener = ImageStreamListener(_receive);

  void _receive(ImageInfo info, bool synchronous) {
    if (!mounted) {
      info.dispose();
      return;
    }
    void update() {
      _image?.dispose();
      _image = info;
    }

    if (synchronous) {
      update();
    } else {
      setState(update);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(_TexturedPlate old) {
    super.didUpdateWidget(old);
    if (old.asset != widget.asset) _resolve();
  }

  void _resolve() {
    final provider = AssetImage(widget.asset);
    final stream = provider.resolve(createLocalImageConfiguration(context));
    if (_stream?.key == stream.key) return;
    _stream?.removeListener(_listener);
    _image?.dispose();
    _image = null;
    _stream = stream..addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texture = _image?.image;
    if (texture == null) {
      return Image.asset(
        widget.asset,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
        filterQuality: FilterQuality.medium,
      );
    }
    return CustomPaint(painter: widget.painter(texture, widget.phase));
  }
}

/// A cord of fixed length, bent by a travelling wave. The feather eyelet is
/// registered to its last point, even at the widest part of the swing.
class _KeyCharm extends StatelessWidget {
  const _KeyCharm({
    required this.phase,
    required this.metal,
    required this.feathers,
  });

  final double phase;
  final Widget metal, feathers;

  static const anchor = Offset(110, 48);
  static const eye = Offset(24.1, 2.8);

  @override
  Widget build(BuildContext context) {
    final beat = phase * 2;
    final cord = <Offset>[anchor];
    const segments = 48;
    for (var i = 0; i < segments; i++) {
      final t = (i + .5) / segments;
      final angle =
          .12 +
          1.69 * math.exp(-6.0 * t) +
          (.15 + .33 * t) * math.sin(beat - 1.35 * t) +
          .045 * t * math.sin(phase - .8);
      cord.add(
        cord.last +
            Offset(-math.sin(angle), math.cos(angle)) * (110 / segments),
      );
    }
    final tip = cord.last;
    final featherTurn =
        .055 + .35 * math.sin(beat - 1.55) + .045 * math.sin(phase - 1.0);
    return Transform.translate(
      offset: Offset(12, -1.7 * math.sin(phase)),
      child: Transform.rotate(
        alignment: const Alignment(.12, -.61),
        angle: -.019 * math.sin(beat - .34),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 97,
              top: 16,
              width: 92.27,
              height: 211,
              child: metal,
            ),
            Positioned(
              left: tip.dx - eye.dx,
              top: tip.dy - eye.dy,
              width: 44.13,
              height: 85,
              child: Transform.rotate(
                alignment: Alignment(
                  2 * eye.dx / 44.13 - 1,
                  2 * eye.dy / 85 - 1,
                ),
                angle: featherTurn,
                child: feathers,
              ),
            ),
            CustomPaint(painter: _SilkCord(cord)),
          ],
        ),
      ),
    );
  }
}

class _SilkCord extends CustomPainter {
  const _SilkCord(this.points);

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Path()..addPolygon(points, false);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xff9c565e)
      ..strokeWidth = 3.1;
    canvas.drawPath(line, stroke);
    canvas.drawPath(
      line,
      stroke
        ..color = const Color(0xffe5a6a0)
        ..strokeWidth = 2.35,
    );
    // Short diagonal highlights describe the twist and follow the local tangent.
    stroke
      ..color = const Color(0xfffbd3be)
      ..strokeWidth = .76;
    for (var i = 1; i < points.length; i++) {
      final tangent =
          (points[i] - points[i - 1]) / (points[i] - points[i - 1]).distance;
      final normal = Offset(-tangent.dy, tangent.dx);
      final mid = (points[i] + points[i - 1]) * .5;
      canvas.drawLine(
        mid - normal * .85 - tangent * .55,
        mid + normal * .85 + tangent * .55,
        stroke,
      );
    }
    // Two snug turns loop around the gold upper arm of the star.
    for (final offset in [0.0, 2.25]) {
      final wrap = Path()
        ..moveTo(107.5 + offset, 46.2)
        ..quadraticBezierTo(110.7 + offset, 46.8, 111.2 + offset, 52.3);
      canvas.drawPath(
        wrap,
        stroke
          ..color = const Color(0xff98535a)
          ..strokeWidth = 2.7,
      );
      canvas.drawPath(
        wrap,
        stroke
          ..color = const Color(0xffedb7ad)
          ..strokeWidth = 1.65,
      );
    }
  }

  @override
  bool shouldRepaint(_SilkCord oldDelegate) => oldDelegate.points != points;
}

/// The coins are clipped at the velvet lip, with room to rise above the back.
class _PurseOpening extends CustomClipper<Path> {
  const _PurseOpening();

  @override
  Path getClip(Size size) {
    const artSize = 430.0;
    final lip = Path()
      ..moveTo(45, 0)
      ..lineTo(45, 146)
      ..cubicTo(51, 160, 69, 156, 86, 162)
      ..cubicTo(115, 169, 114, 209, 138, 226)
      ..cubicTo(151, 236, 166, 227, 182, 229)
      ..cubicTo(210, 230, 231, 258, 252, 250)
      ..cubicTo(275, 242, 287, 241, 299, 223)
      ..cubicTo(312, 200, 319, 175, 342, 168)
      ..cubicTo(361, 160, 381, 166, 393, 143)
      ..lineTo(393, 0)
      ..close();
    return lip.transform(
      Matrix4.diagonal3Values(
        size.width / artSize,
        size.height / artSize,
        1,
      ).storage,
    );
  }

  @override
  bool shouldReclip(_PurseOpening oldClipper) => false;
}

class _RisingCoin extends StatelessWidget {
  const _RisingCoin({
    required this.phase,
    required this.center,
    required this.diameter,
    required this.tilt,
    required this.drift,
    required this.rise,
    required this.face,
  });

  final double phase, diameter, tilt, drift, rise;
  final Offset center;
  final Widget face;

  @override
  Widget build(BuildContext context) {
    final lift = math.pow((1 + math.sin(phase)) / 2, 2).toDouble();
    final transform = Matrix4.identity()
      ..setEntry(3, 2, -.0012)
      ..rotateZ(tilt + drift * .070 * lift)
      ..rotateY(tilt + drift * .14 * lift);
    return Positioned(
      left: center.dx - diameter / 2 + drift * lift,
      top: center.dy - diameter / 2 - rise * lift,
      width: diameter,
      height: diameter,
      child: Transform(
        alignment: Alignment.center,
        transform: transform,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x562B1222),
                    offset: Offset(1.8, 2.3 + 2 * lift),
                    blurRadius: 2.5 + 2 * lift,
                    spreadRadius: -1.5,
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(1.4 + lift, 1.8),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0xFFAC743E),
                  BlendMode.srcIn,
                ),
                child: face,
              ),
            ),
            face,
          ],
        ),
      ),
    );
  }
}

/// Each bird leans around its toes. Its wing folds around the shoulder in
/// the same local frame, so the feathers follow the body through the greeting.
class _PerchedBird extends StatelessWidget {
  const _PerchedBird({
    required this.phase,
    required this.left,
    required this.body,
    required this.wing,
  });

  final double phase;
  final bool left;
  final Widget body;
  final Widget wing;

  @override
  Widget build(BuildContext context) {
    final beat = phase - (left ? .0 : .65);
    final settle = (1 - math.cos(beat)) / 2;
    final ruffle = math.pow((1 - math.cos(beat - .90)) / 2, 3).toDouble();
    return Transform.rotate(
      alignment: left ? const Alignment(-.26, .105) : const Alignment(.30, .12),
      angle: (left ? -.084 : .073) * settle,
      child: Stack(
        fit: StackFit.expand,
        children: [
          body,
          Transform.rotate(
            alignment: left
                ? const Alignment(-.39, -.47)
                : const Alignment(.48, -.36),
            angle: (left ? .13 : -.115) * ruffle,
            child: wing,
          ),
        ],
      ),
    );
  }
}

/// The wax and flap share a paper hinge. Their shadow falls on the pocket.
class _WaxEnvelope extends StatelessWidget {
  const _WaxEnvelope({
    required this.phase,
    required this.body,
    required this.flap,
  });

  final double phase;
  final Widget body, flap;

  @override
  Widget build(BuildContext context) {
    final lift = (1 - math.cos(phase)) / 2;
    final hinge = Matrix4.identity()
      ..setEntry(3, 2, -.0009)
      ..rotateX(.70 * lift);
    Widget folded(Widget child) => Transform(
      alignment: const Alignment(0, -0.60),
      transform: hinge,
      child: child,
    );
    return Transform.translate(
      offset: Offset(.8 * math.sin(phase), -2.8 * lift),
      child: Transform.rotate(
        angle: .019 * math.sin(phase),
        child: Stack(
          fit: StackFit.expand,
          children: [
            body,
            ClipPath(
              clipper: const _EnvelopeSilhouette(),
              child: Transform.translate(
                offset: Offset(0, 1.2 + 6.5 * lift),
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(
                    sigmaX: 1.4 + 2.6 * lift,
                    sigmaY: 1.4 + 2.6 * lift,
                  ),
                  child: folded(
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Color.lerp(
                          const Color(0x604a253f),
                          const Color(0x384a253f),
                          lift,
                        )!,
                        BlendMode.srcIn,
                      ),
                      child: flap,
                    ),
                  ),
                ),
              ),
            ),
            folded(
              Stack(
                fit: StackFit.expand,
                children: [
                  flap,
                  CustomPaint(painter: _WaxReflection(phase)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnvelopeSilhouette extends CustomClipper<Path> {
  const _EnvelopeSilhouette();
  @override
  Path getClip(Size size) => Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(20, 50, 230, 199),
        const Radius.circular(18),
      ),
    );
  @override
  bool shouldReclip(_EnvelopeSilhouette old) => false;
}

class _WaxReflection extends CustomPainter {
  const _WaxReflection(this.phase);
  final double phase;
  // Follow the raised inner heart clockwise, with a soft tail on the glaze.
  static final _rim =
      (Path()
            ..moveTo(125, 116)
            ..cubicTo(137, 96, 159, 108, 152, 129)
            ..cubicTo(146, 141, 134, 152, 125, 156)
            ..cubicTo(112, 148, 98, 136, 98, 123)
            ..cubicTo(98, 104, 116, 100, 125, 116)
            ..close())
          .computeMetrics()
          .first;

  @override
  void paint(Canvas canvas, Size size) {
    final length = _rim.length;
    final progress = phase / (2 * math.pi);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;
    for (var i = 0; i < 12; i++) {
      final start = ((progress + i * .005) % 1) * length;
      final end = start + .005 * length;
      paint.color = const Color(0xffffead9).withValues(
        alpha: .30 * math.pow(math.sin((i + .5) * math.pi / 12), 2).toDouble(),
      );
      canvas.drawPath(_rim.extractPath(start, math.min(length, end)), paint);
      if (end > length) {
        canvas.drawPath(_rim.extractPath(0, end - length), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_WaxReflection old) => old.phase != phase;
}

/// Both halves of the wire and its pearl share a single inclined ellipse.
class _HeartOrbit extends CustomPainter {
  const _HeartOrbit(this.phase, {required this.front});

  final double phase;
  final bool front;
  static const center = Offset(124.6, 117.3);
  static const tilt = -.43;
  static const major = 115.5;
  static const minor = 35.2;

  @override
  void paint(Canvas canvas, Size size) {
    final wire = Rect.fromCenter(
      center: Offset.zero,
      width: 2 * major,
      height: 2 * minor,
    );
    final angle = 2.30 - phase;
    final x = major * math.cos(angle);
    final depth = math.sin(angle);
    final y = minor * depth;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);
    final start = front ? 0.0 : math.pi;
    canvas.drawArc(
      wire,
      start,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.1
        ..color = const Color(0xffac7055),
    );
    canvas.drawArc(
      wire.shift(const Offset(0, -.35)),
      start,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.05
        ..shader = const LinearGradient(
          colors: [
            Color(0xffffe5ae),
            Color(0xffdc995f),
            Color(0xffffeac2),
            Color(0xffefbd83),
          ],
        ).createShader(wire),
    );
    canvas.restore();

    if ((depth >= 0) != front) return;
    final bead =
        center +
        Offset(
          x * math.cos(tilt) - y * math.sin(tilt),
          x * math.sin(tilt) + y * math.cos(tilt),
        );
    final radius = 8.3 + .7 * depth;
    final bounds = Rect.fromCircle(center: bead, radius: radius);
    canvas.drawCircle(
      bead,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.39, -.46),
          radius: .90,
          colors: [
            Color(0xfffff7de),
            Color(0xfff9d294),
            Color(0xffe5a565),
            Color(0xffbe7c57),
            Color(0xffecb481),
          ],
          stops: [0, .22, .56, .83, 1],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(_HeartOrbit old) =>
      old.phase != phase || old.front != front;
}
