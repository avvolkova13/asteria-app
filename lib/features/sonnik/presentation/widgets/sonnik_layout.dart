import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'dart:ui';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';

import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/subscription_widget.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

abstract final class SonnikAssets {
  static const clouds = 'assets/images/sonnik/sonnik_clouds.webp';
  static const liveyaBackground = 'assets/images/sonnik/liveya_bg.webp';
  static const liveyaCharacter = 'assets/images/sonnik/liveya_character.webp';
  static const proCrystal = 'assets/images/sonnik/pro_crystal.webp';
}

abstract final class SonnikPalette {
  static const background = Color(0xFF170A44);
  static const surface = Color(0xFFF4ECFF);
  static const surfaceMuted = Color(0xFFE4D7F6);
  static const white = Colors.white;
  static const gold = Color(0xFFFFD88A);
  static const purple = Color(0xFF9B67FF);
  static const pink = Color(0xFFFF66BE);
  static const disabled = Color(0xFF5A447A);
  static const darkText = Color(0xFF21152F);

  static const ctaGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [purple, pink],
  );

  static const proGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7F4DFF), Color(0xFFFF7DC9)],
  );
}

class SonnikPageScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final bool resizeToAvoidBottomInset;
  final bool canPop;

  const SonnikPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.resizeToAvoidBottomInset = false,
    this.canPop = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: SonnikPalette.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: SonnikPalette.background,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: SonnikPalette.background),
              ),
            ),
            Positioned.fill(
              child: RotatedBox(
                quarterTurns: 2,
                child: Image.asset(SonnikAssets.clouds, fit: BoxFit.cover),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x3310062F),
                      Color(0x0010062F),
                      Color(0xB310062F),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  SonnikTopNavBar(title: title, canPop: canPop),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SonnikTopNavBar extends StatelessWidget {
  final String title;
  final bool canPop;

  const SonnikTopNavBar({super.key, required this.title, this.canPop = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: canPop
                ? LotusButtons.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    icon: const LotusIconSurface(
                      diameter: 32,
                      child: ClayIcon(
                        Icons.arrow_back_ios_new_rounded,
                        color: SonnikPalette.white,
                        size: 20,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                  )
                : null,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.navTitle.copyWith(color: SonnikPalette.white),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final balance = MonetizationProvider.maybeOf(context)?.balance ?? 0;
              return Semantics(
                button: true,
                label: '${context.l10n.balanceTitle}: $balance',
                excludeSemantics: true,
                child: LotusTap(
                  onTap: () => BalanceRoute.push(context),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$balance',
                        style: AppTypography.navTitle.copyWith(color: SonnikPalette.white),
                      ),
                      const SizedBox(width: 4),
                      LotusRasterIcon(
                        'assets/icons/star_coin_icon.png',
                        height: 16,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          const SubscriptionWidget(),
        ],
      ),
    );
  }
}

class SonnikLiveyaAvatar extends StatelessWidget {
  const SonnikLiveyaAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      height: 156,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: SonnikPalette.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: SonnikPalette.pink.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(SonnikAssets.liveyaBackground, fit: BoxFit.cover),
            Transform.translate(
              offset: const Offset(0, 12),
              child: Image.asset(
                SonnikAssets.liveyaCharacter,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SonnikTextArea extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SonnikTextArea({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: TextField(
        onTap: LotusFeedback.selection,
        controller: controller,
        onChanged: onChanged,
        expands: true,
        minLines: null,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
        cursorColor: SonnikPalette.gold,
        style: context.textTheme.urbanistRegular16.copyWith(
          color: SonnikPalette.white,
        ),
        decoration: InputDecoration(
          hintText: context.l10n.dreamInputHint,
          hintStyle: AppTypography.placeholder.copyWith(
            color: SonnikPalette.white.withValues(alpha: 0.56),
          ),
          filled: true,
          fillColor: SonnikPalette.white.withValues(alpha: 0.13),
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: SonnikPalette.white.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: SonnikPalette.white.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: SonnikPalette.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}

class SonnikGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const SonnikGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return LotusTap(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.72,
        child: Container(
          width: double.infinity,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: isEnabled ? SonnikPalette.ctaGradient : null,
            color: isEnabled ? null : SonnikPalette.disabled,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: SonnikPalette.pink.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            style: context.textTheme.inverseUrbanistSemiBold17.copyWith(
              color: SonnikPalette.white.withValues(
                alpha: isEnabled ? 1 : 0.55,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SonnikGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final VoidCallback? onTap;

  const SonnikGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: SonnikPalette.white.withValues(alpha: 0.12),
            borderRadius: borderRadius,
            border: Border.all(
              color: SonnikPalette.white.withValues(alpha: 0.18),
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return content;

    return LotusTap(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}

class SonnikQuotaBadge extends StatelessWidget {
  final int requestsLeft;

  const SonnikQuotaBadge({super.key, required this.requestsLeft});

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.attemptsLeftCount(requestsLeft);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE6A64F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: context.textTheme.inverseUrbanistSemiBold17.copyWith(
          color: SonnikPalette.darkText,
          fontSize: 14,
        ),
      ),
    );
  }
}

class SonnikOfferCard extends StatelessWidget {
  final String title;
  final Widget badge;
  final VoidCallback onTap;
  final bool showCrystal;

  const SonnikOfferCard({
    super.key,
    required this.title,
    required this.badge,
    required this.onTap,
    this.showCrystal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SonnikGlassPanel(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 128),
          child: Stack(
            children: [
              if (showCrystal)
                Positioned(
                  right: -18,
                  bottom: -22,
                  child: Image.asset(SonnikAssets.proCrystal, width: 94),
                )
              else
                Positioned(
                  right: 8,
                  bottom: 12,
                  child: LotusRasterIcon(
                    'assets/icons/star_coin_icon.png',
                    width: 42,
                  ),
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.text1SemiBold.copyWith(color: SonnikPalette.white),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const ClayIcon(
                      Icons.arrow_forward_rounded,
                      color: SonnikPalette.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
              Positioned(left: 0, bottom: 0, child: badge),
            ],
          ),
        ),
      ),
    );
  }
}

class SonnikPill extends StatelessWidget {
  final Widget child;

  const SonnikPill({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: SonnikPalette.proGradient,
        borderRadius: BorderRadius.circular(999),
      ),
      child: child,
    );
  }
}
