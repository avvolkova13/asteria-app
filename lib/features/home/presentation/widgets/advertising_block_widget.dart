import 'package:asteria_app/features/sonnik/presentation/screens/dream_journal_screen.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class AdvertisingBlockWidget extends StatelessWidget {
  static const _backgroundAsset = 'assets/images/home/advertising_card_bg.webp';
  static const _liveyaAsset = 'assets/images/home/advertising_card_liveya.webp';
  // Figma dark Surface/card for the dream banner (node 4379:8613).
  static const _cardBackground = Color(0xFF151028);
  static const _descriptionColor = AppColorsDark.textSecondary;
  const AdvertisingBlockWidget({super.key, this.horizontalMargin = 16})
    : capture = false;

  const AdvertisingBlockWidget.capture({super.key, this.horizontalMargin = 16})
    : capture = true;
  final double horizontalMargin;
  final bool capture;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context);
          final sideBySide = constraints.maxWidth >= scale.scale(306);
          final portraitWidth = (constraints.maxWidth * .24).clamp(58.0, 100.0);
          final primary = capture
              ? const DreamCaptureButton()
              : AsteriaActionButton(
                  text: context.l10n.dreamDecode,
                  gold: true,
                  width: double.infinity,
                  onPressed: () => CreateSonnikInitialRoute.push(context),
                );
          return ClipRRect(
            borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: CardLensDecoration(
                borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: ColoredBox(color: _cardBackground),
                  ),
                  Positioned.fill(
                    child: Opacity(
                      opacity: .28,
                      child: Image.asset(
                        _backgroundAsset,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      context.l10n.adDreamTitle,
                                      style: context
                                          .textTheme
                                          .inversePlayfairSemiBold24,
                                    ),
                                  ),
                                  if (sideBySide) ...[
                                    const SizedBox(height: 6),
                                    _description(context),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset(
                              _liveyaAsset,
                              width: portraitWidth,
                              height: sideBySide ? portraitWidth * 1.3 : 64,
                              fit: BoxFit.contain,
                              excludeFromSemantics: true,
                            ),
                          ],
                        ),
                        if (!sideBySide) ...[
                          const SizedBox(height: 6),
                          _description(context),
                        ],
                        const SizedBox(height: 12),
                        if (sideBySide)
                          Row(
                            children: [
                              Expanded(child: primary),
                              const SizedBox(width: 8),
                              const DreamJournalLink(),
                            ],
                          )
                        else ...[
                          primary,
                          const DreamJournalLink(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _description(BuildContext context) => Text(
    context.l10n.adDreamDescription,
    style: context.textTheme.inverseUrbanistRegular16.copyWith(
      color: _descriptionColor,
    ),
  );
}
