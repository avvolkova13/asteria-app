import 'package:asteria_app/core/ui_kit/widgets/asteria_activity_indicator.dart';
import '../../core/payments/apple/apple_checkout_fixture.dart';
import 'dart:async';

import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/durable/analytics_taxonomy.dart';
import 'package:asteria_app/core/analytics/durable/native_checkout_analytics.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/payments/api/store_payments_api.dart';
import 'package:asteria_app/core/payments/gateway/payment_gateway.dart';
import 'package:asteria_app/core/payments/gateway/store_kit_gateway.dart';
import 'package:asteria_app/core/payments/models/payment_product.dart';
import 'package:asteria_app/core/payments/models/purchase_result.dart'
    show StoreProvider;
import 'package:asteria_app/core/payments/routing/payment_provider_route.dart';
import 'package:asteria_app/core/payments/storage/pending_purchases_store.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/coins_paywall/presentation/screens/coins_paywall_screen.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_cubit.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart' show InAppPurchase;
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

const product = PaymentProduct(
  id: 'asteria_stars_10',
  type: ProductType.consumable,
  title: '10 stars',
  description: '',
  localizedPrice: r'$0.99',
  rawPrice: 0.99,
  currencyCode: 'USD',
);

void main() {
  late RecordingFacade facade;
  late TestPaywall cubit;
  late StreamSubscription<PaywallState> subscription;

  setUp(() async {
    await di.reset();
    facade = RecordingFacade();
    cubit = TestPaywall();
    subscription = cubit.stream.listen(NativeCheckoutAnalytics(facade).onState);
    di.registerSingleton<AnalyticsFacade>(facade);
    di.registerSingleton<ProductAnalyticsService>(
      ProductAnalyticsService(facade),
    );
    di.registerFactory<PaywallCubit>(() => cubit);
    di.registerSingleton<PaymentProviderRouter>(
      PaymentProviderRouter(
        Storefront(),
        platform: TargetPlatform.iOS,
        distributionChannel: DistributionChannel.global,
      ),
    );
  });
  tearDown(() async {
    await subscription.cancel();
    if (!cubit.isClosed) await cubit.close();
    await di.reset();
  });

  Future<void> purchase(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        home: Builder(
          builder: (context) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: const CoinsPaywallScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'$0.99'));
    await tester.pump();
    expect(cubit.state, const PaywallPurchasing('asteria_stars_10'));
  }

  testWidgets('pending is not failure and later success is retained', (
    tester,
  ) async {
    await purchase(tester);
    cubit.publish(const PaywallPending('asteria_stars_10'));
    await tester.pump();
    expect(facade.outcomes, ['pending']);
    cubit.publish(
      const PaywallSuccess(productId: 'asteria_stars_10', newBalance: 10),
    );
    await tester.pump();
    expect(facade.outcomes, ['pending', 'success']);
    await tester.pumpWidget(const SizedBox());
  });

  for (final code in [
    PaywallFailureCode.canceled,
    PaywallFailureCode.purchaseFailed,
  ]) {
    testWidgets(
      '$code has one outcome with the native listener and screen mounted',
      (tester) async {
        await purchase(tester);
        cubit.publish(PaywallFailed(code, productId: 'asteria_stars_10'));
        await tester.pump();
        expect(facade.outcomes, [
          code == PaywallFailureCode.canceled ? 'cancelled' : 'failed',
        ]);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'StoreKit success preserves checkout context and reloads packages',
    (tester) async {
      final platform = CheckoutPlatform();
      final iap = InAppPurchase.instance;
      InAppPurchasePlatform.instance = platform;
      final gateway = StoreBillingGateway(
        iapInstance: iap,
        storeProvider: StoreProvider.apple,
      );
      final backgroundUpdates = <Object>[];
      final updates = gateway.purchaseUpdates.listen(backgroundUpdates.add);
      final apple = AppleCheckoutFixture(context: checkoutContext);
      final pending = CheckoutPendingStore();
      final realCubit = PaywallCubit(
        storeGateway: gateway,
        appleCoordinator: apple.coordinator,
        pendingPurchasesStore: pending,
        monetizationProvider: CheckoutMonetization(),
        authSession: CheckoutSession(),
        analyticsContext: (productId, uid) async {
          expect(productId, product.id);
          expect(uid, 'checkout-user');
          return checkoutContext;
        },
      );
      final nativeAnalytics = realCubit.stream.listen(
        NativeCheckoutAnalytics(facade).onState,
      );
      await di.unregister<PaywallCubit>();
      di.registerFactory<PaywallCubit>(() => realCubit);
      addTearDown(() async {
        await apple.dispose();
        await updates.cancel();
        await nativeAnalytics.cancel();
        if (!realCubit.isClosed) await realCubit.close();
        await platform.controller.close();
      });

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: const CoinsPaywallScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(r'$0.99'));
      await tester.pump();
      expect(realCubit.state, isA<PaywallPurchasing>());
      expect(apple.purchasedToken, 'unique-server-token');

      apple.deliver();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        apple.contexts.single?['installation_id'],
        checkoutContext['installation_id'],
      );
      expect(apple.contexts.single?['attempt_id'], apple.attemptId);
      expect(
        apple.journal.saved?.analyticsContext?['attempt_id'],
        apple.attemptId,
      );
      expect(apple.journal.entries, isEmpty);
      expect(apple.finished, ['exact']);
      expect(facade.outcomes, ['success']);
      expect(realCubit.state, isA<PaywallProductsLoaded>());
      expect(find.text(r'$0.99'), findsOneWidget);
      expect(find.byType(AsteriaActivityIndicator), findsNothing);
      await tester.pump(const Duration(minutes: 2));
      expect(facade.outcomes, ['success']);
      expect(apple.contexts, hasLength(1));
      await tester.pumpWidget(const SizedBox());
    },
  );
}

const checkoutAccountToken = '04894640-abcd-4abc-9def-123456789abc';
const checkoutContext = <String, Object?>{
  'installation_id': '11111111-1111-4111-8111-111111111111',
  'attempt_id': '22222222-2222-4222-8222-222222222222',
};

class CheckoutPlatform extends InAppPurchasePlatform {
  final controller = StreamController<List<PurchaseDetails>>.broadcast();
  final completed = <String?>[];
  PurchaseParam? purchaseParam;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => controller.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) async =>
      ProductDetailsResponse(
        productDetails: [
          for (final id in ids)
            ProductDetails(
              id: id,
              title: id == product.id ? product.title : id,
              description: '',
              price: id == product.id ? product.localizedPrice : r'$2.99',
              rawPrice: product.rawPrice,
              currencyCode: product.currencyCode,
            ),
        ],
        notFoundIDs: [],
      );

  @override
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) async {
    this.purchaseParam = purchaseParam;
    return true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completed.add(purchase.purchaseID);
  }
}

class CheckoutPaymentsApi extends PaymentsApi {
  final contexts = <Map<String, Object?>?>[];

  @override
  Future<String> preparePurchaseUserToken(String userId) async =>
      checkoutAccountToken;

  @override
  Future<void> recordClientDiagnostic({
    required String userId,
    required String stage,
    String? productId,
    Map<String, Object?> details = const {},
  }) async {}

  @override
  Future<StoreVerifyResponse> verify({
    required String userId,
    required String verificationData,
    required String productId,
    Map<String, Object?>? analyticsContext,
  }) async {
    expect(userId, 'checkout-user');
    expect(verificationData, 'verified-transaction-jws');
    contexts.add(analyticsContext);
    return const StoreVerifyResponse(
      transactionId: '2000001234780842',
      status: 'fulfilled',
      balance: 10,
    );
  }
}

class CheckoutPendingStore extends PendingStore {
  PendingPurchase? saved;
  String? deleted;

  @override
  Future<void> save(PendingPurchase purchase) async => saved = purchase;

  @override
  Future<void> delete(String id) async => deleted = id;
}

class CheckoutMonetization extends Monetization {
  @override
  Future<void> refreshAfterVerify(StoreVerifyResponse response) async {}
}

class CheckoutSession extends Session {
  @override
  String? get currentUid => 'checkout-user';
}

class RecordingFacade implements AnalyticsFacade {
  final outcomes = <Object?>[];
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    final event = AnalyticsTaxonomy.map(name, params ?? {});
    if (event?.name == 'checkout_outcome') {
      outcomes.add(event!.payload['outcome']);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestPaywall extends PaywallCubit {
  TestPaywall()
    : super(
        storeGateway: Gateway(),
        storePaymentsApi: PaymentsApi(),
        pendingPurchasesStore: PendingStore(),
        monetizationProvider: Monetization(),
        authSession: Session(),
      );
  @override
  Future<void> loadProducts(List<String> productIds) async =>
      emit(const PaywallProductsLoaded([product]));
  @override
  Future<void> purchase(PaymentProduct product) async =>
      emit(PaywallPurchasing(product.id));
  void publish(PaywallState state) => emit(state);
}

class Storefront implements AppleStorefrontService {
  @override
  Future<String?> currentCountryCode() async => 'US';
  @override
  Stream<String?> get countryCodeUpdates => const Stream.empty();
}

class Gateway implements PaymentGateway {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class PaymentsApi implements StorePaymentsApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class PendingStore implements PendingPurchasesStore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Monetization implements MonetizationProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Session implements AuthSessionService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
