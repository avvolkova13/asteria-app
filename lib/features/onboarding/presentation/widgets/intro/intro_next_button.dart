import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:flutter/material.dart';
import 'package:asteria_app/features/affirmation/player/player_pebble.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';

/// A fixed navigation anchor: its outer arc records completed tour steps.
class IntroNextButton extends StatefulWidget {
  const IntroNextButton({
    super.key,
    required this.index,
    this.page,
    this.totalPages = 4,
    required this.label,
    required this.onPressed,
  });
  final int index;
  final double? page;
  final int totalPages;
  final String label;
  final VoidCallback onPressed;
  @override
  State<IntroNextButton> createState() => _IntroNextButtonState();
}

class _IntroNextButtonState extends State<IntroNextButton>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );
  double _phaseStart = 0;
  double _phaseEnd = 1;
  double get _phase => _phaseStart + (_phaseEnd - _phaseStart) * _breath.value;
  bool _reduced = false;
  bool _resumeBreath = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    if (reduced) {
      _breath.stop();
    } else if (_reduced || _breath.value == 0) {
      _breath.forward();
    }
    _reduced = reduced;
  }

  @override
  void didUpdateWidget(IntroNextButton old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index && !_reduced) {
      final current = _phase;
      _phaseStart = current;
      _phaseEnd = current.floorToDouble() + 1;
      _breath.forward(from: 0);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _resumeBreath = _resumeBreath || _breath.isAnimating;
      _breath.stop();
    } else if (_resumeBreath && !_reduced) {
      _breath.forward();
      _resumeBreath = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _breath.dispose();
    super.dispose();
  }

  bool _pressed = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final reduced =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    final page = reduced
        ? widget.index.toDouble()
        : (widget.page ?? widget.index.toDouble());
    final progress = (page + 1) / widget.totalPages;
    final morph = (page - (widget.totalPages - 2)).clamp(0.0, 1.0);
    final travel = reduced ? 0.0 : math.sin(math.pi * (page - page.floor()));
    return Semantics(
      button: true,
      label: widget.label,
      onTap: widget.onPressed,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          onFocusChange: (value) => setState(() => _focused = value),
          borderRadius: BorderRadius.circular(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _breath,
                  builder: (context, _) {
                    final phase = _phase;
                    final fluid = reduced
                        ? 0.0
                        : (1 - math.cos(phase * 2 * math.pi)) / 2;
                    final tilt = reduced
                        ? 0.0
                        : .035 * math.sin(phase * 2 * math.pi);
                    return Transform.scale(
                      scaleX: 1 + .065 * travel,
                      scaleY: 1 - .045 * travel,
                      child: CustomPaint(
                        key: const ValueKey('intro-next-progress'),
                        painter: _ProgressRim(progress, _focused, fluid, tilt),
                        child: SizedBox(
                          width: 104,
                          height: 95,
                          child: Center(
                            child: AnimatedScale(
                              scale: _pressed && !reduced ? .92 : 1,
                              duration: reduced
                                  ? Duration.zero
                                  : const Duration(milliseconds: 150),
                              child: SizedBox(
                                width: 84,
                                height: 75,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned.fill(
                                      child: Transform.rotate(
                                        angle: tilt,
                                        child: CustomPaint(
                                          painter: LotusSurfacePainter(
                                            _dropShape(84, 75, fluid),
                                            _pressed,
                                            _focused,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox.square(
                                      dimension: 46,
                                      child: _ClayArrowMorph(progress: morph),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: AppTypography.text2SemiBold.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRim extends CustomPainter {
  const _ProgressRim(this.progress, this.focused, this.fluid, this.tilt);
  final double progress, fluid, tilt;
  final bool focused;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(tilt);
    canvas.translate(-size.width / 2, -size.height / 2);
    final rect = (Offset.zero & size).deflate(2);
    final contour = Path()
      ..addRRect(_dropShape(rect.width, rect.height, fluid).toRRect(rect));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = focused ? 3 : 1.5;
    canvas.drawPath(
      contour,
      paint..color = AppColorsDark.linkGold.withValues(alpha: .16),
    );
    final metric = contour.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      paint..color = AppColorsDark.linkGold,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ProgressRim old) =>
      progress != old.progress ||
      focused != old.focused ||
      fluid != old.fluid ||
      tilt != old.tilt;
}

BorderRadius _dropShape(double width, double height, double fluid) =>
    BorderRadius.lerp(
      LotusPebbleContour.play.resolve(width, height),
      BorderRadius.only(
        topLeft: Radius.elliptical(width * .60, height * .52),
        topRight: Radius.elliptical(width * .40, height * .65),
        bottomRight: Radius.elliptical(width * .52, height * .38),
        bottomLeft: Radius.elliptical(width * .48, height * .47),
      ),
      fluid,
    )!;

/// The endpoints retain the application's illustrated icons. Between them the
/// two rounded arms move as one pearlescent stroke, rather than cross-fading.
class _ClayArrowMorph extends StatelessWidget {
  const _ClayArrowMorph({required this.progress});
  final double progress;
  @override
  Widget build(BuildContext context) {
    final arrow = (1 - progress / .12).clamp(0.0, 1.0);
    final check = ((progress - .88) / .12).clamp(0.0, 1.0);
    return Stack(
      alignment: Alignment.center,
      children: [
        if (progress < .12)
          Opacity(
            opacity: arrow,
            child: const PlayerClayGlyph(ClayGlyph.chevron, 46),
          ),
        if (progress > 0 && progress < 1)
          Positioned.fill(
            child: Opacity(
              opacity: (1 - arrow - check).clamp(0.0, 1.0),
              child: CustomPaint(painter: _ClayMorphPainter(progress)),
            ),
          ),
        if (progress > .88)
          Opacity(
            opacity: check,
            child: const ClayIcon(
              Icons.check_rounded,
              size: 32,
              color: AppColors.textInverse,
            ),
          ),
      ],
    );
  }
}

class _ClayMorphPainter extends CustomPainter {
  const _ClayMorphPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    Offset point(Offset start, Offset end) =>
        Offset.lerp(start, end, progress)!;
    final a = point(const Offset(18, 12), const Offset(13, 23));
    final b = point(const Offset(30, 23), const Offset(21, 30));
    final c = point(const Offset(18, 34), const Offset(34, 16));
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      path.shift(const Offset(0, 1.5)),
      paint
        ..strokeWidth = 7
        ..color = AppColorsDark.modal.withValues(alpha: .65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    paint.maskFilter = null;
    canvas.drawPath(
      path,
      paint
        ..strokeWidth = 6.5
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF5F5), Color(0xFFFFE6F4), Color(0xFFC4B4DD)],
        ).createShader(Offset.zero & size),
    );
    paint.shader = null;
    canvas.drawPath(
      path.shift(const Offset(-.4, -.6)),
      paint
        ..strokeWidth = 1.6
        ..color = AppColors.textInverse.withValues(alpha: .48),
    );
  }

  @override
  bool shouldRepaint(_ClayMorphPainter old) => progress != old.progress;
}
