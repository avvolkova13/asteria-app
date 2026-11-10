part of '../app_route.dart';

final class NatalCardRouteParams {
  NatalCardRouteParams();
}

class NatalCardRoute extends AppRoute {
  NatalCardRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: routeName,
        path: routeName,
        pageBuilder: (context, state) {
          return CupertinoPage<void>(name: routeName, key: state.pageKey, child: NatalCardScreen());
        },
      );

  static const routeName = '/natal-card';

  static void go(BuildContext context, {NatalCardRouteParams? params}) => context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {NatalCardRouteParams? params}) => context.pushNamed(routeName, extra: params);

  static void pushReplacement(BuildContext context, {NatalCardRouteParams? params}) =>
      context.pushReplacementNamed(routeName, extra: params);
}
