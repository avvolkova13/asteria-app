part of '../app_route.dart';

final class CoinsPaywallRouteParams {
  final int minimumStars;
  final String? returnUid;

  const CoinsPaywallRouteParams({this.minimumStars = 0, this.returnUid})
    : assert(minimumStars >= 0);
}

class CoinsPaywallRoute extends AppRoute {
  CoinsPaywallRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
         name: routeName,
         path: routeName,
         pageBuilder: (context, state) {
           final params = state.extra as CoinsPaywallRouteParams?;
           return AsteriaPage<bool>(
             name: routeName,
             key: state.pageKey,
             child: ContextualPurchasePage(
               returnUid: params?.returnUid,
               subscription: false,
               child: CoinsPaywallScreen(
                 minimumStars: params?.minimumStars ?? 0,
               ),
             ),
           );
         },
       );

  static const routeName = '/coins-paywall';

  static void go(BuildContext context, {CoinsPaywallRouteParams? params}) =>
      context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {CoinsPaywallRouteParams? params}) =>
      context.pushNamed(routeName, extra: params);

  static void pushReplacement(
    BuildContext context, {
    CoinsPaywallRouteParams? params,
  }) => context.pushReplacementNamed(routeName, extra: params);
}
