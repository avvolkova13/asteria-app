import 'dart:convert';
import 'dart:math';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// The queue, installation credentials, and attribution have separate lifetimes.
class AnalyticsStore {
  AnalyticsStore._(
    this._eventBox,
    this._contextBox,
    this._attributionBox,
    this.maxEvents,
    this.maxBytes,
  ) : _openStore = null;

  AnalyticsStore.deferred({Future<AnalyticsStore> Function()? openStore})
    : _eventBox = null,
      _contextBox = null,
      _attributionBox = null,
      maxEvents = 10000,
      maxBytes = 20 * 1024 * 1024,
      _openStore = openStore ?? (() => AnalyticsStore.open());

  Box<Map>? _eventBox;
  Box<Map>? _contextBox;
  Box<Map>? _attributionBox;
  Box<Map> get _events => _eventBox!;
  Box<Map> get _context => _contextBox!;
  Box<Map> get _attribution => _attributionBox!;
  final Future<AnalyticsStore> Function()? _openStore;
  final _memoryDiagnostics = <String, int>{};
  Future<bool>? _recovering;
  bool get isAvailable =>
      _eventBox?.isOpen == true &&
      _contextBox?.isOpen == true &&
      _attributionBox?.isOpen == true;

  Future<bool> recover() => _recovering ??= Future<bool>.microtask(() async {
    if (isAvailable) return true;
    try {
      final opened = await (_openStore ?? (() => AnalyticsStore.open()))();
      _eventBox = opened._eventBox;
      _contextBox = opened._contextBox;
      _attributionBox = opened._attributionBox;
      if (_memoryDiagnostics.containsKey('storage_open_failures')) {
        await _count('storage_recoveries', 1);
      }
      for (final counter in _memoryDiagnostics.entries) {
        await _count(counter.key, counter.value);
      }
      await _context.flush();
      _memoryDiagnostics.clear();
      return true;
    } catch (_) {
      _eventBox = null;
      _contextBox = null;
      _attributionBox = null;
      _memoryDiagnostics.update(
        'storage_open_failures',
        (n) => n + 1,
        ifAbsent: () => 1,
      );
      return false;
    } finally {
      _recovering = null;
    }
  });
  final int maxEvents;
  final int maxBytes;
  Future<void> _tail = Future.value();

  static Future<AnalyticsStore> open({
    int maxEvents = 10000,
    int maxBytes = 20 * 1024 * 1024,
  }) async {
    return AnalyticsStore._(
      await Hive.openBox<Map>(
        'analytics_events_v1',
        compactionStrategy: (entries, deleted) => deleted > 100,
      ),
      await Hive.openBox<Map>('analytics_context_v1'),
      await Hive.openBox<Map>('analytics_attribution_v1'),
      maxEvents,
      maxBytes,
    );
  }

  Future<T> serial<T>(Future<T> Function() operation) {
    final next = _tail.then((_) => operation());
    _tail = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }

  Map<String, Object?> get context =>
      Map<String, Object?>.from(_contextBox?.get('installation') ?? {});

  Map<String, Object?> get diagnostics => {
    ...Map<String, Object?>.from(_contextBox?.get('diagnostics') ?? {}),
    ..._memoryDiagnostics,
    'storage_available': isAvailable,
    'queued_events': _eventBox?.length ?? 0,
    'queued_bytes': isAvailable ? queuedBytes : 0,
    'attribution_pending': pendingAttribution != null,
    'attribution_blocked':
        _attributionBox?.get('initial')?['blocked_revision'] != null,
  };

  int get queuedBytes => _events.values.fold(
    0,
    (size, entry) => size + utf8.encode(jsonEncode(entry)).length,
  );

  Map<String, Object?>? get pendingAttribution {
    final raw = _attributionBox?.get('initial');
    final pendingUid =
        raw?['appsflyer_id'] != null &&
        raw?['appsflyer_id'] != raw?['acknowledged_uid'];
    return raw == null ||
            raw['revision'] == raw['acknowledged_revision'] ||
            (raw['revision'] == raw['blocked_revision'] && !pendingUid)
        ? null
        : Map<String, Object?>.from(raw);
  }

  Future<void> initialize() => serial(() async {
    if (context.isNotEmpty) return;
    final random = Random.secure();
    await _context.put('installation', {
      'installation_id': const Uuid().v4(),
      'token': base64UrlEncode(List.generate(32, (_) => random.nextInt(256))),
    });
    await _context.flush();
  });

  Future<void> updateContext(Map<String, Object?> changes) => serial(() async {
    await _context.put('installation', {...context, ...changes});
    await _context.flush();
  });

  /// A persisted journal keeps all three Hive boxes on the same installation.
  Future<bool> prepareContext(
    String platform,
    String environment,
  ) => serial(() async {
    var journal = _context.get('production_transition');
    if (journal == null) {
      final saved = context;
      if (saved['platform'] != null && saved['platform'] != platform) {
        return false;
      }
      if (saved['environment'] == environment || saved['environment'] == null) {
        return true;
      }
      if (saved['environment'] != 'test' || environment != 'production') {
        return false;
      }
      final random = Random.secure();
      final attribution = _attribution.get('initial');
      journal = {
        'context': {
          'installation_id': const Uuid().v4(),
          'token': base64UrlEncode(
            List.generate(32, (_) => random.nextInt(256)),
          ),
          'platform': platform,
          'environment': environment,
          // An environment change is not a new physical install.
          'first_open_done': true,
          if (saved['marketing_first_use_done'] == true)
            'marketing_first_use_done': true,
        },
        'attribution': attribution == null
            ? null
            : {
                ...attribution,
                'acknowledged_revision': null,
                'acknowledged_uid': null,
              },
      };
      await _context.put('production_transition', journal);
      await _context.flush();
    }
    final replacement = Map<String, Object?>.from(journal['context'] as Map);
    if (replacement['platform'] != platform ||
        replacement['environment'] != environment) {
      return false;
    }
    // No events may be recorded or sent until the journal is retired.
    await _events.clear();
    await _events.flush();
    if (journal['attribution'] == null) {
      await _attribution.delete('initial');
    } else {
      await _attribution.put(
        'initial',
        Map.from(journal['attribution'] as Map),
      );
    }
    await _attribution.flush();
    await _context.put('installation', replacement);
    await _context.flush();
    await _context.delete('production_transition');
    await _context.flush();
    return true;
  });

  Future<bool> claimFirstUsefulResult() => serial(() async {
    if (context['marketing_first_use_done'] == true) return false;
    await _context.put('installation', {
      ...context,
      'marketing_first_use_done': true,
    });
    await _context.flush();
    return true;
  });

  Future<void> count(String key, [int amount = 1]) {
    if (!isAvailable) {
      _memoryDiagnostics.update(key, (n) => n + amount, ifAbsent: () => amount);
      return Future.value();
    }
    return serial(() => _count(key, amount));
  }

  Future<void> _count(String key, int amount) async {
    final counters = Map<String, Object?>.from(
      _context.get('diagnostics') ?? {},
    );
    counters[key] = (counters[key] as int? ?? 0) + amount;
    await _context.put('diagnostics', counters);
  }

  Future<void> enqueue(Map<String, Object?> event, DateTime now) =>
      serial(() async {
        if (!_events.values.any((e) => e['event_id'] == event['event_id'])) {
          await _events.add(event);
        }
        await _prune(now);
        await _events.flush();
      });

  Future<List<Map<String, Object?>>> batch(DateTime now) => serial(() async {
    await _prune(now);
    return _events.values
        .take(100)
        .map((e) => Map<String, Object?>.from(jsonDecode(jsonEncode(e)) as Map))
        .toList();
  });

  Future<void> acknowledge(Iterable<String> ids) => serial(() async {
    final accepted = ids.toSet();
    await _events.deleteAll(
      _events.keys
          .where((key) => accepted.contains(_events.get(key)?['event_id']))
          .toList(),
    );
    await _events.flush();
  });

  static int _priority(Map event) => switch (event['event_name']) {
    'screen_viewed' || 'onboarding_step_viewed' || 'feature_result_viewed' => 0,
    'first_open' ||
    'auth_result' ||
    'checkout_started' ||
    'checkout_outcome' => 2,
    _ => 1,
  };

  Future<void> _prune(DateTime now) async {
    final expired = _events.keys.where((key) {
      final date = DateTime.tryParse(
        _events.get(key)?['occurred_at'] as String? ?? '',
      );
      return date == null ||
          !date.isAfter(now.subtract(const Duration(days: 7)));
    }).toList();
    if (expired.isNotEmpty) {
      await _events.deleteAll(expired);
      await _count('dropped_expired', expired.length);
    }
    var bytes = queuedBytes;
    final keys = _events.keys.toList()
      ..sort((a, b) {
        final left = _events.get(a)!;
        final right = _events.get(b)!;
        final priority = _priority(left).compareTo(_priority(right));
        return priority != 0 ? priority : (a as int).compareTo(b as int);
      });
    var dropped = 0;
    for (final key in keys) {
      if (_events.length <= maxEvents && bytes <= maxBytes) break;
      bytes -= utf8.encode(jsonEncode(_events.get(key))).length;
      await _events.delete(key);
      dropped++;
    }
    if (dropped > 0) await _count('dropped_overflow', dropped);
    if (dropped > 0 || expired.isNotEmpty) await _events.compact();
  }

  Future<void> saveAttribution({
    String? appsflyerId,
    Map<String, Object?>? rawPayload,
  }) => serial(() async {
    final state = Map<String, Object?>.from(_attribution.get('initial') ?? {});
    // Only the initial conversion callback belongs here, never deep links.
    if (rawPayload != null && !state.containsKey('raw_payload')) {
      state['raw_payload'] = jsonDecode(jsonEncode(rawPayload));
    }
    if (appsflyerId != null && appsflyerId.isNotEmpty) {
      state['appsflyer_id'] = appsflyerId;
    }
    if (jsonEncode(state) == jsonEncode(_attribution.get('initial'))) return;
    await _attribution.put('initial', {
      ...state,
      'revision': const Uuid().v4(),
    });
    await _attribution.flush();
  });

  Future<void> acknowledgeAttribution(Object? revision) => serial(() async {
    if (pendingAttribution?['revision'] != revision) return;
    await _attribution.put('initial', {
      ..._attribution.get('initial')!,
      'acknowledged_revision': revision,
    });
    await _attribution.flush();
  });

  Future<void> blockAttribution(Object? revision, String reason) => serial(
    () async {
      if (pendingAttribution?['revision'] != revision) return;
      if (_attribution.get('initial')?['blocked_revision'] == revision) return;
      await _attribution.put('initial', {
        ..._attribution.get('initial')!,
        'blocked_revision': revision,
        'blocked_reason': reason,
      });
      await _count(reason, 1);
      await _attribution.flush();
    },
  );

  Future<void> acknowledgeAttributionUid(Object? revision, Object? uid) =>
      serial(() async {
        final state = _attribution.get('initial');
        if (state == null || state['revision'] != revision) return;
        await _attribution.put('initial', {...state, 'acknowledged_uid': uid});
        await _attribution.flush();
      });
}
