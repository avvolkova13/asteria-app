import 'package:asteria_app/core/const/pricing_catalog.dart';
import 'package:asteria_app/core/const/purchase_products_const.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feature prices match AST-142 pricing document', () {
    expect(PricingCatalog.aiAstrologerQuestion, 10);
    expect(PricingCatalog.dreamInterpretation, 10);
    expect(PricingCatalog.compatibilityRequest, 20);
    expect(PurchaseProductsConst.loveDeck.price, 15);
    expect(PurchaseProductsConst.keltDeck.price, 15);
    expect(PurchaseProductsConst.natalCard.price, 100);
    expect(HoroscopeTypeEnum.week.price, 15);
    expect(HoroscopeTypeEnum.month.price, 30);
    expect(HoroscopeTypeEnum.year.price, 70);
    expect(DayHoroscopeOpenEnum.keyTheme.price, 1);
    expect(DayHoroscopeOpenEnum.weaknesses.price, 3);
  });

  test('coin packages match product ids, names and storefront targets', () {
    expect(
      PricingCatalog.coinPackages
          .map(
            (item) => (
              item.productId,
              item.title,
              item.stars,
              item.rubles,
              item.usd,
              item.isPopular,
            ),
          )
          .toList(),
      [
        ('asteria_stars_10', 'Первая Луна', 10, 49, 0.99, false),
        ('asteria_stars_30', 'Ретроградный Путь', 30, 139, 1.99, false),
        ('asteria_stars_60', 'Свет Солнца', 60, 249, 2.99, true),
        ('asteria_stars_120', 'Звёздный Путь', 120, 399, 4.99, false),
        ('asteria_stars_300', 'Тайна Вселенной', 300, 899, 9.99, false),
      ],
    );
  });
}
