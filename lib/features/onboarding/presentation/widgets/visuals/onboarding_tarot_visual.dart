import 'dart:math' as math;

import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'onboarding_visual_styles.dart';

/// Decorative, localized examples of a tarot spread and an Anakra reply.
class OnboardingTarotVisual extends StatelessWidget {
  const OnboardingTarotVisual({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageDirectory =
        Localizations.localeOf(context).languageCode == 'ru' ? '' : 'en/';

    return SizedBox(
      width: 390,
      height: 426,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: 77,
            top: 43,
            width: 236,
            height: 263,
            child: OnboardingMiniCard(radius: 16, child: SizedBox.expand()),
          ),
          _TarotCard(
            left: 39,
            top: 0,
            angle: -12,
            asset: 'assets/images/cards/${languageDirectory}temperance.webp',
            dimmed: true,
          ),
          _TarotCard(
            left: 201,
            top: 0,
            angle: 12,
            asset: 'assets/images/cards/${languageDirectory}the_lovers.webp',
            dimmed: true,
          ),
          _TarotCard(
            left: 140.41,
            top: 23,
            angle: 0,
            asset: 'assets/images/cards/${languageDirectory}the_fool.webp',
          ),
          Positioned(
            left: 39,
            top: 208,
            width: 312,
            child: Column(
              children: [
                _SphereRow(
                  first: l10n.tarotSphereLove,
                  firstIcon: 'heart',
                  second: l10n.tarotSphereSelfRealization,
                  secondIcon: 'award',
                  activeFirst: true,
                ),
                const SizedBox(height: 6),
                _SphereRow(
                  first: l10n.tarotSphereSpirituality,
                  firstIcon: 'education',
                  second: l10n.tarotSphereHealth,
                  secondIcon: 'cup_of_tea',
                ),
                const SizedBox(height: 6),
                _SphereRow(
                  first: l10n.tarotSphereFamily,
                  firstIcon: 'map',
                  second: l10n.tarotSphereCareer,
                  secondIcon: 'education',
                ),
              ],
            ),
          ),
          Positioned(
            left: 149,
            top: 318,
            width: 225,
            height: 33.79,
            child: _MessageBubble(
              color: const Color(0x335B3FD2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.onboardPreviewAnakraQuestion,
                  style: OnboardingVisualStyles.body(12).copyWith(height: 1.2),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 352,
            width: 293,
            height: 16,
            child: Text(
              l10n.anakraName,
              style: OnboardingVisualStyles.body(
                13,
                color: const Color(0xFFB5AAB8),
              ).copyWith(height: 1.2),
            ),
          ),
          Positioned(
            left: 16,
            top: 372,
            width: 274,
            height: 54,
            child: _MessageBubble(
              color: const Color(0x331B1433),
              horizontalPadding: 11,
              child: _ReplyText(l10n.onboardPreviewAnakraReply),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fits the sample reply while preserving the full width of its chat bubble.
class _ReplyText extends StatelessWidget {
  final String text;

  const _ReplyText(this.text);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var size = 12.0;
        var style = OnboardingVisualStyles.body(size).copyWith(height: 1.2);
        final painter = TextPainter(
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          locale: Localizations.localeOf(context),
        );
        while (true) {
          painter.text = TextSpan(text: text, style: style);
          painter.layout(maxWidth: constraints.maxWidth);
          if (painter.height <= constraints.maxHeight || size <= 8) break;
          size -= 0.25;
          style = OnboardingVisualStyles.body(size).copyWith(height: 1.2);
        }
        painter.dispose();
        return Text(text, style: style);
      },
    );
  }
}

class _TarotCard extends StatelessWidget {
  final double left;
  final double top;
  final double angle;
  final String asset;
  final bool dimmed;

  const _TarotCard({
    required this.left,
    required this.top,
    required this.angle,
    required this.asset,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: 116.87,
      height: 175.3,
      child: Transform.rotate(
        angle: angle * math.pi / 180,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0DF3B76A),
                offset: Offset(0, 4),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  asset,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
                if (dimmed) const ColoredBox(color: Color(0x80110D20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SphereRow extends StatelessWidget {
  final String first;
  final String firstIcon;
  final String second;
  final String secondIcon;
  final bool activeFirst;

  const _SphereRow({
    required this.first,
    required this.firstIcon,
    required this.second,
    required this.secondIcon,
    this.activeFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SphereTag(label: first, icon: firstIcon, active: activeFirst),
            const SizedBox(width: 6),
            _SphereTag(label: second, icon: secondIcon),
          ],
        ),
      ),
    );
  }
}

class _SphereTag extends StatelessWidget {
  final String label;
  final String icon;
  final bool active;

  const _SphereTag({
    required this.label,
    required this.icon,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = active
        ? OnboardingVisualStyles.surface
        : OnboardingVisualStyles.gold;

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        gradient: active ? OnboardingVisualStyles.goldGradient : null,
        border: Border.all(color: OnboardingVisualStyles.gold, width: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/sphere_icon/ic_$icon.svg',
            width: 17,
            height: 17,
            colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
            excludeFromSemantics: true,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: OnboardingVisualStyles.body(
              11,
              weight: FontWeight.w600,
              color: foreground,
            ).copyWith(height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Widget child;
  final Color color;
  final double horizontalPadding;

  const _MessageBubble({
    required this.child,
    required this.color,
    this.horizontalPadding = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x24D9C8FF), width: 0.5),
      ),
      child: child,
    );
  }
}
