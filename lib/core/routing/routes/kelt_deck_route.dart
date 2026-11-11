part of '../app_route.dart';

final class KeltDeckRouteParams {
  KeltDeckRouteParams();
}

class KeltDeckRoute extends AppRoute {
  KeltDeckRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: routeName,
        path: routeName,
        pageBuilder: (context, state) {
          return AsteriaPage<void>(name: routeName, key: state.pageKey, child: const KeltDeckScreen());
        },
      );

  static const routeName = '/kelt-deck';

  static void go(BuildContext context, {KeltDeckRouteParams? params}) => context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {KeltDeckRouteParams? params}) => context.pushNamed(routeName, extra: params);

  static void pushReplacement(BuildContext context, {KeltDeckRouteParams? params}) =>
      context.pushReplacementNamed(routeName, extra: params);
}
