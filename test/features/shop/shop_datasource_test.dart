import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/features/shop/data/shop_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'parses flat localized shop payload without depending on i18n',
    () async {
      final dataSource = ShopDataSourceImpl(
        api: _FakeBackendApi([
          {
            'id': 'VY7UBP2lTsNLj96hMqWi',
            'title': 'Dream book',
            'category': 'Requests',
            'description': 'Dream interpretation pack',
            'price': 7,
            'route': null,
            'purchase': {
              'type': 'feature_credit',
              'feature_key': 'sonnik',
              'credit_quantity': 1,
            },
            'i18n': {
              'title': {'ru': 'Сонник', 'en': 'Dream book'},
            },
          },
        ]),
      );

      final items = await dataSource.getShopItems();

      expect(items, hasLength(1));
      expect(items.single.id, 'VY7UBP2lTsNLj96hMqWi');
      expect(items.single.title, 'Dream book');
      expect(items.single.category, 'Requests');
      expect(items.single.description, 'Dream interpretation pack');
      expect(items.single.price, 7);
      expect(items.single.purchase?.featureKey, 'sonnik');
      expect(items.single.purchase?.creditQuantity, 1);
    },
  );
}

class _FakeBackendApi implements BackendApi {
  _FakeBackendApi(this.documents);

  final List<Map<String, dynamic>> documents;

  @override
  Future<Response<dynamic>> getContentCollection(String collection) async {
    expect(collection, 'shop_items');
    return Response<dynamic>(
      data: documents,
      requestOptions: RequestOptions(path: '/api/v1/shop_items'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
