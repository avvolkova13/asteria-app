part of '../app_route.dart';

final class HomeRouteParams {
  HomeRouteParams({this.userId});

  final String? userId;
}

class HomeRoute extends AppRoute {
  HomeRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
         name: routeName,
         path: routeName,
         pageBuilder: (context, state) {
           return CupertinoPage<void>(
             name: routeName,
             key: state.pageKey,
             child: HomeScreen(homeLocalization: HomeLocalization()),
           );
         },
       );

  static const routeName = '/home';

  static void go(BuildContext context, {HomeRouteParams? params}) =>
      context.goNamed(routeName, extra: params);

  static void pushReplacement(
    BuildContext context, {
    HomeRouteParams? params,
  }) => context.pushReplacementNamed(routeName, extra: params);
}
