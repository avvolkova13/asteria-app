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
