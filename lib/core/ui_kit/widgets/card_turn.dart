import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

/// The onboarding turn, shared by every interactive card reveal.
/// Progress is linear; both faces stay mounted so artwork decodes before turning.
class CardTurn extends StatelessWidget {
  const CardTurn({
    super.key,
    required this.progress,
    required this.front,
    required this.back,
    this.horizontal = false,
  });

  static const duration = Duration(milliseconds: 850);
  final double progress;
  final Widget front;
  final Widget back;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final value = reduced
        ? (progress > 0 ? 1.0 : 0.0)
        : Curves.easeInOutCubic.transform(progress.clamp(0.0, 1.0));
    final lift = math.sin(math.pi * value);
    final showFront = value >= .5;
    final angle = (showFront ? value - 1 : value) * math.pi;
    final transform = Matrix4.identity()..setEntry(3, 2, .0015);
    if (horizontal) {
      transform.rotateX(angle);
    } else {
      transform.rotateY(angle);
    }
    return Transform.translate(
      offset: Offset(0, -13 * lift),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColorsDark.homeCanvas.withValues(
                alpha: .35 + .25 * lift,
              ),
              blurRadius: 8 + 14 * lift,
              offset: Offset(0, 5 + 12 * lift),
            ),
          ],
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: transform,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Offstage(offstage: showFront, child: back),
              Offstage(offstage: !showFront, child: front),
            ],
          ),
        ),
      ),
    );
  }
}
