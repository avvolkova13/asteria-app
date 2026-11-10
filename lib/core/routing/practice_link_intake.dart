import 'dart:async';

import 'package:asteria_app/features/affirmation/player/practice_link.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Buffers a public recording until the regular startup destination is mounted.
/// The caller keeps the existing auth, onboarding or home page underneath.
class PracticeLinkIntake {
  PracticeLinkIntake({required this.playerRouteName});

  final String playerRouteName;
  StreamSubscription<Uri>? _subscription;
  GoRouter? _router;
  bool _pending = false;
  bool _scheduled = false;
  bool _opening = false;
  bool _disposed = false;

  void start(Stream<Uri> links, Future<Uri?> Function() getInitialLink) {
    if (_subscription != null || _disposed) return;
    var receivedEvent = false;
    _subscription = links.listen(
      (uri) {
        receivedEvent = true;
        _receive(uri);
      },
      onError: (Object error, StackTrace trace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: trace,
            library: 'practice links',
          ),
        );
      },
    );
    // Another subscriber (for example the payment return handler) may already
    // have received the platform's single initial event.
    Future<void> readInitial() async {
      try {
        final uri = await getInitialLink();
        if (!receivedEvent && uri != null) _receive(uri);
      } on MissingPluginException {
        // Platforms without link support can still navigate inside the app.
      } on PlatformException catch (error, trace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: trace,
            library: 'practice links',
          ),
        );
      }
    }

    unawaited(readInitial());
  }

  void attachRouter(GoRouter router) {
    if (_disposed || identical(_router, router)) return;
    _router?.routerDelegate.removeListener(_schedule);
    _router = router;
    router.routerDelegate.addListener(_schedule);
    _schedule();
  }

  void _receive(Uri uri) {
    if (_disposed || !PracticeLink.matches(uri)) return;
    _pending = true;
    _schedule();
  }

  void _schedule() {
    if (_disposed || !_pending || _scheduled || _router == null) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (_disposed || !_pending) return;
      final router = _router!;
      if (router.routerDelegate.currentConfiguration.isEmpty) return;
      _pending = false;
      if (_opening || router.state.name == playerRouteName) return;
      _opening = true;
      unawaited(
        router
            .pushNamed<void>(playerRouteName)
            .whenComplete(() => _opening = false),
      );
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void dispose() {
    _disposed = true;
    _router?.routerDelegate.removeListener(_schedule);
    _subscription?.cancel();
  }
}
