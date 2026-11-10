import 'package:asteria_app/app/data/models/lunar_calendar/content_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/widgets/lunar_card_image.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:asteria_app/features/home/presentation/widgets/sphere_selection_widget.dart';
import 'package:flutter/material.dart';

class LunarSubcategoriesWidget extends StatelessWidget {
  final ContentModel content;
  final Sphere sphere;

  const LunarSubcategoriesWidget({
    super.key,
    required this.content,
    required this.sphere,
  });

  @override
  Widget build(BuildContext context) {
    final subcategories = _getSubcategories(context);

    if (subcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      clipBehavior: Clip.none,
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final subcategory in subcategories) ...[
              if (subcategory != subcategories.first) const SizedBox(width: 16),
              _MoonSubcategoryCard(
                title: subcategory.title,
                description: subcategory.description,
                assetName: subcategory.assetName,
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<_LunarSubcategoryData> _getSubcategories(BuildContext context) {
    switch (sphere) {
      case Sphere.beauty:
        return _getBeautySubcategories(context);
      case Sphere.garden:
        return _getGardeningSubcategories(context);
      case Sphere.health:
        return _getHealthSubcategories(context);
      case Sphere.workAndRest:
        return _getWorkAndRestSubcategories(context);
      case Sphere.relationships:
        return _getRelationshipsSubcategories(context);
    }
  }

  List<_LunarSubcategoryData> _getBeautySubcategories(BuildContext context) {
    final beauty = content.beauty;
    return [
      _LunarSubcategoryData(
        title: context.l10n.lunarHaircut,
        description: beauty.haircut,
        assetName: 'moon_card_beauty_haircut',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarHairColoring,
        description: beauty.hairColoring,
        assetName: 'moon_card_beauty_hair_coloring',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarSkinCare,
        description: beauty.skinCare,
        assetName: 'moon_card_beauty_skin_care',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarManicurePedicure,
        description: beauty.manicurePedicure,
        assetName: 'moon_card_beauty_manicure_pedicure',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarCosmetology,
        description: beauty.cosmetology,
        assetName: 'moon_card_beauty_cosmetology',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarEpilationDepilation,
        description: beauty.epilationDepilation,
        assetName: 'moon_card_beauty_epilation_depilation',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarSpaRelaxation,
        description: beauty.spaAndRelaxation,
        assetName: 'moon_card_beauty_spa_relaxation',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarFragrancesMagnetism,
        description: beauty.fragrancesAndMagnetism,
        assetName: 'moon_card_beauty_fragrances_magnetism',
      ),
    ];
  }

  List<_LunarSubcategoryData> _getGardeningSubcategories(BuildContext context) {
    final gardening = content.gardening;
    return [
      _LunarSubcategoryData(
        title: context.l10n.lunarSowingPlanting,
        description: gardening.sowingAndPlanting,
        assetName: 'moon_card_gardening_sowing_planting',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarTransplantingPricking,
        description: gardening.transplantingAndPricking,
        assetName: 'moon_card_gardening_transplanting_pricking',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarWateringFertilizing,
        description: gardening.wateringAndFertilizing,
        assetName: 'moon_card_gardening_watering_fertilizing',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarPestControl,
        description: gardening.pestControl,
        assetName: 'moon_card_gardening_pest_control',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarHarvestingPreserving,
        description: gardening.harvestingAndPreserving,
        assetName: 'moon_card_gardening_harvesting_preserving',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarHouseplants,
        description: gardening.houseplants,
        assetName: 'moon_card_gardening_houseplants',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarGarden,
        description: gardening.garden,
        assetName: 'moon_card_gardening_garden',
      ),
    ];
  }

  List<_LunarSubcategoryData> _getHealthSubcategories(BuildContext context) {
    final health = content.health;
    return [
      _LunarSubcategoryData(
        title: context.l10n.lunarHealthImmunity,
        description: health.healthAndImmunity,
        assetName: 'moon_card_health_immunity',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarDailyDiet,
        description: health.dailyDiet,
        assetName: 'moon_card_health_daily_diet',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarWeightLossFasting,
        description: health.weightLossAndFastingDays,
        assetName: 'moon_card_health_weight_loss_fasting',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarSleepRecovery,
        description: health.sleepAndRecovery,
        assetName: 'moon_card_health_sleep_recovery',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarPhysicalActivitySports,
        description: health.physicalActivityAndSports,
        assetName: 'moon_card_health_physical_activity_sports',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarMedicalProcedures,
        description: health.medicalProcedures,
        assetName: 'moon_card_health_medical_procedures',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarMeditations,
        description: health.meditations,
        assetName: 'moon_card_health_meditations',
      ),
    ];
  }

  List<_LunarSubcategoryData> _getWorkAndRestSubcategories(
    BuildContext context,
  ) {
    final workAndRest = content.workAndRest;
    return [
      _LunarSubcategoryData(
        title: context.l10n.lunarJobChange,
        description: workAndRest.jobChange,
        assetName: 'moon_card_work_job_change',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarCareerGrowth,
        description: workAndRest.careerGrowth,
        assetName: 'moon_card_work_career_growth',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarWork,
        description: workAndRest.work,
        assetName: 'moon_card_work_work',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarTravel,
        description: workAndRest.travel,
        assetName: 'moon_card_work_travel',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarImportantDecisions,
        description: workAndRest.importantDecisions,
        assetName: 'moon_card_work_important_decisions',
      ),
    ];
  }

  List<_LunarSubcategoryData> _getRelationshipsSubcategories(
    BuildContext context,
  ) {
    final relationships = content.relationships;
    return [
      _LunarSubcategoryData(
        title: context.l10n.lunarFamily,
        description: relationships.family,
        assetName: 'moon_card_relationships_family',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarCouple,
        description: relationships.couple,
        assetName: 'moon_card_relationships_couple',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarFriends,
        description: relationships.friends,
        assetName: 'moon_card_relationships_friends',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarSex,
        description: relationships.sex,
        assetName: 'moon_card_relationships_sex',
      ),
      _LunarSubcategoryData(
        title: context.l10n.lunarForThoseAlone,
        description: relationships.forThoseAlone,
        assetName: 'moon_card_relationships_alone',
      ),
    ];
  }
}

class _LunarSubcategoryData {
  final String title;
  final String description;
  final String assetName;

  const _LunarSubcategoryData({
    required this.title,
    required this.description,
    required this.assetName,
  });
}

class _MoonSubcategoryCard extends StatelessWidget {
  static const double _width = 304;
  static const double minHeight = 182;
  static const double _padding = 8;
  static const double _imageWidth = 83;
  static const double _imageHeight = 44;
  static const double _titleHeight = 1.1;
  static const double _descriptionHeight = 1.2;

  final String title;
  final String description;
  final String assetName;

  const _MoonSubcategoryCard({
    required this.title,
    required this.description,
    required this.assetName,
  });

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
    final titleStyle = _MoonSubcategoryCard.titleStyle(context);
    final descriptionStyle = _MoonSubcategoryCard.descriptionStyle(context);

    return Container(
      width: _width,
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
                  style: titleStyle,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              LunarCardImage(
                assetName: assetName,
                width: _imageWidth,
                height: _imageHeight,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: descriptionStyle,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
            ),
          ),
        ],
      ),
    );
  }
}
