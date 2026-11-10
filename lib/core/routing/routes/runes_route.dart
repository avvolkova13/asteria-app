part of '../app_route.dart';

final class RunesRouteParams {
  RunesRouteParams();
}

class RunesRoute extends AppRoute {
  RunesRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: routeName,
        path: routeName,
        pageBuilder: (context, state) {
          return CupertinoPage<void>(name: routeName, key: state.pageKey, child: RunesScreen());
        },
      );

  static const routeName = '/runes';

  static void go(BuildContext context, {RunesRouteParams? params}) => context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {RunesRouteParams? params}) => context.pushNamed(routeName, extra: params);

  static void pushReplacement(BuildContext context, {RunesRouteParams? params}) =>
      context.pushReplacementNamed(routeName, extra: params);
}
