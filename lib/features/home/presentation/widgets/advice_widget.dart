import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:flutter/material.dart';

class AdviceWidget extends StatelessWidget {
  final String title;
  final String text;
  final DayStatus? status;

  const AdviceWidget({
    super.key,
    required this.title,
    required this.text,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          style: context.textTheme.playfairSemiBold24.copyWith(
            fontFamily: 'Lora',
            color: status == null
                ? AppColors.textInverse
                : MoonDesignTokens.statusColor(status!),
            height: 1,
          ),
          child: Semantics(header: true, child: Text(title)),
        ),
        const SizedBox(height: 16),
        Text(
          text,
          style: context.textTheme.urbanistRegular16.copyWith(
            fontFamily: 'Onest',
            letterSpacing: -0.408,
            color: AppColors.textInverse,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
