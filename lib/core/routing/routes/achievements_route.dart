part of '../app_route.dart';

final class AchievementsRouteParams {
  AchievementsRouteParams();
}

class AchievementsRoute extends AppRoute {
  AchievementsRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: routeName,
        path: routeName,
        pageBuilder: (context, state) {
          return CupertinoPage<void>(name: routeName, key: state.pageKey, child: AchievementsScreen());
        },
      );

  static const routeName = '/achievements';

  static void go(BuildContext context, {AchievementsRouteParams? params}) => context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {AchievementsRouteParams? params}) => context.pushNamed(routeName, extra: params);

  static void pushReplacement(BuildContext context, {AchievementsRouteParams? params}) =>
      context.pushReplacementNamed(routeName, extra: params);
}
