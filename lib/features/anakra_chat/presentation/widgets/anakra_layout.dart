import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/subscription_widget.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/home/presentation/models/year_animal_asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

abstract final class AnakraAssets {
  static const background = 'assets/images/anakra/background.png';
  static const proCrystal = 'assets/images/sonnik/pro_crystal.webp';
  static const coin = 'assets/icons/star_coin_icon.png';
  static const arrow = 'assets/icons/right_long_arrow.png';
  static const send = 'assets/images/anakra/send.png';
  static const sendDisabled = 'assets/icons/send_button_disabled.png';
}

abstract final class AnakraPalette {
  static const background = Color(0xFF0F0A1A);
  static const backgroundDeep = Color(0xFF140C15);
  static const purple = Color(0xFF6E4BFF);
  static const purpleDark = Color(0xFF5436D9);
  static const violetGlass = Color(0x339A7DB8);
  static const orange = Color(0xFFE6994D);
  static const white = Colors.white;
  static const textMuted = Color(0xFFB5AAB8);

  static const primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [purple, purpleDark],
  );

  static const orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF3B05C), orange],
  );
}

class AnakraPageScaffold extends StatelessWidget {
  final Widget child;
  final bool resizeToAvoidBottomInset;
  final bool canPop;

  const AnakraPageScaffold({
    super.key,
    required this.child,
    this.resizeToAvoidBottomInset = false,
    this.canPop = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AnakraPalette.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AnakraPalette.background,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.sizeOf(context).height,
              child: const _AnakraStarBackground(),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: AsteriaEntrance.sections([
                  AnakraTopNavBar(canPop: canPop),
                  Expanded(child: child),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnakraTopNavBar extends StatelessWidget {
  final bool canPop;

  const AnakraTopNavBar({super.key, this.canPop = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: canPop
                ? LotusButtons.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    icon: const LotusArrowBubble(back: true),
                    padding: EdgeInsets.zero,
                  )
                : null,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              context.l10n.anakraTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.navTitle.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<MonetizationProvider>(
            builder: (context, monetizationProvider, child) {
              final balance = monetizationProvider.balance;
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
                        style: AppTypography.navTitle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      LotusRasterIcon(AnakraAssets.coin, height: 16),
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

class AnakraHeroHeader extends StatelessWidget {
  final bool showRequestsBadge;
  final VoidCallback? onRequestsTap;

  const AnakraHeroHeader({
    super.key,
    this.showRequestsBadge = true,
    this.onRequestsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MonetizationProvider>(
      builder: (context, monetizationProvider, child) {
        final quota = monetizationProvider.requestQuota('anakra');
        final freeRequestsLeft = quota.freeRemaining;
        final paidRequestsLeft = quota.paidRemaining;
        final isPro = monetizationProvider.effectivePro;
        final isCompact = MediaQuery.sizeOf(context).width < 360;
        final avatarSize = isCompact ? 132.0 : 156.0;
        final titleStyle = AppTypography.h2.copyWith(color: Colors.white);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AsteriaEntrance.sections([
                      Text(context.l10n.anakraGreetingTitle, style: titleStyle),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.anakraReady,
                        style: AppTypography.text1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      if (showRequestsBadge && !isPro) ...[
                        const SizedBox(height: 12),
                        Semantics(
                          button: onRequestsTap != null,
                          label: context.l10n.anakraRequestsLeftLabel,
                          child: LotusTap(
                            onTap: onRequestsTap,
                            behavior: HitTestBehavior.opaque,
                            child: AnakraRequestsPill(
                              freeRequestsLeft: freeRequestsLeft,
                              paidRequestsLeft: paidRequestsLeft,
                            ),
                          ),
                        ),
                      ],
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AnakraAvatar(size: avatarSize),
            ],
          ),
        );
      },
    );
  }
}

class AnakraAvatar extends StatelessWidget {
  final double size;

  const AnakraAvatar({super.key, this.size = 156});

  @override
  Widget build(BuildContext context) {
    return AsteriaEntrance(
      child: SizedBox.square(
        dimension: size,
        child: Image.asset(
          YearAnimalAsset.forYear(DateTime.now().year),
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}

class AnakraRequestsPill extends StatelessWidget {
  final int freeRequestsLeft;
  final int paidRequestsLeft;

  const AnakraRequestsPill({
    super.key,
    required this.freeRequestsLeft,
    this.paidRequestsLeft = 0,
  });

  @override
  Widget build(BuildContext context) {
    final totalRequestsLeft = freeRequestsLeft + paidRequestsLeft;
    final requestCount = context.l10n.requestPackageCount(totalRequestsLeft);
    final isRussian = Localizations.localeOf(context).languageCode == 'ru';
    final label = isRussian ? 'Осталось $requestCount' : '$requestCount left';

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AnakraPalette.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: context.textTheme.urbanistRegular12.copyWith(
            color: AppColors.textPrimary,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class AnakraGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Border? border;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const AnakraGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AsteriaCardRadii.tile),
    ),
    this.border,
    this.gradient,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: CardLensDecoration(
        borderRadius: borderRadius,
        gradient:
            gradient ??
            const LinearGradient(
              colors: [AnakraPalette.violetGlass, AnakraPalette.violetGlass],
            ),
        border:
            border ??
            Border.all(color: AnakraPalette.white.withValues(alpha: 0.24)),
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: LotusTap(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      ),
    );
  }
}

class AnakraGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;

  const AnakraGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: text,
      child: LotusTap(
        onTap: enabled ? onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: enabled ? 1 : 0.64,
          child: Container(
            height: height,
            alignment: Alignment.center,
            decoration: CardLensDecoration.button(
              enabled: enabled,
              borderRadius: BorderRadius.circular(16),
              gradient: enabled ? AnakraPalette.primaryGradient : null,
              color: enabled ? null : AnakraPalette.purpleDark,
            ),
            child: Text(
              text,
              style: context.textTheme.inverseUrbanistRegular16,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnakraStarBackground extends StatelessWidget {
  const _AnakraStarBackground();

  @override
  Widget build(BuildContext context) => Image.asset(
    AnakraAssets.background,
    fit: BoxFit.cover,
    alignment: Alignment.center,
    excludeFromSemantics: true,
  );
}
