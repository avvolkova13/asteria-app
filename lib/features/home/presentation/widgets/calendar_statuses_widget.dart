import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/day_status_icon.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_phase_marker.dart';
import 'package:flutter/material.dart';

class CalendarStatusesWidget extends StatelessWidget {
  const CalendarStatusesWidget({super.key, this.visible = true});

  /// Whether sphere-specific day statuses are shown.
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (visible) {
      return SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 14,
          runSpacing: 8,
          children: AsteriaEntrance.sections([
            _CalendarStatusItem(
              status: DayStatus.favorable,
              title: context.l10n.dayFavorable,
            ),
            _CalendarStatusItem(
              status: DayStatus.neutral,
              title: context.l10n.dayNeutral,
            ),
            _CalendarStatusItem(
              status: DayStatus.unfavorable,
              title: context.l10n.dayUnfavorable,
            ),
          ]),
        ),
      );
    }
    return Row(
      children: [
        const SizedBox(
          width: 25,
          child: Center(child: MoonPhaseMarker(size: 16)),
        ),
        Flexible(
          child: Text(
            context.l10n.moonPhaseChange,
            style: context.textTheme.urbanistRegular12.copyWith(
              color: AppColors.textInverse,
              fontFamily: 'Onest',
            ),
          ),
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
        Flexible(
          child: Text(
            title,
            style: context.textTheme.urbanistRegular12.copyWith(
              color: AppColors.textInverse,
            ),
          ),
        ),
      ],
    );
  }
}
