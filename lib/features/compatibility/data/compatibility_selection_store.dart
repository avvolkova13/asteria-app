import 'package:hive/hive.dart';

abstract interface class CompatibilitySelectionStore {
  /// Null means no saved preference; an empty ID means explicitly reset.
  String? read(String userId);
  Future<void> write(String userId, String? compatibilityId);
}

class HiveCompatibilitySelectionStore implements CompatibilitySelectionStore {
  HiveCompatibilitySelectionStore(this._box);

  final Box<Map> _box;

  String _key(String userId) => 'compatibility_selection:$userId';

  @override
  String? read(String userId) => _box.get(_key(userId))?['id'] as String?;

  @override
  Future<void> write(String userId, String? compatibilityId) =>
      _box.put(_key(userId), {'id': compatibilityId ?? ''});
}
