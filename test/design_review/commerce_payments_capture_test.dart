import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
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

import 'commerce_review_capture_test.dart'
    show capture, captureKey, bottom, ReviewBinding;

import 'package:flutter/services.dart';

import 'dart:io';

String reviewLang = 'ru';
bool reviewCompact = false;
void main() {
  ReviewBinding();
  setUpAll(() async {
    Directory(
      '/private/tmp/asteria-design-review/commerce',
    ).createSync(recursive: true);
    for (final f in [
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
      (
        'packages/cupertino_icons/CupertinoIcons',
        'packages/cupertino_icons/assets/CupertinoIcons.ttf',
      ),
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
    ]) {
      await (FontLoader(f.$1)..addFont(rootBundle.load(f.$2))).load();
    }
  });
  for (final lang in ['ru', 'en']) {
    for (final compact in [false, true]) {
      testWidgets('payments $lang compact=$compact', (t) async {
        reviewLang = lang;
        reviewCompact = compact;
        t.view.devicePixelRatio = 1;
        t.view.physicalSize = compact
            ? const Size(320, 568)
            : const Size(390, 844);
        final suffix = '${lang}_${compact ? '320_text2' : '390'}';
        addTearDown(t.view.reset);
        for (final state in <(String, ArcPayCheckoutState)>[
          ('initial', const ArcPayCheckoutInitial()),
          ('loading', const ArcPayCheckoutCreating('asteria_stars_10')),
          (
            'ready',
            ArcPayCheckoutReady(
              ArcPayPendingCheckout(
                orderId: 'review',
                productId: 'asteria_stars_10',
                userId: 'user-1',
                checkoutUrl: Uri.parse('https://example.invalid/local-review'),
              ),
              restored: true,
            ),
          ),
          (
            'pending',
            ArcPayCheckoutPending(reviewPaymentOrder(status: 'pending')),
          ),
          (
            'confirming',
            ArcPayCheckoutConfirming(reviewPaymentOrder(status: 'pending')),
          ),
          (
            'fulfilled',
            ArcPayCheckoutFulfilled(reviewPaymentOrder(status: 'fulfilled')),
          ),
          (
            'failed',
            ArcPayCheckoutTerminalFailure(
              reviewPaymentOrder(
                status: 'failed',
                failureCode: 'payment_declined',
              ),
            ),
          ),
          ('abandoned', const ArcPayCheckoutAbandoned(serverConfirmed: true)),
          (
            'error',
            const ArcPayCheckoutFailure(ArcPayCheckoutErrorCode.createPayment),
          ),
        ]) {
          await di.reset();
          final facade = _RecordingAnalyticsFacade();
          final links = PaymentReturnLinkService();
          final user = UserProvider(userRepository: _FakeUserRepository());
          final cubit = ReviewCheckoutCubit();
          di.registerSingleton<AnalyticsFacade>(facade);
          di.registerSingleton<ProductAnalyticsService>(
            ProductAnalyticsService(facade),
          );
          di.registerSingleton<PaymentReturnLinkService>(links);
          await pumpReviewPaymentsScreen(t, cubit, user);
          cubit.publish(state.$2);
          await t.pump();
          await t.pump(const Duration(milliseconds: 350));
          await capture(t, 'payments_${state.$1}_$suffix');
          await bottom(t, 'payments_${state.$1}_$suffix');
          await t.pumpWidget(const SizedBox());
          await cubit.close();
          await links.dispose();
          user.dispose();
          await di.reset();
        }
      });
    }
  }
}

Future<void> pumpReviewPaymentsScreen(
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
          locale: Locale(reviewLang),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocaleService.supportedLocales,
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(reviewCompact ? 2 : 1),
                  disableAnimations: true,
                  padding: EdgeInsets.only(
                    top: reviewCompact ? 20 : 59,
                    bottom: reviewCompact ? 0 : 34,
                  ),
                ),
                child: RepaintBoundary(
                  key: captureKey,
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
      ),
    ),
  );
  await tester.pump();
}

ArcPayOrder reviewPaymentOrder({required String status, String? failureCode}) =>
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

class ReviewCheckoutCubit extends ArcPayCheckoutCubit {
  ReviewCheckoutCubit()
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
  final requests = <String, ArcPayCheckoutRequest>{};

  @override
  ArcPayCheckoutRequest? readCheckoutRequest(String key) => requests[key];

  @override
  Future<ArcPayCheckoutRequest> saveCheckoutRequestIfAbsent(
    ArcPayCheckoutRequest request,
  ) async => requests.putIfAbsent(request.key, () => request);

  ArcPayPendingOrder? value;

  @override
  ArcPayPendingOrder? read() => value;

  @override
  Future<void> save(ArcPayPendingOrder order) async {
    value = order;
    if (requests[order.requestKey]?.requestId == order.requestId) {
      requests.remove(order.requestKey);
    }
  }

  @override
  Future<void> clear() async {
    final order = value;
    if (order != null &&
        requests[order.requestKey]?.requestId == order.requestId) {
      requests.remove(order.requestKey);
    }
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
