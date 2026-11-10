import '../../core/payments/apple/apple_checkout_fixture.dart';
import 'package:asteria_app/core/payments/apple/apple_transactions.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/payments/api/arc_pay_payments_api.dart';
import 'package:asteria_app/core/payments/storage/arc_pay_pending_order_store.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_cubit.dart';
import 'package:asteria_app/features/monetization/presentation/contextual_purchase_page.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
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
    show StoreProvider, PurchaseResult;
import 'package:asteria_app/core/payments/models/purchase_result.dart'
    as app_purchase;
import 'package:asteria_app/core/payments/routing/payment_provider_route.dart';
import 'package:asteria_app/core/payments/storage/pending_purchases_store.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_cubit.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_state.dart';
import 'package:asteria_app/features/subscription/presentation/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:provider/provider.dart';

const product = PaymentProduct(
  id: 'asteria_pro_month',
  type: ProductType.subscription,
  title: 'Monthly PRO',
  description: '',
  localizedPrice: r'$4.99',
  rawPrice: 4.99,
  currencyCode: 'USD',
);

void main() {
  late RecordingFacade facade;
  late TestPaywall cubit;
  late TestMonetization monetization;
  late TestUser user;
  late StreamSubscription<PaywallState> subscription;

  setUp(() async {
    await di.reset();
    facade = RecordingFacade();
    monetization = TestMonetization();
    user = TestUser();
    cubit = TestPaywall(monetization);
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
    monetization.dispose();
    user.dispose();
    await di.reset();
  });

  Future<void> purchase(
    WidgetTester tester, {
    PaywallCubit? realCubit,
    bool startPurchase = true,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: user),
          ChangeNotifierProvider<MonetizationProvider>.value(
            value: monetization,
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: const SubscriptionScreen(
                originSurface: 'subscription-test',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (!startPurchase) return;
    await tester.ensureVisible(find.text(r'$4.99'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'$4.99'));
    await tester.pump();
    expect((realCubit ?? cubit).state, isA<PaywallPurchasing>());
  }

  testWidgets('ArcPay PRO returns to origin after its plans unmount', (
    tester,
  ) async {
    final contextual = _ContextualMonetization();
    addTearDown(contextual.dispose);
    await di.unregister<PaymentProviderRouter>();
    di.registerSingleton<PaymentProviderRouter>(
      PaymentProviderRouter(
        Storefront(),
        platform: TargetPlatform.android,
        distributionChannel: DistributionChannel.ru,
      ),
    );
    di.registerFactory<ArcPayCheckoutCubit>(
      () => ArcPayCheckoutCubit(
        api: _ProProductsApi(),
        store: _ArcStore(),
        currentUserId: () => 'subscription-user',
      ),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: TextButton(
              child: const Text('Original action'),
              onPressed: () => openContextualPurchase(
                context,
                subscription: true,
                originSurface: 'test',
              ),
            ),
          ),
        ),
        SubscriptionRoute(),
        GoRoute(
          path: PaymentsRoute.routeName,
          name: PaymentsRoute.routeName,
          builder: (context, _) =>
              const Scaffold(body: Text('Payment pending')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>.value(value: user),
          ChangeNotifierProvider<MonetizationProvider>.value(value: contextual),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          builder: (context, child) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: child!,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Original action'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Arc PRO'));
    await tester.tap(find.text('Arc PRO'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, PaymentsRoute.routeName);
    contextual
        .activate(); // Fulfillment refreshes entitlements before Continue.
    await tester.pumpAndSettle();
    expect(find.text('Arc PRO', skipOffstage: false), findsNothing);
    router.pop(true);
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/');
    expect(find.text('Original action'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  for (final active in [false, true]) {
    for (final outcome in [
      'success',
      'empty',
      'store_error',
      'verify_error',
      'missing_data_error',
    ]) {
      testWidgets('restore $outcome with active PRO=$active', (tester) async {
        if (active) monetization.activate();
        final gateway = RestoreGateway();
        final payments = RestorePaymentsApi(fail: outcome == 'verify_error');
        final realCubit = PaywallCubit(
          storeGateway: gateway,
          storePaymentsApi: payments,
          pendingPurchasesStore: PendingStore(),
          monetizationProvider: monetization,
          authSession: CancelSession(),
        );
        final analytics = realCubit.stream.listen(
          NativeCheckoutAnalytics(facade).onState,
        );
        await di.unregister<PaywallCubit>();
        di.registerFactory<PaywallCubit>(() => realCubit);
        addTearDown(() async {
          await analytics.cancel();
          if (!realCubit.isClosed) await realCubit.close();
        });
        await purchase(tester, startPurchase: false);
        final l10n = AppLocalizations.of(
          tester.element(find.byType(SubscriptionScreen)),
        );
        final restore = find.text(l10n.subscriptionRestorePurchases);
        expect(restore, findsOneWidget);
        await tester.ensureVisible(restore);
        await tester.pumpAndSettle();
        await tester.tap(restore);
        await tester.pump();
        await realCubit.restorePurchases();
        expect(gateway.restoreCalls, 1);
        if (outcome == 'store_error') {
          gateway.result.completeError(StateError('store unavailable'));
        } else {
          gateway.result.complete(
            outcome == 'empty'
                ? []
                : [
                    if (outcome == 'missing_data_error')
                      const PurchaseResult(
                        productId: 'asteria_pro_month',
                        status: app_purchase.PurchaseStatus.success,
                      )
                    else
                      restoredPurchase,
                  ],
          );
        }
        await tester.pumpAndSettle();
        final expectedOutcome = outcome.endsWith('error') ? 'failed' : outcome;
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text(l10n.subscriptionRestoreInProgress), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
        if (outcome == 'success') {
          expect(
            find.text(l10n.subscriptionPurchasesRestored(1)),
            findsOneWidget,
          );
          expect(monetization.effectivePro, isTrue);
        } else if (outcome == 'empty') {
          expect(
            find.text(l10n.subscriptionNoPurchasesToRestore),
            findsOneWidget,
          );
        } else {
          expect(
            find.text(l10n.subscriptionNoPurchasesToRestore),
            findsNothing,
          );
        }
        final events = facade.events
            .where((e) => e.name.startsWith('restore_'))
            .toList();
        expect(events.map((e) => e.name), [
          'restore_started',
          'restore_outcome',
        ]);
        expect(events.last.payload['outcome'], expectedOutcome);
        expect(events.first.payload['restore_id'], isNotNull);
        expect(
          events.last.payload['restore_id'],
          events.first.payload['restore_id'],
        );
        expect(facade.outcomes, isEmpty);
        expect(
          facade.events.any((e) => e.name == 'payment_succeeded'),
          isFalse,
        );
        expect(payments.contexts.every((context) => context == null), isTrue);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets(
    'inactive Apple subscription exposes restore and prevents duplicate requests',
    (tester) async {
      await purchase(tester, startPurchase: false);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SubscriptionScreen)),
      );
      final restore = find.text(l10n.subscriptionRestorePurchases);
      expect(restore, findsOneWidget);
      await tester.ensureVisible(restore);
      await tester.pumpAndSettle();
      await tester.tap(restore);
      await tester.pump();
      expect(cubit.restoreCalls, 1);
      expect(cubit.state, isA<PaywallLoading>());
      await tester.ensureVisible(restore);
      await tester.pump();
      await tester.tap(restore);
      await tester.pump();
      expect(cubit.restoreCalls, 1);
      cubit.publish(const PaywallRestored([]));
      await tester.pumpAndSettle();
      expect(cubit.state, isA<PaywallProductsLoaded>());
      expect(find.text(r'$4.99'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(monetization.effectivePro, isFalse);
      expect(facade.outcomes, isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('restore becomes available again after a failed request', (
    tester,
  ) async {
    await purchase(tester, startPurchase: false);
    final l10n = AppLocalizations.of(
      tester.element(find.byType(SubscriptionScreen)),
    );
    final restore = find.text(l10n.subscriptionRestorePurchases);
    expect(restore, findsOneWidget);
    await tester.ensureVisible(restore);
    await tester.pumpAndSettle();
    await tester.tap(restore);
    await tester.pump();
    cubit.publish(const PaywallFailed(PaywallFailureCode.restoreFailed));
    await tester.pumpAndSettle();
    await tester.ensureVisible(restore);
    await tester.pumpAndSettle();
    await tester.tap(restore);
    await tester.pump();
    expect(cubit.restoreCalls, 2);
    expect(facade.outcomes, isEmpty);
    cubit.publish(const PaywallRestored([]));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'StoreKit sheet cancellation restores plans and records one cancelled outcome',
    (tester) async {
      final store = iap.InAppPurchase.instance;
      final previousPlatform = InAppPurchasePlatform.instance;
      final platform = CancelCheckoutPlatform();
      InAppPurchasePlatform.instance = platform;
      final gateway = StoreBillingGateway(
        iapInstance: store,
        storeProvider: StoreProvider.apple,
      );
      final backgroundUpdates = <Object>[];
      final updates = gateway.purchaseUpdates.listen(backgroundUpdates.add);
      final apple = AppleCheckoutFixture();
      final pending = CancelPendingStore();
      final realCubit = PaywallCubit(
        storeGateway: gateway,
        appleCoordinator: apple.coordinator,
        pendingPurchasesStore: pending,
        monetizationProvider: monetization,
        authSession: CancelSession(),
      );
      final analytics = realCubit.stream.listen(
        NativeCheckoutAnalytics(facade).onState,
      );
      await di.unregister<PaywallCubit>();
      di.registerFactory<PaywallCubit>(() => realCubit);
      addTearDown(() async {
        await apple.dispose();
        await updates.cancel();
        await analytics.cancel();
        if (!realCubit.isClosed) await realCubit.close();
        await platform.controller.close();
        InAppPurchasePlatform.instance = previousPlatform;
      });

      await purchase(tester, realCubit: realCubit);
      expect(apple.purchasedToken, isNotNull);
      apple.nativeResult.complete(AppleNativePurchaseOutcome.canceled);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(realCubit.state, isA<PaywallProductsLoaded>());
      expect(find.text(r'$4.99'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(facade.outcomes, ['cancelled']);
      expect(backgroundUpdates, isEmpty);
      expect(apple.contexts, isEmpty);
      expect(pending.saveCalls, 0);
      expect(monetization.effectivePro, isFalse);
      await tester.pump(const Duration(minutes: 2));
      expect(facade.outcomes, ['cancelled']);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'recovering an existing subscription does not report a new checkout success',
    (tester) async {
      await purchase(tester);
      cubit.publish(PaywallVerifying(product.id));
      await tester.pump();
      monetization.activate();
      cubit.publish(PaywallRestored([product.id]));
      await tester.pumpAndSettle();

      expect(facade.outcomes, isEmpty);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SubscriptionScreen)),
      );
      expect(find.text(l10n.subscriptionPurchasesRestored(1)), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('records success once after PRO replaces the purchase plans', (
    tester,
  ) async {
    await purchase(tester);
    // The real cubit refreshes PRO before emitting PaywallSuccess.
    monetization.activate();
    await tester.pump();
    expect(find.text(r'$4.99'), findsNothing);
    final l10n = AppLocalizations.of(
      tester.element(find.byType(SubscriptionScreen)),
    );
    expect(find.text(l10n.subscriptionActive), findsOneWidget);
    expect(facade.outcomes, isEmpty);

    cubit.publish(
      const PaywallSuccess(productId: 'asteria_pro_month', newBalance: 10),
    );
    await tester.pump();
    expect(facade.outcomes, ['success']);
    expect(facade.successParams.single['plan_id'], product.id);
    expect(facade.successParams.single['origin_surface'], 'subscription-test');

    cubit.publish(const PaywallVerifying('asteria_pro_month'));
    cubit.publish(
      const PaywallSuccess(productId: 'asteria_pro_month', newBalance: 10),
    );
    await tester.pump();
    expect(facade.outcomes, ['success']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('pending can later succeed without recording a failure', (
    tester,
  ) async {
    await purchase(tester);
    cubit.publish(const PaywallPending('asteria_pro_month'));
    await tester.pump();
    monetization.activate();
    await tester.pump();
    cubit.publish(
      const PaywallSuccess(productId: 'asteria_pro_month', newBalance: 10),
    );
    await tester.pump();
    expect(facade.outcomes, ['pending', 'success']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('records success while plans are still mounted', (tester) async {
    await purchase(tester);
    cubit.publish(
      const PaywallSuccess(productId: 'asteria_pro_month', newBalance: 10),
    );
    await tester.pump();
    expect(facade.outcomes, ['success']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('ignores success for a different product', (tester) async {
    await purchase(tester);
    cubit.publish(
      const PaywallSuccess(productId: 'asteria_pro_year', newBalance: 10),
    );
    await tester.pump();
    expect(facade.outcomes, isEmpty);
    cubit.publish(
      const PaywallSuccess(productId: 'asteria_pro_month', newBalance: 10),
    );
    await tester.pump();
    expect(facade.outcomes, ['success']);
    await tester.pumpWidget(const SizedBox());
  });

  for (final code in [
    PaywallFailureCode.canceled,
    PaywallFailureCode.purchaseFailed,
  ]) {
    testWidgets('$code clears the attempt without duplicate outcomes', (
      tester,
    ) async {
      await purchase(tester);
      cubit.publish(PaywallFailed(code, productId: product.id));
      await tester.pump();
      final expected = code == PaywallFailureCode.canceled
          ? 'cancelled'
          : 'failed';
      expect(facade.outcomes, [expected]);
      cubit.publish(
        const PaywallSuccess(productId: 'asteria_pro_month', newBalance: 10),
      );
      await tester.pump();
      expect(facade.outcomes, [expected]);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

class RecordingFacade implements AnalyticsFacade {
  final events = <CanonicalAnalyticsEvent>[];
  final outcomes = <Object?>[];
  final successParams = <Map<String, dynamic>>[];
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    final event = AnalyticsTaxonomy.map(name, params ?? {});
    if (event != null) events.add(event);
    if (event?.name == 'checkout_outcome') {
      outcomes.add(event!.payload['outcome']);
      if (event.payload['outcome'] == 'success') successParams.add(params!);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestPaywall extends PaywallCubit {
  int restoreCalls = 0;
  TestPaywall(MonetizationProvider monetization)
    : super(
        storeGateway: Gateway(),
        storePaymentsApi: PaymentsApi(),
        pendingPurchasesStore: PendingStore(),
        monetizationProvider: monetization,
        authSession: Session(),
      );
  @override
  Future<void> loadProducts(List<String> ids) async =>
      emit(const PaywallProductsLoaded([product]));
  @override
  Future<void> purchase(PaymentProduct product) async =>
      emit(PaywallPurchasing(product.id));
  @override
  Future<void> restorePurchases() async {
    restoreCalls++;
    emit(const PaywallLoading());
  }

  void publish(PaywallState state) => emit(state);
}

class TestMonetization extends ChangeNotifier implements MonetizationProvider {
  bool _pro = false;
  void activate() {
    _pro = true;
    notifyListeners();
  }

  @override
  bool get effectivePro => _pro;
  @override
  Future<void> refreshAfterVerify(StoreVerifyResponse response) async =>
      activate();
  @override
  int get balance => 10;
  @override
  MonetizationStateModel? get state => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestUser extends ChangeNotifier implements UserProvider {
  @override
  UserModel get currentUser =>
      UserModel.empty().copyWith(id: 'subscription-user');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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

class Session implements AuthSessionService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class CancelCheckoutPlatform extends InAppPurchasePlatform {
  final controller = StreamController<List<PurchaseDetails>>.broadcast();
  int buyCalls = 0;
  @override
  Stream<List<PurchaseDetails>> get purchaseStream => controller.stream;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async => ProductDetailsResponse(
    productDetails: identifiers
        .map(
          (id) => ProductDetails(
            id: id,
            title: id,
            description: '',
            price: id == product.id ? r'$4.99' : r'$9.99',
            rawPrice: id == product.id ? 4.99 : 9.99,
            currencyCode: 'USD',
          ),
        )
        .toList(),
    notFoundIDs: const [],
  );
  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    buyCalls++;
    return true;
  }
}

class CancelPaymentsApi extends PaymentsApi {
  int verifyCalls = 0;
  @override
  Future<String> preparePurchaseUserToken(String userId) async =>
      '04894640-abcd-4abc-9def-123456789abc';
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
    verifyCalls++;
    throw StateError('Cancellation must not verify a payment');
  }
}

class CancelPendingStore extends PendingStore {
  int saveCalls = 0;
  @override
  Future<void> save(PendingPurchase purchase) async {
    saveCalls++;
  }
}

class CancelSession extends Session {
  @override
  String get currentUid => 'subscription-user';
}

const restoredPurchase = PurchaseResult(
  productId: 'asteria_pro_month',
  status: app_purchase.PurchaseStatus.success,
  signedTransactionJws: 'test-restored-jws',
  originalTransactionId: 'test-restored-transaction',
  storeProvider: StoreProvider.apple,
);

class RestoreGateway extends Gateway {
  final result = Completer<List<PurchaseResult>>();
  int restoreCalls = 0;
  @override
  Future<List<PaymentProduct>> loadProducts(List<String> ids) async => [
    product,
  ];
  @override
  Future<List<PurchaseResult>> restorePurchases() {
    restoreCalls++;
    return result.future;
  }

  @override
  Future<void> finalize(PurchaseResult result) async {}
}

class RestorePaymentsApi extends CancelPaymentsApi {
  RestorePaymentsApi({required this.fail});
  final bool fail;
  final contexts = <Map<String, Object?>?>[];
  @override
  Future<StoreVerifyResponse> verify({
    required String userId,
    required String verificationData,
    required String productId,
    Map<String, Object?>? analyticsContext,
  }) async {
    contexts.add(analyticsContext);
    if (fail) throw StateError('verification unavailable');
    return const StoreVerifyResponse(
      transactionId: 'test-restored-transaction',
      status: 'fulfilled',
      balance: 10,
    );
  }
}

class _ContextualMonetization extends TestMonetization {
  @override
  Future<void> refreshForAccess() async {}
  @override
  bool isCurrentUser(String uid) => uid == 'subscription-user';
  @override
  MonetizationStateModel get state => MonetizationStateModel.fromJson({
    'uid': 'subscription-user',
    'catalog_revision': 1,
    'effective_pro': effectivePro,
    'wallet': {
      'uid': 'subscription-user',
      'balance': 0,
      'debt': 0,
      'sequence': 1,
    },
  });
}

class _ProProductsApi implements ArcPayPaymentsApi {
  @override
  Future<List<ArcPayProduct>> getProducts() async => const [
    ArcPayProduct(
      productId: 'pro_30',
      name: 'Arc PRO',
      productType: 'pro_access',
      coins: null,
      durationDays: 30,
      amountMinor: 10000,
      currency: 'RUB',
    ),
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ArcStore implements ArcPayPendingOrderStore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
