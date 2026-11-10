part of '../app_route.dart';

final class TaroCardsRouteParams {
  const TaroCardsRouteParams() : initialTab = TaroCardsTab.day;
  const TaroCardsRouteParams.spread() : initialTab = TaroCardsTab.layout;

  final TaroCardsTab initialTab;
}

class TaroCardsRoute extends AppRoute {
  TaroCardsRoute({
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
             child: TaroCardsScreen(
               initialTab: extra is TaroCardsRouteParams
                   ? extra.initialTab
                   : TaroCardsTab.day,
             ),
           );
         },
       );

  static const routeName = '/taro-cards';

  static void go(BuildContext context, {TaroCardsRouteParams? params}) =>
      context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {TaroCardsRouteParams? params}) =>
      context.pushNamed(routeName, extra: params);

  static void pushReplacement(
    BuildContext context, {
    TaroCardsRouteParams? params,
  }) => context.pushReplacementNamed(routeName, extra: params);
}
