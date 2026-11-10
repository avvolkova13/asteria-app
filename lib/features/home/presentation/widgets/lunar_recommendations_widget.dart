import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/widgets/lunar_card_image.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:flutter/material.dart';

class LunarRecommendationsWidget extends StatelessWidget {
  const LunarRecommendationsWidget({super.key, required this.recommendation});

  final SphereRecommendationModel recommendation;

  @override
  Widget build(BuildContext context) {
    final tasks = recommendation.tasks.entries.toList();
    if (tasks.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      clipBehavior: Clip.none,
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final task in tasks) ...[
              if (task.key != tasks.first.key) const SizedBox(width: 16),
              _LunarRecommendationCard(
                title: _taskTitle(context, task.key),
                assetName: LunarCardAsset.forTaskKey(task.key),
                recommendation: task.value,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _taskTitle(BuildContext context, String taskKey) {
    return switch (taskKey) {
      'haircut' => context.l10n.lunarHaircut,
      'hair_coloring' => context.l10n.lunarHairColoring,
      'skin_care' => context.l10n.lunarSkinCare,
      'manicure_pedicure' => context.l10n.lunarManicurePedicure,
      'cosmetology' => context.l10n.lunarCosmetology,
      'epilation_depilation' => context.l10n.lunarEpilationDepilation,
      'spa_relaxation' ||
      'spa_and_relaxation' => context.l10n.lunarSpaRelaxation,
      'fragrances_magnetism' ||
      'fragrances_and_magnetism' => context.l10n.lunarFragrancesMagnetism,
      'sowing_planting' ||
      'sowing_and_planting' => context.l10n.lunarSowingPlanting,
      'transplanting_pricking' ||
      'transplanting_and_pricking' => context.l10n.lunarTransplantingPricking,
      'watering_fertilizing' ||
      'watering_and_fertilizing' => context.l10n.lunarWateringFertilizing,
      'pest_control' => context.l10n.lunarPestControl,
      'harvesting_preserving' ||
      'harvesting_and_preserving' => context.l10n.lunarHarvestingPreserving,
      'houseplants' => context.l10n.lunarHouseplants,
      'garden' => context.l10n.lunarGarden,
      'health_immunity' ||
      'health_and_immunity' => context.l10n.lunarHealthImmunity,
      'daily_diet' => context.l10n.lunarDailyDiet,
      'weight_loss_fasting' ||
      'weight_loss_and_fasting_days' => context.l10n.lunarWeightLossFasting,
      'sleep_recovery' ||
      'sleep_and_recovery' => context.l10n.lunarSleepRecovery,
      'physical_activity_sports' || 'physical_activity_and_sports' =>
        context.l10n.lunarPhysicalActivitySports,
      'medical_procedures' => context.l10n.lunarMedicalProcedures,
      'meditations' => context.l10n.lunarMeditations,
      'job_change' => context.l10n.lunarJobChange,
      'career_growth' => context.l10n.lunarCareerGrowth,
      'work' => context.l10n.lunarWork,
      'travel' => context.l10n.lunarTravel,
      'important_decisions' => context.l10n.lunarImportantDecisions,
      'family' => context.l10n.lunarFamily,
      'couple' => context.l10n.lunarCouple,
      'friends' => context.l10n.lunarFriends,
      'sex' => context.l10n.lunarSex,
      'for_those_alone' => context.l10n.lunarForThoseAlone,
      _ => taskKey.replaceAll('_', ' '),
    };
  }
}

class _LunarRecommendationCard extends StatelessWidget {
  static const double width = 304;
  static const double minHeight = 182;
  static const double _padding = 8;
  static const double _imageWidth = 83;
  static const double _imageHeight = 44;
  static const double _titleHeight = 1.1;
  static const double _descriptionHeight = 1.2;

  const _LunarRecommendationCard({
    required this.title,
    required this.recommendation,
    required this.assetName,
  });

  final String title;
  final TaskRecommendationModel recommendation;
  final String? assetName;

  static TextStyle titleStyle(BuildContext context) {
    return context.textTheme.playfairMedium20.copyWith(
      color: AppColors.textInverse,
      fontFamily: 'Lora',
      fontWeight: FontWeight.w500,
      height: _titleHeight,
    );
  }

  static TextStyle descriptionStyle(BuildContext context) {
    return context.textTheme.urbanistRegular16.copyWith(
      color: AppColors.textInverse,
      fontFamily: 'Onest',
      fontWeight: FontWeight.w400,
      height: _descriptionHeight,
      letterSpacing: -0.408,
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageAssetName = assetName;

    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: MoonDesignTokens.cardSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle(context),
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                  ),
                ),
              ),
              if (imageAssetName != null) ...[
                const SizedBox(width: 8),
                LunarCardImage(
                  assetName: imageAssetName,
                  width: _imageWidth,
                  height: _imageHeight,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.description,
            style: descriptionStyle(context),
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
            ),
          ),
        ],
      ),
    );
  }
}
