import 'package:asteria_app/core/analytics/durable/analytics_taxonomy.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

/// Reads matched route names, never URLs, query parameters or Page.name.
class AnalyticsRouteObserver extends ChangeNotifier {
  AnalyticsRouteObserver({void Function(String, String?)? onScreen})
    : _onScreen = onScreen ?? _track;
  final void Function(String, String?) _onScreen;
  GoRouter? _router;
  Object? _visibleKey;
  String? _previous;
  int _homeTab = 0;
  String? get visibleScreen => _previous;

  void homeTab(int index) {
    if (index < 0 || index > 3 || index == _homeTab) return;
    _homeTab = index;
    _changed();
  }

  static void _track(String screen, String? previous) {
    di.get<ProductAnalyticsService>().trackScreenView(
      screenName: screen,
      originSurface: previous,
    );
  }

  void attach(GoRouter router) {
    if (identical(_router, router)) return;
    detach();
    _router = router;
    router.routerDelegate.addListener(_changed);
    _changed();
  }

  void _changed() {
    final configuration = _router?.routerDelegate.currentConfiguration;
    if (configuration == null || configuration.isEmpty) return;
    final hasHome = configuration.matches.any((match) {
      final route = match.route;
      return route is GoRoute && route.name == '/home';
    });
    if (!hasHome) _homeTab = 0;
    final match = configuration.last;
    final route = match.route;
    if (!AnalyticsTaxonomy.screens.contains(route.name)) return;
    final screen = route.name == '/home'
        ? ['/home', '/home/personal', '/home/moon', '/home/practices'][_homeTab]
        : route.name!;
    final key = (screen, match.pageKey);
    if (_visibleKey == key) return;
    _visibleKey = key;
    _onScreen(screen, _previous);
    _previous = screen;
    notifyListeners();
  }

  void detach() {
    _router?.routerDelegate.removeListener(_changed);
    _router = null;
    _visibleKey = null;
    _previous = null;
  }
}
