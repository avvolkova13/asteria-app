import 'package:asteria_app/app/data/models/natal_card/natal_card_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores natal interpretations by language', () {
    final card = NatalCardModel.fromJson({
      'source_language': 'en',
      'interpretations': {
        'en': _interpretation('en'),
        'ru': _interpretation('ru'),
      },
    });

    expect(card.sourceLanguage, 'en');
    expect(card.hasLanguage('en-US'), isTrue);
    expect(card.hasLanguage('ru'), isTrue);
    expect(card.interpretationFor('ru').finalConclusion, 'ru conclusion');
    expect(card.interpretationFor('en-US').finalConclusion, 'en conclusion');
    expect(
      card.toJson()['interpretations']['ru']['final_conclusion'],
      'ru conclusion',
    );
    expect(card.interpretationFor('ru').planetInterpretations['sun'], 'ru sun');
    expect(
      card.interpretationFor('ru').houseInterpretations['strong_house'],
      'ru strong house',
    );
    expect(card.interpretationFor('ru').elementsInterpretation, 'ru elements');
  });

  test('does not throw for empty natal card payload', () {
    final card = NatalCardModel.fromJson({'final_conclusion': 'old final'});

    expect(card.hasAnyInterpretation, isFalse);
    expect(card.hasLanguage('ru'), isFalse);
    expect(card.tryInterpretationFor('ru'), isNull);
  });
}

Map<String, dynamic> _interpretation(String label) {
  return {
    'personality': '$label personality',
    'intellectual_area': '$label intellect',
    'love_area': '$label love',
    'talent_area': '$label talent',
    'energy_area': '$label energy',
    'inside_area': '$label inside',
    'final_conclusion': '$label conclusion',
    'elements_interpretation': '$label elements',
    'planet_interpretations': {'sun': '$label sun', 'moon': '$label moon'},
    'house_interpretations': {
      'strong_house': '$label strong house',
      'weak_house': '$label weak house',
      'accent_house': '$label accent house',
    },
  };
}
