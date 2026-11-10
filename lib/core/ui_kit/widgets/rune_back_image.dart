import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

class RuneBackImage extends StatelessWidget {
  const RuneBackImage({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  static const _sourceWidthScale = 297 / 189;
  static const _sourceHeightScale = 446 / 307;
  static const _sourceLeftScale = -54 / 189;
  static const _sourceTopScale = -69 / 307;

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: width * _sourceLeftScale,
              top: height * _sourceTopScale,
              width: width * _sourceWidthScale,
              height: height * _sourceHeightScale,
              child: Image.asset(
                'assets/images/home/daily_symbol_rune_back.webp',
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return ColoredBox(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: ClayIcon(Icons.image_not_supported, size: 64),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
