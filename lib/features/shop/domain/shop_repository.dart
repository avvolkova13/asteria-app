import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/features/shop/data/shop_datasource.dart';

abstract class ShopRepository {
  Future<List<ShopItemModel>> getShopItems();
}

class ShopRepositoryImpl implements ShopRepository {
  final ShopDataSource _dataSource;

  ShopRepositoryImpl({required ShopDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<List<ShopItemModel>> getShopItems() async {
    return _dataSource.getShopItems();
  }
}
