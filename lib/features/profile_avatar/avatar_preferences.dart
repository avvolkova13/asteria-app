import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:asteria_app/features/profile_avatar/avatar_catalog.dart';
import 'package:flutter/foundation.dart';

abstract interface class AvatarStorage {
  String? read(String userId);
  Future<void> write(String userId, String presetId);
}

class HiveAvatarStorage implements AvatarStorage {
  @override
  String? read(String userId) {
    try {
      final value = HiveService.appSettingsBox.get('profile_avatar:$userId');
      final presetId = value?['preset_id'];
      return presetId is String ? presetId : null;
    } catch (_) {
      // Widget previews can build before Hive has been initialized.
      return null;
    }
  }

  @override
  Future<void> write(String userId, String presetId) {
    return HiveService.appSettingsBox.put('profile_avatar:$userId', {
      'preset_id': presetId,
    });
  }
}

/// Device-local avatar choices, isolated by account and never sent as gender.
class AvatarPreferences extends ChangeNotifier {
  AvatarPreferences({AvatarStorage? storage})
    : _storage = storage ?? HiveAvatarStorage();

  static final AvatarPreferences instance = AvatarPreferences();

  final AvatarStorage _storage;
  final Map<String, String> _selectedIds = {};

  AvatarPreset selectedFor(String? userId, Gender? gender) {
    if (userId == null || userId.trim().isEmpty) {
      return AvatarPreset.resolve(null, gender);
    }
    final id = _selectedIds[userId] ?? _storage.read(userId);
    final preset = AvatarPreset.findById(id);
    if (preset != null) _selectedIds[userId] = preset.id;
    return preset ?? AvatarPreset.resolve(null, gender);
  }

  Future<void> select(String userId, String presetId) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'An account is required');
    }
    if (AvatarPreset.findById(presetId) == null) {
      throw ArgumentError.value(presetId, 'presetId', 'Unknown avatar preset');
    }
    await _storage.write(userId, presetId);
    _selectedIds[userId] = presetId;
    notifyListeners();
  }
}
