import 'dart:async';

import 'package:asteria_app/app/app_startup_content_warmup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts content warmup without waiting for it to finish', () async {
    final contentLoad = Completer<void>();
    var loadCalls = 0;

    startLazyContentWarmup(
      loadContent: () {
        loadCalls++;
        return contentLoad.future;
      },
    );

    await Future<void>.delayed(Duration.zero);

    expect(loadCalls, 1);
    expect(contentLoad.isCompleted, isFalse);
  });

  test('reports background content warmup errors', () async {
    final contentLoad = Completer<void>();
    Object? reportedError;

    startLazyContentWarmup(
      loadContent: () => contentLoad.future,
      onError: (error, _) => reportedError = error,
    );

    final error = Exception('content unavailable');
    contentLoad.completeError(error);
    await Future<void>.delayed(Duration.zero);

    expect(reportedError, same(error));
  });
}
