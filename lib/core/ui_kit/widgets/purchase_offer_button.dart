import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
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
    return Semantics(
      button: true,
      child: LotusTap(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: AsteriaActionButton.decoration(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LotusRasterIcon(
                'assets/icons/$purchaseIcon.png',
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '$purchaseName $buttonText',
                  textAlign: TextAlign.center,
                  style: AppTypography.label14.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              LotusRasterIcon(
                'assets/icons/star_coin_icon.png',
                height: 24,
                width: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
