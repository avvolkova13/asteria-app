import 'dart:async';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/routing/router.dart';
import 'package:asteria_app/features/about_us/about_us_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';

import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/features/auth/data/repositories/auth_repository.dart';
import 'package:asteria_app/features/auth/domain/models/auth_identity.dart';
import 'package:asteria_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:asteria_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:asteria_app/features/auth/presentation/screens/email_code_screen.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';

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
  for (final document in LegalDocumentType.values) {
    testWidgets(
      'unauthenticated consent opens $document and returns to login',
      (tester) async {
        final users = _FakeUserRepository();
        final session = _FakeAuthSessionService();
        final cubit = EmailAuthCubit(
          repository: _FakeEmailAuthRepository(),
          sessionService: session,
          userRepository: users,
          userProvider: UserProvider(userRepository: users),
        );
        addTearDown(cubit.close);
        final router = GoRouter(
          initialLocation: AuthRoutes.loginRouteName,
          redirect: (_, state) => authSessionRedirect(session, state.uri.path),
          routes: [
            GoRoute(
              path: AuthRoutes.loginRouteName,
              name: AuthRoutes.loginRouteName,
              builder: (_, __) =>
                  EmailLoginScreen(isRoot: true, onAuthStarted: () {}),
            ),
            AboutUsRoute(),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          BlocProvider<EmailAuthCubit>.value(
            value: cubit,
            child: MaterialApp.router(
              routerConfig: router,
              locale: const Locale('en', 'US'),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: AppLocaleService.supportedLocales,
              builder: (context, child) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: child!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final label = document == LegalDocumentType.agreement
            ? 'Terms of Use'
            : 'Privacy Policy';
        final link = find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('By requesting a code'),
        );
        await tester.ensureVisible(link);
        final policy = tester.widget<RichText>(link).text as TextSpan;
        final span = policy.children!.whereType<TextSpan>().firstWhere(
          (span) => span.text == label,
        );
        final tap = span.recognizer! as TapGestureRecognizer;
        tap.onTap!();
        await tester.pumpAndSettle();
        // Imperative pushes keep the browser URL unchanged by default.
        expect(find.byType(AboutUsScreen), findsOneWidget);
        expect(router.canPop(), isTrue);
        expect(
          tester
              .widget<AboutUsScreen>(find.byType(AboutUsScreen))
              .initialDocument,
          document,
        );
        await tester.tap(find.bySemanticsLabel('Back').first);
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          AuthRoutes.loginRouteName,
        );
        expect(find.byType(EmailLoginScreen), findsOneWidget);
        expect(session.hasSession, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }

  test(
    'starting another profile resets unknown birth time selection',
    () async {
      final users = _FakeUserRepository();
      final cubit = AuthCubit(
        authRepository: _UnusedAuthRepository(),
        userRepository: users,
        userProvider: UserProvider(userRepository: users),
        globalLoaderService: GlobalLoaderService(),
      );
      addTearDown(cubit.close);
      cubit.initializeUser(
        const AuthIdentity.email(userId: 'first', email: 'first@example.com'),
      );
      cubit.updateUserBirthTime(
        isTimeUnknown: true,
        timeOption: TimeOfDayEnum.unknown,
      );
      cubit.initializeUser(
        const AuthIdentity.email(userId: 'second', email: 'second@example.com'),
      );
      expect((cubit.state as UserInitialized).isTimeUnknown, isFalse);
      expect(cubit.lastSelectedTimeOption, isNull);
    },
  );

  testWidgets(
    'deletion failure shows retry and blocks duplicate deletion while loading',
    (tester) async {
      final users = _FakeUserRepository()..deletePending = Completer<void>();
      final session = _FakeAuthSessionService();
      di.registerSingleton<UserRepository>(users);
      di.registerSingleton<AuthSessionService>(session);
      addTearDown(() => di.unregister<UserRepository>());
      addTearDown(() => di.unregister<AuthSessionService>());
      final cubit = EmailAuthCubit(
        repository: _FakeEmailAuthRepository(),
        sessionService: session,
        userRepository: users,
        userProvider: UserProvider(userRepository: users),
      );
      addTearDown(cubit.close);
      await cubit.requestCode('current@example.com');
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
                child: const EmailCodeScreen(
                  deleteAfterVerification: true,
                  expectedUid: 'current-user',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await cubit.verifyCode('123456', expectedUid: 'current-user');
      await tester.pump();
      expect(users.deleteCalls, 1);
      expect(
        tester
            .widget<AuthGradientButton>(find.byType(AuthGradientButton))
            .isLoading,
        isTrue,
      );
      users.deletePending!.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong. Try again.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      users.deletePending = Completer<void>();
      await tester.tap(find.text('Try again'));
      await tester.pump();
      expect(users.deleteCalls, 2);
      expect(
        tester
            .widget<AuthGradientButton>(find.byType(AuthGradientButton))
            .isLoading,
        isTrue,
      );
      users.deletePending!.completeError(StateError('offline'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('timer preserves verification and blocks duplicate requests', (
    tester,
  ) async {
    final repository = _FakeEmailAuthRepository()
      ..pending = Completer<EmailCodeVerification>();
    final users = _FakeUserRepository();
    final cubit = EmailAuthCubit(
      repository: repository,
      sessionService: _FakeAuthSessionService(),
      userRepository: users,
      userProvider: UserProvider(userRepository: users),
    );
    addTearDown(cubit.close);
    await cubit.requestCode('current@example.com');
    final verification = cubit.verifyCode('123456');
    await tester.pump(const Duration(seconds: 2));
    expect(cubit.state, isA<EmailAuthVerifying>());
    await cubit.verifyCode('123456');
    expect(repository.verifyCalls, 1);
    repository.pending!.completeError(
      const EmailAuthException(EmailAuthErrorType.invalidOrExpiredCode),
    );
    await verification;
  });

  testWidgets('timer preserves invalid-code feedback', (tester) async {
    final repository = _FakeEmailAuthRepository()
      ..pending = Completer<EmailCodeVerification>();
    final users = _FakeUserRepository();
    final cubit = EmailAuthCubit(
      repository: repository,
      sessionService: _FakeAuthSessionService(),
      userRepository: users,
      userProvider: UserProvider(userRepository: users),
    );
    addTearDown(cubit.close);
    await cubit.requestCode('current@example.com');
    final verification = cubit.verifyCode('123456');
    repository.pending!.completeError(
      const EmailAuthException(EmailAuthErrorType.invalidOrExpiredCode),
    );
    await verification;
    await tester.pump(const Duration(seconds: 2));
    expect(cubit.state, isA<EmailAuthFailure>());
    expect((cubit.state as EmailAuthFailure).invalidCode, isTrue);
    expect(cubit.canResend, isTrue);
  });

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

  Completer<EmailCodeVerification>? pending;
  int verifyCalls = 0;
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
  }) async {
    verifyCalls++;
    if (pending != null) return pending!.future;
    return verification ??
        const EmailCodeVerification(
          uid: 'current-user',
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          tokenType: 'bearer',
          expiresIn: 900,
          profileExists: true,
        );
  }
}

class _FakeAuthSessionService implements AuthSessionService {
  String? savedUid;

  @override
  String? get currentEmail => null;

  @override
  String? get currentUid => savedUid;

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
  Completer<void>? deletePending;
  int deleteCalls = 0;

  @override
  Future<void> addCompatibilityToHistory(
    SavedCompatibilityModel compatibility,
  ) async {}

  @override
  Future<void> clearCurrentUser() async {}

  @override
  Future<void> deleteUser(String userId) async {
    deleteCalls++;
    await deletePending?.future;
  }

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

class _UnusedAuthRepository implements AuthRepository {
  @override
  Future<UserModel> createUser(UserModel user) => throw UnimplementedError();
}
