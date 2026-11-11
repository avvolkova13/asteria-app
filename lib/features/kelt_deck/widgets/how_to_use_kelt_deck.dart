import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class _HowToUseKeltDeckColors {
  static const surface = ModalGlassTokens.surface;
  static const grabber = ModalGlassTokens.grabber;
  static const text = ModalGlassTokens.text;
}

class HowToUseKeltDeck extends StatelessWidget {
  const HowToUseKeltDeck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final topSafeArea = MediaQuery.paddingOf(context).top;
    final maxSheetHeight = mediaSize.height - topSafeArea - 12;
    final preferredSheetHeight = mediaSize.height - 33;
    final sheetHeight = preferredSheetHeight > maxSheetHeight
        ? maxSheetHeight
        : preferredSheetHeight;

    return SizedBox(
      height: sheetHeight,
      child: ModalGlassSurface(
        color: _HowToUseKeltDeckColors.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AsteriaEntrance.sections([
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: _HowToUseKeltDeckColors.grabber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.deckHowToUse,
                  style: context.textTheme.playfairSemiBold24.copyWith(
                    color: _HowToUseKeltDeckColors.text,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: AsteriaEntrance.sections([
                        _InstructionRow(
                          icon: _InstructionIcon.star,
                          text: context.l10n.keltDeckHowToIntroduction,
                        ),
                        const SizedBox(height: 16),
                        for (
                          var index = 0;
                          index < _localizedItems(context).length;
                          index++
                        ) ...[
                          _InstructionNumberedItem(
                            number: index + 1,
                            text: _localizedItems(context)[index],
                          ),
                          const SizedBox(height: 15),
                        ],
                        _InstructionRow(
                          icon: _InstructionIcon.magicWand,
                          text: context.l10n.keltDeckHowToClosing,
                        ),
                        const SizedBox(height: 16),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  List<String> _localizedItems(BuildContext context) => [
    context.l10n.keltPosition1Item,
    context.l10n.keltPosition2Item,
    context.l10n.keltPosition3Item,
    context.l10n.keltPosition4Item,
    context.l10n.keltPosition5Item,
    context.l10n.keltPosition6Item,
    context.l10n.keltPosition7Item,
    context.l10n.keltPosition8Item,
    context.l10n.keltPosition9Item,
    context.l10n.keltPosition10Item,
  ];

  static TextStyle bodyStyle(BuildContext context) {
    return context.textTheme.urbanistRegular16.copyWith(
      color: _HowToUseKeltDeckColors.text,
      height: 1.2,
      letterSpacing: -0.408,
    );
  }
}

enum _InstructionIcon { star, magicWand }

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
            style: HowToUseKeltDeck.bodyStyle(context),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(child: Text(text, style: HowToUseKeltDeck.bodyStyle(context))),
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
        const SizedBox(width: 4),
        Expanded(child: Text(text, style: HowToUseKeltDeck.bodyStyle(context))),
      ],
    );
  }
}
