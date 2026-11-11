part of '../app_route.dart';

final class AboutUsRouteParams {
  const AboutUsRouteParams({this.document});

  final LegalDocumentType? document;
}

class AboutUsRoute extends AppRoute {
  AboutUsRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
         name: routeName,
         path: routeName,
         pageBuilder: (context, state) {
           final params = state.extra as AboutUsRouteParams?;
           return AsteriaPage<void>(
             name: routeName,
             key: state.pageKey,
             child: AboutUsScreen(initialDocument: params?.document),
           );
         },
       );

  static const routeName = '/about-us';

  static void go(BuildContext context, {AboutUsRouteParams? params}) =>
      context.goNamed(routeName, extra: params);

  static void push(BuildContext context, {AboutUsRouteParams? params}) =>
      context.pushNamed(routeName, extra: params);

  static void pushReplacement(
    BuildContext context, {
    AboutUsRouteParams? params,
  }) => context.pushReplacementNamed(routeName, extra: params);
}
