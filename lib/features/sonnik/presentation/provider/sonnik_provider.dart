import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:flutter/foundation.dart';

class SonnikProvider extends ChangeNotifier {
  SonnikModel? _selectedSonnik;

  String? _ownerId;

  SonnikModel? selectedSonnikFor(String? ownerId) =>
      ownerId != null && ownerId == _ownerId ? _selectedSonnik : null;

  SonnikModel? get selectedSonnik => _selectedSonnik;

  void selectSonnik(SonnikModel sonnik, {String? ownerId}) {
    _ownerId = ownerId;
    _selectedSonnik = sonnik;
    notifyListeners();
  }

  void clear() {
    _ownerId = null;
    _selectedSonnik = null;
    notifyListeners();
  }
}
