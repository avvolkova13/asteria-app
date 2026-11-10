import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:flutter/foundation.dart';

class SonnikProvider extends ChangeNotifier {
  SonnikModel? _selectedSonnik;

  SonnikModel? get selectedSonnik => _selectedSonnik;

  void selectSonnik(SonnikModel sonnik) {
    _selectedSonnik = sonnik;
    notifyListeners();
  }

  void clear() {
    _selectedSonnik = null;
    notifyListeners();
  }
}
