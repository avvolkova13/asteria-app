import 'dart:ui';

import 'cover_motion_spec.dart';

const loveAbundanceMotions = <String, CoverScene>{
  // The quotation marks are separate ceramic pieces with a staggered drift.
  'MOgdL3XZWW6ZLIDUCmfH': CoverScene(
    period: 5,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(79, 113),
          Offset(181, 113),
          Offset(181, 277),
          Offset(79, 277),
        ]),
        pivot: Offset(130, 175),
        shift: Offset(-1, -14),
        degrees: 6,
      ),
      CoverPart(
        shape: CoverShape.polygon([
          Offset(181, 113),
          Offset(283, 113),
          Offset(283, 277),
          Offset(181, 277),
        ]),
        pivot: Offset(232, 175),
        shift: Offset(1, 12),
        degrees: 5,
        phase: -.35,
      ),
    ],
  ),
  'jW65YJ6XjzSvfnTJowcT': CoverScene(
    period: 22,
    effects: [
      CoverEffect(
        CoverEffectKind.steam,
        at: Offset(117, 130),
        size: 49,
        strength: .45,
        color: Color(0xfff8dbc8),
      ),
      CoverEffect(
        CoverEffectKind.steam,
        at: Offset(239, 126),
        size: 40,
        strength: .36,
        color: Color(0xfff7d4d9),
        phase: 1.6,
      ),
    ],
  ),
  'd09HZSKvdtMrmJ9TrsbZ': CoverScene(
    period: 20,
    effects: [
      CoverEffect(
        CoverEffectKind.sound,
        at: Offset(94, 118),
        to: Offset(60, 97),
        size: 37,
        strength: .32,
        color: Color(0xffffd394),
      ),
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(74, 176),
        to: Offset(110, 197),
        size: 13,
        strength: .32,
        color: Color(0xffffd5a0),
        phase: .9,
      ),
    ],
  ),
  // Pivot at the wick, leaving the curved wax lip on the stationary layer.
  'azOXLrtk8gjq01xr5oox': CoverScene(
    period: 12,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(168, 15),
          Offset(191, 15),
          Offset(191, 49),
          Offset(184, 60),
          Offset(179, 68),
          Offset(169, 67),
        ]),
        pivot: Offset(177, 66),
        degrees: 4,
        scale: .035,
      ),
    ],
    effects: [
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(180, 47),
        size: 31,
        strength: .27,
        color: Color(0xffffbd71),
      ),
    ],
  ),
  'KvjWWJfzOtGBXzi0VCzv': CoverScene(
    period: 21,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(57, 242),
        to: Offset(106, 262),
        size: 13,
        strength: .31,
        color: Color(0xffffd7a5),
      ),
    ],
  ),
  'itqgt8x2gCPskF3Dv19h': CoverScene(
    period: 19,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(142, 116),
        to: Offset(190, 116),
        size: 9,
        strength: .33,
        color: Color(0xfffee3a0),
      ),
    ],
  ),
  'upZVgJKPRtRONy5BLpIA': CoverScene(
    period: 16,
    effects: [
      CoverEffect(
        CoverEffectKind.flow,
        at: Offset(158, 125),
        to: Offset(139, 213),
        size: 10,
        strength: .49,
        color: Color(0xffffddbd),
      ),
      CoverEffect(
        CoverEffectKind.wave,
        at: Offset(139, 216),
        size: 23,
        strength: .36,
        color: Color(0xfff8cfaa),
        phase: .5,
      ),
    ],
  ),
  'fxI8f3BFIHA2L13zsdRP': CoverScene(
    period: 21,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(171, 293),
          Offset(180, 291),
          Offset(192, 304),
          Offset(187, 309),
          Offset(171, 307),
        ]),
        pivot: Offset(175, 293),
        degrees: 5,
      ),
    ],
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(147, 191),
        to: Offset(176, 193),
        size: 12,
        strength: .32,
        color: Color(0xffffbb85),
      ),
    ],
  ),
  'V3hQDZpjPVqDVEPedsNb': CoverScene(
    period: 23,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(156, 76),
        to: Offset(196, 73),
        size: 8,
        strength: .36,
        color: Color(0xfffbe2a6),
      ),
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(160, 252),
        to: Offset(195, 258),
        size: 11,
        strength: .38,
        color: Color(0xffffd3a0),
        phase: 1.7,
      ),
    ],
  ),
};
