import 'package:asteria_app/app/data/models/user/user_model.dart';

/// Stable avatar identities, independent of personal profile information.
class AvatarPreset {
  const AvatarPreset({required this.id, required this.name});

  final String id;
  final String name;

  String get assetPath => 'assets/images/home/avatars/$id.png';

  static const List<AvatarPreset> values = [
    AvatarPreset(id: 'sorceress', name: 'Волшебница'),
    AvatarPreset(id: 'sorcerer', name: 'Волшебник'),
    AvatarPreset(id: 'unicorn', name: 'Единорог'),
    AvatarPreset(id: 'elf_woman', name: 'Эльфийка'),
    AvatarPreset(id: 'elf_man', name: 'Эльф'),
    AvatarPreset(id: 'dragon', name: 'Дракон'),
    AvatarPreset(id: 'astrologer', name: 'Астролог'),
    AvatarPreset(id: 'phoenix', name: 'Феникс'),
  ];

  static AvatarPreset? findById(String? id) {
    // Preserve existing device-local selections after retiring the raven.
    final canonicalId = id == 'raven' ? 'astrologer' : id;
    for (final preset in values) {
      if (preset.id == canonicalId) return preset;
    }
    return null;
  }

  static AvatarPreset resolve(String? id, Gender? gender) {
    return findById(id) ?? values[gender == Gender.male ? 4 : 3];
  }
}
