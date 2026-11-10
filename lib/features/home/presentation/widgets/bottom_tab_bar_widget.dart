import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:flutter/material.dart';

const _barContentHeight = 58.0;
const _barTopPadding = 16.0;
const _barHorizontalPadding = 25.0;
const _compactHorizontalPadding = 16.0;
const _buttonGap = 16.0;
const _compactButtonGap = 10.0;
const _tabsHeight = 50.0;
const _barBottomPadding = 25.0;
const _tabsInset = 6.0;
const _barBackgroundInset = -4.0;
const _aiButtonSize = 58.0;
const _aiGlowSize = 118.0;
const _inactiveOpacity = 0.30;
const _tabItemGap = 1.0;
const _activePillColor = Color(0xFF151028);
const _inactiveItemColor = AppColors.white;
const _footerBackdropColor = AppColorsDark.homeCanvas;

const _activeGradient = LinearGradient(
  colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
);

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
      color: _footerBackdropColor,
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
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: _barBackgroundInset,
                              top: _barBackgroundInset,
                              right: _barBackgroundInset,
                              bottom: _barBackgroundInset,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x1F000000),
                                      blurRadius: 40,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: HomeGlassSurface(
                                  radius: 100,
                                  child: SizedBox.expand(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: _tabsInset,
                              ),
                              child: Row(
                                children: [
                                  _TabItem(
                                    icon:
                                        'assets/icons/nav_bar/tab_home_icon.svg',
                                    label: context.l10n.navHome,
                                    isActive: currentIndex == 0,
                                    onPressed: () => onTabChanged(0),
                                  ),
                                  _TabItem(
                                    icon:
                                        'assets/icons/nav_bar/tab_star_icon.svg',
                                    label: context.l10n.navPersonal,
                                    isActive: currentIndex == 1,
                                    onPressed: () => onTabChanged(1),
                                  ),
                                  _TabItem(
                                    icon:
                                        'assets/icons/nav_bar/tab_moon_icon.svg',
                                    label: context.l10n.navMoon,
                                    isActive: currentIndex == 2,
                                    onPressed: () => onTabChanged(2),
                                  ),
                                  _TabItem(
                                    icon:
                                        'assets/icons/nav_bar/tab_practices_icon.svg',
                                    label: context.l10n.navPractices,
                                    isActive: currentIndex == 3,
                                    onPressed: () => onTabChanged(3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: gap),
                    if (onAiAstrologerPressed != null)
                      Semantics(
                        button: true,
                        label: context.l10n.anakraTitle,
                        child: GestureDetector(
                          onTap: onAiAstrologerPressed,
                          behavior: HitTestBehavior.opaque,
                          child: _AiAstrologerButton(
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

class _AiAstrologerButton extends StatelessWidget {
  const _AiAstrologerButton({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    if (assetPath == 'assets/images/year_animals/horse.webp') {
      // The artwork includes the off-centre glow around the 58-point button.
      return SizedBox.square(
        dimension: _aiButtonSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -40.5,
              top: -32.5,
              width: 371 / 3,
              height: 139,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/icons/nav_bar/anakra_horse_badge.png',
                  fit: BoxFit.fill,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      width: _aiButtonSize,
      height: _aiButtonSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: (_aiButtonSize - _aiGlowSize) / 2,
            top: (_aiButtonSize - _aiGlowSize) / 2,
            width: _aiGlowSize,
            height: _aiGlowSize,
            child: CustomPaint(painter: _MessageBubbleSparklePainter()),
          ),
          CustomPaint(
            size: const Size.square(_aiButtonSize),
            painter: _MessageBubbleShadowPainter(),
          ),
          ClipPath(
            clipper: const _MessageBubbleClipper(),
            child: CustomPaint(
              painter: _MessageBubbleBackgroundPainter(),
              child: Stack(
                children: [
                  Positioned(
                    left: 12,
                    top: 2,
                    width: 72,
                    height: 106,
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      alignment: Alignment.topLeft,
                    ),
                  ),
                ],
              ),
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
        colors: [Color(0xFF7354E6), Color(0xFF7050E1), Color(0xFF462A58)],
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

class _MessageBubbleSparklePainter extends CustomPainter {
  static const _sparkles = <Offset>[
    Offset(0.50, 0.03),
    Offset(0.67, 0.06),
    Offset(0.78, 0.13),
    Offset(0.88, 0.29),
    Offset(0.93, 0.48),
    Offset(0.89, 0.68),
    Offset(0.76, 0.83),
    Offset(0.58, 0.94),
    Offset(0.35, 0.92),
    Offset(0.18, 0.80),
    Offset(0.08, 0.60),
    Offset(0.06, 0.40),
    Offset(0.14, 0.22),
    Offset(0.30, 0.10),
    Offset(0.46, 0.14),
    Offset(0.60, 0.18),
    Offset(0.73, 0.31),
    Offset(0.78, 0.52),
    Offset(0.69, 0.69),
    Offset(0.49, 0.78),
    Offset(0.28, 0.70),
    Offset(0.20, 0.50),
    Offset(0.24, 0.31),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE15B97).withValues(alpha: 0.22),
          const Color(0xFFB49CFF).withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const [0.0, 0.46, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawCircle(size.center(Offset.zero), size.width * 0.36, glowPaint);

    final sparklePaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.58)
      ..style = PaintingStyle.fill;

    for (var index = 0; index < _sparkles.length; index++) {
      final point = _sparkles[index];
      final radius = index.isEven ? 0.9 : 0.55;
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        radius,
        sparklePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_MessageBubbleSparklePainter oldDelegate) => false;
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

class _TabItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClayAssetIcon(
          icon,
          width: 24,
          height: 24,
          tint: isActive
              ? AppColors.white
              : _inactiveItemColor.withValues(alpha: _inactiveOpacity),
        ),
        const SizedBox(height: _tabItemGap),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: context.textTheme.urbanistRegular12.copyWith(
                color: isActive
                    ? AppColors.white
                    : _inactiveItemColor.withValues(alpha: _inactiveOpacity),
                fontFamily: 'Onest',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                height: 1.2,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      ],
    );

    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        label: label,
        onTap: onPressed,
        child: ExcludeSemantics(
          child: GestureDetector(
            onTap: onPressed,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (isActive)
                  const Positioned(
                    left: -6,
                    right: -6,
                    top: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _activePillColor,
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                    ),
                  ),
                SizedBox.expand(
                  child: ClayPressFeedback(
                    child: isActive
                        ? ShaderMask(
                            shaderCallback: (bounds) =>
                                _activeGradient.createShader(bounds),
                            blendMode: BlendMode.modulate,
                            child: content,
                          )
                        : content,
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
