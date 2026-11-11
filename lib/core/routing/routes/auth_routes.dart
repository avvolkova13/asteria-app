part of '../app_route.dart';

class AuthRoutes {
  static const loginRouteName = '/auth/login';
  static const emailRouteName = '/auth/email';
  static const emailCodeRouteName = '/auth/email/code';
  static const personalInfoRouteName = '/auth/personal-info';

  static final loginRoute = AuthLoginRoute();
  static final emailRoute = AuthEmailRoute();
  static final emailCodeRoute = AuthEmailCodeRoute();
  static final personalInfoRoute = AuthPersonalInfoRoute();

  static List<AppRoute> get routes => [
    loginRoute,
    emailRoute,
    emailCodeRoute,
    personalInfoRoute,
  ];
}

class AuthLoginRoute extends AppRoute {
  AuthLoginRoute()
    : super(
        name: AuthRoutes.loginRouteName,
        path: AuthRoutes.loginRouteName,
        pageBuilder: (context, state) => AsteriaPage(
          key: state.pageKey,
          name: state.name,
          child: BlocProvider<EmailAuthCubit>(
            create: (_) => di.get<EmailAuthCubit>(),
            child: const EmailLoginScreen(isRoot: true),
          ),
        ),
      );

  static void go(BuildContext context) =>
      context.goNamed(AuthRoutes.loginRouteName);

  static void pushReplacement(BuildContext context) =>
      context.pushReplacementNamed(AuthRoutes.loginRouteName);
}

class AuthPersonalInfoRoute extends AppRoute {
  AuthPersonalInfoRoute()
    : super(
        name: AuthRoutes.personalInfoRouteName,
        path: AuthRoutes.personalInfoRouteName,
        pageBuilder: (context, state) {
          final identity =
              state.extra as AuthIdentity? ??
              AuthIdentity.email(
                userId: di.get<AuthSessionService>().currentUid ?? '',
                email: di.get<AuthSessionService>().currentEmail ?? '',
              );
          return AsteriaPage(
            key: state.pageKey,
            name: state.name,
            child: PersonalInfoInputScreen(
              identity: identity,
              authLocalization: AuthLocalization(),
            ),
          );
        },
      );

  static void go(BuildContext context, {required AuthIdentity identity}) =>
      context.goNamed(AuthRoutes.personalInfoRouteName, extra: identity);

  static void push(BuildContext context, {required AuthIdentity identity}) =>
      context.pushNamed(AuthRoutes.personalInfoRouteName, extra: identity);

  static void pushReplacement(
    BuildContext context, {
    required AuthIdentity identity,
  }) => context.pushReplacementNamed(
    AuthRoutes.personalInfoRouteName,
    extra: identity,
  );
}

class AuthEmailRoute extends AppRoute {
  AuthEmailRoute()
    : super(
        name: AuthRoutes.emailRouteName,
        path: AuthRoutes.emailRouteName,
        pageBuilder: (context, state) {
          final arguments = state.extra as _EmailRouteArguments?;
          return AsteriaPage(
            key: state.pageKey,
            name: state.name,
            child: BlocProvider<EmailAuthCubit>(
              create: (_) => di.get<EmailAuthCubit>(),
              child: EmailLoginScreen(
                deleteAfterVerification:
                    arguments?.deleteAfterVerification ?? false,
                expectedUid: arguments?.expectedUid,
                expectedEmail: arguments?.expectedEmail,
              ),
            ),
          );
        },
      );

  static void push(
    BuildContext context, {
    bool deleteAfterVerification = false,
    String? expectedUid,
    String? expectedEmail,
  }) => context.pushNamed(
    AuthRoutes.emailRouteName,
    extra: _EmailRouteArguments(
      deleteAfterVerification: deleteAfterVerification,
      expectedUid: expectedUid,
      expectedEmail: expectedEmail,
    ),
  );
}

class _EmailRouteArguments {
  final bool deleteAfterVerification;
  final String? expectedUid;
  final String? expectedEmail;

  const _EmailRouteArguments({
    required this.deleteAfterVerification,
    this.expectedUid,
    this.expectedEmail,
  });
}

class _EmailCodeRouteArguments {
  final EmailAuthCubit cubit;
  final bool deleteAfterVerification;
  final String? expectedUid;

  const _EmailCodeRouteArguments({
    required this.cubit,
    required this.deleteAfterVerification,
    this.expectedUid,
  });
}

class AuthEmailCodeRoute extends AppRoute {
  AuthEmailCodeRoute()
    : super(
        name: AuthRoutes.emailCodeRouteName,
        path: AuthRoutes.emailCodeRouteName,
        pageBuilder: (context, state) {
          final arguments = state.extra as _EmailCodeRouteArguments;
          return AsteriaPage(
            key: state.pageKey,
            name: state.name,
            child: BlocProvider<EmailAuthCubit>.value(
              value: arguments.cubit,
              child: EmailCodeScreen(
                deleteAfterVerification: arguments.deleteAfterVerification,
                expectedUid: arguments.expectedUid,
              ),
            ),
          );
        },
      );

  static void push(
    BuildContext context, {
    required EmailAuthCubit cubit,
    bool deleteAfterVerification = false,
    String? expectedUid,
  }) => context.pushNamed(
    AuthRoutes.emailCodeRouteName,
    extra: _EmailCodeRouteArguments(
      cubit: cubit,
      deleteAfterVerification: deleteAfterVerification,
      expectedUid: expectedUid,
    ),
  );
}
