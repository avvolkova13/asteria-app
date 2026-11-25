import 'package:flutter/material.dart';

import 'cover_motion_spec.dart';

const strengthCreativityMotions = <String, CoverScene>{
  // A tuning fork excites the air just beyond the two prongs.
  'SjgtsPxXKEponVBlYiD6': CoverScene(
    period: 15,
    effects: [
      CoverEffect(
        CoverEffectKind.sound,
        at: Offset(172, 67),
        to: Offset(172, 25),
        size: 27,
        strength: .38,
        color: Color(0xffe5c3b4),
      ),
    ],
  ),
  // The brass lid pivots on the original hinge, leaving the base in place.
  'Uy6niGFiHzHBHFQWORlQ': CoverScene(
    period: 24,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(50, 66),
          Offset(315, 66),
          Offset(315, 222),
          Offset(273, 235),
          Offset(266, 240),
          Offset(250, 234),
          Offset(225, 224),
          Offset(120, 215),
          Offset(50, 164),
        ]),
        pivot: Offset(257, 236),
        degrees: -5,
        travel: CoverTravel.ease,
      ),
    ],
  ),
  'DWuLPUAlzUUXyCPulH13': CoverScene(
    period: 18,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(111, 93),
        to: Offset(178, 104),
        size: 11,
        strength: .50,
        color: Color(0xffffd6a4),
      ),
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(143, 139),
        size: 32,
        strength: .22,
        color: Color(0xffd99bf0),
        phase: .7,
      ),
    ],
  ),
  // Light travels from the central join along the repaired edge.
  'NyNDyj8u1W9FPs9mqEJh': CoverScene(
    period: 23,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(178, 175),
        to: Offset(219, 126),
        size: 13,
        strength: .58,
        color: Color(0xffffd27d),
      ),
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(198, 222),
        size: 17,
        strength: .35,
        color: Color(0xffe8aa5a),
        phase: 1.7,
      ),
    ],
  ),
  // Sweep the fabric's reflected light while keeping the two fastened ends.
  '2RIYK845VuQLc9nY5BRI': CoverScene(
    period: 19,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(108, 163),
        to: Offset(184, 193),
        size: 14,
        strength: .34,
        color: Color(0xffffae91),
      ),
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(184, 192),
        to: Offset(242, 161),
        size: 11,
        strength: .27,
        color: Color(0xffffbd9e),
        phase: 2.2,
      ),
    ],
  ),
  '2zZzl9CweTucZB8sNvcP': CoverScene(
    period: 23,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(142, 183),
        to: Offset(198, 206),
        size: 27,
        strength: .25,
        color: Color(0xffffd2ab),
      ),
    ],
  ),
  'RRgftUVHncxKmSVdWWvw': CoverScene(
    period: 18,
    effects: [
      CoverEffect(
        CoverEffectKind.wave,
        at: Offset(171, 254),
        size: 94,
        strength: .32,
        color: Color(0xffc5aacd),
      ),
    ],
  ),
  // A slender stream follows the neck instead of rocking the glass.
  'take-a-pause': CoverScene(
    period: 22,
    effects: [
      CoverEffect(
        CoverEffectKind.flow,
        at: Offset(143, 163),
        to: Offset(142, 232),
        size: 2.8,
        strength: .68,
        color: Color(0xffefb662),
      ),
    ],
  ),
  'tncBUKrnILVRSvOOMhbC': CoverScene(
    period: 22,
    effects: [
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(252, 108),
        size: 40,
        strength: .42,
        color: Color(0xffffc995),
      ),
      CoverEffect(
        CoverEffectKind.windowLight,
        at: Offset(221, 173),
        to: Offset(182, 224),
        size: 24,
        strength: .23,
        color: Color(0xffffca9d),
        phase: .8,
      ),
    ],
  ),
  // The removable top block lifts a little between the stationary supports.
  'mfLqiNf0SiuFxys9mIFc': CoverScene(
    period: 24,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(88, 198),
          Offset(88, 127),
          Offset(123, 111),
          Offset(219, 110),
          Offset(258, 134),
          Offset(259, 198),
          Offset(257, 204),
          Offset(210, 204),
          Offset(207, 202),
          Offset(202, 193),
          Offset(150, 193),
          Offset(144, 201),
          Offset(141, 204),
          Offset(90, 204),
        ]),
        pivot: Offset(174, 184),
        shift: Offset(0, -12),
        travel: CoverTravel.ease,
      ),
    ],
  ),
  'Ey0QKmkIfVmuNWjqhKKy': CoverScene(
    period: 17,
    effects: [
      CoverEffect(
        CoverEffectKind.sound,
        at: Offset(216, 193),
        to: Offset(278, 167),
        size: 29,
        strength: .56,
        color: Color(0xffefaf9c),
      ),
    ],
  ),
  '3EdRmElus4VdoFmQ7a31': CoverScene(
    period: 25,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(157, 146),
        to: Offset(193, 175),
        size: 11,
        strength: .54,
        color: Color(0xffffd497),
      ),
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(227, 86),
        to: Offset(208, 123),
        size: 15,
        strength: .24,
        color: Color(0xfff8c8ad),
        phase: 2.3,
      ),
    ],
  ),
  'OgIzBevTnltDCDJeeVgO': CoverScene(
    period: 42,
    parts: [
      CoverPart(
        shape: CoverShape.oval(Rect.fromLTWH(91, 79, 165, 166)),
        pivot: Offset(174, 163),
        travel: CoverTravel.spin,
      ),
    ],
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(131, 105),
        to: Offset(217, 130),
        size: 12,
        strength: .31,
        color: Color(0xfff4cf8f),
      ),
    ],
  ),
  'lN1JUJGz9ngbLpS2eMgV': CoverScene(
    period: 20,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(164, 54),
        to: Offset(210, 101),
        size: 22,
        strength: .39,
        color: Color(0xffe7daf1),
      ),
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(107, 149),
        to: Offset(159, 172),
        size: 14,
        strength: .30,
        color: Color(0xffb3e3ef),
        phase: 2.4,
      ),
    ],
  ),
  // The loose casting moves aside to show the mold underneath.
  '3qnA0Pc1xSUyJ4FieLzR': CoverScene(
    period: 25,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(230, 206),
          Offset(236, 197),
          Offset(240, 177),
          Offset(241, 158),
          Offset(238, 144),
          Offset(243, 116),
          Offset(286, 109),
          Offset(332, 149),
          Offset(337, 299),
          Offset(193, 303),
          Offset(195, 281),
          Offset(199, 265),
          Offset(204, 241),
          Offset(206, 230),
          Offset(212, 220),
          Offset(219, 213),
        ]),
        pivot: Offset(266, 281),
        shift: Offset(8, -4),
        degrees: 2,
        travel: CoverTravel.ease,
      ),
    ],
  ),
  'yApNZRoNizeuxJnQx3aJ': CoverScene(
    period: 20,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(103, 218),
        to: Offset(258, 225),
        size: 18,
        strength: .34,
        color: Color(0xffffdab7),
      ),
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(175, 98),
        to: Offset(148, 181),
        size: 17,
        strength: .32,
        color: Color(0xffffc982),
        phase: 2.1,
      ),
    ],
  ),
};
