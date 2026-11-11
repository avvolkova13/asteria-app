import 'package:asteria_app/core/config/app_feature_visibility.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';

// Earlier catalogs also sold these products as a personal forecast.
final _personalForecast = RegExp(
  r'(?:персональн|личн)[а-яё]*\s+(?:(?:годов|ежедневн|недельн|месячн)[а-яё]*\s+)?прогноз'
  r'|^(?:годовой|годичный|ежегодный|недельный|месячный|дневной) прогноз$'
  r'|^прогноз на (?:день|неделю|месяц|год)$'
  r'|personal[ _-]+(?:(?:daily|weekly|monthly|annual|yearly)[ _-]+)?forecast'
  r'|^(?:daily|weekly|monthly|annual|yearly)[ _-]+forecast$',
  caseSensitive: false,
);

bool isHiddenHoroscopePurchase(String value) =>
    !AppFeatureVisibility.horoscopes &&
    (AppFeatureVisibility.containsHoroscope(value) ||
        _personalForecast.hasMatch(value.trim()));

bool isShopProductVisible(ShopItemModel product) => ![
  product.id,
  product.purchase?.featureKey ?? '',
  product.route ?? '',
  product.title,
  product.category,
  product.description,
].any(isHiddenHoroscopePurchase);
