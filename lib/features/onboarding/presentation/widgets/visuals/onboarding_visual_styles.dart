import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:flutter/material.dart';

/// Figma onboarding miniature tokens. Sizes are in the 390 × 426 design canvas.
abstract final class OnboardingVisualStyles {
  static const gold = Color(0xFFF3B76A);
  static const white = Colors.white;
  static const surface = Color(0xFF151028);
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), gold, Color(0xFFE6994D)],
    stops: [0, .50032, 1],
  );

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = Colors.white,
    double spacing = -.41,
  }) => TextStyle(
    fontFamily: 'Onest',
    fontSize: size,
    fontWeight: weight,
    height: 1.2,
    letterSpacing: spacing,
    color: color,
  );

  static TextStyle title(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = Colors.white,
  }) => TextStyle(
    fontFamily: 'Lora',
    fontSize: size,
    fontWeight: weight,
    height: 1.1,
    letterSpacing: 0,
    color: color,
  );
}

class OnboardingGoldText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  const OnboardingGoldText(
    this.text, {
    super.key,
    required this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) => ShaderMask(
    shaderCallback: OnboardingVisualStyles.goldGradient.createShader,
    blendMode: BlendMode.srcIn,
    child: Text(
      text,
      style: style.copyWith(color: Colors.white),
      textAlign: textAlign,
    ),
  );
}

class OnboardingMiniCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final bool glow;
  final EdgeInsetsGeometry padding;
  const OnboardingMiniCard({
    super.key,
    required this.child,
    this.color = OnboardingVisualStyles.surface,
    this.radius = 8,
    this.glow = false,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: CardLensDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: glow ? Border.all(color: const Color(0x1AF1B266)) : null,
      boxShadow: glow
          ? const [
              BoxShadow(
                color: Color(0x0DF1B367),
                offset: Offset(0, 4),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ]
          : null,
    ),
    child: child,
  );
}
