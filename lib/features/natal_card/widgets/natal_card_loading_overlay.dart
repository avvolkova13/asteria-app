import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'dart:async';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/subscription_widget.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';

/// Shared by chart generation and loading a translated chart.
class NatalCardLoadingOverlay extends StatefulWidget {
  const NatalCardLoadingOverlay({super.key});

  @override
  State<NatalCardLoadingOverlay> createState() =>
      _NatalCardLoadingOverlayState();
}

class _NatalCardLoadingOverlayState extends State<NatalCardLoadingOverlay> {
  int _textIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() => _textIndex = (_textIndex + 1) % 4);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texts = [
      context.l10n.natalLoadingPattern,
      context.l10n.natalLoadingLanguage,
      context.l10n.natalLoadingCode,
      context.l10n.natalLoadingPortrait,
    ];
    final media = MediaQuery.of(context);
    final balance = MonetizationProvider.maybeOf(context)?.balance ?? 0;

    return Material(
      color: const Color(0xFF0F0A1A),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.clamp(0.0, 390.0);
          final textTop =
              (constraints.maxHeight * 245 / 844 - media.padding.top - 44)
                  .clamp(32.0, double.infinity);
          return Stack(
            fit: StackFit.expand,
            children: [
              // Figma 4313:4983: background extends 10 px beyond each edge.
              Positioned(
                top: -10,
                bottom: -10,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    'assets/images/home/natal_card_figma_background.webp',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 44,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              ClayAssetIcon(
                                'assets/icons/back_icon.svg',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  context.l10n.horoscopeTitle,
                                  style: context
                                      .textTheme
                                      .inversePlayfairSemiBold17
                                      .copyWith(
                                        fontFamily: 'Lora',
                                        height: 1.2,
                                        letterSpacing: 0,
                                      ),
                                ),
                              ),
                              Text(
                                '$balance',
                                style: context
                                    .textTheme
                                    .inverseUrbanistRegular16
                                    .copyWith(
                                      fontFamily: 'Onest',
                                      letterSpacing: -0.408,
                                    ),
                              ),
                              const SizedBox(width: 2),
                              LotusRasterIcon(
                                'assets/icons/star_coin_icon.png',
                                height: 14,
                              ),
                              const SizedBox(width: 8),
                              const IgnorePointer(child: SubscriptionWidget()),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: textTop),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 390,
                          minHeight: 76,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 520),
                            child: Text(
                              texts[_textIndex],
                              key: ValueKey(texts[_textIndex]),
                              textAlign: TextAlign.center,
                              style: context.textTheme.inversePlayfairSemiBold32
                                  .copyWith(
                                    fontFamily: 'Lora',
                                    height: 1.2,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 38),
                      Image.asset(
                        'assets/images/horoscope/horoscope_sphere.webp',
                        width: width,
                        height: width * 343 / 390,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: media.padding.bottom),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
