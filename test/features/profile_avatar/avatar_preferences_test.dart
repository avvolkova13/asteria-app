import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/features/profile_avatar/avatar_catalog.dart';
import 'package:asteria_app/features/profile_avatar/avatar_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog has stable IDs, PNG paths and gender defaults', () {
    expect(AvatarPreset.values.map((preset) => preset.id), [
      'sorceress',
      'sorcerer',
      'unicorn',
      'elf_woman',
      'elf_man',
      'dragon',
      'astrologer',
      'astrologer_woman',
      'phoenix',
    ]);
    for (final preset in AvatarPreset.values) {
      expect(preset.assetPath, 'assets/images/home/avatars/${preset.id}.png');
      expect(AvatarPreset.findById(preset.id), same(preset));
    }
    expect(AvatarPreset.resolve(null, Gender.male).id, 'elf_man');
    expect(AvatarPreset.resolve('missing', Gender.female).id, 'elf_woman');
    expect(AvatarPreset.resolve(null, null).id, 'elf_woman');
    expect(AvatarPreset.resolve('unicorn', Gender.male).id, 'unicorn');
  });

  test('selection persists across preference instances', () async {
    final storage = _MemoryAvatarStorage();
    final preferences = AvatarPreferences(storage: storage);
    addTearDown(preferences.dispose);
    var notifications = 0;
    preferences.addListener(() => notifications += 1);
    await preferences.select('alice', 'phoenix');
    expect(preferences.selectedFor('alice', Gender.female).id, 'phoenix');
    expect(notifications, 1);
    final restored = AvatarPreferences(storage: storage);
    addTearDown(restored.dispose);
    expect(restored.selectedFor('alice', Gender.male).id, 'phoenix');
  });

  test('separates accounts without changing gender defaults', () async {
    final preferences = AvatarPreferences(storage: _MemoryAvatarStorage());
    addTearDown(preferences.dispose);
    await preferences.select('alice', 'dragon');
    expect(preferences.selectedFor('bob', Gender.male).id, 'elf_man');
    await preferences.select('bob', 'astrologer');
    expect(preferences.selectedFor('alice', Gender.female).id, 'dragon');
    expect(preferences.selectedFor('bob', Gender.male).id, 'astrologer');
    expect(preferences.selectedFor(null, Gender.female).id, 'elf_woman');
  });

  test('failed write does not change cached selection or notify', () async {
    final storage = _MemoryAvatarStorage();
    final preferences = AvatarPreferences(storage: storage);
    addTearDown(preferences.dispose);
    await preferences.select('alice', 'unicorn');
    var notifications = 0;
    preferences.addListener(() => notifications += 1);
    storage.failWrites = true;
    await expectLater(preferences.select('alice', 'dragon'), throwsStateError);
    expect(preferences.selectedFor('alice', Gender.female).id, 'unicorn');
    expect(storage.read('alice'), 'unicorn');
    expect(notifications, 0);
  });

  test(
    'unknown persisted IDs fall back and invalid selections never write',
    () async {
      final storage = _MemoryAvatarStorage()..records['alice'] = 'removed';
      final preferences = AvatarPreferences(storage: storage);
      addTearDown(preferences.dispose);
      expect(preferences.selectedFor('alice', Gender.male).id, 'elf_man');
      await expectLater(
        preferences.select('alice', 'missing'),
        throwsArgumentError,
      );
      await expectLater(preferences.select('', 'dragon'), throwsArgumentError);
      expect(storage.records, {'alice': 'removed'});
    },
  );

  test(
    'legacy raven selection resolves to astrologer across instances',
    () async {
      final storage = _MemoryAvatarStorage()..records['alice'] = 'raven';
      final preferences = AvatarPreferences(storage: storage);
      addTearDown(preferences.dispose);
      expect(AvatarPreset.findById('raven')?.id, 'astrologer');
      expect(preferences.selectedFor('alice', Gender.female).id, 'astrologer');
      await preferences.select('alice', 'astrologer');
      expect(storage.read('alice'), 'astrologer');
      final restored = AvatarPreferences(storage: storage);
      addTearDown(restored.dispose);
      expect(restored.selectedFor('alice', Gender.male).id, 'astrologer');
    },
  );

  test('Hive read is safe before initialization', () {
    expect(HiveAvatarStorage().read('alice'), isNull);
  });
}

class _MemoryAvatarStorage implements AvatarStorage {
  final Map<String, String> records = {};
  bool failWrites = false;

  @override
  String? read(String userId) => records[userId];

  @override
  Future<void> write(String userId, String presetId) async {
    if (failWrites) throw StateError('Storage unavailable');
    records[userId] = presetId;
  }
}
