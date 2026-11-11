part of '../app_route.dart';

class AnakraChatRoutes {
  static const anakraChatRouteName = '/anakra-chat';
  static const createAnakraRequestsLeftRouteName = '/anakra/requests-left';
  static const createAnakraSubscriptionRouteName = '/anakra/subscription';

  static final anakraChatRoute = AnakraChatRoute();
  static final createAnakraRequestsLeftRoute = CreateAnakraRequestsLeftRoute();
  static final createAnakraSubscriptionRoute = CreateAnakraSubscriptionRoute();

  static List<AppRoute> get routes => [anakraChatRoute, createAnakraRequestsLeftRoute, createAnakraSubscriptionRoute];
}

final class AnakraChatRouteParams {
  AnakraChatRouteParams();
}

class AnakraChatRoute extends AppRoute {
  AnakraChatRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: AnakraChatRoutes.anakraChatRouteName,
        path: AnakraChatRoutes.anakraChatRouteName,
        pageBuilder: (context, state) {
          return AsteriaPage<void>(
            name: AnakraChatRoutes.anakraChatRouteName,
            key: state.pageKey,
            child: const AnakraChatScreen(),
          );
        },
      );

  static void push(BuildContext context, {AnakraChatRouteParams? params}) =>
      context.pushNamed(AnakraChatRoutes.anakraChatRouteName, extra: params);

  static void pushReplacement(BuildContext context, {AnakraChatRouteParams? params}) =>
      context.pushReplacementNamed(AnakraChatRoutes.anakraChatRouteName, extra: params);

  static void go(BuildContext context, {AnakraChatRouteParams? params}) =>
      context.goNamed(AnakraChatRoutes.anakraChatRouteName, extra: params);
}

final class CreateAnakraRequestsLeftRouteParams {
  CreateAnakraRequestsLeftRouteParams();
}

class CreateAnakraRequestsLeftRoute extends AppRoute {
  CreateAnakraRequestsLeftRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: AnakraChatRoutes.createAnakraRequestsLeftRouteName,
        path: AnakraChatRoutes.createAnakraRequestsLeftRouteName,
        pageBuilder: (context, state) {
          return AsteriaPage<void>(
            name: AnakraChatRoutes.createAnakraRequestsLeftRouteName,
            key: state.pageKey,
            child: const CreateAnakraRequestsLeftScreen(),
          );
        },
      );

  static void push(BuildContext context, {CreateAnakraRequestsLeftRouteParams? params}) =>
      context.pushNamed(AnakraChatRoutes.createAnakraRequestsLeftRouteName, extra: params);

  static void pushReplacement(BuildContext context, {CreateAnakraRequestsLeftRouteParams? params}) =>
      context.pushReplacementNamed(AnakraChatRoutes.createAnakraRequestsLeftRouteName, extra: params);
}

final class CreateAnakraSubscriptionRouteParams {
  CreateAnakraSubscriptionRouteParams();
}

class CreateAnakraSubscriptionRoute extends AppRoute {
  CreateAnakraSubscriptionRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: AnakraChatRoutes.createAnakraSubscriptionRouteName,
        path: AnakraChatRoutes.createAnakraSubscriptionRouteName,
        pageBuilder: (context, state) {
          return AsteriaPage<void>(
            name: AnakraChatRoutes.createAnakraSubscriptionRouteName,
            key: state.pageKey,
            child: const CreateAnakraSubscriptionScreen(),
          );
        },
      );

  static Future<void> push(BuildContext context, {CreateAnakraSubscriptionRouteParams? params}) =>
      context.pushNamed<void>(AnakraChatRoutes.createAnakraSubscriptionRouteName, extra: params);

  static void pushReplacement(BuildContext context, {CreateAnakraSubscriptionRouteParams? params}) =>
      context.pushReplacementNamed(AnakraChatRoutes.createAnakraSubscriptionRouteName, extra: params);
}
