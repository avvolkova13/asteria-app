import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'cover_motion_love_abundance.dart';
import 'cover_motion_lunar_calm.dart';
import 'cover_motion_spec.dart';
import 'cover_motion_strength_creativity.dart';

const coverMotions = {
  ...loveAbundanceMotions,
  ...strengthCreativityMotions,
  ...lunarCalmMotions,
};

const _diameter = 350.0;
const _source = Rect.fromLTWH(0, 0, _diameter, _diameter);
const _tau = math.pi * 2;

class CoverMotionArtwork extends StatefulWidget {
  const CoverMotionArtwork({
    super.key,
    required this.asset,
    required this.scene,
    required this.seconds,
  });

  final String asset;
  final CoverScene scene;
  final double seconds;

  @override
  State<CoverMotionArtwork> createState() => _CoverMotionArtworkState();
}

class _CoverMotionArtworkState extends State<CoverMotionArtwork> {
  ImageStream? _stream;
  ImageInfo? _texture;
  late final _listener = ImageStreamListener(_onImage);
  late _CoverLayers _layers;

  @override
  void initState() {
    super.initState();
    _layers = _CoverLayers(widget.scene.parts);
  }

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
  void didUpdateWidget(CoverMotionArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene != widget.scene) {
      _layers = _CoverLayers(widget.scene.parts);
    }
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
    final texture = _texture;
    if (texture == null) return const SizedBox.expand();
    return RepaintBoundary(
      child: CustomPaint(
        painter: _CoverPainter(
          texture.image,
          _layers,
          widget.scene.effects,
          (widget.seconds % widget.scene.period) * _tau / widget.scene.period,
          MediaQuery.disableAnimationsOf(context),
        ),
      ),
    );
  }
}

class _CoverLayers {
  _CoverLayers(List<CoverPart> parts)
    : moving = [
        for (final part in parts) (part: part, clip: part.shape.path()),
      ] {
    var remainder = Path()..addRect(_source);
    for (final layer in moving) {
      remainder = Path.combine(PathOperation.difference, remainder, layer.clip);
    }
    stationary = remainder;
  }

  final List<({CoverPart part, Path clip})> moving;
  late final Path stationary;
}

class _CoverPainter extends CustomPainter {
  const _CoverPainter(
    this.texture,
    this.layers,
    this.effects,
    this.phase,
    this.reduced,
  );

  final ui.Image texture;
  final _CoverLayers layers;
  final List<CoverEffect> effects;
  final double phase;
  final bool reduced;

  @override
  void paint(Canvas canvas, Size size) {
    final bitmap = Rect.fromLTWH(
      0,
      0,
      texture.width.toDouble(),
      texture.height.toDouble(),
    );
    final paint = Paint()..filterQuality = FilterQuality.medium;
    final destination = fittedTextureRect(texture.width, texture.height);
    final factor = math.min(size.width, size.height) / _diameter;
    canvas
      ..save()
      ..translate(
        (size.width - _diameter * factor) / 2,
        (size.height - _diameter * factor) / 2,
      )
      ..scale(factor);

    if (layers.moving.isEmpty || phase == 0 || reduced) {
      canvas.drawImageRect(texture, bitmap, destination, paint);
    } else {
      canvas
        ..save()
        ..clipPath(layers.stationary)
        ..drawImageRect(texture, bitmap, destination, paint)
        ..restore();

      for (final layer in layers.moving) {
        final part = layer.part;
        final shifted = phase + part.phase;
        final oscillation = switch (part.travel) {
          CoverTravel.swing => math.sin(shifted) - math.sin(part.phase),
          CoverTravel.ease => (math.cos(part.phase) - math.cos(shifted)) / 2,
          CoverTravel.spin => phase / _tau,
        };
        final rotation = part.travel == CoverTravel.spin
            ? phase
            : part.degrees * math.pi / 180 * oscillation;
        canvas
          ..save()
          ..translate(
            part.pivot.dx + part.shift.dx * oscillation,
            part.pivot.dy + part.shift.dy * oscillation,
          )
          ..rotate(rotation)
          ..scale(1 + part.scale * oscillation)
          ..translate(-part.pivot.dx, -part.pivot.dy)
          ..clipPath(layer.clip)
          ..drawImageRect(texture, bitmap, destination, paint)
          ..restore();
      }
    }

    if (!reduced) {
      for (final effect in effects) {
        _drawEffect(canvas, effect, phase + effect.phase);
      }
    }
    canvas.restore();
  }

  static Rect fittedTextureRect(int width, int height) {
    final sourceSize = Size(width.toDouble(), height.toDouble());
    final fitted = applyBoxFit(BoxFit.contain, sourceSize, _source.size);
    return Alignment.center.inscribe(fitted.destination, _source);
  }

  static void _drawEffect(Canvas canvas, CoverEffect effect, double t) {
    final progress = (t / _tau) % 1;
    final pulse = .5 - .5 * math.cos(t);
    final position = effect.at;
    final color = effect.color;
    final radius = effect.size;
    final opacity = effect.strength;

    switch (effect.kind) {
      case CoverEffectKind.glow:
      case CoverEffectKind.windowLight:
        _halo(
          canvas,
          Offset.lerp(position, effect.to ?? position, pulse)!,
          radius * (.92 + .12 * pulse),
          color,
          opacity * (.07 + .29 * pulse),
        );
      case CoverEffectKind.flicker:
        final flicker = .58 + .25 * math.sin(3 * t) + .12 * math.sin(7 * t);
        _halo(
          canvas,
          position.translate(math.sin(3 * t) * 1.6, 0),
          radius,
          color,
          .33 * opacity * flicker,
        );
      case CoverEffectKind.glint:
        final finish =
            effect.to ?? position.translate(radius * .9, -radius * .3);
        final active = math.sin(math.pi * progress);
        final spot = Offset.lerp(position, finish, progress)!;
        _halo(canvas, spot, radius * .53, color, .36 * opacity * active);
        _halo(canvas, spot, radius * .13, color, .59 * opacity * active);
      case CoverEffectKind.steam:
        final tip =
            effect.to ?? position.translate(radius * .18, -radius * 1.5);
        final axis = tip - position;
        for (var strand = 0; strand < 3; strand++) {
          final travel = (progress + strand / 3) % 1;
          final lift = position + axis * travel;
          final sway = math.sin(travel * math.pi * 2 + strand) * radius * .19;
          final fade = math.sin(math.pi * travel);
          final path = Path()
            ..moveTo(lift.dx - sway * .45, lift.dy + radius * .18)
            ..quadraticBezierTo(
              lift.dx + sway,
              lift.dy,
              lift.dx - sway * .2,
              lift.dy - radius * .26,
            );
          canvas.drawPath(
            path,
            Paint()
              ..color = color.withValues(alpha: .26 * opacity * fade)
              ..strokeWidth = 1.4 + travel * 2.5
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4),
          );
        }
      case CoverEffectKind.flow:
        final finish = effect.to ?? position.translate(0, radius);
        final direction = finish - position;
        for (var drop = 0; drop < 4; drop++) {
          final fall = (progress * 2 + drop / 4) % 1;
          final fade = math.sin(math.pi * fall);
          final point =
              position +
              direction * fall +
              Offset(math.sin(math.pi * fall) * radius * .11, 0);
          canvas.drawOval(
            Rect.fromCenter(center: point, width: 1.5, height: 2.8),
            Paint()..color = color.withValues(alpha: .52 * opacity * fade),
          );
        }
      case CoverEffectKind.sound:
        final finish = effect.to ?? position.translate(radius, 0);
        final direction = math.atan2(
          finish.dy - position.dy,
          finish.dx - position.dx,
        );
        for (var ring = 0; ring < 3; ring++) {
          final distance = (progress + ring / 3) % 1;
          final r = radius * (.16 + .9 * distance);
          canvas.drawArc(
            Rect.fromCircle(center: position, radius: r),
            direction - .54,
            1.08,
            false,
            Paint()
              ..color = color.withValues(
                alpha: .32 * opacity * math.sin(math.pi * distance),
              )
              ..strokeWidth = 1
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke,
          );
        }
      case CoverEffectKind.wave:
        for (var ring = 0; ring < 3; ring++) {
          final distance = (progress + ring / 3) % 1;
          final r = radius * (.2 + .8 * distance);
          canvas.drawOval(
            Rect.fromCenter(center: position, width: r * 2, height: r * .31),
            Paint()
              ..color = color.withValues(
                alpha: .27 * opacity * math.sin(math.pi * distance),
              )
              ..strokeWidth = .95
              ..style = PaintingStyle.stroke,
          );
        }
    }
  }

  static void _halo(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double opacity,
  ) {
    final bounds = Rect.fromCircle(center: center, radius: radius);
    canvas.drawOval(
      bounds,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * .25),
            color.withValues(alpha: 0),
          ],
          stops: const [0, .43, 1],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(_CoverPainter oldDelegate) =>
      oldDelegate.texture != texture ||
      oldDelegate.layers != layers ||
      oldDelegate.effects != effects ||
      oldDelegate.phase != phase ||
      oldDelegate.reduced != reduced;
}
