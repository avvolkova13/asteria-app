part of '../app_route.dart';

final class BalanceRouteParams {
  BalanceRouteParams();
}

class BalanceRoute extends AppRoute {
  BalanceRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: routeName,
        path: routeName,
        pageBuilder: (context, state) {
          return AsteriaPage<void>(name: routeName, key: state.pageKey, child: const BalanceScreen());
        },
      );

  static const routeName = '/balance';

  static void go(BuildContext context, {BalanceRouteParams? params}) => context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {BalanceRouteParams? params}) => context.pushNamed(routeName, extra: params);

  static void pushReplacement(BuildContext context, {BalanceRouteParams? params}) =>
      context.pushReplacementNamed(routeName, extra: params);
}

final class BalanceHistoryRouteParams {
  BalanceHistoryRouteParams();
}

class BalanceHistoryRoute extends AppRoute {
  BalanceHistoryRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: routeName,
        path: routeName,
        pageBuilder: (context, state) {
          return AsteriaPage<void>(name: routeName, key: state.pageKey, child: const BalanceHistoryScreen());
        },
      );

  static const routeName = '/balance-history';

  static void go(BuildContext context, {BalanceHistoryRouteParams? params}) => context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {BalanceHistoryRouteParams? params}) => context.pushNamed(routeName, extra: params);

  static void pushReplacement(BuildContext context, {BalanceHistoryRouteParams? params}) =>
      context.pushReplacementNamed(routeName, extra: params);
}
