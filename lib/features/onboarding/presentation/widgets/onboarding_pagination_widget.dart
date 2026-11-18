import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

/// Four pearls stretch into a story track as the page moves under the finger.
class OnboardingPaginationWidget extends StatelessWidget {
  const OnboardingPaginationWidget({
    super.key,
    required this.totalPages,
    required this.currentPage,
    this.page,
    this.progress = const [],
    this.activeColor = AppColorsDark.linkGold,
    this.inactiveColor = AppColors.textInverse,
  });

  final int totalPages;
  final int currentPage;
  final double? page;
  final List<double> progress;
  final Color activeColor, inactiveColor;

  @override
  Widget build(BuildContext context) {
    final reduced =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    return RepaintBoundary(
      child: SizedBox(
        height: 18,
        width: double.infinity,
        child: CustomPaint(
          painter: _PearlProgressPainter(
            count: totalPages,
            page: reduced
                ? currentPage.toDouble()
                : page ?? currentPage.toDouble(),
            progress: progress,
            gold: activeColor,
            pearl: inactiveColor,
          ),
        ),
      ),
    );
  }
}

class _PearlProgressPainter extends CustomPainter {
  const _PearlProgressPainter({
    required this.count,
    required this.page,
    required this.progress,
    required this.gold,
    required this.pearl,
  });
  final int count;
  final double page;
  final List<double> progress;
  final Color gold, pearl;

  @override
  void paint(Canvas canvas, Size size) {
    if (count < 1) return;
    final position = page.clamp(0.0, (count - 1).toDouble());
    const gap = 12.0;
    final unit = math.max(
      0.0,
      (size.width - gap * (count - 1)) / (count + 2.4),
    );
    var x = 0.0;
    for (var i = 0; i < count; i++) {
      final focus = (1 - (position - i).abs()).clamp(0.0, 1.0);
      final width = unit * (1 + 2.4 * focus);
      final height = 5 + 5 * focus;
      final rect = Rect.fromLTWH(x, (size.height - height) / 2, width, height);
      final shape = RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.elliptical(height * .75, height * .85),
        topRight: Radius.elliptical(height * .8, height * .6),
        bottomLeft: Radius.elliptical(height * .55, height * .55),
        bottomRight: Radius.elliptical(height, height),
      );
      canvas.drawRRect(
        shape,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              pearl.withValues(alpha: .26),
              pearl.withValues(alpha: .08),
            ],
          ).createShader(rect),
      );
      // Previous steps stay filled; the incoming scene starts on its own clock.
      final elapsed = i < progress.length ? progress[i].clamp(0.0, 1.0) : 1.0;
      final completed = (position - i).clamp(0.0, 1.0);
      final fill = position < i
          ? elapsed * focus
          : elapsed + (1 - elapsed) * completed;
      canvas.save();
      canvas.clipRRect(shape);
      final fillWidth = width * fill;
      if (fillWidth > 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x, rect.top, fillWidth, height),
            topLeft: shape.tlRadius,
            topRight: shape.trRadius,
            bottomLeft: shape.blRadius,
            bottomRight: shape.brRadius,
          ),
          Paint()
            ..shader = LinearGradient(
              colors: [gold.withValues(alpha: .6), gold],
            ).createShader(rect),
        );
      }
      if (focus > 0) {
        // The small pearl marks the head of the actual story progress.
        final radius = height * .33;
        final tip = (x + fillWidth - radius).clamp(
          x + radius,
          x + width - radius,
        );
        canvas.drawCircle(
          Offset(tip, size.height / 2),
          radius,
          Paint()..color = pearl.withValues(alpha: .95 * focus),
        );
      }
      canvas.restore();
      canvas.drawRRect(
        shape.deflate(.35),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              pearl.withValues(alpha: .38),
              pearl.withValues(alpha: .04),
            ],
          ).createShader(rect),
      );
      x += width + gap;
    }
  }

  @override
  bool shouldRepaint(_PearlProgressPainter oldDelegate) =>
      count != oldDelegate.count ||
      page != oldDelegate.page ||
      gold != oldDelegate.gold ||
      pearl != oldDelegate.pearl ||
      !_sameProgress(oldDelegate.progress);

  bool _sameProgress(List<double> other) {
    if (other.length != progress.length) return false;
    for (var i = 0; i < progress.length; i++) {
      if (progress[i] != other[i]) return false;
    }
    return true;
  }
}
