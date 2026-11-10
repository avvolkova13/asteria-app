import 'dart:async';
import 'dart:collection';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:asteria_app/core/analytics/apps_flyer_events.dart';
import 'package:asteria_app/core/environment/environment.dart';
import 'package:flutter/foundation.dart';

/// Internal record for a single event held in [AppsFlyerService._pending].
class _PendingEvent {
  _PendingEvent(this.name, this.params, this.enqueuedAt);

  final String name;
  final Map<String, dynamic>? params;
  final DateTime enqueuedAt;
}

class AppsFlyerService {
  AppsFlyerService(this._environment);

  final Environment _environment;
  AppsflyerSdk? _appsflyerSdk;
  bool _isSdkConfigured = false;
  bool _isStarted = false;

  /// Set when initialization decided not to configure the SDK at all
  /// (missing/invalid Apple App ID, missing API key, exception during
  /// `initSdk`). Distinct from `_droppedDueToTimeout`: this means the
  /// SDK will never be alive in this session, so `logEvent` must drop
  /// events immediately instead of buffering them forever.
  bool _isDisabled = false;

  /// FIFO buffer for events that arrive before [initialize] and until
  /// the SDK's `onSuccess` callback. Without this, callers like
  /// `AnalyticsFacade` and `ProductAnalyticsService` lose every event
  /// fired during the (potentially multi-second) ATT + start window.
  final Queue<_PendingEvent> _pending = Queue<_PendingEvent>();

  /// Hard cap on the buffer. At overflow we drop the oldest event so we
  /// never grow unbounded if the SDK never starts.
  static const int _maxPendingEvents = 100;

  /// Apple App ID format expected by AppsFlyer iOS SDK. Mirrors the
  /// regex inside `appsflyer_sdk` (the one that fires the assertion on
  /// bundle-id-shaped input). We validate locally to fail with a clear
  /// message instead of an opaque SDK assert.
  static final RegExp _appleAppIdRegExp = RegExp(r'^\d{8,11}$');

  /// If the SDK hasn't called `onSuccess` within this window after the
  /// first queued event or [initialize], whichever happens first, we drop
  /// buffered events and stop buffering further ones. Prevents events from
  /// sitting in memory forever when the SDK fails silently.
  static const Duration _watchdogDuration = Duration(seconds: 60);

  Timer? _watchdog;

  /// Set once the watchdog has fired and dropped pending events. Further
  /// `logEvent` calls before `_isStarted` will be dropped immediately
  /// rather than re-enqueued (the SDK is presumed dead).
  bool _droppedDueToTimeout = false;

  bool get isInitialized => _isStarted;

  /// Configures the AppsFlyer SDK without starting it.
  ///
  /// Split from [startSDK] so that [AttributionService] (or any other
  /// listener) can register callbacks via [onInstallConversionData] /
  /// [onAppOpenAttribution] / [onDeepLinking] before the SDK begins to
  /// emit events. Without this, the very first install conversion
  /// payload can be lost on a cold start.
  Future<void> initialize() async {
    if (_isSdkConfigured) {
      return;
    }
    if (_isDisabled) {
      return;
    }

    final String apiKey;
    try {
      apiKey = _environment.appsflyerApiKey;
    } on Exception {
      if (kDebugMode) {
        debugPrint('[AppsFlyer] disabled: APPSFLYER_API_KEY is not set');
      }
      _isDisabled = true;
      _dropPending('SDK disabled');
      return;
    }

    final String appId;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosAppId = _environment.appsflyerIosAppId;
      if (iosAppId == null) {
        if (kDebugMode) {
          debugPrint('[AppsFlyer] disabled: APPSFLYER_IOS_APP_ID is not set');
        }
        _isDisabled = true;
        _dropPending('SDK disabled');
        return;
      }
      if (!_appleAppIdRegExp.hasMatch(iosAppId)) {
        if (kDebugMode) {
          debugPrint(
            '[AppsFlyer] disabled: APPSFLYER_IOS_APP_ID has invalid '
            'format (expected 8-11 digits, got "$iosAppId")',
          );
        }
        _isDisabled = true;
        _dropPending('SDK disabled');
        return;
      }
      appId = iosAppId;
    } else {
      appId = 'com.finext.asteria';
    }

    try {
      final AppsFlyerOptions options = AppsFlyerOptions(
        afDevKey: apiKey,
        appId: appId,
        // Native debug output may contain attribution payloads and credentials.
        showDebug: false,
        // We now drive the ATT prompt ourselves from Dart via
        // AttPermissionService BEFORE startSDK. AppsFlyer's own wait
        // timer would just block startup for nothing.
        timeToWaitForATTUserAuthorization: 0,
        manualStart: true,
      );

      _appsflyerSdk = AppsflyerSdk(options);

      await _appsflyerSdk!.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true,
      );

      _isSdkConfigured = true;

      // Start watchdog. `??=` protects against double-init on hot
      // restart leaving two timers running.
      _watchdog ??= Timer(_watchdogDuration, _onWatchdogExpired);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting up AppsFlyer');
      }
      // initSdk threw (or the constructor's assert fired in debug).
      // Mark disabled so logEvent doesn't keep buffering events into a
      // queue that will never flush.
      _isDisabled = true;
      _dropPending('SDK disabled');
    }
  }

  /// Starts the SDK. Must be called after [initialize] and after any
  /// callback subscriptions are in place.
  void startSDK() {
    if (_isDisabled) return;
    if (!_isSdkConfigured || _appsflyerSdk == null) return;
    if (_isStarted) return;

    _appsflyerSdk!.startSDK(
      onSuccess: () {
        _isStarted = true;
        if (kDebugMode) {
          debugPrint('AppsFlyer SDK initialized successfully.');
        }
        _flushPendingEvents();
      },
      onError: (int errorCode, String errorMessage) {
        if (kDebugMode) {
          debugPrint('Error initializing AppsFlyer SDK: Code $errorCode');
        }
        _dropPending('startSDK error: $errorCode');
      },
    );
  }

  void onInstallConversionData(void Function(dynamic data) callback) {
    _appsflyerSdk?.onInstallConversionData(callback);
  }

  void onAppOpenAttribution(void Function(dynamic data) callback) {
    _appsflyerSdk?.onAppOpenAttribution(callback);
  }

  void onDeepLinking(void Function(DeepLinkResult result) callback) {
    _appsflyerSdk?.onDeepLinking(callback);
  }

  Future<String?> getAppsFlyerUid() async {
    if (_appsflyerSdk == null) return null;
    try {
      return await _appsflyerSdk!.getAppsFlyerUID();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppsFlyer: Error getting UID');
      }
      return null;
    }
  }

  Future<bool?> logEvent(
    String eventName,
    Map<String, dynamic>? eventValues,
  ) async {
    if (!AppsFlyerEvents.names.contains(eventName)) return false;
    eventValues = AppsFlyerEvents.sanitize(eventValues ?? {});
    if (_isDisabled) {
      // SDK will never be alive this session — drop instead of buffering
      // forever (the previous behavior spammed `event queued` until the
      // 100-event cap was hit).
      return false;
    }
    if (_isStarted && _appsflyerSdk != null) {
      try {
        return await _appsflyerSdk!.logEvent(eventName, eventValues);
      } on Exception {
        if (kDebugMode) {
          debugPrint('AppsFlyer: Error logging event');
        }
        return null;
      }
    }

    // Not started yet. Either buffer or drop.
    if (_droppedDueToTimeout) {
      if (kDebugMode) {
        debugPrint('AppsFlyer: Cannot log event - SDK not started');
      }
      return false;
    }

    // Buffer the event so it can be flushed once onSuccess fires.
    _watchdog ??= Timer(_watchdogDuration, _onWatchdogExpired);
    if (_pending.length >= _maxPendingEvents) {
      final dropped = _pending.removeFirst();
      if (kDebugMode) {
        debugPrint('[AppsFlyer] buffer full, dropping oldest: ${dropped.name}');
      }
    }
    _pending.add(_PendingEvent(eventName, eventValues, DateTime.now()));
    if (kDebugMode) {
      debugPrint('[AppsFlyer] event queued: $eventName');
    }
    return false;
  }

  void setCustomerUserId(String userId) {
    if (_appsflyerSdk == null) return;
    try {
      _appsflyerSdk!.setCustomerUserId(userId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppsFlyer: Error setting customer user id');
      }
    }
  }

  /// Dispatch [_pending] in FIFO order through the guarded [logEvent].
  /// Each native response is handled independently, so a failed or slow
  /// event cannot block the remaining queue or leak an async exception.
  void _flushPendingEvents() {
    _watchdog?.cancel();
    _watchdog = null;
    if (_pending.isEmpty) return;
    if (kDebugMode) {
      debugPrint('[AppsFlyer] flushing ${_pending.length} pending events');
    }
    while (_pending.isNotEmpty) {
      final e = _pending.removeFirst();
      unawaited(logEvent(e.name, e.params));
    }
  }

  /// Called by the watchdog timer if the SDK never reached onSuccess
  /// within [_watchdogDuration]. Drops pending events and marks the
  /// service so further calls before start (if start eventually does
  /// happen) are not re-queued.
  void _onWatchdogExpired() {
    if (_isStarted) return;
    if (_pending.isEmpty) {
      _droppedDueToTimeout = true;
      return;
    }
    if (kDebugMode) {
      debugPrint(
        '[AppsFlyer] watchdog: SDK did not start within '
        '${_watchdogDuration.inSeconds}s, dropping ${_pending.length} '
        'pending events',
      );
    }
    _pending.clear();
    _droppedDueToTimeout = true;
  }

  /// Drops queued events when initialization disables the SDK or start fails.
  void _dropPending(String reason) {
    _watchdog?.cancel();
    _watchdog = null;
    if (_pending.isNotEmpty && kDebugMode) {
      debugPrint(
        '[AppsFlyer] dropping ${_pending.length} pending events ($reason)',
      );
    }
    _pending.clear();
  }
}
