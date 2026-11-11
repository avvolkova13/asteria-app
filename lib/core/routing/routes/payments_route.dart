part of '../app_route.dart';

final class PaymentsRouteParams {
  final String productId;
  final int amountMinor;
  final num price;
  final String currency;

  const PaymentsRouteParams({
    required this.productId,
    required this.amountMinor,
    required this.price,
    required this.currency,
  });
}

class PaymentsRoute extends AppRoute {
  PaymentsRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
         name: routeName,
         path: routeName,
         pageBuilder: (context, state) {
           final params = state.extra as PaymentsRouteParams?;
           return AsteriaPage<bool>(
             name: routeName,
             key: state.pageKey,
             child: BlocProvider<ArcPayCheckoutCubit>(
               create: (_) => di.get<ArcPayCheckoutCubit>(),
               child: PaymentsScreen(
                 productId: params?.productId,
                 amountMinor: params?.amountMinor,
                 price: params?.price,
                 currency: params?.currency,
               ),
             ),
           );
         },
       );

  static const routeName = '/payments';

  static void go(BuildContext context, {required PaymentsRouteParams params}) =>
      context.goNamed(routeName, extra: params);

  static void push(
    BuildContext context, {
    required PaymentsRouteParams params,
  }) => context.pushNamed(routeName, extra: params);

  static Future<bool?> pushForResult(
    BuildContext context, {
    required PaymentsRouteParams params,
  }) => context.pushNamed<bool>(routeName, extra: params);

  static void pushReplacement(
    BuildContext context, {
    required PaymentsRouteParams params,
  }) => context.pushReplacementNamed(routeName, extra: params);
}
