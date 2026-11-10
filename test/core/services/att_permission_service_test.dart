import 'package:asteria_app/core/services/att_permission_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('app_tracking_transparency');

  group('AttPermissionService', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      debugDefaultTargetPlatformOverride = null;
    });

    test('Android => notSupported, never touches the plugin', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      var pluginCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        pluginCalled = true;
        return 0;
      });

      final service = AttPermissionService();
      final status = await service.ensureRequested();

      expect(status, AttStatus.notSupported);
      expect(pluginCalled, isFalse);
    });

    test('iOS with cached authorized status => returns cache, no prompt',
        () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      var requestCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'getTrackingAuthorizationStatus') {
          // 3 => authorized
          return 3;
        }
        if (call.method == 'requestTrackingAuthorization') {
          requestCalled = true;
          return 3;
        }
        return null;
      });

      final service = AttPermissionService();
      final status = await service.ensureRequested();

      expect(status, AttStatus.authorized);
      expect(requestCalled, isFalse);
    });

    test('iOS with cached denied status => returns denied, no prompt',
        () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      var requestCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'getTrackingAuthorizationStatus') {
          // 2 => denied
          return 2;
        }
        if (call.method == 'requestTrackingAuthorization') {
          requestCalled = true;
          return 2;
        }
        return null;
      });

      final service = AttPermissionService();
      final status = await service.ensureRequested();

      expect(status, AttStatus.denied);
      expect(requestCalled, isFalse);
    });

    test(
        'iOS with notDetermined status => requests authorization, returns result',
        () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      var requestCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'getTrackingAuthorizationStatus') {
          // 0 => notDetermined
          return 0;
        }
        if (call.method == 'requestTrackingAuthorization') {
          requestCalled = true;
          // 3 => authorized
          return 3;
        }
        return null;
      });

      final service = AttPermissionService();
      final status = await service.ensureRequested();

      expect(status, AttStatus.authorized);
      expect(requestCalled, isTrue);
    });

    test('iOS exception while requesting => returns notDetermined', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'getTrackingAuthorizationStatus') {
          return 0; // notDetermined
        }
        if (call.method == 'requestTrackingAuthorization') {
          throw PlatformException(code: 'boom');
        }
        return null;
      });

      final service = AttPermissionService();
      final status = await service.ensureRequested();

      expect(status, AttStatus.notDetermined);
    });

    test('currentStatus on Android => notSupported, no plugin call', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      var pluginCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        pluginCalled = true;
        return 0;
      });

      final service = AttPermissionService();
      final status = await service.currentStatus();

      expect(status, AttStatus.notSupported);
      expect(pluginCalled, isFalse);
    });

    test('currentStatus on iOS => maps TrackingStatus to AttStatus', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        if (call.method == 'getTrackingAuthorizationStatus') {
          // 1 => restricted
          return 1;
        }
        return null;
      });

      final service = AttPermissionService();
      final status = await service.currentStatus();

      expect(status, AttStatus.restricted);
    });
  });
}
