import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:flutter/material.dart';

class PaywallFeatureItem extends StatelessWidget {
  final String title;
  final String description;

  const PaywallFeatureItem({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: const LotusRasterIcon(
            'assets/icons/clay/moon_icon.webp',
            width: 19,
            height: 19,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${title.replaceAll('\n', ' ').trim()} ',
                  style: context.textTheme.inverseUrbanistSemiBold16.copyWith(
                    color: const Color(0xFFF3B76A),
                  ),
                ),
                TextSpan(text: description),
              ],
            ),
            style: context.textTheme.inverseUrbanistRegular16.copyWith(
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class PaywallFeaturesCard extends StatelessWidget {
  const PaywallFeaturesCard({super.key, required this.features});

  final List<PaywallFeatureItem> features;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 260),
      padding: const EdgeInsets.all(16),
      decoration: CardLensDecoration(
        color: const Color(0x339A7DB8),
        borderRadius: BorderRadius.circular(AsteriaCardRadii.card),
        border: Border.all(color: const Color(0x33FFFFFF), width: 0.7),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 300;
          final wandWidth = isCompact ? 82.0 : 105.0;
          final wandHeight = wandWidth * 157 / 105;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.natalInsideTitle,
                style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        for (var i = 0; i < features.length; i++) ...[
                          if (i != 0) const SizedBox(height: 8),
                          features[i],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Image.asset(
                      'assets/images/home/natal_paywall_wand.webp',
                      width: wandWidth,
                      height: wandHeight,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
