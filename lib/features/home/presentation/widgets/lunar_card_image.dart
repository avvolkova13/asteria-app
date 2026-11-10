import 'dart:math' as math;

import 'package:flutter/material.dart';

class LunarCardAsset {
  const LunarCardAsset._();

  static String path(String assetName) {
    return 'assets/images/prediction_images/$assetName.webp';
  }

  static String? forTaskKey(String taskKey) {
    return switch (taskKey) {
      'haircut' => 'moon_card_beauty_haircut',
      'hair_coloring' => 'moon_card_beauty_hair_coloring',
      'skin_care' => 'moon_card_beauty_skin_care',
      'manicure_pedicure' => 'moon_card_beauty_manicure_pedicure',
      'cosmetology' => 'moon_card_beauty_cosmetology',
      'epilation_depilation' => 'moon_card_beauty_epilation_depilation',
      'spa_relaxation' ||
      'spa_and_relaxation' => 'moon_card_beauty_spa_relaxation',
      'fragrances_magnetism' ||
      'fragrances_and_magnetism' => 'moon_card_beauty_fragrances_magnetism',
      'sowing_planting' ||
      'sowing_and_planting' => 'moon_card_gardening_sowing_planting',
      'transplanting_pricking' || 'transplanting_and_pricking' =>
        'moon_card_gardening_transplanting_pricking',
      'watering_fertilizing' ||
      'watering_and_fertilizing' => 'moon_card_gardening_watering_fertilizing',
      'pest_control' => 'moon_card_gardening_pest_control',
      'harvesting_preserving' || 'harvesting_and_preserving' =>
        'moon_card_gardening_harvesting_preserving',
      'houseplants' => 'moon_card_gardening_houseplants',
      'garden' => 'moon_card_gardening_garden',
      'health_immunity' || 'health_and_immunity' => 'moon_card_health_immunity',
      'daily_diet' => 'moon_card_health_daily_diet',
      'weight_loss_fasting' ||
      'weight_loss_and_fasting_days' => 'moon_card_health_weight_loss_fasting',
      'sleep_recovery' ||
      'sleep_and_recovery' => 'moon_card_health_sleep_recovery',
      'physical_activity_sports' || 'physical_activity_and_sports' =>
        'moon_card_health_physical_activity_sports',
      'medical_procedures' => 'moon_card_health_medical_procedures',
      'meditations' => 'moon_card_health_meditations',
      'job_change' => 'moon_card_work_job_change',
      'career_growth' => 'moon_card_work_career_growth',
      'work' => 'moon_card_work_work',
      'travel' => 'moon_card_work_travel',
      'important_decisions' => 'moon_card_work_important_decisions',
      'family' => 'moon_card_relationships_family',
      'couple' => 'moon_card_relationships_couple',
      'friends' => 'moon_card_relationships_friends',
      'sex' => 'moon_card_relationships_sex',
      'for_those_alone' => 'moon_card_relationships_alone',
      _ => null,
    };
  }
}

class LunarCardImage extends StatelessWidget {
  static const Set<String> _preCroppedAssetNames = {
    'moon_card_beauty_haircut',
    'moon_card_beauty_hair_coloring',
  };

  static const Map<String, _LunarCardImageSpec> _imageSpecs = {
    'moon_card_beauty_skin_care': _LunarCardImageSpec.figmaCrop(
      leftFactor: 0.1905,
      topFactor: -0.4237,
      widthFactor: 0.5814,
      heightFactor: 1.6338,
    ),
    'moon_card_beauty_manicure_pedicure': _LunarCardImageSpec.figmaCrop(
      leftFactor: 0.0815,
      topFactor: -0.0558,
      widthFactor: 0.837,
      heightFactor: 1.4946,
    ),
    'moon_card_beauty_cosmetology': _LunarCardImageSpec.figmaCrop(
      leftFactor: -0.1039,
      topFactor: -0.2247,
      widthFactor: 1.1479,
      heightFactor: 2.0938,
    ),
    'moon_card_beauty_epilation_depilation': _LunarCardImageSpec.figmaCrop(
      leftFactor: 0.2974,
      topFactor: -0.6311,
      widthFactor: 0.7361,
      heightFactor: 2.0685,
    ),
    'moon_card_beauty_spa_relaxation': _LunarCardImageSpec.figmaCrop(
      leftFactor: 0.0042,
      topFactor: -1.2121,
      widthFactor: 1.0333,
      heightFactor: 2.9034,
    ),
    'moon_card_beauty_fragrances_magnetism': _LunarCardImageSpec.figmaCrop(
      leftFactor: 0.2334,
      topFactor: -0.3024,
      widthFactor: 0.566,
      heightFactor: 1.5902,
    ),
    'moon_card_gardening_sowing_planting': _LunarCardImageSpec.figmaCrop(
      leftFactor: -0.0366,
      topFactor: -0.25,
      widthFactor: 1.1024,
      heightFactor: 1.3864,
    ),
    'moon_card_gardening_transplanting_pricking': _LunarCardImageSpec.figmaCrop(
      leftFactor: 0.0663,
      topFactor: -0.0455,
      widthFactor: 0.8675,
      heightFactor: 1.0909,
    ),
    'moon_card_gardening_watering_fertilizing': _LunarCardImageSpec.figmaCrop(
      leftFactor: -0.179,
      topFactor: -0.3677,
      widthFactor: 1.3012,
      heightFactor: 1.6364,
    ),
    'moon_card_gardening_pest_control': _LunarCardImageSpec.cover(),
    'moon_card_gardening_harvesting_preserving': _LunarCardImageSpec.cover(),
    'moon_card_gardening_houseplants': _LunarCardImageSpec.figmaCrop(
      leftFactor: 0.0392,
      topFactor: -0.0682,
      widthFactor: 0.9217,
      heightFactor: 1.1591,
    ),
    'moon_card_gardening_garden': _LunarCardImageSpec.figmaCrop(
      leftFactor: 0.0392,
      topFactor: -0.0682,
      widthFactor: 0.9217,
      heightFactor: 1.1591,
    ),
    'moon_card_health_immunity': _LunarCardImageSpec.contain(),
    'moon_card_health_daily_diet': _LunarCardImageSpec.contain(),
    'moon_card_health_weight_loss_fasting': _LunarCardImageSpec.contain(),
    'moon_card_health_sleep_recovery': _LunarCardImageSpec.contain(),
    'moon_card_health_physical_activity_sports': _LunarCardImageSpec.figmaCrop(
      leftFactor: -0.0566,
      topFactor: -0.2901,
      widthFactor: 1.1009,
      heightFactor: 1.3845,
    ),
    'moon_card_health_medical_procedures': _LunarCardImageSpec.figmaCrop(
      leftFactor: -0.0487,
      topFactor: -0.2727,
      widthFactor: 1.0948,
      heightFactor: 1.3768,
    ),
    'moon_card_health_meditations': _LunarCardImageSpec.figmaCrop(
      leftFactor: -0.6442,
      topFactor: -0.453,
      widthFactor: 1.5181,
      heightFactor: 1.9091,
    ),
    'moon_card_work_career_growth': _LunarCardImageSpec.figmaCrop(
      leftFactor: 0.0003,
      topFactor: -0.1477,
      widthFactor: 1.0003,
      heightFactor: 1.258,
    ),
    'moon_card_work_job_change': _LunarCardImageSpec.cover(),
    'moon_card_work_work': _LunarCardImageSpec.cover(),
    'moon_card_work_travel': _LunarCardImageSpec.cover(),
    'moon_card_work_important_decisions': _LunarCardImageSpec.cover(),
    'moon_card_relationships_family': _LunarCardImageSpec.figmaCrop(
      leftFactor: -0.0602,
      topFactor: -0.1818,
      widthFactor: 1.1205,
      heightFactor: 1.4091,
    ),
    'moon_card_relationships_couple': _LunarCardImageSpec.figmaCrop(
      leftFactor: -0.2416,
      topFactor: -0.45,
      widthFactor: 1.4783,
      heightFactor: 1.859,
    ),
    'moon_card_relationships_friends': _LunarCardImageSpec.figmaCrop(
      leftFactor: -0.1029,
      topFactor: -0.25,
      widthFactor: 1.2058,
      heightFactor: 1.5164,
    ),
    'moon_card_relationships_sex': _LunarCardImageSpec.figmaCrop(
      leftFactor: -0.1017,
      topFactor: -0.2448,
      widthFactor: 1.1525,
      heightFactor: 1.4493,
    ),
    'moon_card_relationships_alone': _LunarCardImageSpec.figmaCrop(
      leftFactor: -0.0977,
      topFactor: -0.25,
      widthFactor: 1.1992,
      heightFactor: 1.508,
    ),
  };

  final String assetName;
  final double width;
  final double height;

  const LunarCardImage({
    super.key,
    required this.assetName,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = LunarCardAsset.path(assetName);

    if (_preCroppedAssetNames.contains(assetName)) {
      return SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.fill,
        ),
      );
    }

    final spec = _imageSpecs[assetName] ?? const _LunarCardImageSpec.cover();
    final imageWidth = width * spec.widthFactor;
    final imageHeight = height * spec.heightFactor;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: width * spec.leftFactor,
              top: height * spec.topFactor,
              width: imageWidth,
              height: imageHeight,
              child: Image.asset(
                assetPath,
                width: imageWidth,
                height: imageHeight,
                cacheWidth: math.max(1, imageWidth * 2).round(),
                cacheHeight: math.max(1, imageHeight * 2).round(),
                fit: spec.fit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LunarCardImageSpec {
  final double leftFactor;
  final double topFactor;
  final double widthFactor;
  final double heightFactor;
  final BoxFit fit;

  const _LunarCardImageSpec.cover()
    : leftFactor = 0,
      topFactor = 0,
      widthFactor = 1,
      heightFactor = 1,
      fit = BoxFit.cover;

  const _LunarCardImageSpec.contain()
    : leftFactor = 0,
      topFactor = 0,
      widthFactor = 1,
      heightFactor = 1,
      fit = BoxFit.contain;

  const _LunarCardImageSpec.figmaCrop({
    required this.leftFactor,
    required this.topFactor,
    required this.widthFactor,
    required this.heightFactor,
  }) : fit = BoxFit.fill;
}
