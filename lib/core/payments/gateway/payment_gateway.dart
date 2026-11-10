import 'package:asteria_app/core/payments/models/payment_product.dart';
import 'package:asteria_app/core/payments/models/purchase_result.dart';
import 'package:asteria_app/core/payments/models/purchase_update.dart';

abstract class PaymentGateway {
  Future<List<PaymentProduct>> loadProducts(List<String> ids);

  Future<PurchaseResult> purchase(PaymentProduct product, {String? userToken});

  Future<void> finalize(PurchaseResult result);

  Stream<PurchaseUpdate> get purchaseUpdates;

  Future<List<PurchaseResult>> restorePurchases();

  Future<String?> currentStorefrontCountry();
}

class StoreProductLoadException implements Exception {
  final String code;
  final String message;
  final List<String> requestedIds;
  final List<String> notFoundIds;
  final List<String> loadedIds;
  final List<PaymentProduct> loadedProducts;
  final String? storeErrorCode;
  final String? storeErrorMessage;

  const StoreProductLoadException({
    required this.code,
    required this.message,
    required this.requestedIds,
    this.notFoundIds = const [],
    this.loadedIds = const [],
    this.loadedProducts = const [],
    this.storeErrorCode,
    this.storeErrorMessage,
  });

  Map<String, Object?> toDiagnosticDetails() => {
    'code': code,
    'message': message,
    'requested_ids': requestedIds,
    'not_found_ids': notFoundIds,
    'loaded_ids': loadedIds,
    'store_error_code': storeErrorCode,
    'store_error_message': storeErrorMessage,
  };

  @override
  String toString() => 'StoreProductLoadException($code): $message';
}
