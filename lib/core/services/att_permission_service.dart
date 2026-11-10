import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

/// Internal ATT status used by the rest of the app.
///
/// Isolated from the `TrackingStatus` enum exported by the
/// `app_tracking_transparency` package so callers don't have to depend on
/// the underlying SDK type.
enum AttStatus {
  /// Android, iOS < 14, or any other platform where ATT does not apply.
  notSupported,

  /// User has not yet been asked.
  notDetermined,

  /// Restricted by parental controls or MDM.
  restricted,

  /// User explicitly denied tracking.
  denied,

  /// User explicitly authorized tracking.
  authorized,
}

/// Manages the iOS App Tracking Transparency (ATT) consent flow.
///
/// On iOS, shows the native ATT prompt when the status is `notDetermined`
/// and returns the user's choice. On Android (and non-iOS platforms) this
/// is a no-op that returns [AttStatus.notSupported] without touching the
/// underlying plugin.
///
/// Must be invoked once during app initialization, BEFORE
/// `AppsFlyerService.startSDK()`. AppsFlyer's iOS SDK will block on its
/// internal ATT wait timer otherwise (see
/// `AppsFlyerOptions.timeToWaitForATTUserAuthorization`).
///
/// Not to be confused with `AttributionService`, which is a different
/// concern (subscribing to AppsFlyer install/attribution callbacks).
class AttPermissionService {
  /// Hard timeout on `requestTrackingAuthorization()`. The native prompt
  /// is normally blocking and resolves once the user taps, but defensively
  /// we don't want a frozen prompt to halt app initialization forever.
  static const Duration _requestTimeout = Duration(seconds: 10);

  /// Returns the cached/current ATT status without showing any UI.
  Future<AttStatus> currentStatus() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      if (kDebugMode) {
        debugPrint('[AttPermissionService] not supported (non-iOS)');
      }
      return AttStatus.notSupported;
    }

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      final mapped = _map(status);
      if (kDebugMode) {
        debugPrint('[AttPermissionService] currentStatus: $mapped');
      }
      return mapped;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AttPermissionService] currentStatus error: $e');
      }
      return AttStatus.notDetermined;
    }
  }

  /// Ensures the ATT prompt has been requested. On iOS:
  /// - If status is `notDetermined`, shows the native prompt and awaits the result.
  /// - If status is already determined, returns the cached value (no prompt).
  /// - On any error/timeout, returns [AttStatus.notDetermined] and lets
  ///   the rest of the app continue.
  ///
  /// On Android (and other non-iOS platforms), this is a no-op that
  /// returns [AttStatus.notSupported] without calling into the plugin.
  Future<AttStatus> ensureRequested() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      if (kDebugMode) {
        debugPrint('[AttPermissionService] not supported (Android)');
      }
      return AttStatus.notSupported;
    }

    AttStatus current;
    try {
      final raw = await AppTrackingTransparency.trackingAuthorizationStatus;
      current = _map(raw);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AttPermissionService] iOS, reading status failed: $e — '
          'returning notDetermined',
        );
      }
      return AttStatus.notDetermined;
    }

    if (current != AttStatus.notDetermined) {
      if (kDebugMode) {
        debugPrint('[AttPermissionService] cached status: $current');
      }
      return current;
    }

    if (kDebugMode) {
      debugPrint(
        '[AttPermissionService] iOS, status notDetermined, requesting...',
      );
    }

    try {
      final raw = await AppTrackingTransparency.requestTrackingAuthorization()
          .timeout(_requestTimeout);
      final mapped = _map(raw);
      if (kDebugMode) {
        debugPrint('[AttPermissionService] result: $mapped');
      }
      return mapped;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint(
          '[AttPermissionService] requestTrackingAuthorization timed out '
          'after ${_requestTimeout.inSeconds}s — returning notDetermined',
        );
      }
      return AttStatus.notDetermined;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AttPermissionService] requestTrackingAuthorization error: $e — '
          'returning notDetermined',
        );
      }
      return AttStatus.notDetermined;
    }
  }

  AttStatus _map(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.notDetermined:
        return AttStatus.notDetermined;
      case TrackingStatus.restricted:
        return AttStatus.restricted;
      case TrackingStatus.denied:
        return AttStatus.denied;
      case TrackingStatus.authorized:
        return AttStatus.authorized;
      case TrackingStatus.notSupported:
        return AttStatus.notSupported;
    }
  }
}
