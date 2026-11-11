part of '../app_route.dart';

final class SubscriptionRouteParams {
  SubscriptionRouteParams({this.originSurface, this.returnUid});

  final String? originSurface;
  final String? returnUid;
}

class SubscriptionRoute extends AppRoute {
  SubscriptionRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
         name: routeName,
         path: routeName,
         pageBuilder: (context, state) {
           final params = state.extra is SubscriptionRouteParams
               ? state.extra! as SubscriptionRouteParams
               : null;
           return AsteriaPage<bool>(
             name: routeName,
             key: state.pageKey,
             child: ContextualPurchasePage(
               returnUid: params?.returnUid,
               subscription: true,
               child: SubscriptionScreen(originSurface: params?.originSurface),
             ),
           );
         },
       );

  static const routeName = '/subscription';

  static void go(BuildContext context, {SubscriptionRouteParams? params}) =>
      context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {SubscriptionRouteParams? params}) =>
      context.pushNamed(routeName, extra: params);

  static void pushReplacement(
    BuildContext context, {
    SubscriptionRouteParams? params,
  }) => context.pushReplacementNamed(routeName, extra: params);
}
