import 'dart:convert';

import 'package:asteria_app/app/data/models/prompt_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PromptResponse.compatibilityData', () {
    test('parses fenced JSON with corrected percentage keys', () {
      final response = PromptResponse.fromJson(
        _responseJson('''
```json
{
  "phrase": "Доверие укрепляет гармонию",
  "introduction": "Короткое вступление",
  "percentage": "77%",
  "general_compatibility": "Общее описание",
  "love_compatibility": "Любовь",
  "love_compatibility_percentage": "82%",
  "family_compatibility": "Семья",
  "family_compatibility_percentage": "80%",
  "conflicts": "Конфликты",
  "conflicts_percentage": "30%"
}
```
'''),
      );

      final compatibilityData = response.compatibilityData;

      expect(compatibilityData, isNotNull);
      expect(compatibilityData!.percentage, '77%');
      expect(compatibilityData.loveCompatibilityPercentage, '82%');
      expect(compatibilityData.familyCompatibilityPercentage, '80%');
      expect(compatibilityData.conflictsPercentage, '30%');
    });

    test('keeps backward compatibility with misspelled persentage keys', () {
      final response = PromptResponse.fromJson(
        _responseJson(
          jsonEncode({
            'phrase': 'Доверие укрепляет гармонию',
            'introduction': 'Короткое вступление',
            'percentage': '77%',
            'general_compatibility': 'Общее описание',
            'love_compatibility': 'Любовь',
            'love_compatibility_persentage': '82%',
            'family_compatibility': 'Семья',
            'family_compatibility_persentage': '80%',
            'conflicts': 'Конфликты',
            'conflicts_persentage': '30%',
          }),
        ),
      );

      final compatibilityData = response.compatibilityData;

      expect(compatibilityData, isNotNull);
      expect(compatibilityData!.loveCompatibilityPercentage, '82%');
      expect(compatibilityData.familyCompatibilityPercentage, '80%');
      expect(compatibilityData.conflictsPercentage, '30%');
    });
  });
}

Map<String, dynamic> _responseJson(String text) {
  return {
    'id': 'resp_1',
    'object': 'response',
    'created_at': 1710000000,
    'status': 'completed',
    'output': [
      {
        'id': 'msg_1',
        'type': 'message',
        'status': 'completed',
        'role': 'assistant',
        'content': [
          {
            'type': 'output_text',
            'text': text,
            'annotations': <dynamic>[],
            'logprobs': null,
          },
        ],
      },
    ],
  };
}
