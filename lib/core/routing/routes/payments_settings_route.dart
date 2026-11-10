part of '../app_route.dart';

final class PaymentsSettingsRouteParams {
  PaymentsSettingsRouteParams();
}

class PaymentsSettingsRoute extends AppRoute {
  PaymentsSettingsRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: routeName,
        path: routeName,
        pageBuilder: (context, state) {
          return CupertinoPage<void>(name: routeName, key: state.pageKey, child: PaymentsSettingsScreen());
        },
      );

  static const routeName = '/payments-settings';

  static void go(BuildContext context, {PaymentsSettingsRouteParams? params}) => context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {PaymentsSettingsRouteParams? params}) => context.pushNamed(routeName, extra: params);

  static void pushReplacement(BuildContext context, {PaymentsSettingsRouteParams? params}) =>
      context.pushReplacementNamed(routeName, extra: params);
}
