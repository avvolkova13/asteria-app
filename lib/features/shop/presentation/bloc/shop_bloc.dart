import 'package:asteria_app/features/monetization/domain/purchase_visibility.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/shop/domain/shop_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'shop_event.dart';
part 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final ShopRepository _shopRepository;
  final MonetizationProvider _monetizationProvider;

  ShopBloc({
    required ShopRepository shopRepository,
    required MonetizationProvider monetizationProvider,
  }) : _shopRepository = shopRepository,
       _monetizationProvider = monetizationProvider,
       super(ShopInitial()) {
    on<ShopLoadProducts>(_onLoadProducts);
    on<ShopPurchaseProduct>(_onPurchaseProduct);
  }

  /// Загрузка товаров в магазин
  Future<void> _onLoadProducts(
    ShopLoadProducts event,
    Emitter<ShopState> emit,
  ) async {
    emit(ShopLoading());

    try {
      // Загружаем товары из репозитория
      final products = await _shopRepository.getShopItems();
      await _monetizationProvider.ensureLoaded();

      // Обновляем purchasedQuantity для request-pack товаров из Mongo quota.
      final productsWithPurchaseInfo = products.where(isShopProductVisible).map(
        (product) {
          final feature = product.purchase?.featureKey;
          final purchasedQuantity = feature == null
              ? 0
              : _monetizationProvider.requestQuota(feature).paidRemaining;
          return product.copyWith(purchasedQuantity: purchasedQuantity);
        },
      ).toList();

      emit(ShopLoaded(products: productsWithPurchaseInfo));
    } catch (e) {
      emit(const ShopError());
    }
  }

  /// Покупка товара
  Future<void> _onPurchaseProduct(
    ShopPurchaseProduct event,
    Emitter<ShopState> emit,
  ) async {
    if (state is ShopLoaded) {
      final currentState = state as ShopLoaded;
      emit(ShopPurchaseLoading(products: currentState.products));

      try {
        // TODO: Реализовать логику покупки товара через репозиторий
        await Future.delayed(const Duration(seconds: 1)); // Имитация покупки

        emit(ShopPurchaseSuccess(products: currentState.products));
      } catch (e) {
        emit(ShopPurchaseError(products: currentState.products));
      }
    }
  }
}
