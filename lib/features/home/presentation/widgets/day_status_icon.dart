import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/models/day_status_assets.dart';
import 'package:flutter/material.dart';

class DayStatusIcon extends StatelessWidget {
  const DayStatusIcon({
    super.key,
    required this.status,
    required this.size,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  final DayStatus status;
  final double size;
  final String? semanticLabel;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();
    final image = Image.asset(
      status.iconAssetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      cacheWidth: cacheSize,
      cacheHeight: cacheSize,
      semanticLabel: semanticLabel,
    );

    return SizedBox(
      width: size,
      height: size,
      child: excludeFromSemantics ? ExcludeSemantics(child: image) : image,
    );
  }
}
