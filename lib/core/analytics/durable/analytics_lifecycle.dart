import 'dart:async';

import 'package:flutter/widgets.dart';

import 'durable_analytics.dart';

class AnalyticsLifecycle with WidgetsBindingObserver {
  AnalyticsLifecycle(this.analytics);
  final DurableAnalytics analytics;
  bool _away = false;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    analytics.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_away) return;
      _away = false;
      unawaited(_resume());
    } else if (!_away) {
      _away = true;
      unawaited(
        analytics.pause().catchError(
          (Object _) => analytics.reportStorageFailure(),
        ),
      );
    }
  }

  Future<void> _resume() async {
    try {
      await analytics.resume();
      analytics.start();
    } catch (_) {
      await analytics.reportStorageFailure();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    analytics.dispose();
  }
}
