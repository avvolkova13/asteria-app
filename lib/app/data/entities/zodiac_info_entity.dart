import 'package:equatable/equatable.dart';

class ZodiacInfoEntity extends Equatable {
  @override
  List<Object?> get props => [
    zodiacAsset,
    birthDate,
    elementString,
    planetString,
    characterString,
  ];

  final String zodiacAsset;
  final DateTime birthDate;
  final String elementString;
  final String planetString;
  final String characterString;

  const ZodiacInfoEntity({
    required this.zodiacAsset,
    required this.birthDate,
    required this.elementString,
    required this.planetString,
    required this.characterString,
  });

  ZodiacInfoEntity copyWith({
    String? zodiacAsset,
    DateTime? birthDate,
    String? elementString,
    String? planetString,
    String? characterString,
  }) {
    return ZodiacInfoEntity(
      zodiacAsset: zodiacAsset ?? this.zodiacAsset,
      birthDate: birthDate ?? this.birthDate,
      elementString: elementString ?? this.elementString,
      planetString: planetString ?? this.planetString,
      characterString: characterString ?? this.characterString,
    );
  }
}
