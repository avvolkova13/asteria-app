import 'package:asteria_app/core/ui_kit/app_typography.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:flutter/material.dart';

const _accent = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  stops: [0, 0.5, 1],
);

class AnakraQuickActionButton extends StatelessWidget {
  const AnakraQuickActionButton({
    super.key,
    required this.text,
    required this.onPressed,
  });
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: text,
    child: CustomPaint(
      painter: const _OutlinePainter(),
      child: Material(
        color: Colors.transparent,
        child: LotusInkTap(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2.4),
            child: ShaderMask(
              shaderCallback: _accent.createShader,
              blendMode: BlendMode.srcIn,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: AppTypography.text1SemiBold.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _OutlinePainter extends CustomPainter {
  const _OutlinePainter();
  @override
  void paint(Canvas canvas, Size size) => canvas.drawRRect(
    RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.5),
      const Radius.circular(4),
    ),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = _accent.createShader(Offset.zero & size),
  );
  @override
  bool shouldRepaint(covariant _OutlinePainter oldDelegate) => false;
}
