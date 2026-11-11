import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class MonthHoroscopeWidget extends StatelessWidget {
  final String title;
  final String description;
  const MonthHoroscopeWidget({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CardLensDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/home/month_widget_bg.webp'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.inversePlayfairSemiBold24),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: context.textTheme.inverseUrbanistRegular16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Image.asset('assets/images/home/hand_with_star.webp', height: 140),
        ],
      ),
    );
  }
}
