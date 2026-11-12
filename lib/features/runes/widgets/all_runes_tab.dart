import 'package:asteria_app/core/ui_kit/widgets/artwork_unavailable.dart';
import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

class _AllRunesColors {
  static const surface = ModalGlassTokens.surface;
  static const grabber = ModalGlassTokens.grabber;
  static const text = ModalGlassTokens.text;
  static const gold = Color(0xFFF3B76A);
  static const goldGradient = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );
  static const purpleGradient = ModalGlassTokens.headingGradient;
}

class AllRunesTab extends StatelessWidget {
  const AllRunesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final contentProvider = di.get<ContentProvider>();
    final userProvider = di.get<UserProvider>();

    return ListenableBuilder(
      listenable: Listenable.merge([contentProvider, userProvider]),
      builder: (context, _) {
        if (contentProvider.runes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                context.l10n.runesEmpty,
                style: context.textTheme.urbanistRegular16.copyWith(
                  color: _AllRunesColors.text,
                ),
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width - 32;
            final runeWidth = (availableWidth - 32) / 3;
            final runeHeight = runeWidth * 181 / 108;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: contentProvider.runes.map((rune) {
                final bool canView = userProvider.isContentViewed(rune.id);
                // final bool canView = true;
                return SizedBox(
                  width: runeWidth,
                  child: _RuneGridItem(
                    rune: rune,
                    width: runeWidth,
                    height: runeHeight,
                    isLocked: !canView,
                    onTap: canView
                        ? () => _showRuneDescription(context, rune)
                        : null,
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  void _showRuneDescription(BuildContext context, RuneOfDayModel rune) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: ModalGlassTokens.barrier,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _RuneDescriptionModal(rune: rune);
      },
    );
  }
}

class _RuneGridItem extends StatelessWidget {
  const _RuneGridItem({
    required this.rune,
    required this.width,
    required this.height,
    required this.isLocked,
    required this.onTap,
  });

  final RuneOfDayModel rune;
  final double width;
  final double height;
  final bool isLocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LotusFeedback(
      onActivate: onTap,
      keyboard: true,
      builder: (activate) => Semantics(
        button: !isLocked,
        enabled: !isLocked,
        label: isLocked
            ? context.l10n.runeLockedLabel(rune.title)
            : context.l10n.runeOpenLabel(rune.title),
        onTap: activate,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: activate,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/runes/${rune.imageName}.webp',
                      width: width,
                      height: height,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return ArtworkUnavailable(
                          width: width,
                          height: height,
                          radius: 0,
                        );
                      },
                    ),
                    if (isLocked) ...[
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0F0A1A,
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      ClayAssetIcon(
                        'assets/icons/white_lock_icon.svg',
                        width: 24,
                        height: 24,
                        tint: _AllRunesColors.gold,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rune.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.urbanistRegular12.copyWith(
                  color: AppColors.white,
                  height: 1.2,
                  letterSpacing: -0.408,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuneDescriptionModal extends StatelessWidget {
  final RuneOfDayModel rune;

  const _RuneDescriptionModal({required this.rune});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = screenHeight * 0.9;
    final minHeight = maxHeight < 500.0 ? maxHeight : 500.0;
    final modalHeight = 556.0.clamp(minHeight, maxHeight).toDouble();
    return SizedBox(
      height: modalHeight,
      child: ModalGlassSurface(
        color: _AllRunesColors.surface,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  height: 4,
                  width: 64,
                  decoration: BoxDecoration(
                    color: _AllRunesColors.grabber,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AsteriaEntrance.sections([
                      _GradientText(
                        text: rune.title,
                        gradient: _AllRunesColors.goldGradient,
                        style: context.textTheme.playfairSemiBold24.copyWith(
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (rune.keywords.isNotEmpty)
                        _DescriptionSection(
                          title: context.l10n.commonKeywords,
                          body: rune.keywords.join(', '),
                        ),
                      if (rune.generalDescription.isNotEmpty)
                        _DescriptionSection(
                          title: context.l10n.commonDescription,
                          body: rune.generalDescription,
                        ),
                      if (rune.definitions.isNotEmpty)
                        _DescriptionSection(
                          title: context.l10n.commonMeaning,
                          body: rune.definitions.join(', '),
                        ),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GradientText(
            text: title,
            gradient: _AllRunesColors.purpleGradient,
            style: context.textTheme.playfairMedium20.copyWith(
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: context.textTheme.urbanistRegular16.copyWith(
              color: _AllRunesColors.text,
              height: 1.2,
              letterSpacing: -0.408,
            ),
          ),
        ],
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
        textAlign: TextAlign.left,
        style: style.copyWith(color: AppColors.white),
      ),
    );
  }
}
