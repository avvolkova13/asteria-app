import 'package:asteria_app/core/payments/api/arc_pay_subscriptions_api.dart';
import 'package:asteria_app/core/payments/storage/arc_pay_pending_subscription_store.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/arc_pay_subscription_cubit.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/arc_pay_subscription_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restores pending checkout and refreshes only after active', () async {
    final store = _FakeStore()
      ..value = ArcPayPendingSubscription(
        subscriptionId: 'subscription-1',
        productId: 'asteria_pro_month',
        userId: 'user-1',
        checkoutUrl: Uri.parse('https://checkout.example/setup'),
      );
    final api = _FakeApi()..current = _subscription(status: 'active');
    var refreshCalls = 0;
    final cubit = ArcPaySubscriptionCubit(
      api: api,
      store: store,
      refreshUser: () async => refreshCalls++,
      currentUserId: () => 'user-1',
      pollingInterval: const Duration(days: 1),
    );

    await cubit.initialize();

    expect(cubit.state, isA<ArcPaySubscriptionActive>());
    expect(store.value, isNull);
    expect(refreshCalls, 1);
    await cubit.close();
  });

  test(
    'pending status survives local polling and remains recoverable',
    () async {
      final store = _FakeStore()
        ..value = ArcPayPendingSubscription(
          subscriptionId: 'subscription-1',
          productId: 'asteria_pro_month',
          userId: 'user-1',
          checkoutUrl: Uri.parse('https://checkout.example/setup'),
        );
      final api = _FakeApi()..current = _subscription(status: 'charge_pending');
      final cubit = ArcPaySubscriptionCubit(
        api: api,
        store: store,
        refreshUser: () async {},
        currentUserId: () => 'user-1',
        pollingInterval: const Duration(days: 1),
      );

      await cubit.initialize();

      expect(cubit.state, isA<ArcPaySubscriptionPending>());
      expect(store.value, isNotNull);
      await cubit.close();
    },
  );
}

ArcPaySubscription _subscription({required String status}) =>
    ArcPaySubscription(
      subscriptionId: 'subscription-1',
      status: status,
      checkoutUrl: Uri.parse('https://checkout.example/setup'),
      productId: 'asteria_pro_month',
      currentPeriodEnd: null,
      nextChargeAt: null,
      cancelAtPeriodEnd: false,
      failureCode: null,
    );

class _FakeApi extends ArcPaySubscriptionsApi {
  _FakeApi() : super.forDio(Dio(), _FakeSession());

  ArcPaySubscription? current;

  @override
  Future<ArcPaySubscription?> getCurrent() async => current;
}

class _FakeStore extends ArcPayPendingSubscriptionStore {
  ArcPayPendingSubscription? value;
  @override
  ArcPayPendingSubscription? read() => value;
  @override
  Future<void> save(ArcPayPendingSubscription subscription) async =>
      value = subscription;
  @override
  Future<void> clear() async => value = null;
}

class _FakeSession implements AuthSessionService {
  @override
  String? get currentEmail => null;
  @override
  String? get currentUid => 'mongo-user';
  @override
  bool get hasRecentSignIn => true;
  @override
  bool get hasSession => true;
  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async => 'token';
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
