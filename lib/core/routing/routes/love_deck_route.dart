part of '../app_route.dart';

final class LoveDeckRouteParams {
  LoveDeckRouteParams();
}

class LoveDeckRoute extends AppRoute {
  LoveDeckRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: routeName,
        path: routeName,
        pageBuilder: (context, state) {
          return AsteriaPage<void>(name: routeName, key: state.pageKey, child: const LoveDeckScreen());
        },
      );

  static const routeName = '/love-deck';

  static void go(BuildContext context, {LoveDeckRouteParams? params}) => context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {LoveDeckRouteParams? params}) => context.pushNamed(routeName, extra: params);

  static void pushReplacement(BuildContext context, {LoveDeckRouteParams? params}) =>
      context.pushReplacementNamed(routeName, extra: params);
}
