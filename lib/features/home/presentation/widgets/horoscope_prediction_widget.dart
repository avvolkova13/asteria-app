import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class HoroscopePredictionWidget extends StatelessWidget {
  final String category;
  final String prediction;
  final String assetImage;
  const HoroscopePredictionWidget({
    Key? key,
    required this.category,
    required this.prediction,
    required this.assetImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AppColors.cardTinted,
      ),
      child: Stack(
        children: [
          // Основной контент с текстом
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: context.textTheme.playfairSemiBold24),
                const SizedBox(height: 16),
                Text(prediction, style: context.textTheme.urbanistRegular16),
              ],
            ),
          ),
          // Изображение в правом верхнем углу
          Positioned(
            top: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(4),
              ),
              child: Image.asset(
                'assets/images/prediction_images/$assetImage.webp',
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
