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
    final stream = AssetImage(
      widget.asset,
    ).resolve(createLocalImageConfiguration(context));
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
          widget.scene.hingedCase,
          widget.scene.deformation,
          widget.scene.tiltDegrees,
          widget.scene.tiltPivot,
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
      if (layer.part.fixedClip) continue;
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
    this.hingedCase,
    this.deformation,
    this.tiltDegrees,
    this.tiltPivot,
    this.phase,
    this.reduced,
  );

  final ui.Image texture;
  final _CoverLayers layers;
  final List<CoverEffect> effects;
  final bool hingedCase;
  final CoverDeformation? deformation;
  final double tiltDegrees;
  final Offset? tiltPivot;
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

    if (!reduced && tiltDegrees != 0) {
      final center = tiltPivot ?? _source.center;
      canvas
        ..translate(center.dx, center.dy)
        ..rotate(tiltDegrees * math.pi / 180 * math.sin(phase))
        ..translate(-center.dx, -center.dy);
    }

    if (deformation != null && !reduced) {
      _drawDeformedTexture(canvas, destination);
    } else if (hingedCase && !reduced && phase != 0) {
      _drawHingedCase(canvas, bitmap, destination, paint);
    } else if (layers.moving.isEmpty || phase == 0 || reduced) {
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
        canvas.save();
        if (part.fixedClip) canvas.clipPath(layer.clip);
        canvas
          ..translate(
            part.pivot.dx + part.shift.dx * oscillation,
            part.pivot.dy + part.shift.dy * oscillation,
          )
          ..rotate(rotation)
          ..skew(part.horizontalShear * oscillation, 0)
          ..scale(
            1 + part.scale * oscillation,
            1 + (part.scale + part.verticalScale) * oscillation,
          )
          ..translate(-part.pivot.dx, -part.pivot.dy);
        if (!part.fixedClip) canvas.clipPath(layer.clip);
        canvas
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

  // Trace the upper brass lip, including the scalloped clasp attached to it.
  static final _caseLid = Path()
    ..moveTo(42, 123)
    ..lineTo(308, 123)
    ..lineTo(308, 210)
    ..quadraticBezierTo(299, 223, 280, 223)
    ..lineTo(202, 223)
    ..quadraticBezierTo(198, 230, 185, 230)
    ..quadraticBezierTo(180, 237, 175, 231)
    ..quadraticBezierTo(161, 230, 158, 223)
    ..lineTo(74, 223)
    ..quadraticBezierTo(57, 223, 43, 213)
    ..close();

  static final _caseBase = Path.combine(
    PathOperation.difference,
    Path()..addRect(_source),
    _caseLid,
  );

  void _drawHingedCase(
    Canvas canvas,
    Rect bitmap,
    Rect destination,
    Paint paint,
  ) {
    final opening = (.5 - .5 * math.cos(phase));
    final lift = 32 * opening;
    // The velvet lining bridges the raised front lip and the stationary base.
    final lining = Path()
      ..moveTo(54, 213)
      ..quadraticBezierTo(56, 195 - lift * .52, 68, 208 - lift)
      ..quadraticBezierTo(175, 197 - lift, 284, 208 - lift)
      ..quadraticBezierTo(297, 199 - lift * .52, 298, 213)
      ..lineTo(295, 228)
      ..quadraticBezierTo(175, 240, 55, 228)
      ..close();
    canvas.drawPath(
      lining,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff311527), Color(0xff140c16), Color(0xff663347)],
        ).createShader(Rect.fromLTRB(54, 212 - lift, 298, 230)),
    );
    // Continue the lower rim behind the clasp when the clasp lifts away.
    canvas.save();
    canvas.clipRect(const Rect.fromLTRB(153, 223, 205, 238));
    canvas.translate(60, 0);
    canvas.drawImageRect(texture, bitmap, destination, paint);
    canvas.restore();
    canvas.save();
    canvas.clipPath(_caseBase);
    canvas.drawImageRect(texture, bitmap, destination, paint);
    canvas.restore();
    canvas.save();
    canvas.translate(175, 221 - lift);
    canvas.scale(1 - .018 * opening, 1 - .14 * opening);
    canvas.translate(-175, -221);
    canvas.clipPath(_caseLid);
    canvas.drawImageRect(texture, bitmap, destination, paint);
    canvas.restore();
  }

  Offset _canopyPoint(double x, double y) {
    final drop = ((y - 58) / 246).clamp(0.0, 1.0);
    final side = (x - 180).abs();
    // The cushion widens towards its base. Keep its seam and the rear
    // panel still, with a gradual transition into the free side folds.
    final cushionWidth = 50 + ((y - 213) * .75).clamp(0.0, 62.0);
    final freeEdge = ((side - cushionWidth) / 23).clamp(0.0, 1.0);
    final protection = ((y - 178) / 38).clamp(0.0, 1.0);
    final weight = drop * (1 - protection * (1 - freeEdge));
    final wave = math.sin(phase - 2.4 * drop + (x - 180) / 130);
    return Offset(x + 12 * weight * wave, y - 3 * weight * wave * wave);
  }

  void _drawDeformedTexture(Canvas canvas, Rect destination) {
    const divisions = 28;
    final positions = <Offset>[];
    final coordinates = <Offset>[];
    final stride = divisions + 1;
    final indices = <int>[];
    final travel = math.sin(phase);
    for (var row = 0; row <= divisions; row++) {
      for (var column = 0; column <= divisions; column++) {
        final u = column / divisions;
        final v = row / divisions;
        final x = destination.left + u * destination.width;
        final y = destination.top + v * destination.height;
        if (deformation == CoverDeformation.canopy) {
          positions.add(_canopyPoint(x, y));
        } else {
          final dx = (x - 173) / 117;
          final dy = (y - 173) / 91;
          final weight = (1 - dx * dx - dy * dy).clamp(0.0, 1.0);
          final depth = ((y - 125) / 80).clamp(0.0, 1.0);
          positions.add(Offset(x + (26 * depth - 11) * weight * travel, y));
        }
        coordinates.add(Offset(u * texture.width, v * texture.height));
        if (column < divisions && row < divisions) {
          final i = row * stride + column;
          indices.addAll([
            i,
            i + 1,
            i + stride,
            i + 1,
            i + stride + 1,
            i + stride,
          ]);
        }
      }
    }
    final mesh = ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: coordinates,
      indices: indices,
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

  static Rect fittedTextureRect(int width, int height) {
    final sourceSize = Size(width.toDouble(), height.toDouble());
    final fitted = applyBoxFit(BoxFit.contain, sourceSize, _source.size);
    return Alignment.center.inscribe(fitted.destination, _source);
  }

  // Pencil contours relative to the flower centre in the transparent artwork.
  static final _petalContours = [
    Path()
      ..moveTo(0, 0)
      ..cubicTo(-20, -5, -39, -20, -39, -38)
      ..quadraticBezierTo(-17, -40, 0, 0),
    Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-25, -26, -7, -47)
      ..quadraticBezierTo(17, -38, 0, 0),
    Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(9, -39, 40, -43)
      ..quadraticBezierTo(46, -18, 0, 0),
  ].map((path) => path.computeMetrics().first).toList();

  // Follow the lip of the original shell from its central whorl outwards.
  static final _shellRidge =
      (Path()
            ..moveTo(0, 0)
            ..cubicTo(3, -6, 12, 3, 5, 10)
            ..cubicTo(-4, 20, -22, 10, -19, -4)
            ..cubicTo(-14, -29, 17, -22, 21, 1)
            ..cubicTo(27, 39, -18, 48, -37, 20)
            ..cubicTo(-61, -18, -27, -55, 10, -41)
            ..cubicTo(69, -23, 78, 46, 37, 71))
          .computeMetrics()
          .first;

  static void _drawEffect(Canvas canvas, CoverEffect effect, double t) {
    final progress = (t / _tau) % 1;
    final pulse = .5 - .5 * math.cos(t);
    final position = effect.at;
    final color = effect.color;
    final radius = effect.size;
    final opacity = effect.strength;

    switch (effect.kind) {
      case CoverEffectKind.shellLustre:
        final distance = _shellRidge.length * progress;
        final tangent = _shellRidge.getTangentForOffset(distance)!;
        final spot = position + tangent.position;
        final shine = math.sin(math.pi * progress) * opacity;
        canvas.save();
        canvas.translate(spot.dx, spot.dy);
        canvas.rotate(tangent.angle);
        canvas.scale(1.45, .55);
        _halo(canvas, Offset.zero, radius, color, shine * .72);
        _halo(canvas, Offset.zero, radius * .5, color, shine * .6);
        canvas.restore();
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
      case CoverEffectKind.kettleSteam:
        final end = effect.to!;
        for (var strand = 0; strand < 3; strand++) {
          final left = Path();
          final right = <Offset>[];
          for (var step = 0; step <= 36; step++) {
            final height = step / 36;
            final center = Offset.lerp(position, end, height)!;
            final wave = _tau * height * 1.4 - t + strand * .85;
            final drift =
                radius * height * (math.sin(wave) + .35 * math.sin(2 * wave));
            final x = center.dx + drift + 7 * math.sin(math.pi * height);
            final width = 1.5 + radius * height * (.48 + .26 * math.cos(wave));
            if (step == 0) {
              left.moveTo(x - width, center.dy);
            } else {
              left.lineTo(x - width, center.dy);
            }
            right.add(Offset(x + width, center.dy));
          }
          for (final point in right.reversed) {
            left.lineTo(point.dx, point.dy);
          }
          left.close();
          final density = opacity * (strand == 0 ? .68 : .32);
          canvas.drawPath(
            left,
            Paint()
              ..shader = ui.Gradient.linear(
                position,
                end,
                [
                  color.withValues(alpha: density * .55),
                  color.withValues(alpha: density),
                  color.withValues(alpha: density * .55),
                  color.withValues(alpha: 0),
                ],
                const [0, .16, .60, 1],
              )
              ..maskFilter = MaskFilter.blur(
                BlurStyle.normal,
                strand == 0 ? 1.8 : 3.8,
              ),
          );
        }
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
      case CoverEffectKind.pour:
        final end = effect.to!;
        // Follow the illustrated stream: water turns down at the lip, then
        // falls almost vertically. Both ends stay fixed throughout the loop.
        for (var strand = 0; strand < 2; strand++) {
          final path = Path();
          for (var step = 0; step <= 32; step++) {
            final u = step / 32;
            final bend = math.pow(1 - u, 3);
            final wave =
                math.sin(math.pi * u) * math.sin(_tau * 2 * u - t * 3 + strand);
            final x =
                end.dx +
                (position.dx - end.dx) * bend +
                (strand - .5) * radius +
                wave * 1.1;
            final y = position.dy + (end.dy - position.dy) * u;
            if (step == 0) {
              path.moveTo(x, y);
            } else {
              path.lineTo(x, y);
            }
          }
          const spacing = 27.0;
          final y = position.dy + spacing * (progress * 4 + strand * .47);
          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strand == 0 ? 2.1 : 1.3
              ..strokeCap = StrokeCap.round
              ..shader = ui.Gradient.linear(
                Offset(0, y),
                Offset(0, y + spacing),
                [
                  color.withValues(alpha: .08),
                  color.withValues(alpha: opacity),
                  color.withValues(alpha: .08),
                ],
                const [0, .58, 1],
                TileMode.repeated,
              ),
          );
        }
      case CoverEffectKind.sand:
        final peak = effect.to!;
        final grainPaint = Paint();
        // Staggered grains accelerate out of the neck and disperse at the pile.
        for (var grain = 0; grain < 28; grain++) {
          final fall = (progress * 2 + grain / 28) % 1;
          final distance = fall * (.35 + .65 * fall);
          final spread = math.sin(grain * 2.4) * (0.35 + 1.25 * distance);
          final point = Offset.lerp(position, peak, distance)!;
          grainPaint.color = (grain.isEven ? color : const Color(0xffbb783e))
              .withValues(alpha: .88 * math.min(1, fall * 18));
          canvas.drawOval(
            Rect.fromCenter(
              center: point.translate(spread, 0),
              width: 1.5,
              height: 1.4 + 1.6 * distance,
            ),
            grainPaint,
          );
        }
        for (var grain = 0; grain < 8; grain++) {
          final slide = (progress + grain / 8) % 1;
          final run = slide * (grain.isEven ? 12 : -12);
          grainPaint.color = color.withValues(alpha: .85 * (1 - slide));
          canvas.drawCircle(
            peak.translate(run, run.abs() * .57),
            .95,
            grainPaint,
          );
        }
      case CoverEffectKind.flowerSketch:
        final pencil = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.45
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(
            alpha: opacity * (1 - ((progress - .74) / .26).clamp(0.0, 1.0)),
          );
        canvas.save();
        canvas.translate(position.dx, position.dy);
        for (var i = 0; i < _petalContours.length; i++) {
          final stroke = _petalContours[i];
          final fraction = (progress * 4.6 - i).clamp(0.0, 1.0);
          canvas.drawPath(
            stroke.extractPath(0, fraction * stroke.length),
            pencil,
          );
        }
        canvas.restore();
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
      case CoverEffectKind.shellEcho:
        final axis = effect.to! - position;
        canvas.save();
        canvas.translate(position.dx, position.dy);
        const sweep = 2.2;
        final start = axis.direction - sweep / 2;
        for (var ring = 0; ring < 4; ring++) {
          final travel = (progress + ring / 4) % 1;
          final bounds = Rect.fromCircle(
            center: Offset.zero,
            radius: radius * (.34 + .66 * travel),
          );
          final light = color.withValues(
            alpha: opacity * math.sin(math.pi * travel),
          );
          final clear = color.withValues(alpha: 0);
          final paint = Paint()
            ..shader = ui.Gradient.sweep(
              Offset.zero,
              [clear, light, light, clear],
              const [0, .28, .7, 1],
              TileMode.clamp,
              0,
              sweep,
              Matrix4.rotationZ(start).storage,
            )
            ..strokeWidth = 1.6
            ..style = PaintingStyle.stroke;
          canvas.drawArc(bounds, start, sweep, false, paint);
        }
        canvas.restore();
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
      oldDelegate.hingedCase != hingedCase ||
      oldDelegate.deformation != deformation ||
      oldDelegate.tiltDegrees != tiltDegrees ||
      oldDelegate.tiltPivot != tiltPivot ||
      oldDelegate.phase != phase ||
      oldDelegate.reduced != reduced;
}
