import 'dart:math' as math;

import 'package:flutter/material.dart';

class DoorMotionArtwork extends StatelessWidget {
  const DoorMotionArtwork({
    super.key,
    required this.asset,
    required this.seconds,
  });

  final String asset;
  final double seconds;

  static const cycle = Duration(seconds: 24);
  static const _frameClipper = _DoorClipper(_DoorPart.frame);
  static const _leafClipper = _DoorClipper(_DoorPart.leaf);

  @override
  Widget build(BuildContext context) {
    final phase = 2 * math.pi * seconds / cycle.inSeconds;
    final opening = (1 - math.cos(phase)) / 2;
    final angle = .12 + .82 * opening;
    final frame = Image.asset(asset, fit: BoxFit.contain);

    return LayoutBuilder(
      builder: (context, constraints) {
        final unit = constraints.maxWidth / _DoorClipper.sourceSize;
        final hinge = Offset(116 * unit, 0);
        final swing = Matrix4.identity()
          ..setEntry(0, 0, 1.18 * math.cos(angle))
          ..setEntry(1, 0, -.073 + .17 * opening);

        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _DoorwayLight(opening)),
            ClipPath(clipper: _frameClipper, child: frame),
            Transform(
              origin: hinge,
              transform: swing,
              child: ClipPath(clipper: _leafClipper, child: frame),
            ),
          ],
        );
      },
    );
  }
}

enum _DoorPart { frame, leaf }

class _DoorClipper extends CustomClipper<Path> {
  const _DoorClipper(this.part);

  static const sourceSize = 350.0;

  final _DoorPart part;

  static Path innerArch() => Path()
    ..moveTo(111, 293)
    ..lineTo(111, 129)
    ..cubicTo(111, 93, 139, 65, 172, 65)
    ..cubicTo(207, 65, 234, 92, 234, 131)
    ..lineTo(234, 293)
    ..close();

  @override
  Path getClip(Size size) {
    final path = switch (part) {
      _DoorPart.frame => Path.combine(
        PathOperation.difference,
        Path()..addRect(const Rect.fromLTWH(0, 0, sourceSize, sourceSize)),
        innerArch()..addRect(const Rect.fromLTRB(111, 278, 234, 320)),
      ),
      _DoorPart.leaf =>
        Path()
          ..moveTo(113, 293)
          ..lineTo(114, 121)
          ..cubicTo(114, 96, 134, 73, 160, 71)
          ..cubicTo(189, 68, 212, 86, 213, 119)
          ..lineTo(213, 297)
          ..quadraticBezierTo(210, 300, 204, 299)
          ..close(),
    };
    return path.transform(
      Matrix4.diagonal3Values(
        size.width / sourceSize,
        size.height / sourceSize,
        1,
      ).storage,
    );
  }

  @override
  bool shouldReclip(_DoorClipper oldClipper) => part != oldClipper.part;
}

class _DoorwayLight extends CustomPainter {
  const _DoorwayLight(this.opening);

  final double opening;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / _DoorClipper.sourceSize,
      size.height / _DoorClipper.sourceSize,
    );
    final cutout = _DoorClipper.innerArch();
    final glow = Color.lerp(
      const Color(0xffcf784c),
      const Color(0xffffe0a3),
      opening,
    )!;
    canvas.drawPath(
      cutout,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(.44, -.2),
          radius: .91,
          colors: [glow, const Color(0xffb45d38), const Color(0xff55272d)],
          stops: const [0, .62, 1],
        ).createShader(cutout.getBounds()),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DoorwayLight oldDelegate) =>
      opening != oldDelegate.opening;
}
