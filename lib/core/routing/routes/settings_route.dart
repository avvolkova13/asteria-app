part of '../app_route.dart';

final class SettingsRouteParams {
  SettingsRouteParams();
}

class SettingsRoute extends AppRoute {
  SettingsRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: routeName,
        path: routeName,
        pageBuilder: (context, state) {
          return CupertinoPage<void>(name: routeName, key: state.pageKey, child: SettingsScreen());
        },
      );

  static const routeName = '/settings';

  static void go(BuildContext context, {SettingsRouteParams? params}) => context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {SettingsRouteParams? params}) => context.pushNamed(routeName, extra: params);

  static void pushReplacement(BuildContext context, {SettingsRouteParams? params}) =>
      context.pushReplacementNamed(routeName, extra: params);
}
