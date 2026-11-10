import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/day_status_icon.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:flutter/material.dart';

class CalendarStatusesWidget extends StatelessWidget {
  const CalendarStatusesWidget({super.key, this.visible = true});

  /// Whether sphere-specific day statuses are shown.
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (visible) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _CalendarStatusItem(
                  status: DayStatus.favorable,
                  title: context.l10n.dayFavorable,
                ),
              ),
              Expanded(
                child: _CalendarStatusItem(
                  status: DayStatus.neutral,
                  title: context.l10n.dayNeutral,
                ),
              ),
              Expanded(
                child: _CalendarStatusItem(
                  status: DayStatus.unfavorable,
                  title: context.l10n.dayUnfavorable,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            const SizedBox(
              width: 25,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: MoonDesignTokens.selectedDay,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(width: 5, height: 5),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '— ${context.l10n.moonPhaseChange}',
                style: context.textTheme.urbanistRegular12.copyWith(
                  color: AppColors.textInverse,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CalendarStatusItem extends StatelessWidget {
  final DayStatus status;
  final String title;
  const _CalendarStatusItem({required this.status, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DayStatusIcon(status: status, size: 25, excludeFromSemantics: true),
        const SizedBox(width: 4),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.urbanistRegular12.copyWith(
            color: AppColors.textInverse,
            fontSize: 8,
            height: 1.05,
          ),
        ),
      ],
    );
  }
}
