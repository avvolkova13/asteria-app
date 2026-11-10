import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

class GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final LinearGradient gradient;

  GradientCircularProgressPainter({required this.progress, required this.strokeWidth, required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Создаем градиентную кисть для активной части
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Создаем кисть для фоновой части (белая)
    final backgroundPaint = Paint()
      ..color = AppColors.surface
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -90 * (3.14159 / 180); // Начинаем сверху
    final progressSweepAngle = 2 * 3.14159 * progress; // Угол прогресса
    final backgroundSweepAngle = 2 * 3.14159 * (1 - progress); // Угол фона

    // Рисуем фоновую дугу (прозрачная неактивная часть)
    if (backgroundSweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + progressSweepAngle,
        backgroundSweepAngle,
        false,
        backgroundPaint,
      );
    }

    // Рисуем дугу прогресса (активная часть с градиентом)
    if (progressSweepAngle > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, progressSweepAngle, false, gradientPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is GradientCircularProgressPainter &&
        (oldDelegate.progress != progress || oldDelegate.strokeWidth != strokeWidth);
  }
}
