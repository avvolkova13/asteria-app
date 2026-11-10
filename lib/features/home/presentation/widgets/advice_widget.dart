import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:flutter/material.dart';

class AdviceWidget extends StatelessWidget {
  final String title;
  final String text;
  final DayStatus status;

  const AdviceWidget({
    Key? key,
    required this.title,
    required this.text,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          style: context.textTheme.playfairSemiBold24.copyWith(
            color: MoonDesignTokens.statusColor(status),
            height: 1,
          ),
          child: Text(title),
        ),
        const SizedBox(height: 16),
        Text(
          text,
          style: context.textTheme.urbanistRegular16.copyWith(
            color: AppColors.textInverse,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
