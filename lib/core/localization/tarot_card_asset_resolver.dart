class TarotCardAssetResolver {
  const TarotCardAssetResolver._();

  static String resolve({
    required String imageName,
    required String languageCode,
  }) {
    final directory = languageCode == 'ru'
        ? 'assets/images/cards'
        : 'assets/images/cards/en';
    return '$directory/$imageName.webp';
  }
}
