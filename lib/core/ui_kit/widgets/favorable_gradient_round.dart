import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class FavorableGradientRound extends StatelessWidget {
  final String date;
  final String description;
  final String backgroundImage;

  const FavorableGradientRound({
    required this.date,
    required this.description,
    required this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 133,
      height: 133,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(100),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Дата
            Text(
              date,
              style: context.textTheme.inverseUrbanistSemiBold16,
              textAlign: TextAlign.center,
            ),
            // Описание
            SizedBox(
              child: Text(
                description,
                style: context.textTheme.inverseUrbanistRegular16,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
