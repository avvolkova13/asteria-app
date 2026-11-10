import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:dio/dio.dart';

class ArcPaySubscriptionProduct {
  final String productId;
  final String name;
  final int amountMinor;
  final String currency;
  final String periodUnit;
  final int periodCount;

  const ArcPaySubscriptionProduct({
    required this.productId,
    required this.name,
    required this.amountMinor,
    required this.currency,
    required this.periodUnit,
    required this.periodCount,
  });

  factory ArcPaySubscriptionProduct.fromJson(Map<String, dynamic> json) =>
      ArcPaySubscriptionProduct(
        productId: json['product_id'] as String,
        name: json['name'] as String,
        amountMinor: json['amount_minor'] as int,
        currency: json['currency'] as String,
        periodUnit: json['period_unit'] as String,
        periodCount: json['period_count'] as int,
      );
}

class ArcPaySubscription {
  final String subscriptionId;
  final String status;
  final Uri? checkoutUrl;
  final String productId;
  final DateTime? currentPeriodEnd;
  final DateTime? nextChargeAt;
  final bool cancelAtPeriodEnd;
  final String? failureCode;

  const ArcPaySubscription({
    required this.subscriptionId,
    required this.status,
    required this.checkoutUrl,
    required this.productId,
    required this.currentPeriodEnd,
    required this.nextChargeAt,
    required this.cancelAtPeriodEnd,
    required this.failureCode,
  });

  factory ArcPaySubscription.fromJson(Map<String, dynamic> json) =>
      ArcPaySubscription(
        subscriptionId: json['subscription_id'] as String,
        status: json['status'] as String,
        checkoutUrl: json['checkout_url'] == null
            ? null
            : Uri.parse(json['checkout_url'] as String),
        productId: json['product_id'] as String,
        currentPeriodEnd: json['current_period_end'] == null
            ? null
            : DateTime.parse(json['current_period_end'] as String),
        nextChargeAt: json['next_charge_at'] == null
            ? null
            : DateTime.parse(json['next_charge_at'] as String),
        cancelAtPeriodEnd: (json['cancel_at_period_end'] as bool?) ?? false,
        failureCode: json['failure_code'] as String?,
      );
}

class ArcPaySubscriptionsApi {
  final Dio _dio;
  final AuthSessionService _authSession;

  ArcPaySubscriptionsApi(Environment environment, this._authSession, {Dio? dio})
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

  ArcPaySubscriptionsApi.forDio(Dio dio, this._authSession) : _dio = dio;

  Future<Options> _currentUserSessionOptions() async {
    final expectedUid = _authSession.currentUid;
    if (expectedUid == null) {
      throw StateError('User session is required');
    }
    final token = await _authSession.getAccessTokenForUid(expectedUid);
    if (token == null || token.isEmpty) {
      throw StateError('User session is required');
    }
    return Options(headers: {'X-Asteria-User-Token': token});
  }

  Future<List<ArcPaySubscriptionProduct>> getProducts() async {
    final response = await _dio.get<List<dynamic>>(
      'api/v2/payments/arc-pay/subscriptions/products',
    );
    return (response.data ?? const [])
        .map(
          (item) =>
              ArcPaySubscriptionProduct.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<ArcPaySubscription> createCheckout({
    required String productId,
    required String requestId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'api/v2/payments/arc-pay/subscriptions/checkout',
      data: {'product_id': productId, 'request_id': requestId},
      options: await _currentUserSessionOptions(),
    );
    return ArcPaySubscription.fromJson(response.data!);
  }

  Future<ArcPaySubscription?> getCurrent() async {
    final response = await _dio.get<dynamic>(
      'api/v2/payments/arc-pay/subscriptions/current',
      options: await _currentUserSessionOptions(),
    );
    final data = response.data;
    return data == null
        ? null
        : ArcPaySubscription.fromJson(data as Map<String, dynamic>);
  }

  Future<ArcPaySubscription> cancel(String subscriptionId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'api/v2/payments/arc-pay/subscriptions/$subscriptionId/cancel',
      options: await _currentUserSessionOptions(),
    );
    return ArcPaySubscription.fromJson(response.data!);
  }

  Future<ArcPaySubscription> retry(String subscriptionId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'api/v2/payments/arc-pay/subscriptions/$subscriptionId/retry',
      options: await _currentUserSessionOptions(),
    );
    return ArcPaySubscription.fromJson(response.data!);
  }
}
