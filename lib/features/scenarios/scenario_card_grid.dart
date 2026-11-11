import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show OrdinalSortKey;

enum ScenarioMood {
  calendar(Color(0xFF43376E), Color(0xFFBEAAFF), Color(0xFF737FD6)),
  practice(Color(0xFF56406C), Color(0xFFF2CDE8), Color(0xFFC6A4DE)),
  relationships(Color(0xFF552D50), Color(0xFFEEAFBB), Color(0xFFCA8FB6)),
  strength(Color(0xFF3C304E), Color(0xFFF6CC96), Color(0xFFBE90B8));

  const ScenarioMood(this.ground, this.rim, this.mist);
  final Color ground, rim, mist;
}

class ScenarioCardGrid extends StatefulWidget {
  const ScenarioCardGrid({super.key, required this.cards})
    : assert(cards.length == 4);
  final List<ScenarioCard> cards;

  @override
  State<ScenarioCardGrid> createState() => _ScenarioCardGridState();
}

class _ScenarioCardGridState extends State<ScenarioCardGrid>
    with SingleTickerProviderStateMixin {
  late final _pass = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..addStatusListener(_onStatus);
  Timer? _pause;
  bool _enabled = false;
  int _next = 0;
  ScenarioMood? _lit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final visible = ModalRoute.isCurrentOf(context) ?? true;
    final enabled =
        TickerMode.valuesOf(context).enabled && visible && !reducedMotion;
    if (enabled == _enabled) return;
    _enabled = enabled;
    if (enabled) {
      _schedule();
    } else {
      _pause?.cancel();
      _pass.stop();
      _lit = null;
      _next = 0;
    }
  }

  void _schedule() {
    _pause = Timer(const Duration(milliseconds: 1100), () {
      setState(() => _lit = widget.cards[_next].mood);
      _next = (_next + 1) % widget.cards.length;
      _pass.forward(from: 0);
    });
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _enabled) {
      setState(() => _lit = null);
      _schedule();
    }
  }

  @override
  void dispose() {
    _pause?.cancel();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _RimPhase(
    mood: _lit,
    progress: _pass,
    child: LayoutBuilder(
      builder: (context, bounds) {
        const gap = 10.0;
        final wideText = MediaQuery.textScalerOf(context).scale(16) > 20;
        if (wideText || bounds.maxWidth < 315) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final card in widget.cards)
                Padding(
                  padding: const EdgeInsets.only(bottom: gap),
                  child: card.withEntrance(),
                ),
            ],
          );
        }
        final width = (bounds.maxWidth - gap) / 2;
        Widget column(int top, int bottom, int topFlex) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: topFlex, child: widget.cards[top].withEntrance()),
              const SizedBox(height: gap),
              Expanded(
                flex: 5 - topFlex,
                child: widget.cards[bottom].withEntrance(),
              ),
            ],
          ),
        );
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: width * 2.86 + gap),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                column(0, 2, 3),
                const SizedBox(width: gap),
                column(1, 3, 2),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _RimPhase extends InheritedWidget {
  const _RimPhase({
    required this.mood,
    required this.progress,
    required super.child,
  });

  final ScenarioMood? mood;
  final Animation<double> progress;

  @override
  bool updateShouldNotify(_RimPhase oldWidget) => oldWidget.mood != mood;
}

class ScenarioCard extends StatelessWidget {
  const ScenarioCard({
    super.key,
    required this.mood,
    required this.title,
    required this.subtitle,
    required this.art,
    required this.onTap,
  });
  final ScenarioMood mood;
  final String title, subtitle, art;
  final VoidCallback onTap;

  static const _inset = 16.0;
  static const _gap = 8.0;
  static const _radius = BorderRadius.all(Radius.circular(30));
  static final _title = AppTypography.h3.copyWith(color: AppColors.textInverse);
  static final _caption = AppTypography.text2.copyWith(
    color: AppColors.cardTinted,
  );

  @override
  Widget build(BuildContext context) {
    final phase = context.dependOnInheritedWidgetOfExactType<_RimPhase>();
    return Semantics(
      button: true,
      sortKey: OrdinalSortKey(mood.index.toDouble()),
      child: Material(
        color: Colors.transparent,
        child: LotusInkTap(
          onTap: onTap,
          borderRadius: _radius,
          child: CustomPaint(
            foregroundPainter: phase != null && phase.mood == mood
                ? _RimHighlight(mood.rim, phase.progress)
                : null,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _GlassArtwork(mood),
                child: Padding(
                  padding: const EdgeInsets.all(_inset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: LotusRasterIcon(
                          art,
                          width: 126,
                          height: switch (mood) {
                            ScenarioMood.calendar ||
                            ScenarioMood.strength => 110,
                            ScenarioMood.practice ||
                            ScenarioMood.relationships => 64,
                          },
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: _gap),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: _title),
                            const SizedBox(height: 6),
                            Text(subtitle, style: _caption),
                          ],
                        ),
                      ),
                    ],
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

class _RimHighlight extends CustomPainter {
  _RimHighlight(this.tint, this.progress) : super(repaint: progress);

  final Color tint;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t <= 0 || t >= 1 || size.isEmpty) return;
    final rect = Offset.zero & size;
    final rim = ScenarioCard._radius.toRRect(rect).deflate(1.3);
    final envelope = math.sin(math.pi * t);
    final pearl = Color.lerp(tint, AppColors.white, .80)!;
    final clear = pearl.withValues(alpha: 0);
    final shader = SweepGradient(
      transform: GradientRotation(math.pi * (.73 + 1.14 * t)),
      colors: [
        clear,
        pearl.withValues(alpha: .56 * envelope),
        clear,
        clear,
      ],
      stops: const [0, .075, .17, 1],
    ).createShader(rect);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..shader = shader;
    canvas.save();
    canvas.clipRRect(rim.inflate(1.2));
    canvas.drawRRect(
      rim,
      stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.3),
    );
    canvas.drawRRect(
      rim,
      stroke
        ..strokeWidth = 1.35
        ..maskFilter = null,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RimHighlight oldDelegate) =>
      oldDelegate.tint != tint || oldDelegate.progress != progress;
}

// Paint the mist, bevel and directional reflections inside the same contour.
class _GlassArtwork extends CustomPainter {
  const _GlassArtwork(this.mood);
  final ScenarioMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = RRect.fromRectAndRadius(
      rect.deflate(.7),
      const Radius.circular(30),
    );
    final w = size.width, h = size.height;
    final floor = AppColorsDark.homeCanvas;
    final fill = Paint();
    Color shade(Color a, Color b, double mix) => Color.lerp(a, b, mix)!;
    canvas.save();
    canvas.clipRRect(shape);
    fill.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        shade(mood.ground, mood.mist, .32),
        mood.ground,
        shade(mood.ground, floor, .78),
      ],
      stops: const [0, .46, 1],
    ).createShader(rect);
    canvas.drawRect(rect, fill);

    void cloud(
      double x,
      double y,
      double rx,
      double ry,
      double angle,
      Color color,
    ) {
      canvas.save();
      canvas.translate(w * x, h * y);
      canvas.rotate(angle);
      canvas.scale(w * rx, h * ry);
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [
            color,
            color.withValues(alpha: color.a * .60),
            color.withValues(alpha: 0),
          ],
          stops: const [0, .42, 1],
        ).createShader(const Rect.fromLTRB(-1, -1, 1, 1));
      canvas.drawCircle(Offset.zero, 1, glow);
      canvas.restore();
    }

    final mist = mood.mist, rim = mood.rim;
    switch (mood) {
      case ScenarioMood.calendar:
        cloud(.63, .22, .61, .33, -.44, mist.withValues(alpha: .9));
        cloud(.82, .20, .31, .19, .24, rim.withValues(alpha: .85));
        cloud(.66, .17, .23, .15, .24, shade(mist, mood.ground, .31));
      case ScenarioMood.practice:
        cloud(.69, .18, .83, .16, -.34, rim.withValues(alpha: .85));
        cloud(.40, .35, .72, .085, -.34, mist.withValues(alpha: .69));
      case ScenarioMood.relationships:
        cloud(.37, .18, .46, .25, -.62, mist.withValues(alpha: .86));
        cloud(.78, .17, .40, .23, .45, rim.withValues(alpha: .84));
      case ScenarioMood.strength:
        cloud(.80, .23, .69, .32, -.52, mist.withValues(alpha: .78));
        cloud(.92, .18, .53, .14, -.52, rim.withValues(alpha: .94));
        cloud(
          .91,
          .13,
          .28,
          .065,
          -.52,
          AppColors.cardTinted.withValues(alpha: .70),
        );
    }
    final veil = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          floor.withValues(alpha: 0),
          floor.withValues(alpha: .12),
          floor.withValues(alpha: .62),
        ],
        stops: const [0, .44, 1],
      ).createShader(rect);
    canvas.drawRect(rect, veil);
    // Retain the colored, diffused inner light of each scenario under the
    // common glass reflection. The existing clip keeps every halo inside.
    canvas.drawRRect(
      shape.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..color = rim.withValues(alpha: .67),
    );
    canvas.drawRRect(
      shape.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = rim.withValues(alpha: .48),
    );
    CardLensDecoration.paintFinish(canvas, shape);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlassArtwork oldDelegate) => oldDelegate.mood != mood;
}
