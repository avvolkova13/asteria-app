import 'dart:async';
import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

const _barContentHeight = 66.0;
const _barTopPadding = 10.0;
const _barHorizontalPadding = 14.0;
const _compactHorizontalPadding = 8.0;
const _buttonGap = 9.0;
const _compactButtonGap = 6.0;
const _tabsHeight = 62.0;
const _barBottomPadding = 8.0;
const _aiButtonSize = 58.0;

class BottomTabBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;
  final VoidCallback? onAiAstrologerPressed;
  final String aiAstrologerAsset;

  const BottomTabBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.aiAstrologerAsset,
    this.onAiAstrologerPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        MediaQuery.paddingOf(context).bottom + _barBottomPadding;

    return ColoredBox(
      color: AppColorsDark.homeCanvas,
      child: SizedBox(
        height: _barTopPadding + _barContentHeight + bottomPadding,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 360;
              final horizontalPadding = isCompact
                  ? _compactHorizontalPadding
                  : _barHorizontalPadding;
              final gap = isCompact ? _compactButtonGap : _buttonGap;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  _barTopPadding,
                  horizontalPadding,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: _tabsHeight,
                        child: _LiquidTabStrip(
                          index: currentIndex,
                          onChanged: onTabChanged,
                        ),
                      ),
                    ),
                    SizedBox(width: gap),
                    if (onAiAstrologerPressed != null)
                      Semantics(
                        button: true,
                        label: context.l10n.anakraTitle,
                        child: LotusTap(
                          onTap: onAiAstrologerPressed,
                          behavior: HitTestBehavior.opaque,
                          child: AnakraIdleBadge(
                            assetPath: aiAstrologerAsset,
                          ),
                        ),
                      )
                    else
                      const SizedBox.square(dimension: _aiButtonSize),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Only the portrait and its light move. The chat target and shell stay still.
class AnakraIdleBadge extends StatefulWidget {
  const AnakraIdleBadge({super.key, required this.assetPath});

  final String assetPath;

  @override
  State<AnakraIdleBadge> createState() => _AnakraIdleMotionState();
}

class _AnakraIdleMotionState extends State<AnakraIdleBadge>
    with WidgetsBindingObserver {
  static const _interval = Duration(milliseconds: 40);
  static const _cycleTicks = 140;

  Timer? _timer;
  int _ticks = 0;
  bool _visible = false;
  bool _foreground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    _visible =
        !reduced &&
        TickerMode.valuesOf(context).enabled &&
        (ModalRoute.isCurrentOf(context) ?? true);
    if (reduced) _ticks = 0;
    _updateTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _updateTimer();
  }

  void _updateTimer() {
    if (!_visible || !_foreground) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= Timer.periodic(_interval, (_) {
      setState(() => _ticks = (_ticks + 1) % _cycleTicks);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final angle = 2 * math.pi * _ticks / _cycleTicks;
    return RepaintBoundary(
      child: _AiAstrologerButton(assetPath: widget.assetPath, angle: angle),
    );
  }
}

class _AiAstrologerButton extends StatelessWidget {
  const _AiAstrologerButton({required this.assetPath, required this.angle});

  final String assetPath;
  final double angle;

  @override
  Widget build(BuildContext context) {
    final breath = math.sin(angle);
    final glint = math.pow(math.max(0.0, math.sin(angle - .25)), 4).toDouble();
    return SizedBox(
      width: _aiButtonSize,
      height: _aiButtonSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size.square(_aiButtonSize),
            painter: _MessageBubbleShadowPainter(),
          ),
          ClipPath(
            clipper: const _MessageBubbleClipper(),
            child: CustomPaint(
              painter: _MessageBubbleBackgroundPainter(),
              child: Center(
                child: Transform(
                  alignment: Alignment.bottomCenter,
                  transformHitTests: false,
                  transform:
                      Matrix4.translationValues(.55 * breath, -1.65 * breath, 0)
                        ..rotateZ(.043 * breath)
                        ..scaleByDouble(
                          1 + .024 * breath,
                          1 + .035 * breath,
                          1,
                          1,
                        ),
                  child: Image.asset(
                    assetPath,
                    width: 46,
                    height: 46,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
          ),
          if (glint > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _AnakraGlint(glint)),
              ),
            ),
          CustomPaint(
            size: const Size.square(_aiButtonSize),
            painter: _MessageBubbleBorderPainter(),
          ),
        ],
      ),
    );
  }
}

class _AnakraGlint extends CustomPainter {
  const _AnakraGlint(this.intensity);

  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .78, size.height * .24);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.cardTinted.withValues(alpha: .45 * intensity),
          AppColors.cardTinted.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 8));
    canvas.drawCircle(center, 8, glow);
    final r = 2.6 + 1.5 * intensity;
    final flare = Path()
      ..moveTo(0, -r)
      ..quadraticBezierTo(0, 0, r * .72, 0)
      ..quadraticBezierTo(0, 0, 0, r)
      ..quadraticBezierTo(0, 0, -r * .72, 0)
      ..quadraticBezierTo(0, 0, 0, -r)
      ..close();
    canvas.drawPath(
      flare.shift(center),
      Paint()..color = AppColors.white.withValues(alpha: .86 * intensity),
    );
  }

  @override
  bool shouldRepaint(_AnakraGlint oldDelegate) =>
      oldDelegate.intensity != intensity;
}

class _MessageBubbleClipper extends CustomClipper<Path> {
  const _MessageBubbleClipper();

  @override
  Path getClip(Size size) => _messageBubblePath(size);

  @override
  bool shouldReclip(_MessageBubbleClipper oldClipper) => false;
}

class _MessageBubbleBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF786190), Color(0xFF513C69), Color(0xFF30243F)],
        stops: [0.0, 0.48, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    final sideTonePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.72, -0.12),
        radius: 0.72,
        colors: [
          const Color(0xFF7A59A1).withValues(alpha: 0.86),
          const Color(0xFF7A59A1).withValues(alpha: 0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.58, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.srcOver;
    canvas.drawRect(rect, sideTonePaint);
  }

  @override
  bool shouldRepaint(_MessageBubbleBackgroundPainter oldDelegate) => false;
}

class _MessageBubbleShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _messageBubblePath(size);
    canvas.drawShadow(
      path,
      const Color(0xFFE15B97).withValues(alpha: 0.34),
      4,
      true,
    );
    canvas.drawShadow(
      path.shift(const Offset(0, 1)),
      const Color(0xFF9A7DB8).withValues(alpha: 0.24),
      10,
      true,
    );
  }

  @override
  bool shouldRepaint(_MessageBubbleShadowPainter oldDelegate) => false;
}

class _MessageBubbleBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFECCBF8).withValues(alpha: 0.82);

    canvas.drawPath(_messageBubblePath(size), borderPaint);
  }

  @override
  bool shouldRepaint(_MessageBubbleBorderPainter oldDelegate) => false;
}

Path _messageBubblePath(Size size) {
  final w = size.width;
  final h = size.height;

  return Path()
    ..moveTo(w * 0.50, 0)
    ..cubicTo(w * 0.78, 0, w, h * 0.22, w, h * 0.50)
    ..cubicTo(w, h * 0.78, w * 0.78, h, w * 0.50, h)
    ..cubicTo(w * 0.45, h, w * 0.41, h * 0.99, w * 0.38, h * 0.96)
    ..cubicTo(w * 0.26, h * 0.94, w * 0.05, h * 0.99, w * 0.05, h * 0.94)
    ..cubicTo(w * 0.05, h * 0.88, w * 0.03, h * 0.78, w * 0.08, h * 0.70)
    ..cubicTo(w * 0.03, h * 0.63, 0, h * 0.55, 0, h * 0.50)
    ..cubicTo(0, h * 0.22, w * 0.22, 0, w * 0.50, 0)
    ..close();
}

class _LiquidTabStrip extends StatefulWidget {
  const _LiquidTabStrip({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  State<_LiquidTabStrip> createState() => _LiquidTabStripState();
}

class _LiquidTabStripState extends State<_LiquidTabStrip>
    with TickerProviderStateMixin {
  late final _position = AnimationController.unbounded(
    vsync: this,
    value: widget.index.toDouble(),
  );
  late final _lift = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 145),
  );
  static final _spring = SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: 380,
    ratio: .98,
  );
  int? _target;
  static const _assets = ['home', 'personal', 'moon', 'practice'];

  bool _reduced = false;
  bool _dragging = false;
  int? _pointer;
  double _origin = 0;
  double _startIndex = 0;
  int _candidate = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced) {
      _lift.value = 0;
      _position.value = widget.index.toDouble();
    }
  }

  void _settleOn(int index) {
    final destination = index.toDouble();
    if (_reduced) {
      _position.value = destination;
      return;
    }
    if (_target == index && _position.isAnimating) return;
    _target = index;
    final velocity = _position.velocity.clamp(-14.0, 14.0);
    if ((_position.value - destination).abs() < .001 && velocity.abs() < .01) {
      _position.value = destination;
      return;
    }
    _position.animateWith(
      SpringSimulation(
        _spring,
        _position.value,
        destination,
        velocity,
        snapToEnd: true,
      ),
    );
  }

  @override
  void didUpdateWidget(_LiquidTabStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index && !_dragging) _settleOn(widget.index);
  }

  @override
  void dispose() {
    _lift.dispose();
    _position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ink = AppColors.white;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final labels = [
      context.l10n.navHome,
      context.l10n.navPersonal,
      context.l10n.navMoon,
      context.l10n.navPractices,
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xc046344f),
            Color(0xd2251b31),
            Color(0xcf44354b),
          ],
        ),
        border: Border.all(color: ink.withValues(alpha: .16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: LayoutBuilder(
          builder: (context, bounds) {
            final slot = bounds.maxWidth / labels.length;
            double logical(double x) => (rtl ? bounds.maxWidth - x : x) / slot;
            int indexAt(double x) =>
                logical(x).floor().clamp(0, labels.length - 1);
            return Listener(
              onPointerDown: (e) {
                if (_pointer != null || e.buttons != 1) return;
                _pointer = e.pointer;
                _origin = logical(e.localPosition.dx);
                _candidate = indexAt(e.localPosition.dx);
                _startIndex = _candidate.toDouble();
                if (!_reduced) _lift.forward();
              },
              onPointerCancel: (e) {
                if (_pointer != e.pointer) return;
                _pointer = null;
                _dragging = false;
                _lift.reverse();
                _settleOn(widget.index);
              },
              onPointerUp: (e) {
                if (_pointer != e.pointer) return;
                _pointer = null;
                _lift.reverse();
              },
              child: GestureDetector(
                excludeFromSemantics: true,
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (_) {
                  _dragging = true;
                  _target = null;
                },
                onHorizontalDragUpdate: (e) {
                  if (!_dragging) return;
                  _candidate = indexAt(e.localPosition.dx);
                  _position.value = _reduced
                      ? _candidate.toDouble()
                      : (_startIndex + logical(e.localPosition.dx) - _origin)
                            .clamp(0.0, 3.0);
                },
                onHorizontalDragEnd: (_) {
                  if (!_dragging) return;
                  _dragging = false;
                  _settleOn(_candidate);
                  if (_candidate != widget.index) {
                    LotusFeedback.selection();
                    widget.onChanged(_candidate);
                  }
                },
                onHorizontalDragCancel: () {
                  if (!_dragging) return;
                  _dragging = false;
                  _settleOn(widget.index);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      children: [
                        for (var i = 0; i < labels.length; i++)
                          Expanded(
                            child: LotusFeedback(
                              onActivate: () {
                                _settleOn(i);
                                widget.onChanged(i);
                              },
                              keyboard: true,
                              builder: (activate) => Semantics(
                                button: true,
                                selected: widget.index == i,
                                label: labels[i],
                                onTap: activate,
                                child: ExcludeSemantics(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: activate,
                                    child: SizedBox.expand(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          LotusRasterIcon(
                                            'assets/icons/nav_bar/clay_${_assets[i]}.webp',
                                            width: 28,
                                            height: 26,
                                            fit: BoxFit.contain,
                                            excludeFromSemantics: true,
                                          ),
                                          const SizedBox(height: 2),
                                          Flexible(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  labels[i],
                                                  maxLines: 1,
                                                  style:
                                                      (widget.index == i
                                                              ? AppTypography
                                                                    .tabBarSemiBold
                                                              : AppTypography
                                                                    .tabBar)
                                                          .copyWith(
                                                            color: ink.withValues(
                                                              alpha:
                                                                  widget.index ==
                                                                      i
                                                                  ? 1
                                                                  : .78,
                                                            ),
                                                          ),
                                                ),
                                              ),
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
                      ],
                    ),
                    AnimatedBuilder(
                      animation: Listenable.merge([_position, _lift]),
                      builder: (context, _) {
                        final lift = Curves.easeOut.transform(_lift.value);
                        final position = rtl
                            ? 3 - _position.value
                            : _position.value;
                        final speed = (_position.velocity.abs() / 12).clamp(
                          0.0,
                          1.0,
                        );
                        final width = slot + 3 * lift + 7 * speed;
                        final height =
                            bounds.maxHeight - 9 + 4 * lift - 2 * speed;
                        final left = (slot * (position + .5) - width / 2).clamp(
                          -1.5,
                          bounds.maxWidth - width + 1.5,
                        );
                        return Positioned(
                          left: left,
                          top: (bounds.maxHeight - height) / 2,
                          width: width,
                          height: height,
                          child: IgnorePointer(
                            child: ExcludeSemantics(
                              child: RawMagnifier(
                                key: const ValueKey('navigation-lens'),
                                size: Size(width, height),
                                magnificationScale: _reduced
                                    ? 1
                                    : 1.025 + .085 * lift + .045 * speed,
                                decoration: const MagnifierDecoration(
                                  shape: StadiumBorder(),
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: ink.withValues(
                                        alpha: .31 + .20 * lift,
                                      ),
                                      width: .8,
                                    ),
                                    gradient: LinearGradient(
                                      begin: const Alignment(-.45, -1),
                                      end: const Alignment(.55, 1),
                                      stops: const [0, .10, .44, .78, 1],
                                      colors: [
                                        const Color(
                                          0xffffe9f4,
                                        ).withValues(alpha: .29 + .10 * lift),
                                        const Color(
                                          0xffe2b9ed,
                                        ).withValues(alpha: .12 + .07 * lift),
                                        const Color(
                                          0xffcbaad7,
                                        ).withValues(alpha: .11),
                                        const Color(
                                          0xffd1acd9,
                                        ).withValues(alpha: .16),
                                        const Color(
                                          0xffead2ed,
                                        ).withValues(alpha: .23 + .08 * lift),
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
