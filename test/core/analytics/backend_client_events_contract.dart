import 'dart:convert';
import 'dart:io';

import 'package:asteria_app/core/analytics/apps_flyer_events.dart';
import 'package:flutter_test/flutter_test.dart';

// Run explicitly with a backend checkout as documented in
// docs/gmkt-22-mobile-analytics.md.
void main() => registerBackendClientEventsContract(requireBackend: true);

void registerBackendClientEventsContract({required bool requireBackend}) {
  final configured =
      Platform.environment['ASTERIA_BACKEND_PATH'] ??
      Platform.environment['GMKT22_BACKEND'];
  final root = configured ?? '../asteria-back';
  if (!requireBackend && configured == null && !Directory(root).existsSync()) {
    return;
  }
  test(
    'every event accepted by the backend has the required AF policy',
    () async {
      final model = File('$root/app/services/analytics/models.py');
      expect(
        model.existsSync(),
        isTrue,
        reason:
            'Missing ${model.path}. Set ASTERIA_BACKEND_PATH to the backend checkout.',
      );
      final result = await Process.run('python3', [
        '-B',
        'test/core/analytics/validate_backend_contract.py',
        model.path,
        'client-events',
      ]);
      expect(result.exitCode, 0, reason: result.stderr.toString());
      final events = (jsonDecode(result.stdout as String) as List)
          .cast<String>();
      expect(events, isNotEmpty);
      for (final name in events) {
        final mapped = AppsFlyerEvents.fromCanonical(name, {
          'feature': 'sonnik',
          'screen': '/settings',
          'outcome': 'success',
        });
        if (name == 'analytics_queue_dropped') {
          expect(mapped, isNull, reason: name);
        } else {
          expect(mapped, isNotNull, reason: name);
          expect(
            mapped,
            isNot(name),
            reason: 'AF must not receive the warehouse name',
          );
          expect(AppsFlyerEvents.names, contains(mapped), reason: name);
        }
      }
    },
  );
}
