import 'package:flutter/material.dart';

import 'cover_motion_spec.dart';

const lunarCalmMotions = <String, CoverScene>{
  // Луна на краю окна — the small crescent drifts inside the fixed stone arch.
  'VjpyuyP2LiSbPotxcPjW': CoverScene(
    period: 28,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(123, 104),
          Offset(224, 104),
          Offset(224, 213),
          Offset(123, 213),
        ]),
        pivot: Offset(174, 160),
        shift: Offset(2, -6),
        degrees: .8,
      ),
    ],
  ),

  // Свет на исходе дня — soft caustics travel through separate prism facets.
  'JkdxrsDTLLC3PcvxkmJs': CoverScene(
    period: 24,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(121, 126),
        to: Offset(187, 152),
        size: 18,
        strength: .55,
        color: Color(0xffffc18a),
      ),
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(220, 273),
        size: 23,
        strength: .32,
        color: Color(0xffffa77e),
        phase: 1.8,
      ),
    ],
  ),

  // Намерение на новолуние — the boat rocks under the anchored eclipse.
  'en49nDLEdETuFD2AE4kA': CoverScene(
    period: 22,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(89, 235),
          Offset(260, 235),
          Offset(261, 314),
          Offset(89, 314),
        ]),
        pivot: Offset(175, 285),
        shift: Offset(5, -2),
        degrees: 3,
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
    period: 30,
    parts: [
      CoverPart(
        shape: CoverShape.oval(Rect.fromLTRB(199, 14, 260, 76)),
        pivot: Offset(229, 45),
        shift: Offset(-7, -4),
        degrees: .4,
        travel: CoverTravel.ease,
      ),
    ],
    effects: [
      CoverEffect(
        CoverEffectKind.windowLight,
        at: Offset(152, 169),
        to: Offset(151, 177),
        size: 10,
        strength: .52,
        color: Color(0xffffbd76),
      ),
    ],
  ),

  // То, что осталось от сна — a sheen runs along the feather, starting at its quill.
  'gkgBQSSVsX8KG74xHDHx': CoverScene(
    period: 23,
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
    period: 31,
    effects: [
      CoverEffect(
        CoverEffectKind.windowLight,
        at: Offset(122, 135),
        to: Offset(136, 220),
        size: 22,
        strength: .38,
        color: Color(0xffe9c9ff),
      ),
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(194, 125),
        size: 23,
        strength: .24,
        color: Color(0xffffc1a6),
        phase: 2.3,
      ),
    ],
  ),

  // Последний свет дня — the horizon lights briefly and slowly softens again.
  'end-the-day': CoverScene(
    period: 32,
    effects: [
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(168, 162),
        size: 40,
        strength: .45,
        color: Color(0xffffad6e),
      ),
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(95, 180),
        to: Offset(188, 163),
        size: 10,
        strength: .33,
        color: Color(0xffffd6aa),
        phase: 1.5,
      ),
    ],
  ),

  // Подальше от шума — brass catches light along the join of the velvet case.
  'u6CbAmMlH0wBWDV7IPit': CoverScene(
    period: 24,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(91, 217),
        to: Offset(177, 219),
        size: 11,
        strength: .56,
        color: Color(0xffffbf6b),
      ),
    ],
  ),

  // Тепло в ладонях — warmth travels through the two pieces of amber.
  'jm8SxlyHPrcWnxeDzapR': CoverScene(
    period: 20,
    effects: [
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(147, 206),
        size: 25,
        strength: .57,
        color: Color(0xffffbd68),
      ),
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(206, 224),
        size: 17,
        strength: .53,
        color: Color(0xffffd18b),
        phase: 2.1,
      ),
    ],
  ),

  // Пока греется чайник — steam emerges directly from the spout.
  'lbf64Djr0E6Ea3KLBqRa': CoverScene(
    period: 19,
    effects: [
      CoverEffect(
        CoverEffectKind.steam,
        at: Offset(287, 175),
        to: Offset(276, 83),
        size: 22,
        strength: .54,
        color: Color(0xffffddd9),
      ),
    ],
  ),

  // Мысли на бумаге — light follows the pencil and its gold ferrule.
  'Xe0Urlp7kqRChzBxz5Ym': CoverScene(
    period: 24,
    effects: [
      CoverEffect(
        CoverEffectKind.glint,
        at: Offset(165, 184),
        to: Offset(271, 151),
        size: 10,
        strength: .49,
        color: Color(0xffffd2a1),
      ),
    ],
  ),

  // Вечер между страниц — only the free end of the ribbon can move.
  'RMU7rfxrXT8WgXvcb4l7': CoverScene(
    period: 23,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(209, 264),
          Offset(239, 264),
          Offset(266, 303),
          Offset(220, 303),
        ]),
        pivot: Offset(225, 264),
        shift: Offset.zero,
        degrees: 1.8,
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

  // Прогулка в своём ритме — a soft reflection alternates over the suede toes.
  'vhbT71sWOrtPb09BCGJf': CoverScene(
    period: 26,
    effects: [
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(84, 230),
        size: 24,
        strength: .26,
        color: Color(0xffefb99c),
      ),
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(192, 263),
        size: 24,
        strength: .28,
        color: Color(0xffffc5aa),
        phase: 2.8,
      ),
    ],
  ),

  // Взгляд вдаль — reflection crosses the still glass above the horizon.
  '5kgmKpVpsoFUO6RRiO4n': CoverScene(
    period: 28,
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

  // Тихий край дня — the cloud drifts in the sky, within its available margin.
  'yliaOclUECyQlRnFec77': CoverScene(
    period: 36,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(0, 94),
          Offset(350, 94),
          Offset(350, 253),
          Offset(0, 253),
        ]),
        pivot: Offset(175, 169),
        shift: Offset(8, -2),
        degrees: 0,
        travel: CoverTravel.ease,
      ),
    ],
    effects: [
      CoverEffect(
        CoverEffectKind.glow,
        at: Offset(202, 168),
        size: 33,
        strength: .28,
        color: Color(0xffffbb87),
      ),
    ],
  ),

  // В своём темпе — the shell gently rocks around its grounded lower point.
  'own-pace': CoverScene(
    period: 26,
    parts: [
      CoverPart(
        shape: CoverShape.polygon([
          Offset(51, 73),
          Offset(310, 73),
          Offset(310, 291),
          Offset(51, 291),
        ]),
        pivot: Offset(174, 278),
        shift: Offset.zero,
        degrees: 2.5,
      ),
    ],
  ),

  // Место для отдыха — a soft light travels on separate folds of sheer fabric.
  'allow-rest': CoverScene(
    period: 34,
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
