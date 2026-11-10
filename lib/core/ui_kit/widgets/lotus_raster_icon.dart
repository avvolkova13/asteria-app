import 'package:flutter/widgets.dart';

import 'lotus_glyph_motion.dart';

/// Keeps the original raster layout while giving illustrated UI marks the
/// same tap response and light-preserving tint as their vector counterparts.
class LotusRasterIcon extends StatelessWidget {
  const LotusRasterIcon(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.color,
    this.excludeFromSemantics = false,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) => LotusGlyphMotion(
    child: Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: BlendMode.modulate,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: excludeFromSemantics,
    ),
  );
}
