part of '../app_route.dart';

final class OnboardingRouteParams {
  OnboardingRouteParams({this.onComplete});

  final VoidCallback? onComplete;
}

class OnboardingRoute extends AppRoute {
  OnboardingRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
         name: routeName,
         path: routeName,
         pageBuilder: (context, state) {
           final params = state.extra as OnboardingRouteParams?;
           return CupertinoPage<void>(
             name: routeName,
             key: state.pageKey,
             child: OnboardingScreen(
               pages: OnboardingData.getPages(context),
               localization: OnboardingLocalization(),
               onComplete: () {
                 params?.onComplete?.call();
                 // TODO: real logic for onboarding completion

                 AuthLoginRoute.go(context);
                 // Testing:
               },
             ),
           );
         },
       );

  static const routeName = '/onboarding';

  static void go(BuildContext context, {OnboardingRouteParams? params}) =>
      context.goNamed(routeName, extra: params);

  static void pushReplacement(
    BuildContext context, {
    OnboardingRouteParams? params,
  }) => context.pushReplacementNamed(routeName, extra: params);
}
