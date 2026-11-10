import 'dart:io';

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/compatibility/data/compatibility_selection_store.dart';
import 'package:asteria_app/features/compatibility/presentation/provider/compatibility_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../support/compatibility_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Box<Map> box;
  late UserProvider user;
  late CompatibilityProvider provider;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'compatibility-selection-',
    );
    box = await Hive.openBox<Map>('selection', path: directory.path);
    user = UserProvider(userRepository: _UnusedRepository());
    user.applyServerUserSnapshot(
      UserModel.empty().copyWith(
        id: 'a',
        compatibilityHistory: [
          savedCompatibility(),
          savedCompatibility(id: 'older'),
        ],
      ),
    );
    provider = CompatibilityProvider(
      userProvider: user,
      store: HiveCompatibilitySelectionStore(box),
    );
  });
  tearDown(() async {
    provider.dispose();
    user.dispose();
    await box.close();
    await directory.delete(recursive: true);
  });

  test(
    'reset survives profile refresh and reopening storage without deleting history',
    () async {
      expect(provider.selectedCompatibility?.id, 'recent');
      await provider.clear();
      user.applyServerUserSnapshot(user.currentUser!);
      expect(provider.selectedCompatibility, isNull);
      expect(user.currentUser!.compatibilityHistory, hasLength(2));
      provider.dispose();
      await box.close();
      box = await Hive.openBox<Map>('selection', path: directory.path);
      provider = CompatibilityProvider(
        userProvider: user,
        store: HiveCompatibilitySelectionStore(box),
      );
      expect(provider.selectedCompatibility, isNull);
    },
  );

  test(
    'old selection persists and a new calculation can replace it after reset',
    () async {
      await provider.selectCompatibility(
        user.currentUser!.compatibilityHistory.last,
      );
      expect(provider.selectedCompatibility?.id, 'older');
      provider.dispose();
      provider = CompatibilityProvider(
        userProvider: user,
        store: HiveCompatibilitySelectionStore(box),
      );
      expect(provider.selectedCompatibility?.id, 'older');
      await provider.clear();
      final result = savedCompatibility(id: 'new');
      user.applyServerUserSnapshot(
        user.currentUser!.copyWith(
          compatibilityHistory: [
            result,
            ...user.currentUser!.compatibilityHistory,
          ],
        ),
      );
      expect(provider.selectedCompatibility, isNull);
      await provider.selectCompatibility(result);
      expect(provider.selectedCompatibility?.id, 'new');
      expect(user.currentUser!.compatibilityHistory, hasLength(3));
    },
  );

  test('accounts have independent selections', () async {
    final accountA = user.currentUser!;
    await provider.clear();
    user.applyServerUserSnapshot(accountA.copyWith(id: 'b'));
    expect(provider.selectedCompatibility?.id, 'recent');
    await provider.selectCompatibility(accountA.compatibilityHistory.last);
    user.applyServerUserSnapshot(accountA);
    expect(provider.selectedCompatibility, isNull);
    user.applyServerUserSnapshot(accountA.copyWith(id: 'b'));
    expect(provider.selectedCompatibility?.id, 'older');
  });

  test(
    'deleted selected record is not replaced by another history entry',
    () async {
      await provider.selectCompatibility(
        user.currentUser!.compatibilityHistory.last,
      );
      user.applyServerUserSnapshot(
        user.currentUser!.copyWith(
          compatibilityHistory: [savedCompatibility()],
        ),
      );
      expect(provider.selectedCompatibility, isNull);
    },
  );

  test('write failure preserves selection and reaches the caller', () async {
    await box.close();
    await expectLater(provider.clear(), throwsA(isA<HiveError>()));
    expect(provider.selectedCompatibility?.id, 'recent');
  });
}

class _UnusedRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
