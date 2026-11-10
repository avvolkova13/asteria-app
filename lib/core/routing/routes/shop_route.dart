part of '../app_route.dart';

final class ShopRouteParams {
  ShopRouteParams();
}

class ShopRoute extends AppRoute {
  ShopRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: routeName,
        path: routeName,
        pageBuilder: (context, state) {
          return CupertinoPage<void>(name: routeName, key: state.pageKey, child: ShopScreen());
        },
      );

  static const routeName = '/shop';

  static void go(BuildContext context, {ShopRouteParams? params}) => context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {ShopRouteParams? params}) => context.pushNamed(routeName, extra: params);

  static void pushReplacement(BuildContext context, {ShopRouteParams? params}) =>
      context.pushReplacementNamed(routeName, extra: params);
}
