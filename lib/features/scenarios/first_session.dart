import 'package:asteria_app/core/services/hive/hive_service.dart';

import 'package:hive/hive.dart';

abstract final class FirstSession {
  static Box<Map> get _settings => Hive.box<Map>(HiveBoxNames.appSettings);
  static const path = '/first-session';
  static String _key(String uid) => 'first-session-pending/$uid';
  static bool pending(String uid) =>
      _settings.get(_key(uid))?['pending'] == true;
  static Future<void> begin(String uid) =>
      _settings.put(_key(uid), {'pending': true});
  static Future<void> finish(String uid) => _settings.delete(_key(uid));
}
