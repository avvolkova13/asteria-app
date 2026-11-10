part of '../app_route.dart';

final class ArticleRouteParams {
  ArticleRouteParams({required this.articleId});

  final String articleId;
}

class ArticleRoute extends AppRoute {
  ArticleRoute({
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
          name: routeName,
          path: routeName,
          pageBuilder: (context, state) {
            final params = state.extra as ArticleRouteParams?;
            return CupertinoPage<void>(
              name: routeName,
              key: state.pageKey,
              child: ArticleScreen(articleId: params?.articleId ?? ''),
            );
          },
        );

  static const routeName = '/article';

  static void go(BuildContext context, {required String articleId}) =>
      context.goNamed(routeName, extra: ArticleRouteParams(articleId: articleId));

  static void push(BuildContext context, {required String articleId}) =>
      context.pushNamed(routeName, extra: ArticleRouteParams(articleId: articleId));

  static void pushReplacement(BuildContext context, {required String articleId}) =>
      context.pushReplacementNamed(routeName, extra: ArticleRouteParams(articleId: articleId));
}
