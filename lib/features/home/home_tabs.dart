/// Stable semantic names for the current navigation order.
abstract final class HomeTabs {
  static const today = 0;
  static const calendar = 1;
  static const practices = 2;
  static const readings = 3;

  /// Preserve historical analytics identities when the visible tabs move.
  static const analyticsScreens = [
    '/home',
    '/home/moon',
    '/home/practices',
    '/home/personal',
  ];
}
