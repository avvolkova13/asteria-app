import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:dio/dio.dart';

class ArcPayProduct {
  final String productId;
  final String name;
  final String productType;
  final int? coins;
  final int? durationDays;
  final int amountMinor;
  final String currency;

  const ArcPayProduct({
    required this.productId,
    required this.name,
    required this.productType,
    required this.coins,
    required this.durationDays,
    required this.amountMinor,
    required this.currency,
  });

  factory ArcPayProduct.fromJson(Map<String, dynamic> json) => ArcPayProduct(
    productId: json['product_id'] as String,
    name: json['name'] as String,
    productType:
        (json['product_type'] as String?) ??
        (json['coins'] == null ? 'pro_access' : 'stars'),
    coins: json['coins'] as int?,
    durationDays: json['duration_days'] as int?,
    amountMinor: json['amount_minor'] as int,
    currency: json['currency'] as String,
  );
}

class ArcPayCheckout {
  final String orderId;
  final Uri checkoutUrl;
  final String status;

  const ArcPayCheckout({
    required this.orderId,
    required this.checkoutUrl,
    required this.status,
  });

  factory ArcPayCheckout.fromJson(Map<String, dynamic> json) => ArcPayCheckout(
    orderId: json['order_id'] as String,
    checkoutUrl: Uri.parse(json['checkout_url'] as String),
    status: json['status'] as String,
  );
}

class ArcPayOrder {
  final String orderId;
  final String productId;
  final String productType;
  final int? coins;
  final int? durationDays;
  final int amountMinor;
  final String currency;
  final String status;
  final String providerStatus;
  final String clientState;
  final String? paymentMethod;
  final int? balance;
  final String? failureCode;
  final int unrecoveredCoins;

  const ArcPayOrder({
    required this.orderId,
    required this.productId,
    required this.productType,
    required this.coins,
    required this.durationDays,
    required this.amountMinor,
    required this.currency,
    required this.status,
    required this.providerStatus,
    required this.clientState,
    required this.paymentMethod,
    required this.balance,
    required this.failureCode,
    required this.unrecoveredCoins,
  });

  factory ArcPayOrder.fromJson(Map<String, dynamic> json) => ArcPayOrder(
    orderId: json['order_id'] as String,
    productId: json['product_id'] as String,
    productType:
        (json['product_type'] as String?) ??
        (json['coins'] == null ? 'pro_access' : 'stars'),
    coins: json['coins'] as int?,
    durationDays: json['duration_days'] as int?,
    amountMinor: json['amount_minor'] as int,
    currency: json['currency'] as String,
    status: json['status'] as String,
    providerStatus: json['provider_status'] as String,
    clientState: (json['client_state'] as String?) ?? 'active',
    paymentMethod: json['payment_method'] as String?,
    balance: json['balance'] as int?,
    failureCode: json['failure_code'] as String?,
    unrecoveredCoins: (json['unrecovered_coins'] as int?) ?? 0,
  );
}

class ArcPayPaymentsApi {
  final Dio _dio;
  final AuthSessionService _authSession;

  ArcPayPaymentsApi(Environment environment, this._authSession, {Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: environment.asteriaBackendUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
              headers: {
                'Authorization': 'Bearer ${environment.asteriaApiKey}',
                'Content-Type': 'application/json',
              },
            ),
          );

  ArcPayPaymentsApi.forDio(Dio dio, this._authSession) : _dio = dio;

  Future<Options> _userSessionOptions(String expectedUid) async {
    final token = await _authSession.getAccessTokenForUid(expectedUid);
    if (token == null || token.isEmpty) {
      throw StateError('User session is required');
    }
    return Options(headers: {'X-Asteria-User-Token': token});
  }

  Future<List<ArcPayProduct>> getProducts() async {
    final response = await _dio.get<List<dynamic>>(
      'api/v2/payments/arc-pay/products',
    );
    return (response.data ?? const [])
        .map((item) => ArcPayProduct.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<ArcPayCheckout> createCheckout({
    required String userId,
    required String productId,
    required String requestId,
    String platform = 'android',
    Map<String, Object?>? analyticsContext,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'api/v2/payments/arc-pay/checkout',
      data: {
        'user_id': userId,
        'product_id': productId,
        'request_id': requestId,
        'platform': platform,
        if (analyticsContext?['attempt_id'] != null)
          'attempt_id': analyticsContext!['attempt_id'],
      },
      options: await _userSessionOptions(userId),
    );
    return ArcPayCheckout.fromJson(response.data!);
  }

  Future<ArcPayOrder> getOrder({
    required String orderId,
    required String userId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'api/v2/payments/arc-pay/orders/$orderId',
      queryParameters: {'user_id': userId},
      options: await _userSessionOptions(userId),
    );
    return ArcPayOrder.fromJson(response.data!);
  }

  Future<ArcPayOrder> abandonOrder({
    required String orderId,
    required String userId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'api/v2/payments/arc-pay/orders/$orderId/abandon',
      data: {'user_id': userId},
      options: await _userSessionOptions(userId),
    );
    return ArcPayOrder.fromJson(response.data!);
  }
}
