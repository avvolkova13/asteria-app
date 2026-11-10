import 'package:package_info_plus/package_info_plus.dart';

Future<String?> readAnalyticsAppVersion({
  Future<PackageInfo> Function()? load,
}) async {
  try {
    final info = await (load ?? PackageInfo.fromPlatform)().timeout(
      const Duration(seconds: 5),
    );
    if (info.version.isEmpty || info.buildNumber.isEmpty) return null;
    final version = '${info.version}+${info.buildNumber}';
    return version.length <= 64 ? version : null;
  } catch (_) {
    // Missing platform metadata disables collection; never invent a release.
    return null;
  }
}
