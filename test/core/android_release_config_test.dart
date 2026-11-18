import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release never falls back to the debug signing identity', () {
    final config = File('android/app/build.gradle.kts').readAsStringSync();
    expect(config, isNot(contains('signingConfigs.getByName("debug")')));
    expect(
      config,
      contains('signingConfig = signingConfigs.getByName("release")'),
    );
    expect(config, contains('validateReleaseSigningConfig'));
    expect(config, contains('name == "preReleaseBuild"'));
    expect(config, contains('dependsOn(validateReleaseSigningConfig)'));
    expect(config, contains('check(keystorePropertiesFile.exists())'));
  });
}
