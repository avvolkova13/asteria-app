import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/extensions/build_context_extensions.dart';
import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:asteria_app/core/ui_kit/app_typography.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

// Local tokens from Figma 4825:51040 (dark purchase sheet).
const Color _notEnoughStarsError = Color(0xFFE36A6A);
const Color _notEnoughStarsPrimary = Color(0xFF6E4BFF);
const Color _notEnoughStarsPrimaryPressed = Color(0xFF5A3FD1);
const LinearGradient _notEnoughStarsButtonGradient = LinearGradient(
  colors: [_notEnoughStarsPrimary, _notEnoughStarsPrimaryPressed],
);

class NotEnoughStarsPurchaseContent extends StatelessWidget {
  final int balance;
  final int requiredAmount;
  final VoidCallback onCancel;
  final VoidCallback onBuyStars;
  final String? description;
  final VoidCallback? onSubscribe;
  final bool isBusy;

  const NotEnoughStarsPurchaseContent({
    super.key,
    required this.balance,
    required this.requiredAmount,
    required this.onCancel,
    required this.onBuyStars,
    this.description,
    this.onSubscribe,
    this.isBusy = false,
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
          child: Text(
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _PurchaseActionButton.outline(
              text: context.l10n.commonCancel,
              onPressed: onCancel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PurchaseActionButton.primary(
              text: context.l10n.balanceBuy,
              onPressed: onBuyStars,
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _PurchaseActionButton.primary({
    required this.text,
    required this.onPressed,
  }) : isPrimary = true;

  const _PurchaseActionButton.outline({
    required this.text,
    required this.onPressed,
  }) : isPrimary = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    final textStyle = AppTypography.text1SemiBold.copyWith(
      color: ModalGlassTokens.text,
    );

    return Semantics(
      button: true,
      label: text,
      enabled: true,
      onTap: LotusFeedback.action(onPressed),
      child: ExcludeSemantics(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            child: Ink(
              decoration: CardLensDecoration.button(
                color: isPrimary ? null : Colors.transparent,
                gradient: isPrimary ? _notEnoughStarsButtonGradient : null,
                borderRadius: borderRadius,
                border: isPrimary
                    ? null
                    : Border.all(color: _notEnoughStarsPrimary),
              ),
              child: LotusInkTap(
                onTap: onPressed,
                borderRadius: borderRadius,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Center(
                    child: Text(
                      text,
                      style: textStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
