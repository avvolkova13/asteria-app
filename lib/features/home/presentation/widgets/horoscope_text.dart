import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

/// Текстовый прогноз гороскопа
class HoroscopeText extends StatelessWidget {
  final String title;
  final String description;

  const HoroscopeText({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textTheme.urbanistRegular16,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: context.textTheme.urbanistRegular16,
          ),
        ],
      ),
    );
  }
}
