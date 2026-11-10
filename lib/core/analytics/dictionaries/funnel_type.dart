/// Controlled vocabulary for the `funnel_type` analytics parameter.
///
/// Adapter infers this from the event name for explicit `ast_*` events;
/// UI passes it only for generic events (e.g. `home_card_view/click`).
enum FunnelType {
  compatibility('compatibility'),
  natalChart('natal_chart'),
  sonnik('sonnik'),
  anakra('anakra'),
  tarot('tarot'),
  runes('runes'),
  moon('moon'),
  affirmations('affirmations'),
  subscription('subscription'),
  coins('coins'),
  shop('shop'),
  profile('profile');

  const FunnelType(this.value);

  final String value;
}
