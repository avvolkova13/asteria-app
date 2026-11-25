import 'package:flutter/material.dart';

enum CoverDeformation { horizon, canopy }

enum CoverTravel { swing, ease, spin }

enum CoverEffectKind {
  glow,
  glint,
  steam,
  kettleSteam,
  flow,
  sand,
  pour,
  sound,
  shellEcho,
  shellLustre,
  flicker,
  flowerSketch,
  wave,
  windowLight,
}

class CoverScene {
  const CoverScene({
    required this.period,
    this.hingedCase = false,
    this.deformation,
    this.tiltDegrees = 0,
    this.tiltPivot,
    this.parts = const [],
    this.effects = const [],
  });

  final double period;
  final bool hingedCase;
  final CoverDeformation? deformation;
  final double tiltDegrees;
  final Offset? tiltPivot;
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
    this.horizontalShear = 0,
    this.fixedClip = false,
  });

  final CoverShape shape;
  final Offset pivot;
  final Offset shift;
  final double degrees, phase, scale, verticalScale, horizontalShear;
  final CoverTravel travel;
  final bool fixedClip;
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
