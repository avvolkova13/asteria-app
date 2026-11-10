import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/features/compatibility/data/compatibility_selection_store.dart';
import 'package:asteria_app/features/compatibility/presentation/provider/compatibility_provider.dart';

class MemoryCompatibilitySelectionStore implements CompatibilitySelectionStore {
  final _values = <String, String>{};

  @override
  String? read(String userId) => _values[userId];

  @override
  Future<void> write(String userId, String? compatibilityId) async {
    _values[userId] = compatibilityId ?? '';
  }
}

void registerTestCompatibilityProvider(UserProvider user) {
  di.registerSingleton<CompatibilityProvider>(
    CompatibilityProvider(
      userProvider: user,
      store: MemoryCompatibilitySelectionStore(),
    ),
    dispose: (provider) => provider.dispose(),
  );
}
