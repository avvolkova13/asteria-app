part of '../app_route.dart';

class SonnikRoutes {
  static const createSonnikRouteName = '/sonnik/create';
  static const createSonnikInitialRouteName = '/sonnik/initial';
  static const createSonnikRequestsLeftRouteName = '/sonnik/requests-left';
  static const createSonnikSubscriptionRouteName = '/sonnik/subscription';
  static const createSonnikHistoryRouteName = '/sonnik/history';
  static const createSonnikLoadedRouteName = '/sonnik/loaded';

  static final createSonnikRoute = CreateSonnikRoute();
  static final createSonnikInitialRoute = CreateSonnikInitialRoute();
  static final createSonnikRequestsLeftRoute = CreateSonnikRequestsLeftRoute();
  static final createSonnikSubscriptionRoute = CreateSonnikSubscriptionRoute();
  static final createSonnikHistoryRoute = CreateSonnikHistoryRoute();
  static final createSonnikLoadedRoute = CreateSonnikLoadedRoute();

  static List<AppRoute> get routes => [
        createSonnikRoute,
        createSonnikInitialRoute,
        createSonnikRequestsLeftRoute,
        createSonnikSubscriptionRoute,
        createSonnikHistoryRoute,
        createSonnikLoadedRoute,
      ];
}

class CreateSonnikRoute extends AppRoute {
  CreateSonnikRoute()
      : super(
          name: SonnikRoutes.createSonnikRouteName,
          path: SonnikRoutes.createSonnikRouteName,
          pageBuilder: (context, state) => AsteriaPage(child: CreateSonnikScreen()),
        );

  static void push(BuildContext context) => context.pushNamed(SonnikRoutes.createSonnikRouteName);

  static void pushReplacement(BuildContext context) =>
      context.pushReplacementNamed(SonnikRoutes.createSonnikRouteName);
}

final class CreateSonnikInitialRouteParams {
  CreateSonnikInitialRouteParams();
}

class CreateSonnikInitialRoute extends AppRoute {
  CreateSonnikInitialRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
          name: SonnikRoutes.createSonnikInitialRouteName,
          path: SonnikRoutes.createSonnikInitialRouteName,
          pageBuilder: (context, state) {
            return AsteriaPage<void>(
              name: SonnikRoutes.createSonnikInitialRouteName,
              key: state.pageKey,
              child: const CreateSonnikInitialScreen(),
            );
          },
        );

  static void push(BuildContext context, {CreateSonnikInitialRouteParams? params}) =>
      context.pushNamed(SonnikRoutes.createSonnikInitialRouteName, extra: params);

  static void pushReplacement(BuildContext context, {CreateSonnikInitialRouteParams? params}) =>
      context.pushReplacementNamed(SonnikRoutes.createSonnikInitialRouteName, extra: params);
}

final class CreateSonnikRequestsLeftRouteParams {
  CreateSonnikRequestsLeftRouteParams();
}

class CreateSonnikRequestsLeftRoute extends AppRoute {
  CreateSonnikRequestsLeftRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
          name: SonnikRoutes.createSonnikRequestsLeftRouteName,
          path: SonnikRoutes.createSonnikRequestsLeftRouteName,
          pageBuilder: (context, state) {
            return AsteriaPage<void>(
              name: SonnikRoutes.createSonnikRequestsLeftRouteName,
              key: state.pageKey,
              child: const CreateSonnikRequestsLeftScreen(),
            );
          },
        );

  static void push(BuildContext context, {CreateSonnikRequestsLeftRouteParams? params}) =>
      context.pushNamed(SonnikRoutes.createSonnikRequestsLeftRouteName, extra: params);

  static void pushReplacement(BuildContext context, {CreateSonnikRequestsLeftRouteParams? params}) =>
      context.pushReplacementNamed(SonnikRoutes.createSonnikRequestsLeftRouteName, extra: params);
}

final class CreateSonnikSubscriptionRouteParams {
  CreateSonnikSubscriptionRouteParams();
}

class CreateSonnikSubscriptionRoute extends AppRoute {
  CreateSonnikSubscriptionRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
          name: SonnikRoutes.createSonnikSubscriptionRouteName,
          path: SonnikRoutes.createSonnikSubscriptionRouteName,
          pageBuilder: (context, state) {
            return AsteriaPage<void>(
              name: SonnikRoutes.createSonnikSubscriptionRouteName,
              key: state.pageKey,
              child: const CreateSonnikSubscriptionScreen(),
            );
          },
        );

  static Future<void> push(BuildContext context, {CreateSonnikSubscriptionRouteParams? params}) =>
      context.pushNamed<void>(SonnikRoutes.createSonnikSubscriptionRouteName, extra: params);

  static void pushReplacement(BuildContext context, {CreateSonnikSubscriptionRouteParams? params}) =>
      context.pushReplacementNamed(SonnikRoutes.createSonnikSubscriptionRouteName, extra: params);
}

final class CreateSonnikHistoryRouteParams {
  CreateSonnikHistoryRouteParams();
}

class CreateSonnikHistoryRoute extends AppRoute {
  CreateSonnikHistoryRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
          name: SonnikRoutes.createSonnikHistoryRouteName,
          path: SonnikRoutes.createSonnikHistoryRouteName,
          pageBuilder: (context, state) {
            return AsteriaPage<void>(
              name: SonnikRoutes.createSonnikHistoryRouteName,
              key: state.pageKey,
              child: const CreateSonnikHistoryScreen(),
            );
          },
        );

  static void push(BuildContext context, {CreateSonnikHistoryRouteParams? params}) =>
      context.pushNamed(SonnikRoutes.createSonnikHistoryRouteName, extra: params);

  static void pushReplacement(BuildContext context, {CreateSonnikHistoryRouteParams? params}) =>
      context.pushReplacementNamed(SonnikRoutes.createSonnikHistoryRouteName, extra: params);
}

final class CreateSonnikLoadedRouteParams {
  CreateSonnikLoadedRouteParams();
}

class CreateSonnikLoadedRoute extends AppRoute {
  CreateSonnikLoadedRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
          name: SonnikRoutes.createSonnikLoadedRouteName,
          path: SonnikRoutes.createSonnikLoadedRouteName,
          pageBuilder: (context, state) {
            return AsteriaPage<void>(
              name: SonnikRoutes.createSonnikLoadedRouteName,
              key: state.pageKey,
              child: const CreateSonnikLoadedScreen(),
            );
          },
        );

  static void push(BuildContext context, {CreateSonnikLoadedRouteParams? params}) =>
      context.pushNamed(SonnikRoutes.createSonnikLoadedRouteName, extra: params);

  static void pushReplacement(BuildContext context, {CreateSonnikLoadedRouteParams? params}) =>
      context.pushReplacementNamed(SonnikRoutes.createSonnikLoadedRouteName, extra: params);
}
