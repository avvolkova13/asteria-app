import 'dart:async';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:asteria_app/core/analytics/attribution/attribution_snapshot.dart';
import 'package:asteria_app/core/analytics/durable/durable_analytics.dart';
import 'package:asteria_app/core/services/apps_flyer_service.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Listens to AppsFlyer attribution callbacks, normalizes them into a
/// stable [AttributionSnapshot], and persists the result.
///
/// Two persisted records:
/// - `first_touch_snapshot` — written once on the first conversion payload
///   we receive after install. Never overwritten afterwards.
/// - `current_snapshot` — last known attribution. Overwritten on
///   re-engagement / deep link / re-attribution.
///
/// The service must be initialized **after** [AppsFlyerService.initialize]
/// (so the SDK exists) but **before** [AppsFlyerService.startSDK] — that
/// way the very first install conversion callback is not lost.
class AttributionService {
  AttributionService(
    this._appsFlyerService, {
    DurableAnalytics? analytics,
    Box<Map>? box,
  }) : _analytics = analytics,
       _box = box;

  static const String _firstTouchKey = 'first_touch_snapshot';
  static const String _currentKey = 'current_snapshot';

  final AppsFlyerService _appsFlyerService;
  final DurableAnalytics? _analytics;
  Future<void> _pendingWrites = Future.value();
  Future<void> get pendingWrites => _pendingWrites;
  Timer? _uidRetry;
  Future<void>? _uidRequest;

  Box<Map>? _box;
  AttributionSnapshot? _firstTouchSnapshot;
  AttributionSnapshot? _currentSnapshot;
  String? _appsflyerId;

  final StreamController<AttributionSnapshot?> _controller =
      StreamController<AttributionSnapshot?>.broadcast();

  bool _initialized = false;

  AttributionSnapshot? get currentSnapshot => _currentSnapshot;
  AttributionSnapshot? get firstTouchSnapshot => _firstTouchSnapshot;
  Stream<AttributionSnapshot?> get snapshotStream => _controller.stream;

  /// Loads any persisted snapshot from Hive and registers AppsFlyer
  /// callbacks.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _box ??= HiveService.attributionBox;
    _firstTouchSnapshot = _readSnapshot(_firstTouchKey);
    _currentSnapshot = _readSnapshot(_currentKey) ?? _firstTouchSnapshot;

    _appsFlyerService.onInstallConversionData((data) {
      _handlePayload(data, source: 'install_conversion');
    });
    _appsFlyerService.onAppOpenAttribution((data) {
      _handlePayload(data, source: 'app_open_attribution');
    });
    _appsFlyerService.onDeepLinking(_handleDeepLink);

    // appsflyer UID becomes available shortly after startSDK; fetch in
    // the background so it can be merged into snapshots.
    unawaited(refreshUid());
    _uidRetry = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_appsflyerId == null) unawaited(refreshUid());
    });
  }

  Future<void> refreshUid() => _uidRequest ??= _resolveAppsflyerId()
      .whenComplete(() => _uidRequest = null);

  Future<void> _resolveAppsflyerId() async {
    try {
      final uid = await _appsFlyerService.getAppsFlyerUid();
      if (uid == null || uid.isEmpty) return;
      await _analytics?.attribution(appsflyerId: uid);
      _appsflyerId = uid;
      if (_currentSnapshot != null && _currentSnapshot!.appsflyerId != uid) {
        _currentSnapshot = _currentSnapshot!.copyWith(appsflyerId: uid);
        await _persist(_currentKey, _currentSnapshot!);
        _controller.add(_currentSnapshot);
      }
      if (_firstTouchSnapshot != null &&
          _firstTouchSnapshot!.appsflyerId == null) {
        _firstTouchSnapshot = _firstTouchSnapshot!.copyWith(appsflyerId: uid);
        await _persist(_firstTouchKey, _firstTouchSnapshot!);
      }
    } catch (_) {
      await _analytics?.reportStorageFailure();
    }
  }

  void _handlePayload(dynamic raw, {required String source}) {
    final payload = _extractDataMap(raw);
    if (payload == null || payload.isEmpty) return;
    if (raw is Map && raw['status'] == 'failure') return;
    final initialConversion = source == 'install_conversion';
    if (initialConversion && raw is Map) {
      final fullPayload = Map<String, Object?>.from(raw);
      _pendingWrites = _pendingWrites.then((_) async {
        try {
          await _analytics?.attribution(rawPayload: fullPayload);
        } catch (_) {
          await _analytics?.reportStorageFailure();
        }
      });
    }
    final snapshot = AttributionSnapshot.fromAppsFlyerPayload(
      payload,
      appsflyerId: _appsflyerId,
    );
    _queueSnapshot(snapshot, initialConversion: initialConversion);
  }

  void _handleDeepLink(DeepLinkResult result) {
    if (result.status != Status.FOUND) return;
    final clickEvent = result.deepLink?.clickEvent;
    if (clickEvent == null || clickEvent.isEmpty) return;

    final snapshot = AttributionSnapshot.fromAppsFlyerPayload(
      clickEvent,
      appsflyerId: _appsflyerId,
    );
    _queueSnapshot(snapshot, initialConversion: false);
  }

  void _queueSnapshot(
    AttributionSnapshot snapshot, {
    required bool initialConversion,
  }) {
    _pendingWrites = _pendingWrites.then((_) async {
      try {
        await _applySnapshot(snapshot, initialConversion: initialConversion);
      } catch (_) {
        await _analytics?.reportStorageFailure();
      }
    });
  }

  Future<void> _applySnapshot(
    AttributionSnapshot incoming, {
    required bool initialConversion,
  }) async {
    if (incoming.isEmpty) return;

    if (initialConversion && _firstTouchSnapshot == null) {
      _firstTouchSnapshot = incoming;
      await _persist(_firstTouchKey, incoming);
    }

    final merged = _firstTouchSnapshot != null
        ? _firstTouchSnapshot!.mergeLastTouch(incoming)
        : incoming;
    _currentSnapshot = merged;
    await _persist(_currentKey, merged);
    _controller.add(merged);
  }

  /// Updates the persisted snapshot's `customer_user_id` once the user
  /// has signed up / logged in.
  Future<void> attachCustomerUserId(String customerUserId) async {
    if (customerUserId.isEmpty) return;

    if (_firstTouchSnapshot != null &&
        _firstTouchSnapshot!.customerUserId == null) {
      _firstTouchSnapshot = _firstTouchSnapshot!.copyWith(
        customerUserId: customerUserId,
      );
      await _persist(_firstTouchKey, _firstTouchSnapshot!);
    }
    if (_currentSnapshot != null) {
      _currentSnapshot = _currentSnapshot!.copyWith(
        customerUserId: customerUserId,
      );
      await _persist(_currentKey, _currentSnapshot!);
      _controller.add(_currentSnapshot);
    }
  }

  /// Updates `last_touch_at` to now without changing other fields.
  /// Useful for app open / login flows where we want to keep
  /// re-engagement timestamps fresh even without new attribution data.
  Future<void> markTouch() async {
    if (_currentSnapshot == null) return;
    final updated = _currentSnapshot!.copyWith(lastTouchAt: DateTime.now());
    _currentSnapshot = updated;
    await _persist(_currentKey, updated);
    _controller.add(updated);
  }

  AttributionSnapshot? _readSnapshot(String key) {
    final box = _box;
    if (box == null) return null;
    final raw = box.get(key);
    if (raw == null) return null;
    try {
      return AttributionSnapshot.fromJson(Map<String, dynamic>.from(raw));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AttributionService] Failed to decode snapshot');
      }
      return null;
    }
  }

  Future<void> _persist(String key, AttributionSnapshot snapshot) async {
    final box = _box;
    if (box == null) return;
    await box.put(key, snapshot.toJson());
  }

  /// AppsFlyer wraps the actual data in different envelopes depending on
  /// the callback. Normalize to a flat `Map<String, dynamic>`.
  Map<String, dynamic>? _extractDataMap(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      for (final key in ['data', 'payload']) {
        final inner = map[key];
        if (inner is Map) {
          return Map<String, dynamic>.from(inner);
        }
      }
      return map;
    }
    return null;
  }

  Future<void> dispose() async {
    _uidRetry?.cancel();
    await _uidRequest;
    await _pendingWrites;
    await _controller.close();
  }
}
