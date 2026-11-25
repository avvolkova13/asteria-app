import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CompassMotionArtwork extends StatefulWidget {
  const CompassMotionArtwork({
    super.key,
    required this.asset,
    required this.seconds,
  });

  final String asset;
  final double seconds;

  @override
  State<CompassMotionArtwork> createState() => _CompassMotionArtworkState();
}

class _CompassMotionArtworkState extends State<CompassMotionArtwork> {
  ImageStream? _stream;
  ImageInfo? _texture;
  late final _listener = ImageStreamListener(_onImage);

  void _onImage(ImageInfo texture, bool _) {
    _texture?.dispose();
    setState(() => _texture = texture);
  }

  void _resolveImage() {
    final stream = AssetImage(widget.asset)
        .resolve(createLocalImageConfiguration(context));
    if (_stream?.key == stream.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(CompassMotionArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) _resolveImage();
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _texture?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const period = 20;
    final phase = (widget.seconds % period) * 2 * math.pi / period;
    final texture = _texture;
    if (texture == null) return const SizedBox.expand();
    return CustomPaint(
      painter: _CompassPainter(texture.image, .29 * math.sin(phase)),
    );
  }
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter(this.texture, this.angle);

  final ui.Image texture;
  final double angle;

  static const _canvas = Rect.fromLTWH(0, 0, 350, 350);
  static const _pivot = Offset(174.5, 184.5);

  static final _needle = Path()
    ..moveTo(230, 129.5)
    ..lineTo(187, 181)
    ..quadraticBezierTo(190, 191, 177, 195)
    ..lineTo(120.5, 240)
    ..lineTo(161, 184)
    ..quadraticBezierTo(160, 176, 170, 173)
    ..close();

  static final _repair = Path()
    ..moveTo(228, 122)
    ..quadraticBezierTo(236, 124, 240, 134)
    ..cubicTo(222, 166, 208, 183, 186, 200)
    ..lineTo(122, 249)
    ..quadraticBezierTo(113, 244, 114, 236)
    ..lineTo(154, 176)
    ..quadraticBezierTo(163, 168, 170, 165)
    ..close();

  static final _pin = Path()
    ..addOval(Rect.fromCircle(center: _pivot, radius: 12.5));

  void _rotate(Canvas canvas, double turn) {
    canvas.translate(_pivot.dx, _pivot.dy);
    canvas.rotate(turn);
    canvas.translate(-_pivot.dx, -_pivot.dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.medium;
    final pixels = Rect.fromLTWH(
      0,
      0,
      texture.width.toDouble(),
      texture.height.toDouble(),
    );

    canvas
      ..save()
      ..scale(size.width / _canvas.width, size.height / _canvas.height)
      ..drawImageRect(texture, pixels, _canvas, paint)
      ..saveLayer(_canvas, Paint())
      ..save();

    // Rebuild the dial beneath the needle with the adjacent quadrants, using
    // a soft mask to preserve the continuous texture around the compass rose.
    _rotate(canvas, math.pi / 2);
    canvas
      ..drawImageRect(texture, pixels, _canvas, paint)
      ..restore()
      ..saveLayer(_canvas, Paint()..blendMode = BlendMode.dstIn)
      ..drawPath(
        _repair,
        Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      )
      ..restore()
      ..restore()
      ..save();

    _rotate(canvas, angle);
    canvas
      ..clipPath(_needle)
      ..drawImageRect(texture, pixels, _canvas, paint)
      ..restore()
      ..save()
      ..clipPath(_pin)
      ..drawImageRect(texture, pixels, _canvas, paint)
      ..restore()
      ..restore();
  }

  @override
  bool shouldRepaint(_CompassPainter oldDelegate) =>
      oldDelegate.texture != texture || oldDelegate.angle != angle;
}
