class YearAnimalAsset {
  static const _basePath = 'assets/images/year_animals';

  static const _assetsByCycleIndex = <String>[
    '$_basePath/rat.webp',
    '$_basePath/ox.webp',
    '$_basePath/tiger.webp',
    '$_basePath/rabbit.webp',
    '$_basePath/dragon.webp',
    '$_basePath/snake.webp',
    '$_basePath/horse.webp',
    '$_basePath/goat.webp',
    '$_basePath/monkey.webp',
    '$_basePath/rooster.webp',
    '$_basePath/dog.webp',
    '$_basePath/pig.webp',
  ];

  static String forYear(int year) {
    return _assetsByCycleIndex[(year - 4) % _assetsByCycleIndex.length];
  }
}
