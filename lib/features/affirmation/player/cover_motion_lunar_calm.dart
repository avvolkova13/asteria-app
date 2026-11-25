import 'package:flutter/material.dart';

import 'cover_motion_spec.dart';

const lunarCalmMotions = <String, CoverScene>{
  // Луна на краю окна — the small crescent drifts inside the fixed stone arch.
  'VjpyuyP2LiSbPotxcPjW': CoverScene(
    period: 5.6,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(123, 104),
          Offset(224, 104),
          Offset(224, 213),
          Offset(123, 213),
        ]),
        pivot: Offset(174, 160),
        shift: Offset(6, -13),
        degrees: 4,
      ),
    ],
  ),

  // Свет на исходе дня — soft caustics travel through separate prism facets.
  'JkdxrsDTLLC3PcvxkmJs': CoverScene(
    period: 6,
    tiltDegrees: 3.5,
    tiltPivot: Offset(175, 270),
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(121, 126),
        to: Offset(187, 152),
        size: 18,
        strength: .9,
        color: Color(0xffffc18a),
      ),
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(220, 273),
        size: 23,
        strength: .62,
        color: Color(0xffffa77e),
        phase: 1.8,
      ),
    ],
  ),

  // Намерение на новолуние — the boat rocks under the anchored eclipse.
  'en49nDLEdETuFD2AE4kA': CoverScene(
    period: 6,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(89, 235),
          Offset(260, 235),
          Offset(261, 314),
          Offset(89, 314),
        ]),
        pivot: Offset(175, 285),
        shift: Offset(8, -5),
        degrees: 5,
      ),
    ],
    effects: [
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(172, 43),
        size: 13,
        strength: .26,
        color: Color(0xffffb6b4),
        phase: 1.4,
      ),
    ],
  ),

  // Луна по дороге домой — separate movement in the sky and in the warm window.
  'AHICl7F381lItjTdo0JX': CoverScene(
    period: 7,
    parts: [
      CoverPart(
        shape: CoverShape.oval(Rect.fromLTRB(199, 14, 260, 76)),
        pivot: Offset(229, 45),
        shift: Offset(-9, -5),
        degrees: .4,
        travel: CoverTravel.ease,
      ),
    ],
    effects: [
      CoverEffect(
        CoverEffectKind.steam,
        at: Offset(224, 90),
        to: Offset(210, 62),
        size: 14,
        strength: .85,
        color: Color(0xffeacde0),
      ),
      CoverEffect(
        CoverEffectKind.windowLight,
        at: Offset(130, 191),
        to: Offset(130, 194),
        size: 24,
        strength: .86,
        color: Color(0xffffbd76),
      ),
    ],
  ),

  // То, что осталось от сна — a sheen runs along the feather, starting at its quill.
  'gkgBQSSVsX8KG74xHDHx': CoverScene(
    period: 6,
    tiltDegrees: 1.2,
    tiltPivot: Offset(175, 250),
    parts: [
      // Shear above the cushion so the quill keeps its point of contact.
      CoverPart(
        shape: CoverShape.polygon([
          Offset(10, 55),
          Offset(315, 55),
          Offset(315, 180),
          Offset(10, 180),
        ]),
        pivot: Offset(175, 180),
        horizontalShear: .085,
        verticalScale: .04,
      ),
      CoverPart(
        shape: CoverShape.polygon([
          Offset(12, 261),
          Offset(54, 261),
          Offset(62, 300),
          Offset(12, 300),
        ]),
        pivot: Offset(44, 261),
        horizontalShear: .12,
      ),
      CoverPart(
        shape: CoverShape.polygon([
          Offset(302, 261),
          Offset(340, 261),
          Offset(340, 300),
          Offset(294, 300),
        ]),
        pivot: Offset(309, 261),
        horizontalShear: .11,
        phase: .3,
      ),
    ],
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(113, 193),
        to: Offset(262, 110),
        size: 15,
        strength: .52,
        color: Color(0xffffd9c4),
      ),
    ],
  ),

  // Окно в тихий вечер — light drifts behind the panes, with the sill anchored.
  'Q2hvhy5ACR3qTUWRqXiN': CoverScene(
    period: 6,
    parts: [
      // The upper sprig bends above the rail inside the right pane.
      CoverPart(
        shape: CoverShape.polygon([
          Offset(184, 136),
          Offset(226, 136),
          Offset(234, 185),
          Offset(174, 185),
        ]),
        pivot: Offset(200, 185),
        horizontalShear: .14,
        fixedClip: true,
      ),
    ],
    effects: [
      CoverEffect(
        CoverEffectKind.windowLight,
        at: Offset(122, 135),
        to: Offset(136, 220),
        size: 35,
        strength: .92,
        color: Color(0xffe9c9ff),
      ),
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(194, 125),
        size: 31,
        strength: .65,
        color: Color(0xffffc1a6),
        phase: 2.3,
      ),
    ],
  ),

  // Последний свет дня — a candle lantern swings from the top of its handle.
  'end-the-day': CoverScene(
    period: 6,
    tiltDegrees: 4,
    tiltPivot: Offset(175, 27),
    effects: [
      CoverEffect(
        CoverEffectKind.flicker,
        at: Offset(175, 216),
        size: 23,
        strength: .95,
        color: Color(0xffffb959),
      ),
      CoverEffect(
        CoverEffectKind.windowLight,
        at: Offset(172, 216),
        to: Offset(177, 211),
        size: 40,
        strength: .78,
        color: Color(0xffffbc75),
      ),
    ],
  ),

  // Подальше от шума — lift the velvet lid about its rear hinge.
  'u6CbAmMlH0wBWDV7IPit': CoverScene(period: 6, hingedCase: true),

  // Тепло в ладонях — warmth travels through the two pieces of amber.
  'jm8SxlyHPrcWnxeDzapR': CoverScene(
    period: 6,
    tiltDegrees: 3.2,
    tiltPivot: Offset(175, 298),
    effects: [
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(133, 216),
        to: Offset(175, 183),
        size: 27,
        strength: .93,
        color: Color(0xffffbd68),
      ),
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(196, 233),
        to: Offset(223, 214),
        size: 20,
        strength: .88,
        color: Color(0xffffd18b),
        phase: 3.14,
      ),
    ],
  ),

  // Пока греется чайник — steam emerges directly from the spout.
  'lbf64Djr0E6Ea3KLBqRa': CoverScene(
    period: 4,
    effects: [
      CoverEffect(
        CoverEffectKind.kettleSteam,
        at: Offset(284, 173),
        to: Offset(296, 39),
        size: 19,
        strength: .95,
        color: Color(0xffffeee4),
      ),
    ],
  ),

  // Вечер между страниц — only the free end of the ribbon can move.
  'RMU7rfxrXT8WgXvcb4l7': CoverScene(
    period: 4.8,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(211, 267),
          Offset(250, 267),
          Offset(273, 304),
          Offset(213, 304),
        ]),
        pivot: Offset(228, 267),
        horizontalShear: .45,
        verticalScale: .055,
      ),
    ],
    effects: [
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(147, 185),
        size: 24,
        strength: .28,
        color: Color(0xffffd1a2),
      ),
    ],
  ),

  // Прогулка в своём ритме — each heel rolls over its own planted toe.
  'vhbT71sWOrtPb09BCGJf': CoverScene(
    period: 4.8,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(30, 140),
          Offset(212, 140),
          Offset(212, 197),
          Offset(202, 204),
          Offset(184, 216),
          Offset(172, 223),
          Offset(159, 237),
          Offset(147, 252),
          Offset(139, 269),
          Offset(134, 280),
          Offset(30, 280),
        ]),
        pivot: Offset(82, 255),
        degrees: 4,
        shift: Offset(3, 1),
        travel: CoverTravel.ease,
      ),
      CoverPart(
        shape: CoverShape.polygon([
          Offset(212, 140),
          Offset(310, 140),
          Offset(310, 322),
          Offset(134, 322),
          Offset(134, 280),
          Offset(139, 269),
          Offset(147, 252),
          Offset(159, 237),
          Offset(172, 223),
          Offset(184, 216),
          Offset(202, 204),
          Offset(212, 197),
        ]),
        pivot: Offset(168, 281),
        degrees: -4,
        shift: Offset(-2, -1),
        travel: CoverTravel.ease,
      ),
    ],
  ),

  // Взгляд вдаль — the hills slide at different depths inside the glass.
  '5kgmKpVpsoFUO6RRiO4n': CoverScene(
    period: 8,
    deformation: CoverDeformation.horizon,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(204, 70),
        to: Offset(251, 113),
        size: 21,
        strength: .48,
        color: Color(0xffffe2db),
      ),
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(243, 149),
        size: 17,
        strength: .24,
        color: Color(0xffffc6ab),
        phase: 2.1,
      ),
    ],
  ),

  // The moon hangs from its top ring; the star trails on a second joint.
  'yliaOclUECyQlRnFec77': CoverScene(
    period: 5.6,
    tiltPivot: Offset(175, 24),
    tiltDegrees: 5,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(138, 258),
          Offset(212, 258),
          Offset(212, 331),
          Offset(138, 331),
        ]),
        pivot: Offset(175, 258),
        degrees: 7,
        phase: -.65,
      ),
    ],
  ),

  // В своём темпе — the shell gently rocks around its grounded lower point.
  'own-pace': CoverScene(
    period: 7.2,
    tiltPivot: Offset(151, 278),
    tiltDegrees: 5,
    effects: [
      CoverEffect(
        CoverEffectKind.shellLustre,
        at: Offset(174, 190),
        color: Color(0xffffe3cb),
        size: 14,
      ),
    ],
  ),

  // Место для отдыха — a breeze runs from the suspension ring down both curtains.
  'allow-rest': CoverScene(
    period: 7.6,
    deformation: CoverDeformation.canopy,
    effects: [
      CoverEffect(
        CoverEffectKind.windowLight,
        at: Offset(142, 85),
        to: Offset(79, 227),
        size: 15,
        strength: .34,
        color: Color(0xffffd4ac),
      ),
      CoverEffect(
        CoverEffectKind.windowLight,
        at: Offset(195, 81),
        to: Offset(267, 227),
        size: 14,
        strength: .29,
        color: Color(0xffffbf9d),
        phase: 1.6,
      ),
    ],
  ),
};
