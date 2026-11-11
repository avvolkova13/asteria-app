import 'package:asteria_app/core/config/app_feature_visibility.dart';
import 'package:flutter/foundation.dart';

enum GlobalLoaderType { compatibility, horoscope, natalCard, sonnik, insight }

class GlobalLoaderService extends ChangeNotifier {
  bool _isLoading = false;
  GlobalLoaderType? _loaderType;

  bool get isLoading => _isLoading;

  GlobalLoaderType? get loaderType => _loaderType;

  void show() {
    if (_isLoading) return;
    _isLoading = true;
    _loaderType = null;
    notifyListeners();
  }

  void showWithSpheres(GlobalLoaderType type) {
    if (type == GlobalLoaderType.horoscope &&
        !AppFeatureVisibility.horoscopes) {
      return;
    }
    if (_isLoading) return;
    _isLoading = true;
    _loaderType = type;
    notifyListeners();
  }

  void hide() {
    if (!_isLoading) return;
    _isLoading = false;
    _loaderType = null;
    notifyListeners();
  }
}
