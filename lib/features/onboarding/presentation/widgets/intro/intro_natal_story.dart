import 'dart:math' as math;

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/responsive_heading.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_wheel.dart';
import 'package:flutter/material.dart';

import 'intro_story.dart';

/// A guided illustration, without collecting or calculating birth data.
class IntroNatalStory extends StatelessWidget {
  const IntroNatalStory({super.key, required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) => IntroStory(
    active: active,
    duration: const Duration(seconds: 18),
    builder: (context, seconds, static, _) => LayoutBuilder(
      builder: (context, bounds) {
        final diameter = math.min(
          bounds.maxWidth,
          bounds.maxWidth >= 340 ? 250.0 : 207.0,
        );
        return Column(
          key: const ValueKey('intro-natal-story'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: diameter,
                height: diameter,
                child: _NatalAssembly(seconds: seconds, isStatic: static),
              ),
            ),
            const SizedBox(height: 14),
            if (static)
              const _StaticNatalPanel()
            else
              _NarratedNatalPanel(seconds: seconds),
          ],
        );
      },
    ),
  );
}

class _NarratedNatalPanel extends StatelessWidget {
  const _NarratedNatalPanel({required this.seconds});
  final double seconds;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (seconds >= 12.6) {
      return StoryReveal(
        time: seconds,
        start: 12.6,
        child: StoryCard(
          key: const ValueKey('intro-natal-question'),
          title: l.introNatalQuestionTitle,
          text: l.introNatalQuestion,
          emphasis: true,
        ),
      );
    }
    if (seconds >= 9.3) {
      return StoryReveal(
        time: seconds,
        start: 9.3,
        end: 12,
        child: StoryCard(
          key: const ValueKey('intro-natal-pattern'),
          title: l.introNatalPatternTitle,
          text: l.introNatalPattern,
        ),
      );
    }
    if (seconds >= 6) {
      return StoryReveal(
        time: seconds,
        start: 6,
        end: 8.7,
        child: StoryCard(
          key: const ValueKey('intro-natal-strength'),
          title: l.introNatalStrengthTitle,
          text: l.introNatalStrength,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Reduced Motion keeps both observations readable in one natural-height panel.
class _StaticNatalPanel extends StatelessWidget {
  const _StaticNatalPanel();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final body = AppTypography.text1.copyWith(
      color: AppColors.textInverse,
      height: 1.3,
    );
    return IntroStoryFocus(
      child: HomeGlassSurface(
        key: const ValueKey('intro-natal-question'),
        animateEntrance: false,
        tint: AppColorsDark.modal.withValues(alpha: .96),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.introNatalStrength, style: body),
              const SizedBox(height: 12),
              Text(l.introNatalPattern, style: body),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  l.introNatalQuestionTitle,
                  style: AppTypography.text2SemiBold.copyWith(
                    color: AppColorsDark.linkGold,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              ResponsiveHeading(
                l.introNatalQuestion,
                style: AppTypography.h3.copyWith(
                  color: AppColors.textInverse,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NatalAssembly extends StatelessWidget {
  const _NatalAssembly({required this.seconds, required this.isStatic});

  final double seconds;
  final bool isStatic;

  @override
  Widget build(BuildContext context) {
    final arrival = isStatic
        ? 1.0
        : Curves.easeOutCubic.transform(((seconds - .15) / .5).clamp(0.0, 1.0));
    final count = isStatic
        ? _planets.length
        : (((seconds - .5) / 3.5) * _planets.length)
              .floor()
              .clamp(0, _planets.length)
              .toInt();
    final highlighted = isStatic
        ? null
        : seconds >= 6 && seconds < 9
        ? ('sun', 6.0, 9.0)
        : seconds >= 9.3 && seconds < 12.3
        ? ('moon', 9.3, 12.3)
        : null;
    return ExcludeSemantics(
      child: Opacity(
        opacity: arrival,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MediaQuery(
              // Only the shared story clock animates the illustration.
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: NatalWheel(
                key: const ValueKey('intro-natal-chart'),
                data: _stages[count],
                hasKnownBirthTime: false,
                preview: true,
              ),
            ),
            if (highlighted != null)
              IgnorePointer(
                child: CustomPaint(
                  key: ValueKey('intro-natal-highlight-${highlighted.$1}'),
                  painter: _NatalPointHighlight(
                    longitude: _planets
                        .firstWhere((p) => p.code == highlighted.$1)
                        .longitude,
                    intensity:
                        (((seconds - highlighted.$2) / .3).clamp(0.0, 1.0) *
                        ((highlighted.$3 - seconds) / .3).clamp(0.0, 1.0)),
                    color: AppColorsDark.linkGold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NatalPointHighlight extends CustomPainter {
  const _NatalPointHighlight({
    required this.longitude,
    required this.intensity,
    required this.color,
  });
  final double longitude;
  final double intensity;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // The production wheel's label rail is radius 159 on its 700pt canvas.
    final radius = 159 * size.width / 700;
    final angle = (longitude - 105) * math.pi / 180;
    final center =
        Offset(size.width / 2, size.height / 2) +
        Offset.fromDirection(angle, radius);
    canvas.drawCircle(
      center,
      17,
      Paint()..color = color.withValues(alpha: .10 * intensity),
    );
    canvas.drawCircle(
      center,
      13,
      Paint()
        ..color = color.withValues(alpha: .92 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      center,
      19,
      Paint()
        ..color = color.withValues(alpha: .30 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8,
    );
  }

  @override
  bool shouldRepaint(_NatalPointHighlight oldDelegate) =>
      longitude != oldDelegate.longitude ||
      intensity != oldDelegate.intensity ||
      color != oldDelegate.color;
}

// Deliberately illustrative positions. No houses, birth coordinates, or exact
// degree claims are shown in this example or sent to a service.
const _planets = [
  PlanetHousePositionModel(
    code: 'sun',
    name: 'Sun',
    signCode: 'taurus',
    sign: 'Taurus',
    house: 0,
    longitude: 52,
  ),
  PlanetHousePositionModel(
    code: 'moon',
    name: 'Moon',
    signCode: 'scorpio',
    sign: 'Scorpio',
    house: 0,
    longitude: 224,
  ),
  PlanetHousePositionModel(
    code: 'mercury',
    name: 'Mercury',
    signCode: 'gemini',
    sign: 'Gemini',
    house: 0,
    longitude: 71,
  ),
  PlanetHousePositionModel(
    code: 'venus',
    name: 'Venus',
    signCode: 'aries',
    sign: 'Aries',
    house: 0,
    longitude: 18,
  ),
  PlanetHousePositionModel(
    code: 'mars',
    name: 'Mars',
    signCode: 'leo',
    sign: 'Leo',
    house: 0,
    longitude: 146,
  ),
  PlanetHousePositionModel(
    code: 'jupiter',
    name: 'Jupiter',
    signCode: 'sagittarius',
    sign: 'Sagittarius',
    house: 0,
    longitude: 255,
  ),
];

final _stages = List<PlanetsHousesDataModel>.generate(
  _planets.length + 1,
  (count) => PlanetsHousesDataModel(
    data: '',
    elements: const Elements(fire: '0', earth: '0', air: '0', water: '0'),
    positions: _planets.take(count).toList(growable: false),
  ),
  growable: false,
);
