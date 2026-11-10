part of '../app_route.dart';

final class RunesRouteParams {
  const RunesRouteParams() : initialTab = RunesTab.day;
  const RunesRouteParams.spread() : initialTab = RunesTab.layout;

  final RunesTab initialTab;
}

class RunesRoute extends AppRoute {
  RunesRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
         name: routeName,
         path: routeName,
         pageBuilder: (context, state) {
           final extra = state.extra;
           return CupertinoPage<void>(
             name: routeName,
             key: state.pageKey,
             child: RunesScreen(
               initialTab: extra is RunesRouteParams
                   ? extra.initialTab
                   : RunesTab.day,
             ),
           );
         },
       );

  static const routeName = '/runes';

  static void go(BuildContext context, {RunesRouteParams? params}) =>
      context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {RunesRouteParams? params}) =>
      context.pushNamed(routeName, extra: params);

  static void pushReplacement(
    BuildContext context, {
    RunesRouteParams? params,
  }) => context.pushReplacementNamed(routeName, extra: params);
}
