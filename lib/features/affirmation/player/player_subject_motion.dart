/// The illustration associated with each animated foreground.
enum PlayerSubjectMotion {
  hearts('category_love'),
  birds('category_love_2'),
  envelope('category_love_3'),
  key('category_izobilie'),
  coins('category_izobilie_2'),
  pomegranate('category_izobilie_3'),
  mountain('category_power'),
  lion('category_power_2'),
  sunInHand('category_power_3'),
  palette('category_creative'),
  quill('category_creative_2'),
  book('category_creative_3'),
  moonClouds('category_moon'),
  fullMoon('category_moon_2'),
  orb('category_moon_3'),
  lotus('category_calm'),
  stones('category_calm_2'),
  lunarRibbons('category_calm_3'),
  morning('hand_with_star'),
  workday('workday-is-over'),
  sleep('time-for-sleep'),
  breathing('easy-breathing-rhythm'),
  feather('gentle-exhale'),
  shaking('shake-off-the-day'),
  massage('feel-the-difference'),
  cloudHands('cloud-hands'),
  boards('sadhu-board');

  const PlayerSubjectMotion(this.assetName);

  final String assetName;

  static final _byAsset = {
    for (final motion in values) motion.assetName: motion,
  };

  static PlayerSubjectMotion? forAsset(String? asset) {
    if (asset == null) return null;
    final name = asset.split('/').last;
    return _byAsset[name.replaceFirst('.webp', '')];
  }

  bool get isAffirmation => assetName.startsWith('category_');
}
