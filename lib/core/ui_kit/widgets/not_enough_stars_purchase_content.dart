import 'package:asteria_app/core/ui_kit/widgets/responsive_heading.dart';
import 'package:asteria_app/core/ui_kit/widgets/purchase_modal_actions.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/extensions/build_context_extensions.dart';
import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:asteria_app/core/ui_kit/app_typography.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

// Local tokens from Figma 4825:51040 (dark purchase sheet).
const Color _notEnoughStarsError = Color(0xFFE36A6A);

class NotEnoughStarsPurchaseContent extends StatelessWidget {
  final int balance;
  final int requiredAmount;
  final VoidCallback onCancel;
  final VoidCallback onBuyStars;
  final String? description;
  final VoidCallback? onSubscribe;
  final bool isBusy;
  final String? errorMessage;

  const NotEnoughStarsPurchaseContent({
    super.key,
    required this.balance,
    required this.requiredAmount,
    required this.onCancel,
    required this.onBuyStars,
    this.description,
    this.onSubscribe,
    this.isBusy = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isBusy,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            height: 4,
            width: 64,
            decoration: BoxDecoration(
              color: ModalGlassTokens.grabber,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: AsteriaEntrance.sections([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _TitleRow(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    // The Figma description is 363px wide in a 390px sheet.
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      description ?? context.l10n.purchaseNotEnoughGeneric,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textInverse,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _BalanceRow(
                      balance: balance,
                      requiredAmount: requiredAmount,
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          errorMessage!,
                          key: const ValueKey('purchase-inline-error'),
                          textAlign: TextAlign.center,
                          style: context.textTheme.inverseUrbanistRegular16,
                        ),
                      ),
                    ),
                  ],
                ]),
              ),
            ),
          ),
          if (onSubscribe != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _PurchaseActionButton.primary(
                text: context.l10n.openSubscription,
                onPressed: onSubscribe!,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ButtonsRow(onCancel: onCancel, onBuyStars: onBuyStars),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 24,
          child: Center(
            child: ClayAssetIcon(
              'assets/icons/close_icon.svg',
              width: 20,
              height: 20,
              tint: _notEnoughStarsError,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: ResponsiveHeading(
            context.l10n.notEnoughStarsTitle,
            style: AppTypography.h2.copyWith(color: AppColors.textInverse),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final int balance;
  final int requiredAmount;

  const _BalanceRow({required this.balance, required this.requiredAmount});

  @override
  Widget build(BuildContext context) {
    final before = context.l10n.balanceLabel;
    final after = context.l10n.purchaseRequired;
    return LayoutBuilder(
      builder: (context, constraints) {
        final measurement = TextPainter(
          text: TextSpan(
            text: '$before $balance$after $requiredAmount',
            style: AppTypography.text1SemiBold,
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        // Two coin marks, their padding and the arrow between the amounts.
        final fitsOneLine =
            measurement.width + 2 * (19 + 4) + 24 + 2 * 8 <=
            constraints.maxWidth;
        measurement.dispose();
        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _AmountLabel(label: before, amount: balance),
            if (fitsOneLine) const _ArrowIcon(),
            _AmountLabel(label: after, amount: requiredAmount),
          ],
        );
      },
    );
  }
}

class _AmountLabel extends StatelessWidget {
  final String label;
  final int amount;

  const _AmountLabel({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: AppTypography.text1.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
                TextSpan(
                  text: '$amount',
                  style: AppTypography.text1SemiBold.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        LotusRasterIcon(
          'assets/icons/star_coin_icon.png',
          width: 19,
          height: 29,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _ArrowIcon extends StatelessWidget {
  const _ArrowIcon();

  @override
  Widget build(BuildContext context) {
    return LotusRasterIcon(
      'assets/icons/right_long_arrow.png',
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    );
  }
}

class _ButtonsRow extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onBuyStars;

  const _ButtonsRow({required this.onCancel, required this.onBuyStars});

  @override
  Widget build(BuildContext context) {
    return PurchaseModalActions(
      cancelLabel: context.l10n.commonCancel,
      onCancel: onCancel,
      primary: _PurchaseActionButton.primary(
        text: context.l10n.balanceBuy,
        onPressed: onBuyStars,
      ),
    );
  }
}

class _PurchaseActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _PurchaseActionButton.primary({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AsteriaActionButton(
      text: text,
      onPressed: onPressed,
      width: double.infinity,
    );
  }
}
