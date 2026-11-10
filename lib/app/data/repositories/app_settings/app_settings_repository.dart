import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:hive/hive.dart';

abstract class AppSettingsRepository {
  bool getDarkMode();

  void setDarkMode(bool isDarkMode);

  bool getShowOnboarding();

  void setShowOnboarding(bool showOnboarding);

  Future<void> clearAllSettings();
}

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  static const String _darkModeKey = 'dark_mode';
  static const String _showOnboardingKey = 'show_onboarding';

  Box<Map> get _box => HiveService.appSettingsBox;

  @override
  bool getDarkMode() {
    final Map<dynamic, dynamic>? result = _box.get(_darkModeKey);
    return result?['value'] as bool? ?? false;
  }

  @override
  void setDarkMode(bool isDarkMode) {
    _box.put(_darkModeKey, {'value': isDarkMode});
  }

  @override
  bool getShowOnboarding() {
    final Map<dynamic, dynamic>? result = _box.get(_showOnboardingKey);
    return result?['value'] as bool? ?? true;
  }

  @override
  void setShowOnboarding(bool showOnboarding) {
    _box.put(_showOnboardingKey, {'value': showOnboarding});
  }

  @override
  Future<void> clearAllSettings() async {
    await _box.clear();
  }
}
