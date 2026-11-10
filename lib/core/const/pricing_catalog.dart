class CoinPackagePrice {
  final String productId;
  final String title;
  final int stars;
  final int rubles;
  final double usd;
  final bool isPopular;

  const CoinPackagePrice({
    required this.productId,
    required this.title,
    required this.stars,
    required this.rubles,
    required this.usd,
    this.isPopular = false,
  });
}

abstract final class PricingCatalog {
  static const int aiAstrologerQuestion = 10;
  static const int dreamInterpretation = 10;
  static const int compatibilityRequest = 20;
  static const int paidTarotSpread = 15;
  static const int yearlyHoroscope = 70;
  static const int natalChart = 100;
  static const int weeklyHoroscope = 15;
  static const int monthlyHoroscope = 30;

  static const List<CoinPackagePrice> coinPackages = [
    CoinPackagePrice(
      productId: 'asteria_stars_10',
      title: 'Первая Луна',
      stars: 10,
      rubles: 49,
      usd: 0.99,
    ),
    CoinPackagePrice(
      productId: 'asteria_stars_30',
      title: 'Ретроградный Путь',
      stars: 30,
      rubles: 139,
      usd: 1.99,
    ),
    CoinPackagePrice(
      productId: 'asteria_stars_60',
      title: 'Свет Солнца',
      stars: 60,
      rubles: 249,
      usd: 2.99,
      isPopular: true,
    ),
    CoinPackagePrice(
      productId: 'asteria_stars_120',
      title: 'Звёздный Путь',
      stars: 120,
      rubles: 399,
      usd: 4.99,
    ),
    CoinPackagePrice(
      productId: 'asteria_stars_300',
      title: 'Тайна Вселенной',
      stars: 300,
      rubles: 899,
      usd: 9.99,
    ),
  ];

  static CoinPackagePrice? coinPackageFor(String productId) {
    for (final package in coinPackages) {
      if (package.productId == productId) return package;
    }
    return null;
  }
}
