import 'dart:async';

import 'package:asteria_app/core/di/retryable_initialization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  test(
    'rollback restores shadowed service and leaves unrelated scopes intact',
    () async {
      final container = GetIt.asNewInstance();
      addTearDown(container.reset);
      final savedService = _Service();
      container.registerSingleton<_Service>(savedService);
      container.pushNewScope(scopeName: 'existing-user-session');
      container.registerSingleton<String>('saved session');
      final initialization = TransactionalDiInitialization(
        container,
        scopeName: 'bootstrap',
      );
      await expectLater(
        initialization.initialize(() async {
          container.registerSingleton<_Service>(_Service());
          throw StateError('version unavailable');
        }),
        throwsStateError,
      );
      expect(container<_Service>(), same(savedService));
      expect(container<String>(), 'saved session');
      expect(container.hasScope('existing-user-session'), isTrue);
      expect(container.hasScope('bootstrap'), isFalse);
    },
  );

  test('concurrent failed DI is rolled back before the next retry', () async {
    final container = GetIt.asNewInstance();
    addTearDown(container.reset);
    final initialization = TransactionalDiInitialization(
      container,
      scopeName: 'bootstrap',
    );
    final ready = Completer<void>();
    var calls = 0;
    Future<void> register() async {
      calls++;
      container.registerSingleton<String>('partial');
      await ready.future;
      throw StateError('storage unavailable');
    }

    final first = initialization.initialize(register);
    final second = initialization.initialize(register);
    final failures = expectLater(
      Future.wait([first, second]),
      throwsStateError,
    );
    ready.complete();
    await failures;
    expect(calls, 1);
    expect(container.isRegistered<String>(), isFalse);
    await initialization.initialize(() async {
      container.registerSingleton<String>('ready');
    });
    expect(container<String>(), 'ready');
  });

  test(
    'failed DI rolls back only its own registrations before retry',
    () async {
      final container = GetIt.asNewInstance();
      addTearDown(container.reset);
      final savedUser = _SavedUser();
      container.registerSingleton<_SavedUser>(savedUser);
      final initialization = TransactionalDiInitialization(
        container,
        scopeName: 'bootstrap',
      );
      var disposed = 0;
      await expectLater(
        initialization.initialize(() async {
          container.registerSingleton<String>(
            'partial',
            dispose: (_) => disposed++,
          );
          throw StateError('storage unavailable');
        }),
        throwsStateError,
      );
      expect(container.isRegistered<String>(), isFalse);
      expect(disposed, 1);
      expect(container<_SavedUser>(), same(savedUser));
      await initialization.initialize(() async {
        container.registerSingleton<String>('ready');
      });
      expect(container<String>(), 'ready');
      expect(container<_SavedUser>(), same(savedUser));
    },
  );

  test(
    'completed DI is reused without registering duplicate services',
    () async {
      final container = GetIt.asNewInstance();
      addTearDown(container.reset);
      final initialization = TransactionalDiInitialization(
        container,
        scopeName: 'bootstrap',
      );
      var calls = 0;
      Future<void> register() async {
        calls++;
        container.registerSingleton<_Service>(_Service());
      }

      await initialization.initialize(register);
      final service = container<_Service>();
      await initialization.initialize(register);
      expect(calls, 1);
      expect(container<_Service>(), same(service));
    },
  );

  test('concurrent DI requests share one pending registration', () async {
    final container = GetIt.asNewInstance();
    addTearDown(container.reset);
    final initialization = TransactionalDiInitialization(
      container,
      scopeName: 'bootstrap',
    );
    final ready = Completer<void>();
    var calls = 0;
    Future<void> register() async {
      calls++;
      await ready.future;
      container.registerSingleton<String>('ready');
    }

    final first = initialization.initialize(register);
    final second = initialization.initialize(register);
    ready.complete();
    await Future.wait([first, second]);
    expect(calls, 1);
  });

  test(
    'startup retry retains listeners and app-open but repeats failed step',
    () async {
      final steps = RetryableStartupSteps();
      var listeners = 0;
      var appOpens = 0;
      var routing = 0;
      Future<String> start() async {
        await steps.run<void>('listeners', () {
          listeners++;
        });
        await steps.run<void>('app-open', () {
          appOpens++;
        });
        return steps.run<String>('route', () {
          routing++;
          if (routing == 1) throw StateError('route unavailable');
          return '/home';
        });
      }

      await expectLater(start(), throwsStateError);
      expect(await start(), '/home');
      expect(listeners, 1);
      expect(appOpens, 1);
      expect(routing, 2);
    },
  );

  test('concurrent startup retries share work including its result', () async {
    final steps = RetryableStartupSteps();
    final ready = Completer<String>();
    var calls = 0;
    Future<String> action() {
      calls++;
      return ready.future;
    }

    final first = steps.run<String>('startup', action);
    final second = steps.run<String>('startup', action);
    ready.complete('/home');
    expect(await first, '/home');
    expect(await second, '/home');
    expect(calls, 1);
  });
}

class _SavedUser {}

class _Service {}
