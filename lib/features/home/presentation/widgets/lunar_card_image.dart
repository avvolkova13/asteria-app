import 'package:flutter/material.dart';

class LunarCardAsset {
  const LunarCardAsset._();

  static String path(String assetName) {
    return 'assets/images/prediction_images/$assetName.webp';
  }

  // Calendar cards follow the same order for each date, regardless of the
  // property order of the recommendation returned by the backend.
  static const _assetsByTask = {
    'haircut': 'moon_card_beauty_haircut',
    'hair_coloring': 'moon_card_beauty_hair_coloring',
    'skin_care': 'moon_card_beauty_skin_care',
    'manicure_pedicure': 'moon_card_beauty_manicure_pedicure',
    'cosmetology': 'moon_card_beauty_cosmetology',
    'epilation_depilation': 'moon_card_beauty_epilation_depilation',
    'spa_relaxation': 'moon_card_beauty_spa_relaxation',
    'spa_and_relaxation': 'moon_card_beauty_spa_relaxation',
    'fragrances_magnetism': 'moon_card_beauty_fragrances_magnetism',
    'fragrances_and_magnetism': 'moon_card_beauty_fragrances_magnetism',
    'sowing_planting': 'moon_card_gardening_sowing_planting',
    'sowing_and_planting': 'moon_card_gardening_sowing_planting',
    'transplanting_pricking': 'moon_card_gardening_transplanting_pricking',
    'transplanting_and_pricking': 'moon_card_gardening_transplanting_pricking',
    'watering_fertilizing': 'moon_card_gardening_watering_fertilizing',
    'watering_and_fertilizing': 'moon_card_gardening_watering_fertilizing',
    'pest_control': 'moon_card_gardening_pest_control',
    'harvesting_preserving': 'moon_card_gardening_harvesting_preserving',
    'harvesting_and_preserving': 'moon_card_gardening_harvesting_preserving',
    'houseplants': 'moon_card_gardening_houseplants',
    'garden': 'moon_card_gardening_garden',
    'health_immunity': 'moon_card_health_immunity',
    'health_and_immunity': 'moon_card_health_immunity',
    'daily_diet': 'moon_card_health_daily_diet',
    'weight_loss_fasting': 'moon_card_health_weight_loss_fasting',
    'weight_loss_and_fasting_days': 'moon_card_health_weight_loss_fasting',
    'sleep_recovery': 'moon_card_health_sleep_recovery',
    'sleep_and_recovery': 'moon_card_health_sleep_recovery',
    'physical_activity_sports': 'moon_card_health_physical_activity_sports',
    'physical_activity_and_sports': 'moon_card_health_physical_activity_sports',
    'medical_procedures': 'moon_card_health_medical_procedures',
    'meditations': 'moon_card_health_meditations',
    'job_change': 'moon_card_work_job_change',
    'career_growth': 'moon_card_work_career_growth',
    'work': 'moon_card_work_work',
    'travel': 'moon_card_work_travel',
    'important_decisions': 'moon_card_work_important_decisions',
    'family': 'moon_card_relationships_family',
    'couple': 'moon_card_relationships_couple',
    'friends': 'moon_card_relationships_friends',
    'sex': 'moon_card_relationships_sex',
    'for_those_alone': 'moon_card_relationships_alone',
  };

  static final _displayOrder = {
    for (final (index, key) in _assetsByTask.keys.indexed) key: index,
  };

  static String? forTaskKey(String taskKey) => _assetsByTask[taskKey];

  static int displayOrder(String taskKey) =>
      _displayOrder[taskKey] ?? _assetsByTask.length;
}

class LunarCardImage extends StatelessWidget {
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
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: Padding(
      padding: const EdgeInsets.all(3),
      child: Image.asset(
        LunarCardAsset.path(assetName),
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    ),
  );
}
