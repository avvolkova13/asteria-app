import 'dart:math' as math;

import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

/// A pearl with a small orbiting star. Accepts the constraints of icon slots.
class AsteriaActivityIndicator extends StatelessWidget {
  const AsteriaActivityIndicator({
    super.key,
    this.size = 32,
    this.color,
    this.semanticsLabel,
  });

  final double size;
  final String? semanticsLabel;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: _ActivityMark(
      line: false,
      color: color,
      semanticsLabel: semanticsLabel,
    ),
  );
}

/// Used above results when an in-place lookup is still running.
class AsteriaLoadingLine extends StatelessWidget {
  const AsteriaLoadingLine({super.key, this.minHeight = 3});

  final double minHeight;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: minHeight,
    child: const _ActivityMark(line: true),
  );
}

class _ActivityMark extends StatefulWidget {
  const _ActivityMark({required this.line, this.color, this.semanticsLabel});

  final bool line;
  final Color? color;
  final String? semanticsLabel;

  @override
  State<_ActivityMark> createState() => _ActivityMarkState();
}

class _ActivityMarkState extends State<_ActivityMark>
    with SingleTickerProviderStateMixin {
  late final _phase = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      _phase.stop();
      _phase.value = 0;
    } else if (!_phase.isAnimating) {
      _phase.repeat();
    }
  }

  @override
  void dispose() {
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark =
        ThemeData.estimateBrightnessForColor(
          Theme.of(context).colorScheme.surface,
        ) ==
        Brightness.dark;
    final pearl =
        widget.color ?? (dark ? AppColors.cardTinted : AppColors.uiPressed);
    return Semantics(
      label:
          widget.semanticsLabel ??
          AppLocalizations.maybeOf(context)?.loading ??
          MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ActivityPainter(
            phase: _phase,
            pearl: pearl,
            spark: dark ? AppColorsDark.linkGold : AppColors.warning,
            line: widget.line,
          ),
        ),
      ),
    );
  }
}

class _ActivityPainter extends CustomPainter {
  _ActivityPainter({
    required this.phase,
    required this.pearl,
    required this.spark,
    required this.line,
  }) : super(repaint: phase);

  final Animation<double> phase;
  final Color pearl;
  final Color spark;
  final bool line;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final angle = phase.value * 2 * math.pi - math.pi / 4;
    if (line) {
      final track = RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.height / 2),
      );
      final width = size.width * .32;
      final x = (size.width - width) * (.5 + .5 * math.sin(angle));
      canvas.drawRRect(track, Paint()..color = pearl.withValues(alpha: .22));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, width, size.height),
          Radius.circular(size.height / 2),
        ),
        Paint()
          ..shader = LinearGradient(
            colors: [
              pearl.withValues(alpha: .4),
              pearl,
              spark,
              pearl.withValues(alpha: .4),
            ],
          ).createShader(Rect.fromLTWH(x, 0, width, size.height)),
      );
      return;
    }

    final scale = size.shortestSide / 32;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.rotate(-.45);
    const orbit = Rect.fromLTRB(-13, -7, 13, 7);
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = pearl.withValues(alpha: .76);
    canvas.drawOval(orbit, rim);
    const globe = Rect.fromLTWH(-8, -8, 16, 16);
    canvas.drawOval(
      globe,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.38, -.52),
          radius: .96,
          colors: [
            AppColors.white,
            pearl,
            AppColors.primary,
            AppColors.deepPurple,
          ],
          stops: const [0, .3, .72, 1],
        ).createShader(globe),
    );
    canvas.drawArc(orbit, 0, math.pi, false, rim..strokeWidth = 1.25);
    canvas.translate(13 * math.cos(angle), 7 * math.sin(angle));
    canvas.rotate(.45);
    final star = Path()
      ..moveTo(0, -3.8)
      ..quadraticBezierTo(.7, -.8, 3.4, 0)
      ..quadraticBezierTo(.7, .7, 0, 3.8)
      ..quadraticBezierTo(-.7, .7, -3.4, 0)
      ..quadraticBezierTo(-.7, -.8, 0, -3.8)
      ..close();
    canvas.drawPath(star, Paint()..color = spark);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ActivityPainter old) =>
      phase != old.phase ||
      pearl != old.pearl ||
      spark != old.spark ||
      line != old.line;
}
