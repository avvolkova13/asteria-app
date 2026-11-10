import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/compatibility/data/compatibility_selection_store.dart';
import 'package:flutter/foundation.dart';

class CompatibilityProvider extends ChangeNotifier {
  CompatibilityProvider({
    required UserProvider userProvider,
    required CompatibilitySelectionStore store,
  }) : _userProvider = userProvider,
       _store = store {
    _readAccountSelection();
    _userProvider.addListener(_onUserChanged);
  }

  final UserProvider _userProvider;
  final CompatibilitySelectionStore _store;
  String? _userId;
  String? _selectedId;
  bool _disposed = false;

  SavedCompatibilityModel? get selectedCompatibility {
    final history = _userProvider.currentUser?.compatibilityHistory;
    if (history == null || history.isEmpty) return null;
    // Keep the existing preview until the user explicitly selects or resets it.
    if (_selectedId == null) return history.first;
    for (final compatibility in history) {
      if (compatibility.id == _selectedId) return compatibility;
    }
    return null;
  }

  Future<void> selectCompatibility(SavedCompatibilityModel compatibility) =>
      _saveSelection(compatibility.id);

  Future<void> clear() => _saveSelection(null);

  Future<void> _saveSelection(String? id) async {
    final userId = _userId;
    if (userId == null) return;
    await _store.write(userId, id);
    if (_disposed || _userId != userId) return;
    _selectedId = id ?? '';
    notifyListeners();
  }

  void _readAccountSelection() {
    _userId = _userProvider.currentUser?.id;
    final userId = _userId;
    _selectedId = userId == null ? null : _store.read(userId);
  }

  void _onUserChanged() {
    if (_userId != _userProvider.currentUser?.id) _readAccountSelection();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _userProvider.removeListener(_onUserChanged);
    super.dispose();
  }
}
