import 'dart:math' as math;

import 'package:flutter/material.dart';

class PlateMotionArtwork extends StatelessWidget {
  const PlateMotionArtwork({
    super.key,
    required this.asset,
    required this.seconds,
  });

  final String asset;
  final double seconds;

  static const _cycleSeconds = 24;
  static const _drift = [
    Offset(-13, -10),
    Offset(14, -4),
    Offset(6, 14),
    Offset(-10, 12),
  ];

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(asset, fit: BoxFit.contain);
    final phase = (seconds % _cycleSeconds) * 2 * math.pi / _cycleSeconds;
    final separation = (1 - math.cos(phase)) / 2;
    if (separation < .018) return image;

    return Stack(
      fit: StackFit.expand,
      children: [
        for (var index = 0; index < _drift.length; index++)
          FractionalTranslation(
            translation:
                _drift[index] * (separation / _PlateShardClipper.sourceSize),
            child: ClipPath(clipper: _PlateShardClipper(index), child: image),
          ),
      ],
    );
  }
}

class _PlateShardClipper extends CustomClipper<Path> {
  const _PlateShardClipper(this.index);

  static const sourceSize = 350.0;

  final int index;

  // The three authored masks follow the center of the visible gold seams.
  // Their complement is the fourth piece, so the source is partitioned once.
  static final _masks = [
    Path()
      ..moveTo(0, 0)
      ..lineTo(224, 0)
      ..lineTo(213, 61)
      ..cubicTo(208, 79, 208, 99, 194, 115)
      ..cubicTo(191, 129, 191, 150, 184, 167)
      ..cubicTo(167, 182, 153, 198, 137, 209)
      ..cubicTo(120, 219, 101, 234, 82, 243)
      ..lineTo(0, 296)
      ..close(),
    Path()
      ..moveTo(224, 0)
      ..lineTo(350, 0)
      ..lineTo(350, 230)
      ..lineTo(274, 208)
      ..cubicTo(252, 200, 230, 188, 211, 181)
      ..quadraticBezierTo(195, 176, 184, 167)
      ..cubicTo(191, 150, 191, 129, 194, 115)
      ..cubicTo(208, 99, 208, 79, 213, 61)
      ..close(),
    Path()
      ..moveTo(137, 209)
      ..cubicTo(120, 219, 101, 234, 82, 243)
      ..lineTo(0, 296)
      ..lineTo(0, 350)
      ..lineTo(119, 350)
      ..lineTo(127, 269)
      ..cubicTo(129, 250, 143, 234, 137, 209)
      ..close(),
  ];

  static final _pieces = [
    _masks[0],
    _masks[1],
    Path.combine(
      PathOperation.difference,
      Path()..addRect(const Rect.fromLTWH(0, 0, sourceSize, sourceSize)),
      _masks.reduce((a, b) => Path.combine(PathOperation.union, a, b)),
    ),
    _masks[2],
  ];

  @override
  Path getClip(Size size) {
    return _pieces[index].transform(
      Matrix4.diagonal3Values(
        size.width / sourceSize,
        size.height / sourceSize,
        1,
      ).storage,
    );
  }

  @override
  bool shouldReclip(_PlateShardClipper oldClipper) => index != oldClipper.index;
}
