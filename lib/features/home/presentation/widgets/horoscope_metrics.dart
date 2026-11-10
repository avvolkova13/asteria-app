import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/gradient_circular_progress_painter.dart';
import 'package:flutter/material.dart';

/// Метрики гороскопа с круговыми индикаторами
class HoroscopeMetrics extends StatelessWidget {
  final String lovePercentage;
  final String financesPercentage;
  final String energyPercentage;
  const HoroscopeMetrics({
    Key? key,
    required this.lovePercentage,
    required this.financesPercentage,
    required this.energyPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMetricIndicator(
          lovePercentage,
          context.l10n.personalLove,
          context,
        ),
        _buildMetricIndicator(
          financesPercentage,
          context.l10n.personalFinances,
          context,
        ),
        _buildMetricIndicator(
          energyPercentage,
          context.l10n.personalEnergy,
          context,
        ),
      ],
    );
  }

  Widget _buildMetricIndicator(
    String percentage,
    String label,
    BuildContext context,
  ) {
    return Container(
      width: 71,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 4),
          // Круговой индикатор с процентом внутри
          SizedBox(
            width:
                90, // Увеличил размер с учетом толщины индикатора (9px * 2 + 72px)
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Фоновый круг внутри
                Container(
                  width: 72, // Внутренний размер для фона
                  height: 72,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF8A6CAF).withValues(alpha: 0.40),
                    shape: OvalBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
                // Прогресс круг с градиентом
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CustomPaint(
                    painter: GradientCircularProgressPainter(
                      progress: _getProgressValue(percentage),
                      strokeWidth: 9,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF6686F1), // #6686F1
                          Color(0xFFB36BFF), // #B36BFF
                        ],
                      ),
                    ),
                  ),
                ),
                // Процент внутри круга
                Text(
                  percentage,
                  textAlign: TextAlign.center,
                  style: context.textTheme.urbanistMedium20.copyWith(
                    height: 1.10,
                  ),
                ),
              ],
            ),
          ),
          // Название метрики
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.urbanistSemiBold16,
          ),
        ],
      ),
    );
  }

  double _getProgressValue(String percentage) {
    final value = int.parse(percentage.replaceAll('%', ''));
    return value / 100.0;
  }
}
