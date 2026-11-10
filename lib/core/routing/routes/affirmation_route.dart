part of '../app_route.dart';

class AffirmationRoute extends AppRoute {
  AffirmationRoute({
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
              child: const AffirmationScreen(),
            );
          },
        );

  static const routeName = '/affirmation';

  static void go(BuildContext context) => context.goNamed(routeName);

  static void push(BuildContext context) => context.pushNamed(routeName);

  static void pushReplacement(BuildContext context) => context.pushReplacementNamed(routeName);
}

class AffirmationPlayerRoute extends AppRoute {
  AffirmationPlayerRoute()
    : super(
        name: routeName,
        path: routeName,
        pageBuilder: (context, state) => CupertinoPage<void>(
          key: state.pageKey,
          name: routeName,
          child: const AffirmationPlayerScreen(),
        ),
      );

  static const routeName = '/affirmation/player';

  static Future<void> push(BuildContext context) async {
    await context.pushNamed<void>(routeName);
  }
}
