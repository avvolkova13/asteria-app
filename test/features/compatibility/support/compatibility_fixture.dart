import 'package:asteria_app/app/data/models/prompt_response.dart';
import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';

SavedCompatibilityModel savedCompatibility({
  String id = 'recent',
  String percentage = '69%',
}) {
  return SavedCompatibilityModel(
    id: id,
    firstBirthdate: DateTime(1995, 5, 13),
    secondBirthdate: DateTime(1994, 5, 22),
    generalPercentage: percentage,
    createdAt: DateTime(2026, 8, 14),
    compatibilityData: _compatibilityData(percentage),
  );
}

CompatibilityData _compatibilityData(String percentage) => CompatibilityData(
  generalCompatibility: 'Общее описание совместимости.',
  loveCompatibility: 'Любовь',
  loveCompatibilityPercentage: '82%',
  familyCompatibility: 'Семья',
  familyCompatibilityPercentage: '80%',
  conflicts: 'Конфликты',
  conflictsPercentage: '30%',
  percentage: percentage,
  phrase: 'Стабильность встречает переменчивость.',
  introduction:
      'Эта пара может быть интересной, но требует терпения и гибкости',
);
