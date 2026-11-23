import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'player_subject_motion.dart';

part 'breath_practice_motion.dart';
part 'contact_practice_motion.dart';
part 'evening_meditation_motion.dart';
part 'movement_practice_motion.dart';

/// Practice illustrations share a fixed coordinate system and a uniform outer fit.
class BodyMotionArtwork extends StatelessWidget {
  const BodyMotionArtwork({
    super.key,
    required this.motion,
    required this.phase,
  });

  final PlayerSubjectMotion motion;
  final double phase;

  static const _dir = 'assets/images/practices';

  Widget _layer(
    String name,
    Rect rect, {
    Offset offset = Offset.zero,
    double angle = 0,
    Offset? pivot,
    bool original = false,
    Widget Function(Widget)? finish,
  }) {
    final image = Image.asset(
      '$_dir/${original ? '' : 'motion-'}$name.webp',
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
      gaplessPlayback: true,
    );
    return Positioned.fromRect(
      rect: rect.shift(offset),
      child: Transform.rotate(
        angle: angle,
        alignment: pivot == null
            ? Alignment.center
            : Alignment(
                2 * (pivot.dx - rect.left) / rect.width - 1,
                2 * (pivot.dy - rect.top) / rect.height - 1,
              ),
        child: finish?.call(image) ?? image,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wave = math.sin(phase);
    final lift = .5 - .5 * math.cos(phase);
    final List<Widget> layers = switch (motion) {
      PlayerSubjectMotion.morning => [
        _layer('palm', const Rect.fromLTRB(104, 196, 504, 417)),
        _layer(
          'sun',
          const Rect.fromLTRB(174, 1, 468, 274),
          offset: Offset(0, -6 - 10 * lift),
          angle: wave * .058,
          pivot: const Offset(321, 146),
        ),
      ],
      PlayerSubjectMotion.workday => [
        _layer('tea', const Rect.fromLTRB(29, 162, 570, 481)),
        Positioned.fill(child: CustomPaint(painter: _Steam(phase))),
      ],
      PlayerSubjectMotion.sleep => [
        Positioned.fill(child: _SleepCushion(phase: phase)),
      ],
      PlayerSubjectMotion.breathing => _breathingLayers(),
      PlayerSubjectMotion.feather => _featherLayers(),
      PlayerSubjectMotion.shaking => _shakingLayers(),
      PlayerSubjectMotion.massage => _massageLayers(),
      PlayerSubjectMotion.cloudHands => _cloudLayers(),
      PlayerSubjectMotion.boards => _boardLayers(),
      _ => throw ArgumentError.value(motion, 'motion'),
    };
    final morning = motion == PlayerSubjectMotion.morning;
    // The morning master is a 536×417 transparent canvas with its hand on
    // the right. Centre the visible subject and leave room above the sun.
    final composition = SizedBox(
      width: morning ? 480 : 636,
      height: morning ? 480 : 636,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: morning ? -64 : 18,
            top: morning ? 40 : 18,
            width: 600,
            height: 600,
            child: Stack(clipBehavior: Clip.none, children: layers),
          ),
        ],
      ),
    );
    return FittedBox(fit: BoxFit.contain, child: composition);
  }
}
