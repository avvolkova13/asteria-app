/// Controlled vocabulary for the `offer_type` analytics parameter.
///
/// Describes what we sell on a paywall / purchase event.
enum OfferType {
  subscription('subscription'),
  requestPack('request_pack'),
  coinPackage('coin_package'),
  oneOffUnlock('one_off_unlock'),
  shopItem('shop_item'),
  proUnlock('pro_unlock');

  const OfferType(this.value);

  final String value;
}
