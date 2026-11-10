import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';
import 'package:asteria_app/core/payments/catalog/product_catalog.dart';

import 'analytics_store.dart';
import 'analytics_json_size.dart';
import 'analytics_taxonomy.dart';
import 'analytics_transport.dart';

class DurableAnalytics {
  DurableAnalytics({
    required this.store,
    required this.transport,
    required this.currentUid,
    required this.accessToken,
    required this.platform,
    required this.appVersion,
    required this.environment,
    required this.enabled,
    this.onEventRecorded,
    this.deviceContext,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  static const buildEnabled = bool.fromEnvironment('ASTERIA_ANALYTICS_ENABLED');
  final AnalyticsStore store;
  final AnalyticsTransport transport;
  final String? Function() currentUid;
  final Future<String?> Function(String expectedUid) accessToken;
  final String platform;
  final String appVersion;
  final String environment;
  final bool enabled;
  final DateTime Function() clock;
  final Future<Map<String, Object?>?> Function()? deviceContext;
  String? _acknowledgedDeviceContext;
  Map<String, Object?>? _bufferedAttribution;
  void Function(Map<String, Object?> event)? onEventRecorded;
  Future<void> _writes = Future.value();
  Future<void>? _flushing;
  Future<void>? _bootstrapping;
  Future<void>? _identifying;
  Future<void>? _initializing;
  bool _ready = false;
  Timer? _timer;
  bool _disposed = false;
  bool _paused = false;
  bool _contextMismatch = false;
  int _failures = 0;
  int storageFailures = 0;

  Future<void> reportStorageFailure() async {
    storageFailures++;
    try {
      await store.count('storage_failures');
    } catch (_) {
      // Memory counter remains available when the disk itself is unavailable.
    }
  }

  String get _installation => store.context['installation_id'] as String;
  String get _token => store.context['token'] as String;
  String? get _identity {
    final uid = currentUid();
    return uid != null && store.context['identity_user'] == uid
        ? store.context['identity_id'] as String?
        : null;
  }

  Future<void> _serial(Future<void> Function() action) {
    final result = _writes.then((_) => action());
    _writes = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<void> initialize() => _initializing ??= _initialize().whenComplete(() {
    _initializing = null;
  });

  Future<void> _initialize() async {
    if (!enabled) return;
    if (_ready) return;
    if (!store.isAvailable && !await store.recover()) return;
    await store.initialize();
    _contextMismatch = !await store.prepareContext(platform, environment);
    if (_contextMismatch) {
      await store.count('installation_context_mismatch');
      return;
    }
    await store.updateContext({
      'platform': platform,
      'environment': environment,
    });
    // Persist the original envelope before enqueue: replay after a crash uses
    // the same ID, timestamp and identity, including a crash between box writes.
    if (store.context['first_open_done'] != true) {
      await _ensureSession();
      final first = store.context['first_open_pending'];
      final event = first is Map
          ? Map<String, Object?>.from(first)
          : _event('first_open', {}, clock().toUtc(), null);
      await store.updateContext({'first_open_pending': event});
      await store.enqueue(event, clock().toUtc());
      await store.updateContext({
        'first_open_done': true,
        'first_open_pending': null,
      });
      if (first is! Map) _notifyRecorded(event);
      await _enqueue('session_started', {}, clock().toUtc(), _identity);
      await store.updateContext({
        'last_active': clock().toUtc().toIso8601String(),
      });
    } else {
      await _resume();
    }
    _ready = true;
  }

  /// Starts retries without tying startup, ATT, or product calls to network I/O.
  void start() {
    if (!enabled || _disposed || _contextMismatch || _timer != null) return;
    _schedule(const Duration(milliseconds: 1));
  }

  void _schedule(Duration delay) {
    if (_disposed || _paused) return;
    _timer?.cancel();
    _timer = Timer(delay, () async {
      _timer = null;
      try {
        await flush();
        if (!_paused && store.isAvailable) {
          await store.updateContext({
            'last_active': clock().toUtc().toIso8601String(),
          });
        }
      } catch (_) {
        await reportStorageFailure();
      }
      final seconds = min(300, 15 * pow(2, min(_failures, 5)).toInt());
      _schedule(Duration(seconds: seconds + Random().nextInt(5)));
    });
  }

  Map<String, Object?> _event(
    String name,
    Map<String, Object?> payload,
    DateTime at,
    String? identity,
  ) => {
    'event_id': const Uuid().v4(),
    'event_name': name,
    'schema_version': 1,
    'occurred_at': at.toIso8601String(),
    'session_id': store.context['session_id'],
    'identity_id': identity,
    'platform': platform,
    'app_version': appVersion,
    'environment': environment,
    'payload': payload,
  };

  Future<void> _enqueue(
    String name,
    Map<String, Object?> payload,
    DateTime at,
    String? identity, {
    void Function(Map<String, Object?> event)? onRecorded,
  }) async {
    final event = _event(name, payload, at, identity);
    await store.enqueue(event, at);
    _notifyRecorded(event, onRecorded: onRecorded);
  }

  void _notifyRecorded(
    Map<String, Object?> event, {
    void Function(Map<String, Object?> event)? onRecorded,
  }) {
    try {
      (onRecorded ?? onEventRecorded)?.call(
        Map.unmodifiable({
          ...event,
          'payload': Map<String, Object?>.unmodifiable(event['payload'] as Map),
        }),
      );
    } catch (_) {
      // An optional observer never changes the product event or its delivery.
    }
  }

  Future<void> record(
    String name,
    Map<String, Object?> payload, {
    void Function(Map<String, Object?> event)? onRecorded,
  }) {
    if (!enabled || _disposed || _contextMismatch) return Future.value();
    if (!store.isAvailable || !_ready) {
      return store.count('degraded_dropped_events');
    }
    final at = clock().toUtc();
    final identity = _identity;
    final user = currentUid();
    final copiedPayload = AnalyticsTaxonomy.sanitize(payload);
    return _serial(
      () => _record(name, copiedPayload, at, identity, user, onRecorded),
    );
  }

  Object? _product(Map<String, Object?> payload) =>
      payload['product_id'] ?? payload['plan_id'] ?? payload['package_id'];

  Future<void> _record(
    String name,
    Map<String, Object?> copiedPayload,
    DateTime at,
    String? identity,
    String? user,
    void Function(Map<String, Object?> event)? onRecorded,
  ) async {
    final created = await _ensureSession();
    if (created) await _enqueue('session_started', {}, at, identity);
    final scope = '${store.context['session_id']}:$user';
    final selection =
        '$scope:${copiedPayload['feature']}:${_product(copiedPayload)}';
    if (name == 'paywall_viewed') {
      await store.updateContext({'selected_offer': null});
    }
    if (name == 'checkout_started' &&
        store.context['selected_offer'] != selection) {
      await _enqueue(
        'offer_selected',
        copiedPayload,
        at,
        identity,
        onRecorded: onRecorded,
      );
      await store.updateContext({'selected_offer': selection});
    } else if (name == 'offer_selected') {
      await store.updateContext({'selected_offer': selection});
    }
    if (name.startsWith('feature_') || name.startsWith('checkout_')) {
      final kind = name.startsWith('checkout_') ? 'checkout' : 'feature';
      final scope = '${store.context['session_id']}:$user';
      final context = store.context;
      final attempts = context['attempt_scope'] == scope
          ? Map<String, Object?>.from(context['attempt_ids'] as Map? ?? {})
          : <String, Object?>{};
      final key = '$kind:${copiedPayload['feature']}';
      if (name.endsWith('_started')) {
        attempts[key] = const Uuid().v4();
        if (kind == 'checkout') {
          attempts['$key:product'] = _product(copiedPayload);
          attempts['$key:claimed'] = false;
          attempts['$key:context'] = {
            'installation_id': _installation,
            'session_id': store.context['session_id'],
            'identity_id': identity,
            'attempt_id': attempts[key],
          };
        }
        await store.updateContext({
          'attempt_scope': scope,
          'attempt_ids': attempts,
        });
      }
      final attempt = attempts[key];
      if (attempt != null) copiedPayload['attempt_id'] = attempt;
    }
    await _enqueue(name, copiedPayload, at, identity, onRecorded: onRecorded);
    if (name == 'feature_action_failed' || name == 'feature_result_viewed') {
      // A later history view must not complete an already finished attempt.
      final attempts = Map<String, Object?>.from(
        store.context['attempt_ids'] as Map? ?? {},
      );
      attempts.remove('feature:${copiedPayload['feature']}');
      await store.updateContext({'attempt_ids': attempts});
    }
    if (!_paused) {
      await store.updateContext({'last_active': at.toIso8601String()});
    }
  }

  Future<bool> _ensureSession() async {
    if (store.context['session_id'] != null) return false;
    await store.updateContext({'session_id': const Uuid().v4()});
    return true;
  }

  Future<void> pause() async {
    if (!enabled || !_ready || _contextMismatch || !store.isAvailable) return;
    _paused = true;
    _timer?.cancel();
    _timer = null;
    await _serial(
      () => store.updateContext({
        'last_active': clock().toUtc().toIso8601String(),
      }),
    );
  }

  Future<void> resume() async {
    if (!_ready) {
      await initialize();
      return;
    }
    await _resume();
  }

  Future<void> _resume() async {
    if (!enabled || _contextMismatch || !store.isAvailable) return;
    _paused = false;
    await _serial(() async {
      final now = clock().toUtc();
      final last = DateTime.tryParse(
        store.context['last_active'] as String? ?? '',
      );
      if (last == null || now.difference(last) >= const Duration(minutes: 30)) {
        await store.updateContext({'session_id': const Uuid().v4()});
        await _enqueue('session_started', {}, now, _identity);
      }
      await store.updateContext({'last_active': now.toIso8601String()});
    });
  }

  Future<void> _bootstrap() {
    if (store.context['registered'] == true) return Future.value();
    return _bootstrapping ??= (() async {
      try {
        await transport.post('installations', {
          'installation_id': _installation,
          'platform': platform,
          'environment': environment,
          'app_version': appVersion,
        }, token: _token);
        await store.updateContext({'registered': true});
      } finally {
        _bootstrapping = null;
      }
    })();
  }

  Future<void> identify() {
    if (!enabled ||
        !_ready ||
        _disposed ||
        _contextMismatch ||
        !store.isAvailable) {
      return Future.value();
    }
    return _identifying ??= Future<void>.microtask(() async {
      try {
        final uid = currentUid();
        if (uid == null || _identity != null) return;
        await _bootstrap();
        final token = await accessToken(uid);
        if (token == null || currentUid() != uid) return;
        final response = await transport.post(
          'identify',
          {'installation_id': _installation},
          token: _token,
          accessToken: token,
        );
        final identity = response['identity_id'];
        if (currentUid() != uid ||
            response['user_id'] != uid ||
            identity is! String ||
            identity.isEmpty) {
          return;
        }
        await store.updateContext({
          'identity_user': uid,
          'identity_id': identity,
        });
      } catch (_) {
        await store.count('identify_failures');
      } finally {
        _identifying = null;
      }
    });
  }

  Future<void> attribution({
    String? appsflyerId,
    Map<String, Object?>? rawPayload,
  }) async {
    if (!enabled || _disposed || _contextMismatch) return;
    final buffered = Map<String, Object?>.from(_bufferedAttribution ?? {});
    if (rawPayload != null && !buffered.containsKey('raw_payload')) {
      buffered['raw_payload'] = jsonDecode(jsonEncode(rawPayload));
    }
    if (appsflyerId != null && appsflyerId.isNotEmpty) {
      buffered['appsflyer_id'] = appsflyerId;
    }
    if (buffered.isEmpty) return;
    _bufferedAttribution = buffered;
    await _persistBufferedAttribution();
  }

  Future<void> _persistBufferedAttribution() async {
    if (!_ready || !store.isAvailable) return;
    final buffered = _bufferedAttribution;
    if (buffered == null) return;
    await store.saveAttribution(
      appsflyerId: buffered['appsflyer_id'] as String?,
      rawPayload: buffered['raw_payload'] == null
          ? null
          : Map<String, Object?>.from(buffered['raw_payload'] as Map),
    );
    if (identical(_bufferedAttribution, buffered)) _bufferedAttribution = null;
  }

  Future<void> flush() {
    if (!enabled || _disposed || _contextMismatch) return Future.value();
    return _flushing ??= (() async {
      try {
        if (!store.isAvailable || !_ready) {
          _ready = false;
          await initialize();
          if (!store.isAvailable || !_ready) {
            _failures++;
            return;
          }
        }
        await _writes;
        // Persist a callback recovered during startup even while offline.
        try {
          await _persistBufferedAttribution();
        } catch (_) {
          await reportStorageFailure();
        }
        await _bootstrap();
        // Identity, events, and attribution failures never gate one another.
        await Future.wait([
          identify(),
          _flushEvents(),
          _flushAttribution(),
          _flushDiagnostics(),
          _flushDeviceContext(),
        ]);
      } catch (_) {
        _failures++;
        await store.count('bootstrap_failures');
      } finally {
        _flushing = null;
      }
    })();
  }

  Future<void> _flushDeviceContext() async {
    if (deviceContext == null) return;
    try {
      final context = await deviceContext!().timeout(
        const Duration(seconds: 5),
      );
      if (context == null) return;
      final serialized = jsonEncode(context);
      if (serialized == _acknowledgedDeviceContext) return;
      final response = await transport.post('device-context', {
        'installation_id': _installation,
        'device_context': context,
      }, token: _token);
      if (response['accepted'] == true) _acknowledgedDeviceContext = serialized;
    } catch (_) {
      await store.count('device_context_delivery_failures');
    }
  }

  Future<void> _flushEvents() async {
    try {
      // Bound one wakeup to avoid monopolizing the connection after long offline periods.
      for (var i = 0; i < 10; i++) {
        final batch = await store.batch(clock().toUtc());
        if (batch.isEmpty) break;
        final response = await transport.post('events/batch', {
          'installation_id': _installation,
          'events': batch,
        }, token: _token);
        final accepted = response['accepted_event_ids'];
        if (accepted is! List || accepted.any((id) => id is! String)) {
          throw const AnalyticsDeliveryException(0);
        }
        final submitted = batch.map((e) => e['event_id']).toSet();
        final acknowledged = accepted
            .cast<String>()
            .where(submitted.contains)
            .toSet();
        await store.acknowledge(acknowledged);
        if (acknowledged.length < batch.length) break;
      }
      _failures = 0;
    } catch (_) {
      _failures++;
      await store.count('event_delivery_failures');
    }
  }

  Future<void> _flushDiagnostics() async {
    try {
      final saved = store.context['diagnostic_pending'];
      Map<String, Object?> event;
      if (saved is Map) {
        event = Map<String, Object?>.from(saved);
      } else {
        final counters = store.diagnostics;
        final totals = <String, Object?>{'snapshot_version': 1};
        for (final key in const [
          'dropped_expired',
          'dropped_overflow',
          'degraded_dropped_events',
          'storage_open_failures',
          'storage_recoveries',
          'attribution_oversized',
          'attribution_rejected',
        ]) {
          totals[key] = ((counters[key] as int?) ?? 0).clamp(
            0,
            9007199254740991,
          );
        }
        final acknowledged = store.context['diagnostic_acknowledged'] as Map?;
        if (!totals.entries.any(
              (entry) => entry.key != 'snapshot_version' && entry.value != 0,
            ) ||
            totals.entries.every(
              (entry) => acknowledged?[entry.key] == entry.value,
            )) {
          return;
        }
        event = _event(
          'analytics_queue_dropped',
          totals,
          clock().toUtc(),
          null,
        );
        // A reserved context slot cannot itself evict product events. Lost ACKs
        // replay this exact snapshot; totals collected meanwhile wait for the next one.
        await store.updateContext({'diagnostic_pending': event});
      }
      final response = await transport.post('events/batch', {
        'installation_id': _installation,
        'events': [event],
      }, token: _token);
      final accepted = response['accepted_event_ids'];
      if (accepted is! List || !accepted.contains(event['event_id'])) {
        throw const AnalyticsDeliveryException(0);
      }
      await store.updateContext({
        'diagnostic_pending': null,
        'diagnostic_acknowledged': event['payload'],
      });
    } catch (_) {
      await store.count('diagnostic_delivery_failures');
    }
  }

  Future<void> _flushAttribution() async {
    final pending = store.pendingAttribution;
    if (pending == null) return;
    try {
      final raw = pending['raw_payload'] ?? <String, Object?>{};
      if (analyticsJsonSize(raw) > 65536 ||
          pending['blocked_revision'] == pending['revision']) {
        await store.blockAttribution(
          pending['revision'],
          'attribution_oversized',
        );
        if (pending['appsflyer_id'] != null) {
          await transport.post('install-attribution', {
            'installation_id': _installation,
            'appsflyer_id': pending['appsflyer_id'],
            'raw_payload': <String, Object?>{},
          }, token: _token);
          await store.acknowledgeAttributionUid(
            pending['revision'],
            pending['appsflyer_id'],
          );
        }
        return;
      }
      await transport.post('install-attribution', {
        'installation_id': _installation,
        'appsflyer_id': pending['appsflyer_id'],
        'raw_payload': pending['raw_payload'] ?? <String, Object?>{},
      }, token: _token);
      await store.acknowledgeAttribution(pending['revision']);
    } on AnalyticsDeliveryException catch (error) {
      if (error.status == 422 || error.status == 413) {
        await store.blockAttribution(
          pending['revision'],
          'attribution_rejected',
        );
      } else {
        await store.count('attribution_delivery_failures');
      }
    } catch (_) {
      await store.count('attribution_delivery_failures');
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
  }

  /// Capture before opening the store/payment sheet; persist with the purchase.
  Future<Map<String, Object?>?> checkoutContext(
    String productId,
    String expectedUid,
  ) async {
    if (!enabled ||
        !_ready ||
        _contextMismatch ||
        !store.isAvailable ||
        currentUid() != expectedUid) {
      return null;
    }
    try {
      Map<String, Object?>? result;
      await _serial(() async {
        if (currentUid() != expectedUid) return;
        final feature = ProductCatalog.subscriptionIds.contains(productId)
            ? 'subscription'
            : 'stars';
        final key = 'checkout:$feature';
        Map<String, Object?>? read() {
          final context = store.context;
          if (context['attempt_scope'] !=
              '${context['session_id']}:$expectedUid') {
            return null;
          }
          final attempts = context['attempt_ids'] as Map?;
          if (attempts?['$key:claimed'] == true ||
              attempts?['$key:product'] != productId) {
            return null;
          }
          final raw = attempts?['$key:context'];
          return raw is Map ? Map<String, Object?>.from(raw) : null;
        }

        var context = read();
        if (context == null) {
          await _record(
            'checkout_started',
            AnalyticsTaxonomy.sanitize({
              'feature': feature,
              'product_id': productId,
            }),
            clock().toUtc(),
            _identity,
            expectedUid,
            null,
          );
          context = read();
        }
        if (context != null && currentUid() == expectedUid) {
          final attempts = Map<String, Object?>.from(
            store.context['attempt_ids'] as Map,
          );
          attempts['$key:claimed'] = true;
          await store.updateContext({'attempt_ids': attempts});
          result = context;
        }
      });
      return currentUid() == expectedUid ? result : null;
    } catch (_) {
      await reportStorageFailure();
      return null;
    }
  }

  Future<bool> claimFirstUsefulResult() async {
    if (!enabled || !_ready || _contextMismatch || !store.isAvailable) {
      return false;
    }
    return store.claimFirstUsefulResult();
  }
}
