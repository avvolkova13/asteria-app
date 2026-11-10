import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

/// Навигация по табам гороскопа (SegmentedPicker)
class HoroscopeTabNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final List<String> titles;

  const HoroscopeTabNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.titles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.cardTinted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab(titles[0], 0, context)),
          Expanded(child: _buildTab(titles[1], 1, context)),
          Expanded(child: _buildTab(titles[2], 2, context)),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, BuildContext context) {
    final isSelected = selectedIndex == index;
    final isLast = index == 2;

    return LotusTap(
      onTap: () => onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.uiDisabled, width: 0.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Текст
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style:
                    (isSelected
                            ? AppTypography.text2SemiBold
                            : AppTypography.text2)
                        .copyWith(
                          color: context.textTheme.urbanistRegular16.color,
                        ),
              ),
            ),
            // Разделитель (только для неактивных табов, кроме последнего)
            if (!isSelected && !isLast)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 0.678,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.uiDisabled,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
