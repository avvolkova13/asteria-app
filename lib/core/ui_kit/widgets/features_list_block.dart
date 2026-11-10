import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class FeaturesListBlock extends StatelessWidget {
  final String headerText;
  final String title1;
  final String description1;
  final String title2;
  final String description2;
  final String title3;
  final String description3;

  const FeaturesListBlock({
    Key? key,
    required this.headerText,
    required this.title1,
    required this.description1,
    required this.title2,
    required this.description2,
    required this.title3,
    required this.description3,
  }) : super(key: key);

  Widget _buildFeatureItem(BuildContext context, String title, String description) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: title, style: context.textTheme.urbanistSemiBold16),
          TextSpan(text: description, style: context.textTheme.urbanistRegular16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColors.cardTinted),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(headerText, style: context.textTheme.playfairMedium20),
              Image.asset('assets/icons/circular_icons.png', height: 32),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(context, title1, description1),
          const SizedBox(height: 8),
          _buildFeatureItem(context, title2, description2),
          const SizedBox(height: 8),
          _buildFeatureItem(context, title3, description3),
        ],
      ),
    );
  }
}
