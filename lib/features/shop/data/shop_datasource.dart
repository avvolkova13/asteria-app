import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:flutter/foundation.dart';

abstract class ShopDataSource {
  Future<List<ShopItemModel>> getShopItems();
}

class ShopDataSourceImpl implements ShopDataSource {
  final BackendApi _api;

  ShopDataSourceImpl({required BackendApi api}) : _api = api;

  @override
  Future<List<ShopItemModel>> getShopItems() async {
    try {
      final response = await _api.getContentCollection('shop_items');
      final data = response.data;
      if (data is! List) {
        throw const FormatException('Invalid localized shop response');
      }
      return data
          .map(
            (item) =>
                ShopItemModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (e) {
      debugPrint('Ошибка получения товаров: $e');
      throw Exception('Не удалось получить товары: $e');
    }
  }
}
