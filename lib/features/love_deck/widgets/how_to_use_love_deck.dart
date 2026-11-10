import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class _HowToUseLoveDeckColors {
  static const surface = Color(0xFF130622);
  static const grabber = Color(0xFF332544);
  static const descriptionText = Color(0xFFEEEAFD);
}

class HowToUseLoveDeck extends StatelessWidget {
  const HowToUseLoveDeck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final maxSheetHeight = mediaSize.height * 0.86;
    final sheetHeight = maxSheetHeight > 562 ? 562.0 : maxSheetHeight;

    return SizedBox(
      height: sheetHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _HowToUseLoveDeckColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: _HowToUseLoveDeckColors.grabber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.deckHowToUse,
                  style: context.textTheme.playfairSemiBold24.copyWith(
                    color: AppColors.white,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InstructionRow(
                          icon: _InstructionIcon.star,
                          text: context.l10n.loveDeckHowToIntroduction,
                        ),
                        const SizedBox(height: 16),
                        const _InstructionNumberedList(),
                        const SizedBox(height: 16),
                        _InstructionRow(
                          icon: _InstructionIcon.magicWand,
                          text: context.l10n.loveDeckHowToClosing,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static TextStyle _bodyStyle(BuildContext context) {
    return context.textTheme.urbanistRegular16.copyWith(
      color: _HowToUseLoveDeckColors.descriptionText,
      height: 1.2,
      letterSpacing: 0,
    );
  }
}

enum _InstructionIcon { star, magicWand }

class _InstructionNumberedList extends StatelessWidget {
  const _InstructionNumberedList();

  @override
  Widget build(BuildContext context) {
    final items = [
      context.l10n.loveDeckPositionPartnerFeelings,
      context.l10n.loveDeckPositionYourFeelings,
      context.l10n.loveDeckPositionSharedEnergy,
      context.l10n.loveDeckPositionObstacles,
      context.l10n.loveDeckPositionSupport,
      context.l10n.loveDeckPositionFuture,
    ];
    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _InstructionNumberedItem(number: index + 1, text: items[index]),
          if (index != items.length - 1) const SizedBox(height: 15),
        ],
      ],
    );
  }
}

class _InstructionNumberedItem extends StatelessWidget {
  const _InstructionNumberedItem({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Text(
            '$number.',
            style: HowToUseLoveDeck._bodyStyle(context),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text, style: HowToUseLoveDeck._bodyStyle(context)),
        ),
      ],
    );
  }
}

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({required this.icon, required this.text});

  final _InstructionIcon icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final assetPath = switch (icon) {
      _InstructionIcon.star => 'assets/icons/gradient_star.png',
      _InstructionIcon.magicWand => 'assets/icons/magic_wand.png',
    };
    final iconSize = switch (icon) {
      _InstructionIcon.star => 12.0,
      _InstructionIcon.magicWand => 20.0,
    };
    final topPadding = switch (icon) {
      _InstructionIcon.star => 4.0,
      _InstructionIcon.magicWand => 0.0,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Image.asset(assetPath, width: iconSize, height: iconSize),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: HowToUseLoveDeck._bodyStyle(context),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
