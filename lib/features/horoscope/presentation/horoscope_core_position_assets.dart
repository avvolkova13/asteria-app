const _corePositionAssetsPath = 'assets/images/horoscope/core_positions';

const horoscopeCorePositionVertexAsset = '$_corePositionAssetsPath/vertex.webp';

const _corePositionAssets = <_CorePositionAsset>[
  _CorePositionAsset(
    assetName: 'north_node',
    aliases: ['северн', 'north node', 'rahu', 'раху'],
  ),
  _CorePositionAsset(
    assetName: 'south_node',
    aliases: ['южн', 'south node', 'ketu', 'кету'],
  ),
  _CorePositionAsset(
    assetName: 'fortune',
    aliases: ['колесо фортун', 'part of fortune', 'fortune'],
  ),
  _CorePositionAsset(
    assetName: 'vertex',
    aliases: ['вертекс', 'vertex', 'асцендент', 'ascendant', 'asc'],
  ),
  _CorePositionAsset(assetName: 'sun', aliases: ['солнце', 'sun']),
  _CorePositionAsset(assetName: 'moon', aliases: ['луна', 'moon']),
  _CorePositionAsset(assetName: 'mercury', aliases: ['меркур', 'mercury']),
  _CorePositionAsset(assetName: 'venus', aliases: ['венер', 'venus']),
  _CorePositionAsset(assetName: 'mars', aliases: ['марс', 'mars']),
  _CorePositionAsset(assetName: 'jupiter', aliases: ['юпитер', 'jupiter']),
  _CorePositionAsset(assetName: 'saturn', aliases: ['сатурн', 'saturn']),
  _CorePositionAsset(assetName: 'uranus', aliases: ['уран', 'uranus']),
  _CorePositionAsset(assetName: 'neptune', aliases: ['нептун', 'neptune']),
  _CorePositionAsset(assetName: 'pluto', aliases: ['плутон', 'pluto']),
  _CorePositionAsset(assetName: 'chiron', aliases: ['хирон', 'chiron']),
  _CorePositionAsset(assetName: 'lilith', aliases: ['лилит', 'lilith']),
  _CorePositionAsset(assetName: 'selena', aliases: ['селен', 'selena']),
];

String horoscopeCorePositionAssetFor(String label) {
  final normalizedLabel = _normalizeCorePositionLabel(label);
  for (final asset in _corePositionAssets) {
    if (asset.aliases.any(normalizedLabel.contains)) {
      return '$_corePositionAssetsPath/${asset.assetName}.webp';
    }
  }
  return horoscopeCorePositionVertexAsset;
}

String _normalizeCorePositionLabel(String value) {
  return value.toLowerCase().replaceAll('ё', 'е');
}

class _CorePositionAsset {
  final String assetName;
  final List<String> aliases;

  const _CorePositionAsset({required this.assetName, required this.aliases});
}
