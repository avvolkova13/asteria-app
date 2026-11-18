import 'dart:async';

import 'package:get_it/get_it.dart';

/// Owns registrations made during bootstrap without resetting existing state.
class TransactionalDiInitialization {
  TransactionalDiInitialization(this.container, {required this.scopeName});

  final GetIt container;
  final String scopeName;
  Future<void>? _initialization;
  bool _complete = false;

  Future<void> initialize(Future<void> Function() register) {
    final existing = _initialization;
    if (existing != null && (!_complete || container.hasScope(scopeName))) {
      return existing;
    }
    _complete = false;
    return _initialization =
        Future<void>.microtask(() async {
          container.pushNewScope(scopeName: scopeName);
          try {
            await register();
            _complete = true;
          } catch (_) {
            // Drop only our registrations. Persistent boxes and earlier scopes
            // belong to the application and must survive a bootstrap retry.
            await container.dropScope(scopeName);
            rethrow;
          }
        }).catchError((Object error, StackTrace trace) {
          _initialization = null;
          Error.throwWithStackTrace(error, trace);
        });
  }
}

/// Repeats failed work while retaining completed startup side effects.
class RetryableStartupSteps {
  final Map<Object, Future<dynamic>> _steps = {};

  Future<T> run<T>(Object key, FutureOr<T> Function() action) {
    final existing = _steps[key];
    if (existing != null) return existing as Future<T>;
    final result = Completer<T>();
    _steps[key] = result.future;
    Future<T>.sync(action).then<void>(
      result.complete,
      onError: (Object error, StackTrace trace) {
        _steps.remove(key);
        result.completeError(error, trace);
      },
    );
    return result.future;
  }
}
