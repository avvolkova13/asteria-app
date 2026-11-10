import 'package:flutter/material.dart';
import '../app_colors/app_colors.dart';

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
        GestureDetector(
          onTap: () => onChanged?.call(!value),
          child: Container(
            width: 23,
            height: 23,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 1),
              borderRadius: BorderRadius.circular(2),
              color: value ? AppColors.primary : Colors.transparent,
            ),
            child: value
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.41,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
