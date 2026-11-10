import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class PurchaseOfferButton extends StatelessWidget {
  final String buttonText;
  final String purchaseIcon;
  final String purchaseName;
  final VoidCallback onTap;
  const PurchaseOfferButton({
    Key? key,
    required this.buttonText,
    required this.purchaseIcon,
    required this.purchaseName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LotusTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LotusRasterIcon('assets/icons/$purchaseIcon.png', height: 24, width: 24),
            const SizedBox(width: 4),
            Text('$purchaseName $buttonText', style: context.textTheme.urbanistRegular14.copyWith(color: AppColors.primary)),
            const SizedBox(width: 4),
            LotusRasterIcon('assets/icons/star_coin_icon.png', height: 24, width: 24),
          ],
        ),
      ),
    );
  }
}
