import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/gradient_circular_progress_painter.dart';
import 'package:flutter/material.dart';

class ElementsBlock extends StatelessWidget {
  final String elementsDescription;
  const ElementsBlock({Key? key, required this.elementsDescription})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.natalElementsModalities.replaceAll('\n', ' '),
          style: context.textTheme.playfairSemiBold24,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ElementItem(percentage: '3', label: context.l10n.elementFire),
            _ElementItem(percentage: '4', label: context.l10n.elementWater),
            _ElementItem(percentage: '2', label: context.l10n.elementAir),
            _ElementItem(percentage: '6', label: context.l10n.elementEarth),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          elementsDescription,
          style: context.textTheme.urbanistRegular16,
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

class _ElementItem extends StatelessWidget {
  final String percentage;
  final String label;
  const _ElementItem({Key? key, required this.percentage, required this.label})
    : super(key: key);

  double _getProgressValue(String percentage) {
    final value = int.parse(percentage.replaceAll('%', ''));
    // Конвертируем значение из 10-балльной шкалы в проценты (0.0 - 1.0)
    return (value * 10) / 100.0;
  }

  @override
  Widget build(BuildContext context) {
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
                  style: context.textTheme.playfairMedium20.copyWith(
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
}
