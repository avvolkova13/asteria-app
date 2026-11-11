part of '../app_route.dart';

class CompatibilityRoutes {
  static const createCompatibilityRouteName = '/compatibility/create';
  static const createCompatibilityInitialRouteName = '/compatibility/initial';
  static const createCompatibilityRequestsLeftRouteName = '/compatibility/requests-left';
  static const createCompatibilitySubscriptionRouteName = '/compatibility/subscription';
  static const createCompatibilityHistoryRouteName = '/compatibility/history';
  static const createCompatibilityLoadedRouteName = '/compatibility/loaded';

  static final createCompatibilityRoute = CreateCompatibilityRoute();
  static final createCompatibilityInitialRoute = CreateCompatibilityInitialRoute();
  static final createCompatibilityRequestsLeftRoute = CreateCompatibilityRequestsLeftRoute();
  static final createCompatibilitySubscriptionRoute = CreateCompatibilitySubscriptionRoute();
  static final createCompatibilityHistoryRoute = CreateCompatibilityHistoryRoute();
  static final createCompatibilityLoadedRoute = CreateCompatibilityLoadedRoute();

  static List<AppRoute> get routes => [
        createCompatibilityRoute,
        createCompatibilityInitialRoute,
        createCompatibilityRequestsLeftRoute,
        createCompatibilitySubscriptionRoute,
        createCompatibilityHistoryRoute,
        createCompatibilityLoadedRoute,
      ];
}

class CreateCompatibilityRoute extends AppRoute {
  CreateCompatibilityRoute()
      : super(
          name: CompatibilityRoutes.createCompatibilityRouteName,
          path: CompatibilityRoutes.createCompatibilityRouteName,
          pageBuilder: (context, state) => AsteriaPage(child: CreateCompatibilityScreen()),
        );

  static void push(BuildContext context) => context.pushNamed(CompatibilityRoutes.createCompatibilityRouteName);

  static void pushReplacement(BuildContext context) =>
      context.pushReplacementNamed(CompatibilityRoutes.createCompatibilityRouteName);
}

final class CreateCompatibilityInitialRouteParams {
  CreateCompatibilityInitialRouteParams();
}

class CreateCompatibilityInitialRoute extends AppRoute {
  CreateCompatibilityInitialRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
          name: CompatibilityRoutes.createCompatibilityInitialRouteName,
          path: CompatibilityRoutes.createCompatibilityInitialRouteName,
          pageBuilder: (context, state) {
            return AsteriaPage<void>(
              name: CompatibilityRoutes.createCompatibilityInitialRouteName,
              key: state.pageKey,
              child: const CreateCompatibilityInitialScreen(),
            );
          },
        );

  static void push(BuildContext context, {CreateCompatibilityInitialRouteParams? params}) =>
      context.pushNamed(CompatibilityRoutes.createCompatibilityInitialRouteName, extra: params);

  static void pushReplacement(BuildContext context, {CreateCompatibilityInitialRouteParams? params}) =>
      context.pushReplacementNamed(CompatibilityRoutes.createCompatibilityInitialRouteName, extra: params);
}

final class CreateCompatibilityRequestsLeftRouteParams {
  CreateCompatibilityRequestsLeftRouteParams();
}

class CreateCompatibilityRequestsLeftRoute extends AppRoute {
  CreateCompatibilityRequestsLeftRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
          name: CompatibilityRoutes.createCompatibilityRequestsLeftRouteName,
          path: CompatibilityRoutes.createCompatibilityRequestsLeftRouteName,
          pageBuilder: (context, state) {
            return AsteriaPage<void>(
              name: CompatibilityRoutes.createCompatibilityRequestsLeftRouteName,
              key: state.pageKey,
              child: const CreateCompatibilityRequestsLeftScreen(),
            );
          },
        );

  static void push(BuildContext context, {CreateCompatibilityRequestsLeftRouteParams? params}) =>
      context.pushNamed(CompatibilityRoutes.createCompatibilityRequestsLeftRouteName, extra: params);

  static void pushReplacement(BuildContext context, {CreateCompatibilityRequestsLeftRouteParams? params}) =>
      context.pushReplacementNamed(CompatibilityRoutes.createCompatibilityRequestsLeftRouteName, extra: params);
}

final class CreateCompatibilitySubscriptionRouteParams {
  CreateCompatibilitySubscriptionRouteParams();
}

class CreateCompatibilitySubscriptionRoute extends AppRoute {
  CreateCompatibilitySubscriptionRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
          name: CompatibilityRoutes.createCompatibilitySubscriptionRouteName,
          path: CompatibilityRoutes.createCompatibilitySubscriptionRouteName,
          pageBuilder: (context, state) {
            return AsteriaPage<void>(
              name: CompatibilityRoutes.createCompatibilitySubscriptionRouteName,
              key: state.pageKey,
              child: const CreateCompatibilitySubscriptionScreen(),
            );
          },
        );

  static Future<void> push(BuildContext context, {CreateCompatibilitySubscriptionRouteParams? params}) =>
      context.pushNamed<void>(CompatibilityRoutes.createCompatibilitySubscriptionRouteName, extra: params);

  static void pushReplacement(BuildContext context, {CreateCompatibilitySubscriptionRouteParams? params}) =>
      context.pushReplacementNamed(CompatibilityRoutes.createCompatibilitySubscriptionRouteName, extra: params);
}

final class CreateCompatibilityHistoryRouteParams {
  CreateCompatibilityHistoryRouteParams();
}

class CreateCompatibilityHistoryRoute extends AppRoute {
  CreateCompatibilityHistoryRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
          name: CompatibilityRoutes.createCompatibilityHistoryRouteName,
          path: CompatibilityRoutes.createCompatibilityHistoryRouteName,
          pageBuilder: (context, state) {
            return AsteriaPage<void>(
              name: CompatibilityRoutes.createCompatibilityHistoryRouteName,
              key: state.pageKey,
              child: const CreateCompatibilityHistoryScreen(),
            );
          },
        );

  static void push(BuildContext context, {CreateCompatibilityHistoryRouteParams? params}) =>
      context.pushNamed(CompatibilityRoutes.createCompatibilityHistoryRouteName, extra: params);

  static void pushReplacement(BuildContext context, {CreateCompatibilityHistoryRouteParams? params}) =>
      context.pushReplacementNamed(CompatibilityRoutes.createCompatibilityHistoryRouteName, extra: params);
}

final class CreateCompatibilityLoadedRouteParams {
  CreateCompatibilityLoadedRouteParams();
}

class CreateCompatibilityLoadedRoute extends AppRoute {
  CreateCompatibilityLoadedRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
          name: CompatibilityRoutes.createCompatibilityLoadedRouteName,
          path: CompatibilityRoutes.createCompatibilityLoadedRouteName,
          pageBuilder: (context, state) {
            return AsteriaPage<void>(
              name: CompatibilityRoutes.createCompatibilityLoadedRouteName,
              key: state.pageKey,
              child: const CreateCompatibilityLoadedScreen(),
            );
          },
        );

  static void push(BuildContext context, {CreateCompatibilityLoadedRouteParams? params}) =>
      context.pushNamed(CompatibilityRoutes.createCompatibilityLoadedRouteName, extra: params);

  static void pushReplacement(BuildContext context, {CreateCompatibilityLoadedRouteParams? params}) =>
      context.pushReplacementNamed(CompatibilityRoutes.createCompatibilityLoadedRouteName, extra: params);
}
