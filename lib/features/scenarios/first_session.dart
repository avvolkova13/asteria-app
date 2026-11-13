import 'package:asteria_app/core/services/hive/hive_service.dart';

import 'package:hive/hive.dart';

abstract final class FirstSession {
  static Box<Map> get _settings => Hive.box<Map>(HiveBoxNames.appSettings);
  static const path = '/first-session';
  // Introduce the new scenarios once to accounts created before this release.
  // This is a content revision, independent of routine app version updates.
  static const _introVersion = 1;
  static String _key(String uid) => 'first-session-pending/$uid';
  static bool pending(String uid) =>
      _settings.get(_key(uid))?['pending'] == true ||
      _settings.get(_key(uid))?['introVersion'] != _introVersion;
  static Future<void> begin(String uid) =>
      _settings.put(_key(uid), {'pending': true});
  static Future<void> finish(String uid) => _settings.put(_key(uid), {
    'pending': false,
    'introVersion': _introVersion,
  });
}
