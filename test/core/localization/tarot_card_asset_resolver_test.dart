import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/localization/tarot_card_asset_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps Russian face cards for the Russian interface', () {
    expect(
      TarotCardAssetResolver.resolve(
        imageName: 'the_strength',
        languageCode: 'ru',
      ),
      'assets/images/cards/the_strength.webp',
    );
  });

  test('uses the English face card for every supported English region', () {
    for (final locale in AppLocaleService.supportedLocales.where(
      (locale) => locale.languageCode == 'en',
    )) {
      expect(
        TarotCardAssetResolver.resolve(
          imageName: 'the_strength',
          languageCode: locale.languageCode,
        ),
        'assets/images/cards/en/the_strength.webp',
        reason: locale.toLanguageTag(),
      );
    }
  });

  test('uses English for an unsupported language', () {
    expect(
      TarotCardAssetResolver.resolve(
        imageName: 'ace_of_cups',
        languageCode: 'de',
      ),
      'assets/images/cards/en/ace_of_cups.webp',
    );
  });
}
