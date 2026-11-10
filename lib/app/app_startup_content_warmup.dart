import 'dart:async';

import 'package:flutter/foundation.dart';

void startLazyContentWarmup({
  required Future<void> Function() loadContent,
  void Function(Object error, StackTrace stackTrace)? onError,
}) {
  unawaited(() async {
    try {
      await loadContent();
    } catch (error, stackTrace) {
      if (onError != null) {
        onError(error, stackTrace);
        return;
      }
      debugPrint('[App] content warmup failed: $error');
    }
  }());
}
