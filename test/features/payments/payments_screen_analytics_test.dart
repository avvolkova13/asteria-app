import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/ast_events.dart';
import 'package:asteria_app/core/analytics/dictionaries/failure_reason.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/payments/api/arc_pay_payments_api.dart';
import 'package:asteria_app/core/payments/routing/payment_return_link_service.dart';
import 'package:asteria_app/core/payments/storage/arc_pay_pending_order_store.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_cubit.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_state.dart';
import 'package:asteria_app/features/payments/presentation/screens/payments_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingAnalyticsFacade facade;
  late PaymentReturnLinkService returnLinks;
  late _TestCheckoutCubit cubit;
  late UserProvider userProvider;

  setUp(() async {
    await di.reset();
    facade = _RecordingAnalyticsFacade();
    returnLinks = PaymentReturnLinkService();
    cubit = _TestCheckoutCubit();
    userProvider = UserProvider(userRepository: _FakeUserRepository());
    di.registerSingleton<AnalyticsFacade>(facade);
    di.registerSingleton<ProductAnalyticsService>(
      ProductAnalyticsService(facade),
    );
    di.registerSingleton<PaymentReturnLinkService>(returnLinks);
  });

  tearDown(() async {
    await cubit.close();
    await returnLinks.dispose();
    userProvider.dispose();
    await di.reset();
  });

  testWidgets('fulfilled order emits coin success only once', (tester) async {
    await _pumpPaymentsScreen(tester, cubit, userProvider);
    final fulfilled = ArcPayCheckoutFulfilled(_order(status: 'fulfilled'));

    cubit.publish(fulfilled);
    await tester.pump();
    cubit.publish(const ArcPayCheckoutInitial());
    await tester.pump();
    cubit.publish(fulfilled);
    await tester.pump();

    final events = facade.named(AstEvents.coinPurchaseSuccess);
    expect(events, hasLength(1));
    expect(events.single.params, containsPair(EventParams.afRevenue, 49));
    expect(events.single.params, containsPair(EventParams.afCurrency, 'RUB'));
    expect(
      events.single.params,
      containsPair(EventParams.packageId, 'asteria_stars_10'),
    );
    expect(
      events.single.params,
      containsPair(EventParams.paymentProvider, 'arc_pay'),
    );
    expect(
      events.single.params,
      containsPair(EventParams.underlyingPaymentProvider, 'sbp'),
    );
  });

  testWidgets('terminal order emits controlled coin failure only once', (
    tester,
  ) async {
    await _pumpPaymentsScreen(tester, cubit, userProvider);
    final failed = ArcPayCheckoutTerminalFailure(
      _order(status: 'failed', failureCode: 'payment_declined'),
    );

    cubit.publish(failed);
    await tester.pump();
    cubit.publish(const ArcPayCheckoutInitial());
    await tester.pump();
    cubit.publish(failed);
    await tester.pump();

    final events = facade.named(AstEvents.coinPurchaseFailed);
    expect(events, hasLength(1));
    expect(
      events.single.params,
      containsPair(EventParams.failureReason, FailureReasons.paymentDeclined),
    );
    expect(events.single.params, containsPair(EventParams.price, 49));
    expect(events.single.params, containsPair(EventParams.afCurrency, 'RUB'));
  });

  testWidgets('abandoned order emits user-cancelled coin failure', (
    tester,
  ) async {
    await _pumpPaymentsScreen(tester, cubit, userProvider);

    cubit.publish(const ArcPayCheckoutAbandoned(serverConfirmed: true));
    await tester.pump();

    final event = facade.named(AstEvents.coinPurchaseFailed).single;
    expect(
      event.params,
      containsPair(EventParams.failureReason, FailureReasons.userCancelled),
    );
    expect(event.params, containsPair(EventParams.price, 49));
    expect(event.params, containsPair(EventParams.afCurrency, 'RUB'));
  });

  testWidgets('checkout creation failure keeps route price and currency', (
    tester,
  ) async {
    await _pumpPaymentsScreen(tester, cubit, userProvider);

    cubit.publish(
      const ArcPayCheckoutFailure(ArcPayCheckoutErrorCode.createPayment),
    );
    await tester.pump();

    final event = facade.named(AstEvents.coinPurchaseFailed).single;
    expect(
      event.params,
      containsPair(EventParams.failureReason, FailureReasons.networkError),
    );
    expect(event.params, containsPair(EventParams.price, 49));
    expect(event.params, containsPair(EventParams.afCurrency, 'RUB'));
    expect(
      event.params,
      containsPair(EventParams.packageId, 'asteria_stars_10'),
    );
  });
}

Future<void> _pumpPaymentsScreen(
  WidgetTester tester,
  ArcPayCheckoutCubit cubit,
  UserProvider userProvider,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<UserProvider>.value(
      value: userProvider,
      child: BlocProvider<ArcPayCheckoutCubit>.value(
        value: cubit,
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocaleService.supportedLocales,
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: const PaymentsScreen(
                productId: 'asteria_stars_10',
                price: 49,
                currency: 'RUB',
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

ArcPayOrder _order({required String status, String? failureCode}) =>
    ArcPayOrder(
      orderId: 'order-1',
      productId: 'asteria_stars_10',
      productType: 'stars',
      coins: 10,
      durationDays: null,
      amountMinor: 4900,
      currency: 'RUB',
      status: status,
      providerStatus: status,
      clientState: 'active',
      paymentMethod: 'sbp',
      balance: status == 'fulfilled' ? 10 : null,
      failureCode: failureCode,
      unrecoveredCoins: 0,
    );

class _TestCheckoutCubit extends ArcPayCheckoutCubit {
  _TestCheckoutCubit()
    : super(
        api: ArcPayPaymentsApi.forDio(Dio(), _FakeSession()),
        store: _MemoryPendingOrderStore(),
        currentUserId: () => 'user-1',
        refreshUser: () async {},
        pollingInterval: const Duration(days: 1),
      );

  @override
  Future<void> start({
    String? productId,
    int? amountMinor,
    String? currency,
  }) async {}

  void publish(ArcPayCheckoutState state) => emit(state);
}

class _FakeSession implements AuthSessionService {
  @override
  String? get currentEmail => null;

  @override
  String? get currentUid => 'user-1';

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => true;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async =>
      'access-token';

  @override
  Future<void> deleteCurrentIdentity() async {}

  @override
  Future<void> saveSession({
    required String uid,
    required String? email,
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {}

  @override
  Future<void> signOut() async {}
}

class _MemoryPendingOrderStore extends ArcPayPendingOrderStore {
  ArcPayPendingOrder? value;

  @override
  ArcPayPendingOrder? read() => value;

  @override
  Future<void> save(ArcPayPendingOrder order) async {
    value = order;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

class _RecordedEvent {
  const _RecordedEvent(this.name, this.params);

  final String name;
  final Map<String, dynamic> params;
}

class _RecordingAnalyticsFacade implements AnalyticsFacade {
  final List<_RecordedEvent> events = <_RecordedEvent>[];

  List<_RecordedEvent> named(String name) =>
      events.where((event) => event.name == name).toList(growable: false);

  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    events.add(_RecordedEvent(name, params ?? const <String, dynamic>{}));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
