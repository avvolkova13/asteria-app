import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/balance/data/reward_event_store.dart';
import 'package:asteria_app/features/balance/data/reward_share_service.dart';
import 'package:asteria_app/features/balance/data/rewards_api.dart';
import 'package:asteria_app/features/balance/presentation/provider/rewards_provider.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/balance/presentation/widgets/earn_rewards_section.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('renders exactly the five AST-142 earning cards', (tester) async {
    final userProvider = UserProvider(userRepository: _NoopUserRepository());
    final provider = RewardsProvider(
      api: RewardsApi.forDio(Dio(), _FakeSession()),
      store: RewardEventStore(),
      shareService: const RewardShareService(),
      userProvider: userProvider,
      monetizationProvider: MonetizationProvider(
        api: MonetizationApi.forDio(Dio(), _FakeSession()),
        userProvider: userProvider,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
        home: Builder(
          builder: (context) => Theme(
            data: AppThemeLight.instance.getThemeData(context),
            child: ChangeNotifierProvider.value(
              value: provider,
              child: const Scaffold(
                body: SingleChildScrollView(child: EarnRewardsSection()),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('reward_card_onboarding')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('reward_card_tarot')), findsOneWidget);
    expect(find.byKey(const ValueKey('reward_card_articles')), findsOneWidget);
    expect(find.byKey(const ValueKey('reward_card_share')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('reward_card_login_streak')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('reward_card_'),
      ),
      findsNWidgets(5),
    );
    expect(find.text('Оставить отзыв'), findsNothing);
    expect(find.textContaining('7 дней'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _FakeSession implements AuthSessionService {
  @override
  String? get currentUid => 'user-1';

  @override
  String? get currentEmail => 'user@example.com';

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => true;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async =>
      'user-token';

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

  @override
  Future<void> deleteCurrentIdentity() async {}
}

class _NoopUserRepository implements UserRepository {
  @override
  Future<void> addCompatibilityToHistory(
    SavedCompatibilityModel compatibility,
  ) async {}

  @override
  Future<void> clearCurrentUser() async {}

  @override
  Future<void> deleteUser(String userId) async {}

  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Stream<UserModel?> getMe() => const Stream.empty();

  @override
  Future<UserModel?> getUserById(String userId) async => null;

  @override
  Future<void> setCurrentUser(UserModel user) async {}

  @override
  Future<void> updateCurrentUser(UserModel user) async {}

  @override
  Future<void> updateUserShopItems(
    String userId,
    List<ShopItemModel> shopItems,
  ) async {}
}
