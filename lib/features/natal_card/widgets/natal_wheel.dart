import 'dart:math' as math;

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/localization/localized_display_names.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'natal_wheel_painter.dart';

/// Personal chart over the illustrated zodiac rim. Its Aries glyph marks the
/// middle of the Aries sector; all layers share that coordinate system.
class NatalWheel extends StatefulWidget {
  const NatalWheel({
    super.key,
    required this.data,
    required this.hasKnownBirthTime,
  });

  final PlanetsHousesDataModel data;
  final bool hasKnownBirthTime;

  static bool hasPlanets(PlanetsHousesDataModel data) =>
      data.hasPlanetCoordinates;

  @override
  State<NatalWheel> createState() => _NatalWheelState();
}

bool _valid(double longitude) =>
    longitude.isFinite && longitude >= 0 && longitude < 360;
Offset _point(double longitude, double radius) =>
    Offset.fromDirection((longitude - 105) * math.pi / 180, radius);
const _diameter = 700.0;
const _signs = [
  'aries',
  'taurus',
  'gemini',
  'cancer',
  'leo',
  'virgo',
  'libra',
  'scorpio',
  'sagittarius',
  'capricorn',
  'aquarius',
  'pisces',
];

class _NatalWheelState extends State<NatalWheel> with TickerProviderStateMixin {
  late final _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1160),
  );
  late final _highlight = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
    value: 1,
  );
  String? _previous;
  late var _layout = _WheelLayout(widget.data);
  String? _selected;
  String? _focused;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
      _highlight.value = 1;
    } else if (!_started) {
      _entrance.forward();
    }
    _started = true;
  }

  @override
  void didUpdateWidget(NatalWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.data, oldWidget.data)) {
      _layout = _WheelLayout(widget.data);
      if (!_layout.labels.containsKey(_selected)) _selected = null;
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _highlight.dispose();
    super.dispose();
  }

  void _choose(String? code) {
    if (_selected == null && code == null) return;
    LotusFeedback.selection();
    setState(() {
      _previous = _selected;
      _selected = _selected == code ? null : code;
    });
    if (MediaQuery.disableAnimationsOf(context)) {
      _highlight.value = 1;
    } else {
      _highlight.forward(from: 0);
    }
  }

  String _description(PlanetHousePositionModel p) {
    final l10n = context.l10n;
    final sign = l10n.zodiacSignName(_signs[(p.longitude / 30).floor()]);
    final name = l10n.planetName(p.code);
    if (!widget.hasKnownBirthTime) return '$name · $sign';
    final minute = ((p.longitude % 30) * 60).floor();
    final minutes = (minute % 60).toString().padLeft(2, '0');
    return "$name · $sign ${minute ~/ 60}° $minutes'";
  }

  @override
  Widget build(BuildContext context) {
    final chosen = _layout.planets
        .where((p) => p.code == _selected)
        .firstOrNull;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.maxWidth;
                final scale = size / _diameter;
                final center = Offset(size / 2, size / 2);
                final connected = _layout.connectionsOf(_selected);
                return GestureDetector(
                  excludeFromSemantics: true,
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (tap) {
                    // Use the nearest glyph in overlapping 44 pt touch areas.
                    double closest = math.max(22.0, 24 * scale);
                    String? code;
                    for (final label in _layout.labels.entries) {
                      final distance =
                          (center + label.value * scale - tap.localPosition)
                              .distance;
                      if (distance <= closest) {
                        closest = distance;
                        code = label.key;
                      }
                    }
                    _choose(code);
                  },
                  child: RepaintBoundary(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: FadeTransition(
                            opacity: _entrance.drive(
                              CurveTween(
                                curve: const Interval(
                                  0,
                                  .26,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/home/natal_wheel_rim.webp',
                              excludeFromSemantics: true,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _WheelPainter(
                              _layout,
                              widget.data,
                              widget.hasKnownBirthTime,
                              _selected,
                              _previous,
                              connected,
                              _entrance,
                              _highlight,
                            ),
                          ),
                        ),
                        for (final planet in _layout.planets)
                          _planet(planet, center, scale, connected),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Semantics(
          liveRegion: true,
          child: Text(
            chosen == null
                ? context.l10n.natalWheelSelectPlanet
                : _description(chosen),
            style: context.textTheme.inverseUrbanistRegular14,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _planet(
    PlanetHousePositionModel planet,
    Offset center,
    double scale,
    Set<String> connected,
  ) {
    final location = center + _layout.labels[planet.code]! * scale;
    final selected = planet.code == _selected;
    final active = selected || _focused == planet.code;
    final size = 40 * scale;
    final hitSize = math.max(44.0, size);
    return Positioned(
      key: ValueKey('natal-wheel-${planet.code}'),
      left: location.dx - hitSize / 2,
      top: location.dy - hitSize / 2,
      width: hitSize,
      height: hitSize,
      child: Semantics(
        button: true,
        selected: selected,
        label: _description(planet),
        value: selected
            ? connected
                  .where((code) => code != planet.code)
                  .map(context.l10n.planetName)
                  .join(', ')
            : null,
        onTap: () => _choose(planet.code),
        child: FocusableActionDetector(
          onShowFocusHighlight: (on) =>
              setState(() => _focused = on ? planet.code : null),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _choose(planet.code);
                return null;
              },
            ),
          },
          child: Center(
            child: FadeTransition(
              opacity: _entrance.drive(
                CurveTween(
                  curve: const Interval(.07, .36, curve: Curves.easeOut),
                ),
              ),
              child: AnimatedOpacity(
                opacity: connected.contains(planet.code) ? 1 : .38,
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 160),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xff927589),
                        Color(0xff635066),
                        Color(0xff3a293e),
                        Color(0xff59455f),
                      ],
                    ),
                    border: Border.all(
                      color: active
                          ? const Color(0xffffe3b1)
                          : const Color(0xffa2869c),
                      width: active ? 1.6 : .8,
                    ),
                  ),
                  padding: EdgeInsets.all(size * .16),
                  child: SvgPicture.string(
                    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="-14 -14 28 28"><path d="${_glyphs[planet.code]}" fill="none" stroke="${active || planet.code == 'sun' ? '#ffe1a2' : '#fff0e1'}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>',
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Aspect {
  const _Aspect(this.first, this.second, this.color);
  final PlanetHousePositionModel first;
  final PlanetHousePositionModel second;
  final Color color;
  bool connects(String code) => first.code == code || second.code == code;
}

class _WheelLayout {
  _WheelLayout(PlanetsHousesDataModel data) {
    final seen = <String>{};
    planets =
        [
          for (final p in data.positions)
            if (_glyphs.containsKey(p.code) &&
                _valid(p.longitude) &&
                seen.add(p.code))
              p,
        ]..sort((a, b) {
          final order = a.longitude.compareTo(b.longitude);
          return order != 0 ? order : a.code.compareTo(b.code);
        });
    _positionLabels();

    for (var i = 0; i < planets.length; i++) {
      for (var j = i + 1; j < planets.length; j++) {
        final delta =
            ((planets[i].longitude - planets[j].longitude + 540) % 360 - 180)
                .abs();
        for (final (angle, orb, color) in _rules) {
          if ((delta - angle).abs() <= orb) {
            aspects.add(_Aspect(planets[i], planets[j], color));
            break;
          }
        }
      }
    }
  }
  late final List<PlanetHousePositionModel> planets;
  final aspects = <_Aspect>[];
  final labels = <String, Offset>{};

  // Unwrap the circle across its largest empty arc. Pool neighbouring labels
  // until they have enough separation, preserving their order and mean angle.
  void _positionLabels() {
    if (planets.isEmpty) return;
    var start = 0;
    var largest = -1.0;
    for (var i = 0; i < planets.length; i++) {
      final next = (i + 1) % planets.length;
      final gap = (planets[next].longitude - planets[i].longitude + 360) % 360;
      if (gap > largest) {
        largest = gap;
        start = next;
      }
    }
    const gap = 20.0;
    final groups = <({double shifted, int count})>[];
    for (var i = 0; i < planets.length; i++) {
      final index = (start + i) % planets.length;
      final unwrapped = planets[index].longitude + (index < start ? 360 : 0);
      groups.add((shifted: unwrapped - i * gap, count: 1));
      while (groups.length > 1 &&
          groups[groups.length - 2].shifted > groups.last.shifted) {
        final last = groups.removeLast(), previous = groups.removeLast();
        final count = last.count + previous.count;
        groups.add((
          shifted:
              (last.shifted * last.count + previous.shifted * previous.count) /
              count,
          count: count,
        ));
      }
    }
    var i = 0;
    for (final group in groups) {
      for (var j = 0; j < group.count; j++, i++) {
        final planet = planets[(start + i) % planets.length];
        labels[planet.code] = _point(group.shifted + i * gap, 159);
      }
    }
  }

  Set<String> connectionsOf(String? selected) {
    if (selected == null) return labels.keys.toSet();
    final codes = {selected};
    for (final aspect in aspects) {
      if (aspect.connects(selected)) {
        codes.addAll([aspect.first.code, aspect.second.code]);
      }
    }
    return codes;
  }

  // Major aspects and their tolerances, in degrees, as in the approved wheel.
  static const _rules = [
    (0, 6, Color(0xffd1addc)),
    (60, 4, Color(0xffaac9dc)),
    (90, 5, Color(0xffeaa6b8)),
    (120, 6, Color(0xffb8a5ed)),
    (180, 6, Color(0xffe5b5a4)),
  ];
}

const _glyphs = {
  'sun':
      'M 8 0 A 8 8 0 1 1 -8 0 A 8 8 0 1 1 8 0 M 1 0 A 1 1 0 1 1 -1 0 A 1 1 0 1 1 1 0',
  'moon':
      'M 3 -9 Q 13 1 3 9 Q -3 12 -8 7 Q 4 8 4 0 Q 5 -6 -2 -10 Q 1 -10 3 -9 Z',
  'mercury':
      'M -6 -11 Q -5 -2 1 -3 Q 6 -3 7 -11 M 6 1 A 5.5 5.5 0 1 1 -5 1 A 5.5 5.5 0 1 1 6 1 M .5 7 V 12 M -3 9 H 4',
  'venus':
      'M 6 -3 A 6.5 6.5 0 1 1 -7 -3 A 6.5 6.5 0 1 1 6 -3 M -.5 4 V 12 M -5 8 H 4',
  'mars':
      'M 3 4 A 6.5 6.5 0 1 1 -10 4 A 6.5 6.5 0 1 1 3 4 M 1 -1 L 9 -9 H 3 M 9 -9 V -3',
  'jupiter': 'M -7 -7 Q -1 -9 -3 -3 Q -4 1 -9 4 H 7 M 3 -10 V 10',
  'saturn': 'M -5 -11 V 6 Q 0 -5 5 -1 Q 9 2 3 8 Q 1 12 7 10 M -9 -7 H 0',
  'uranus':
      'M -8 -9 V 2 M 8 -9 V 2 M -8 -5 Q 0 0 8 -5 M 0 -7 V 4 M 4 8 A 4 4 0 1 1 -4 8 A 4 4 0 1 1 4 8',
  'neptune': 'M -8 -9 Q -9 2 0 2 Q 9 2 8 -9 M 0 -10 V 11 M -4 7 H 4',
  'pluto':
      'M 3 -7 A 3 3 0 1 1 -3 -7 A 3 3 0 1 1 3 -7 M -7 -5 Q -7 2 0 2 Q 7 2 7 -5 M 0 2 V 11 M -4 7 H 4',
};
