part of '../app_route.dart';

final class HoroscopeRouteParams {
  HoroscopeRouteParams();
}

class HoroscopeRoute extends AppRoute {
  HoroscopeRoute({super.parentNavigatorKey, super.redirect, super.onExit, super.routes})
    : super(
        name: routeName,
        path: routeName,
        pageBuilder: (context, state) {
          return CupertinoPage<void>(name: routeName, key: state.pageKey, child: HoroscopeScreen());
        },
      );

  static const routeName = '/horoscope';

  static void go(BuildContext context, {HoroscopeRouteParams? params}) => context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {HoroscopeRouteParams? params}) => context.pushNamed(routeName, extra: params);

  static void pushReplacement(BuildContext context, {HoroscopeRouteParams? params}) =>
      context.pushReplacementNamed(routeName, extra: params);
}
