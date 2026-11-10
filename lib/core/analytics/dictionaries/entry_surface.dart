/// Controlled vocabulary for `entry_surface` / `origin_surface` analytics
/// parameters.
///
/// `entry_surface` — первая точка входа в текущий funnel.
/// `origin_surface` — предыдущий экран перед текущим действием (важен для
/// paywall / payment событий).
enum EntrySurface {
  home('home'),
  landing('landing'),
  profile('profile'),
  push('push'),
  deepLink('deep_link'),
  appStore('app_store'),
  shop('shop'),
  anakra('anakra'),
  unknown('unknown');

  const EntrySurface(this.value);

  final String value;
}
