import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:flutter/widgets.dart';

class PracticePencil extends StatelessWidget {
  const PracticePencil({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: const _PracticePencilPainter(),
  );
}

class _PracticePencilPainter extends CustomPainter {
  const _PracticePencilPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..translate(size.width / 2, size.height / 2)
      ..rotate(math.pi / 4)
      ..scale(size.width / 24, size.height / 24);

    const body = Rect.fromLTRB(-3.2, -5.6, 3.2, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(1)),
      Paint()
        ..shader = const LinearGradient(
          colors: [
            AppColors.textInverse,
            AppColorsDark.linkGold,
            AppColors.warning,
          ],
          stops: [0, .4, 1],
        ).createShader(body),
    );

    const cap = Rect.fromLTRB(-3.2, -10.6, 3.2, -5.5);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        cap,
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
      ),
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.cardTinted, AppColors.primary],
        ).createShader(cap),
    );
    canvas.drawRect(
      const Rect.fromLTRB(-3.2, -6.7, 3.2, -5.5),
      Paint()..color = AppColors.textInverse,
    );
    canvas.drawPath(
      Path()
        ..moveTo(-3.1, 5.9)
        ..lineTo(3.1, 5.9)
        ..lineTo(0, 10.7)
        ..close(),
      Paint()..color = AppColorsDark.linkGold,
    );
    canvas.drawPath(
      Path()
        ..moveTo(-1.2, 8.9)
        ..lineTo(1.2, 8.9)
        ..lineTo(0, 10.7)
        ..close(),
      Paint()..color = AppColors.primary,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PracticePencilPainter oldDelegate) => false;
}
