import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/analytics/attribution/attribution_service.dart';
import 'package:asteria_app/core/services/apps_flyer_service.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/auth/data/email_auth_api.dart';
import 'package:asteria_app/features/auth/data/email_auth_repository.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_cubit.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_state.dart';
import 'package:asteria_app/features/auth/presentation/screens/email_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes email and unlocks resend when timer expires', () async {
    final repository = _FakeEmailAuthRepository();
    final userRepository = _FakeUserRepository();
    final cubit = EmailAuthCubit(
      repository: repository,
      sessionService: _FakeAuthSessionService(),
      userRepository: userRepository,
      userProvider: UserProvider(userRepository: userRepository),
    );

    await cubit.requestCode('  User@Example.COM ');

    expect(repository.requestedEmail, 'user@example.com');
    expect(cubit.state, isA<EmailAuthCodeSent>());
    expect((cubit.state as EmailAuthCodeSent).remainingSeconds, 1);
    expect(cubit.canResend, isFalse);

    await Future<void>.delayed(const Duration(milliseconds: 1100));

    expect(cubit.canResend, isTrue);
    expect((cubit.state as EmailAuthCodeSent).remainingSeconds, 0);
    await cubit.close();
  });

  test('invalid email fails locally without calling backend', () async {
    final repository = _FakeEmailAuthRepository();
    final userRepository = _FakeUserRepository();
    final cubit = EmailAuthCubit(
      repository: repository,
      sessionService: _FakeAuthSessionService(),
      userRepository: userRepository,
      userProvider: UserProvider(userRepository: userRepository),
    );

    await cubit.requestCode('not-an-email');

    expect(repository.requestedEmail, isNull);
    expect(cubit.state, isA<EmailAuthFailure>());
    await cubit.close();
  });

  test(
    'reauthentication rejects an email other than the current one',
    () async {
      final repository = _FakeEmailAuthRepository();
      final userRepository = _FakeUserRepository();
      final cubit = EmailAuthCubit(
        repository: repository,
        sessionService: _FakeAuthSessionService(),
        userRepository: userRepository,
        userProvider: UserProvider(userRepository: userRepository),
      );

      await cubit.requestCode(
        'other@example.com',
        expectedEmail: 'current@example.com',
      );

      expect(repository.requestedEmail, isNull);
      expect(cubit.state, isA<EmailAuthFailure>());
      await cubit.close();
    },
  );

  test(
    'reauthentication does not replace the session for another uid',
    () async {
      final repository = _FakeEmailAuthRepository(
        verification: const EmailCodeVerification(
          uid: 'other-user',
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
          tokenType: 'bearer',
          expiresIn: 900,
          profileExists: true,
        ),
      );
      final session = _FakeAuthSessionService();
      final userRepository = _FakeUserRepository();
      final cubit = EmailAuthCubit(
        repository: repository,
        sessionService: session,
        userRepository: userRepository,
        userProvider: UserProvider(userRepository: userRepository),
      );

      await cubit.requestCode('other@example.com');
      await cubit.verifyCode('123456', expectedUid: 'current-user');

      expect(session.savedUid, isNull);
      expect(cubit.state, isA<EmailAuthFailure>());
      await cubit.close();
    },
  );

  test('verification for the expected uid saves the new session', () async {
    final repository = _FakeEmailAuthRepository();
    final session = _FakeAuthSessionService();
    final userRepository = _FakeUserRepository();
    final cubit = EmailAuthCubit(
      repository: repository,
      sessionService: session,
      userRepository: userRepository,
      userProvider: UserProvider(userRepository: userRepository),
    );

    await cubit.requestCode('current@example.com');
    await cubit.verifyCode('123456', expectedUid: 'current-user');

    expect(session.savedUid, 'current-user');
    expect(cubit.state, isA<EmailAuthVerified>());
    await cubit.close();
  });

  test(
    'attribution failure cannot turn a verified login into an error',
    () async {
      final repository = _FakeEmailAuthRepository();
      final session = _FakeAuthSessionService();
      final userRepository = _FakeUserRepository(
        user: UserModel.empty().copyWith(id: 'current-user'),
      );
      final cubit = EmailAuthCubit(
        repository: repository,
        sessionService: session,
        userRepository: userRepository,
        userProvider: UserProvider(userRepository: userRepository),
        attribution: _ThrowingAttributionService(),
      );

      await cubit.requestCode('current@example.com');
      await cubit.verifyCode('123456');

      expect(session.savedUid, 'current-user');
      expect(cubit.state, isA<EmailAuthVerified>());
      await cubit.close();
    },
  );

  testWidgets('root email login shows legal consent links', (tester) async {
    final userRepository = _FakeUserRepository();
    final cubit = EmailAuthCubit(
      repository: _FakeEmailAuthRepository(),
      sessionService: _FakeAuthSessionService(),
      userRepository: userRepository,
      userProvider: UserProvider(userRepository: userRepository),
    );
    addTearDown(cubit.close);
    var authStarted = 0;

    await tester.pumpWidget(
      BlocProvider<EmailAuthCubit>.value(
        value: cubit,
        child: MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocaleService.supportedLocales,
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: EmailLoginScreen(
                isRoot: true,
                onAuthStarted: () => authStarted++,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(authStarted, 1);
    expect(
      find.textContaining('Terms of Use', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Privacy Policy', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('deletion reauthentication locks the current email', (
    tester,
  ) async {
    final userRepository = _FakeUserRepository();
    final cubit = EmailAuthCubit(
      repository: _FakeEmailAuthRepository(),
      sessionService: _FakeAuthSessionService(),
      userRepository: userRepository,
      userProvider: UserProvider(userRepository: userRepository),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider<EmailAuthCubit>.value(
        value: cubit,
        child: MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocaleService.supportedLocales,
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: const EmailLoginScreen(
                deleteAfterVerification: true,
                expectedUid: 'current-user',
                expectedEmail: 'current@example.com',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, 'current@example.com');
    expect(field.readOnly, isTrue);
  });
}

class _FakeEmailAuthRepository implements EmailAuthRepository {
  _FakeEmailAuthRepository({this.verification});

  String? requestedEmail;
  final EmailCodeVerification? verification;

  @override
  Future<EmailCodeChallenge> requestCode(String email) async {
    requestedEmail = email;
    return const EmailCodeChallenge(
      challengeId: '11111111-1111-4111-8111-111111111111',
      expiresIn: 600,
      resendAfter: 1,
    );
  }

  @override
  Future<EmailCodeVerification> verifyCode({
    required String challengeId,
    required String code,
  }) async =>
      verification ??
      const EmailCodeVerification(
        uid: 'current-user',
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        tokenType: 'bearer',
        expiresIn: 900,
        profileExists: true,
      );
}

class _FakeAuthSessionService implements AuthSessionService {
  String? savedUid;

  @override
  String? get currentEmail => null;

  @override
  String? get currentUid => null;

  @override
  bool get hasRecentSignIn => false;

  @override
  bool get hasSession => false;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async =>
      'test-token';

  @override
  Future<void> deleteCurrentIdentity() async {}

  @override
  Future<void> saveSession({
    required String uid,
    required String? email,
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    savedUid = uid;
  }

  @override
  Future<void> signOut() async {}
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({this.user});

  final UserModel? user;

  @override
  Future<void> addCompatibilityToHistory(
    SavedCompatibilityModel compatibility,
  ) async {}

  @override
  Future<void> clearCurrentUser() async {}

  @override
  Future<void> deleteUser(String userId) async {}

  @override
  Stream<UserModel?> getMe() => const Stream.empty();

  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Future<UserModel?> getUserById(String userId) async => user;

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

class _ThrowingAttributionService extends AttributionService {
  _ThrowingAttributionService() : super(_FakeAppsFlyerService());

  @override
  Future<void> attachCustomerUserId(String customerUserId) async {
    throw StateError('test attribution failure');
  }
}

class _FakeAppsFlyerService implements AppsFlyerService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
