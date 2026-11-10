import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import '../app_colors/app_colors.dart';
import '../app_typography.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LotusTap(
          onTap: onChanged == null ? null : () => onChanged!(!value),
          child: Container(
            width: 23,
            height: 23,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 1),
              borderRadius: BorderRadius.circular(2),
              color: value ? AppColors.primary : Colors.transparent,
            ),
            child: value
                ? const ClayIcon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label!,
              style: AppTypography.text1.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ],
    );
  }
}
