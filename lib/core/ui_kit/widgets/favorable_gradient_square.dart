import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class FavorableGradientSquare extends StatelessWidget {
  final String date;
  final String description;
  final String backgroundImage;
  final bool isLeft;
  final bool isRight;
  final double? height;

  const FavorableGradientSquare({
    super.key,
    required this.date,
    required this.description,
    required this.backgroundImage,
    this.height,
    this.isLeft = false,
    this.isRight = false,
  });

  static const double _baseWidth = 133;
  static const double _baseScreenWidth = 390;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.sizeOf(context).width / _baseScreenWidth) * _baseWidth,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: isRight ? 32 : 24,
          right: isLeft ? 32 : 24,
          top: 16,
          bottom: 16,
        ),
        child: Column(
          mainAxisSize: height != null ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: height != null
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: [
            Text(
              date,
              style: context.textTheme.inverseUrbanistSemiBold16,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (height != null)
              Expanded(
                child: Text(
                  description,
                  style: context.textTheme.inverseUrbanistRegular16,
                  textAlign: TextAlign.center,
                  maxLines: null,
                ),
              )
            else
              Text(
                description,
                style: context.textTheme.inverseUrbanistRegular16,
                textAlign: TextAlign.center,
                maxLines: null,
              ),
          ],
        ),
      ),
    );
  }
}
