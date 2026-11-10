import 'package:asteria_app/core/analytics/durable/analytics_app_version.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  test(
    'reads installed package version and build rather than a release literal',
    () async {
      PackageInfo.setMockInitialValues(
        appName: 'Asteria',
        packageName: 'test.asteria',
        version: '2.7.3',
        buildNumber: '108',
        buildSignature: '',
      );
      expect(await readAnalyticsAppVersion(), '2.7.3+108');
    },
  );
  test('missing metadata does not fabricate a version', () async {
    expect(
      await readAnalyticsAppVersion(
        load: () async => throw MissingPluginException(),
      ),
      isNull,
    );
    expect(
      await readAnalyticsAppVersion(
        load: () async => PackageInfo(
          appName: '',
          packageName: '',
          version: '',
          buildNumber: '',
        ),
      ),
      isNull,
    );
  });
}
