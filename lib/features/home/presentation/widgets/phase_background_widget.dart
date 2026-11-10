import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:asteria_app/features/home/presentation/widgets/sphere_selection_widget.dart';
import 'package:flutter/material.dart';

class PhaseBackgroundWidget extends StatelessWidget {
  const PhaseBackgroundWidget({
    super.key,
    required this.background,
    this.sphere,
    this.recommendation,
  });

  final DailyBackgroundModel background;
  final Sphere? sphere;
  final SphereRecommendationModel? recommendation;

  @override
  Widget build(BuildContext context) {
    final status = recommendation == null
        ? DayStatus.neutral
        : DayStatus.fromRecommendation(recommendation!.status);
    final title = recommendation == null || sphere == null
        ? context.l10n.moonBackgroundTitle(background.title)
        : context.l10n.moonSphereStatusTitle(
            sphere!.getLocalizedName(context),
            _shortStatusLabel(context, status),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          style: context.textTheme.playfairSemiBold24.copyWith(
            color: recommendation == null
                ? MoonDesignTokens.chipOrange
                : MoonDesignTokens.statusColor(status),
            height: 1.05,
          ),
          child: Text(title),
        ),
        const SizedBox(height: 12),
        Text(
          background.summary,
          style: context.textTheme.urbanistRegular16.copyWith(
            color: AppColors.textInverse,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  String _shortStatusLabel(BuildContext context, DayStatus status) {
    switch (status) {
      case DayStatus.favorable:
        return context.l10n.moonStatusFavorableShort;
      case DayStatus.neutral:
        return context.l10n.moonStatusNeutralShort;
      case DayStatus.unfavorable:
        return context.l10n.moonStatusUnfavorableShort;
    }
  }
}
