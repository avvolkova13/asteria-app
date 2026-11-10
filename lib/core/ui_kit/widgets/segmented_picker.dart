import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:flutter/material.dart';
import '../app_colors/app_colors.dart';
import '../app_typography.dart';

class SegmentedPicker<T> extends StatelessWidget {
  final List<T> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final String Function(T) labelBuilder;

  const SegmentedPicker({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: options
            .map((option) => _buildOption(option, option == selectedValue))
            .toList(),
      ),
    );
  }

  Widget _buildOption(T option, bool isSelected) {
    return Expanded(
      child: LotusTap(
        onTap: () => onChanged(option),
        child: Container(
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cardTinted : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            labelBuilder(option),
            style: (isSelected ? AppTypography.text2SemiBold : AppTypography.text2)
                .copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
