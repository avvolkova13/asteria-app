import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/extensions/string_extensions.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class CompatibilityWidget extends StatelessWidget {
  final String firstBirthdate;
  final String secondBirthdate;
  final String firstZodiacSign;
  final String secondZodiacSign;
  final int compatibilityPercentage;
  final String compatibilityDescription;
  final String phrase;
  final VoidCallback? onTap;

  const CompatibilityWidget({
    Key? key,
    required this.firstBirthdate,
    required this.secondBirthdate,
    required this.firstZodiacSign,
    required this.secondZodiacSign,
    required this.compatibilityPercentage,
    required this.compatibilityDescription,
    required this.phrase,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LotusTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
            image: AssetImage(
              'assets/images/home/compatibility_background.webp',
            ),
            fit: BoxFit.cover,
            alignment: Alignment(0, 0.08),
            opacity: 0.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Заголовок с именами
                Column(
                  children: [
                    Text(
                      firstZodiacSign,
                      style: context.textTheme.inverseUrbanistSemiBold16,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      firstBirthdate.toFormattedDateString,
                      style: context.textTheme.inverseUrbanistRegular16,
                    ),
                    const SizedBox(height: 4),
                    _buildZodiacSign(
                      firstBirthdate
                          .toDateTimeFromShortDate()
                          .getZodiacSignAsset(),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Процент совместимости
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    '$compatibilityPercentage%',
                    style: context.textTheme.urbanistSemiBold24.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Column(
                  children: [
                    Text(
                      secondZodiacSign,
                      style: context.textTheme.inverseUrbanistSemiBold16,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      secondBirthdate.toFormattedDateString,
                      style: context.textTheme.inverseUrbanistRegular16,
                    ),
                    const SizedBox(height: 4),
                    _buildZodiacSign(
                      secondBirthdate
                          .toDateTimeFromShortDate()
                          .getZodiacSignAsset(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Описание совместимости
            Text(
              '$phrase',
              style: context.textTheme.inverseUrbanistRegular16.copyWith(
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              compatibilityDescription,
              style: context.textTheme.inverseUrbanistRegular16,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacSign(String zodiacSign) {
    return SizedBox(
      height: 100,
      width: 100,
      child: ClipOval(
        child: Image.asset(
          'assets/images/zodiacs/compatibility_round/$zodiacSign.webp',
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
