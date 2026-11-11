import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class EnergyOfTheDayWidget extends StatelessWidget {
  const EnergyOfTheDayWidget({super.key});

  static const double _cardGap = 8;

  @override
  Widget build(BuildContext context) {
    final contentProvider = di.get<ContentProvider>();
    return ListenableBuilder(
      listenable: contentProvider,
      builder: (context, child) {
        final energyOfTheDay = contentProvider.getTodayEnergyOfDay();
        final progressText =
            energyOfTheDay?.phrase ??
            (contentProvider.isLoadingContent
                ? context.l10n.loading
                : context.l10n.commonUnavailable);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(color: AppColors.textPrimary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.energyOfDay,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.inversePlayfairSemiBold24.copyWith(
                  height: 1,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - _cardGap) / 2;
                  final isCompact = cardWidth < 156;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _EnergyCard(
                            title: context.l10n.energyFocus,
                            description: energyOfTheDay?.focus ?? '',
                            progressText: progressText,
                            progressValue: _parsePercentage(
                              energyOfTheDay?.focusPercentage,
                            ),
                            type: _EnergyCardType.focus,
                            isCompact: isCompact,
                          ),
                        ),
                        const SizedBox(width: _cardGap),
                        SizedBox(
                          width: cardWidth,
                          child: _EnergyCard(
                            title: context.l10n.energyRisks,
                            description: energyOfTheDay?.risk ?? '',
                            progressText: progressText,
                            progressValue: _parsePercentage(
                              energyOfTheDay?.riskPercentage,
                            ),
                            type: _EnergyCardType.risk,
                            isCompact: isCompact,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static int? _parsePercentage(String? value) {
    if (value == null) {
      return null;
    }

    final match = RegExp(r'-?\d+([.,]\d+)?').firstMatch(value);
    final parsed = double.tryParse(match?.group(0)?.replaceAll(',', '.') ?? '');

    return parsed?.round().clamp(0, 100);
  }
}

enum _EnergyCardType { focus, risk }

class _EnergyCard extends StatelessWidget {
  const _EnergyCard({
    required this.type,
    required this.title,
    required this.description,
    required this.progressText,
    required this.progressValue,
    required this.isCompact,
  });

  static const Color _cardBackground = Color(0xFF171026);
  static const LinearGradient _orangeGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );

  final _EnergyCardType type;
  final String title;
  final String description;
  final String progressText;
  final int? progressValue;
  final bool isCompact;

  bool get _isFocus => type == _EnergyCardType.focus;

  String get _imagePath => _isFocus
      ? 'assets/images/home/energy_focus.webp'
      : 'assets/images/home/energy_risks.webp';

  @override
  Widget build(BuildContext context) {
    final progress = progressValue;
    final titleStyle = context.textTheme.playfairMedium20.copyWith(
      height: 1.1,
      color: _isFocus ? Colors.white : AppColors.error,
    );
    final phraseStyle = context.textTheme.inverseUrbanistSemiBold16.copyWith(
      fontSize: _phraseFontSize,
      height: 1.2,
      letterSpacing: -0.08,
    );
    final percentageStyle = context.textTheme.inverseUrbanistSemiBold16
        .copyWith(height: 1.2, letterSpacing: -0.408);
    final descriptionStyle = context.textTheme.inverseUrbanistRegular16
        .copyWith(fontSize: 14, height: 1.2, letterSpacing: -0.08);

    final imageWidth = isCompact ? 48.0 : 66.0;
    final imageHeight = isCompact ? 64.0 : 82.0;

    return ClipRRect(
      key: ValueKey('energy-card-${type.name}'),
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: CardLensDecoration(borderRadius: BorderRadius.circular(16)),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: _cardBackground),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _isFocus
                              ? _GradientText(
                                  text: title,
                                  gradient: _orangeGradient,
                                  style: titleStyle,
                                )
                              : Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: titleStyle,
                                ),
                          const SizedBox(height: 4),
                          Text(
                            progressText,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: phraseStyle,
                          ),
                          const SizedBox(height: 4),
                          _GradientText(
                            text: progress == null ? '—' : '$progress%',
                            gradient: _orangeGradient,
                            style: percentageStyle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: imageWidth,
                      height: imageHeight,
                      child: ClipRect(
                        child: Image.asset(
                          _imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (progress != null)
                  _ProgressBar(
                    progressValue: progress,
                    isFocus: _isFocus,
                    gradient: _orangeGradient,
                  )
                else
                  const SizedBox(height: 4),
                const SizedBox(height: 8),
                Text(description, style: descriptionStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double get _phraseFontSize {
    final words = progressText.trim().split(RegExp(r'\s+'));
    final longestWordLength = words.fold<int>(
      0,
      (maxLength, word) => word.length > maxLength ? word.length : maxLength,
    );

    return progressText.length > 28 || longestWordLength >= 12 ? 12 : 13;
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.progressValue,
    required this.isFocus,
    required this.gradient,
  });

  final int progressValue;
  final bool isFocus;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: 4,
        child: DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.uiDisabled),
          child: Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: progressValue / 100,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: isFocus ? null : AppColors.error,
                  gradient: isFocus ? gradient : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText({
    required this.text,
    required this.gradient,
    required this.style,
  });

  final String text;
  final Gradient gradient;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
