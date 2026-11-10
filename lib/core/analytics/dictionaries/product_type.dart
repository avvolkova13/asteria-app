/// Controlled vocabulary for the `product_type` analytics parameter.
///
/// Used for restore-purchase and product-level reporting.
enum ProductType {
  subscription('subscription'),
  coinPackage('coin_package'),
  requestPack('request_pack');

  const ProductType(this.value);

  final String value;
}
