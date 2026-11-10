import 'package:asteria_app/features/scenarios/scenario_picker.dart';
import 'package:asteria_app/features/scenarios/first_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:asteria_app/core/analytics/analytics_route_observer.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/navigator_key.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_route.dart';

part 'routing_scheme.dart';

abstract final class AppRouter {
  static GlobalKey<NavigatorState> get navigatorKey => rootNavigatorKey;

  static GoRouter? _cachedRouter;

  static GoRouter getRouter(String initialLocation) {
    _cachedRouter ??= GoRouter(
      routes: _routes,
      debugLogDiagnostics: true,
      initialLocation: initialLocation,
      navigatorKey: rootNavigatorKey,
    );
    di.get<AnalyticsRouteObserver>().attach(_cachedRouter!);
    return _cachedRouter!;
  }

  static GoRouter createRouter(String initialLocation) {
    return getRouter(initialLocation);
  }
}
