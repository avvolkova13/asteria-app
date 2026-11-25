import 'package:flutter/material.dart';

enum CoverTravel { swing, ease, spin }

enum CoverEffectKind {
  glow,
  glint,
  steam,
  flow,
  pour,
  sound,
  flicker,
  wave,
  windowLight,
}

class CoverScene {
  const CoverScene({
    required this.period,
    this.tiltDegrees = 0,
    this.parts = const [],
    this.effects = const [],
  });

  final double period;
  final double tiltDegrees;
  final List<CoverPart> parts;
  final List<CoverEffect> effects;
}

class CoverShape {
  const CoverShape.polygon(this.points) : oval = null;
  const CoverShape.oval(this.oval) : points = const [];

  final List<Offset> points;
  final Rect? oval;

  Path path() => oval == null
      ? (Path()..addPolygon(points, true))
      : (Path()..addOval(oval!));
}

class CoverPart {
  const CoverPart({
    required this.shape,
    required this.pivot,
    this.shift = Offset.zero,
    this.degrees = 0,
    this.phase = 0,
    this.travel = CoverTravel.swing,
    this.scale = 0,
    this.verticalScale = 0,
  });

  final CoverShape shape;
  final Offset pivot;
  final Offset shift;
  final double degrees, phase, scale, verticalScale;
  final CoverTravel travel;
}

class CoverEffect {
  const CoverEffect(
    this.kind, {
    required this.at,
    this.to,
    this.size = 30,
    this.strength = .6,
    this.color = const Color(0xffffddc5),
    this.phase = 0,
  });

  final CoverEffectKind kind;
  final Offset at;
  final Offset? to;
  final double size, strength, phase;
  final Color color;
}
