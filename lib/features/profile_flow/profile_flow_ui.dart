import 'package:asteria_app/core/ui_kit/widgets/pro_badge_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/card_radii.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'dart:ui' as ui;
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';

class ProfileFlowColors {
  static const background = Color(0xFF080314);
  static const card = Color(0x4D72418A);
  static const cardStrong = Color(0x664F2A66);
  static const border = Color(0x52FFFFFF);
  static const accent = Color(0xFFFFAA47);
  static const purple = Color(0xFF7548FF);
  static const purpleDark = Color(0xFF251B4F);
  static const textMuted = Color(0xCCFFFFFF);
}

class ProfileFlowBackground extends StatelessWidget {
  const ProfileFlowBackground({
    super.key,
    required this.child,
    this.imageAsset,
  });

  final Widget child;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ProfileFlowColors.background,
      child: Stack(
        children: [
          if (imageAsset != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(imageAsset!, fit: BoxFit.cover),
              ),
            )
          else
            const Positioned.fill(
              child: CustomPaint(painter: _ProfileFlowBackgroundPainter()),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0),
                    const Color(0xFF2A1041).withValues(alpha: 0.34),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  stops: const [0, 0.52, 1],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class ProfileFlowHeader extends StatelessWidget {
  const ProfileFlowHeader({
    super.key,
    required this.title,
    this.canPop = false,
    this.showTitleLarge = false,
  });

  final String title;
  final bool canPop;
  final bool showTitleLarge;

  @override
  Widget build(BuildContext context) {
    final monetization = MonetizationProvider.maybeOf(context);
    final hasPro = monetization?.effectivePro ?? false;
    final balance = monetization?.balance ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (canPop) ...[
                    Semantics(
                      button: true,
                      label: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      child: LotusTap(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: LotusArrowBubble(back: true),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.inversePlayfairSemiBold17,
                    ),
                  ),
                ],
              ),
            ),
            _BalancePill(balance: balance),
            const SizedBox(width: 10),
            ProfileProPill(isActive: hasPro),
          ],
        ),
        if (showTitleLarge) ...[
          const SizedBox(height: 28),
          Text(title, style: context.textTheme.inversePlayfairSemiBold32),
        ],
      ],
    );
  }
}

class ProfileProPill extends StatelessWidget {
  const ProfileProPill({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) => ProBadgeSurface(isActive: isActive);
}

class ProfileGlassCard extends StatelessWidget {
  const ProfileGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = AsteriaCardRadii.tile,
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    final card = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: DecoratedBox(
          decoration: CardLensDecoration(
            color: color ?? ProfileFlowColors.card,
            borderRadius: radius,
            border: Border.all(color: ProfileFlowColors.border, width: 0.8),
          ),
          child: Material(
            color: Colors.transparent,
            child: LotusInkTap(
              onTap: onTap,
              borderRadius: radius,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );

    return onTap == null ? card : Semantics(button: true, child: card);
  }
}

class ProfileIconBox extends StatelessWidget {
  const ProfileIconBox({
    super.key,
    this.iconAsset,
    this.icon,
    this.size = 34,
    this.iconSize = 22,
    this.preserveAssetColors = false,
  });

  final String? iconAsset;
  final IconData? icon;
  final double size;
  final double iconSize;
  final bool preserveAssetColors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: iconAsset != null
            ? ClayAssetIcon(
                iconAsset!,
                width: iconSize,
                height: iconSize,
                tint: preserveAssetColors ? null : AppColors.white,
              )
            : ClayIcon(
                icon ?? Icons.star_rounded,
                color: AppColors.white,
                size: iconSize,
              ),
      ),
    );
  }
}

class ProfilePrimaryButton extends StatelessWidget {
  const ProfilePrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: CardLensDecoration.button(
          enabled: onPressed != null && !isLoading,
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF7C4DFF), Color(0xFF6B39E9)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B39E9).withValues(alpha: 0.42),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LotusButtons.elevated(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text(text, style: context.textTheme.inverseUrbanistRegular17),
        ),
      ),
    );
  }
}

class ProfileOutlineButton extends StatelessWidget {
  const ProfileOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ProfileGlassCard(
      padding: EdgeInsets.zero,
      color: Colors.transparent,
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 49),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Center(
            heightFactor: 1,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: context.textTheme.inverseUrbanistRegular17.copyWith(
                color: ProfileFlowColors.accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileSectionText extends StatelessWidget {
  const ProfileSectionText({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? context.textTheme.inverseUrbanistRegular17,
    );
  }
}

class _BalancePill extends StatelessWidget {
  const _BalancePill({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$balance',
          style: context.textTheme.inversePlayfairSemiBold17.copyWith(
            height: 1,
          ),
        ),
        const SizedBox(width: 3),
        LotusRasterIcon(
          'assets/icons/star_coin_icon.png',
          width: 13,
          height: 13,
        ),
      ],
    );
  }
}

class _ProfileFlowBackgroundPainter extends CustomPainter {
  const _ProfileFlowBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final topGlow = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.52, size.height * 0.2),
        size.width * 0.64,
        [
          const Color(0xFF2E1848).withValues(alpha: 0.65),
          const Color(0xFF080314).withValues(alpha: 0),
        ],
      );
    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 0.2),
      size.width * 0.64,
      topGlow,
    );

    final midGlow = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.5, size.height * 0.54),
        size.width * 0.72,
        [
          const Color(0xFF6D2A71).withValues(alpha: 0.34),
          const Color(0xFF080314).withValues(alpha: 0),
        ],
      );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.54),
      size.width * 0.72,
      midGlow,
    );

    _drawWave(
      canvas,
      size,
      top: size.height * 0.5,
      height: 70,
      color: const Color(0xFF4E1E63).withValues(alpha: 0.52),
      phase: 0,
    );
    _drawWave(
      canvas,
      size,
      top: size.height * 0.59,
      height: 58,
      color: const Color(0xFF37134F).withValues(alpha: 0.6),
      phase: 28,
    );
    _drawWave(
      canvas,
      size,
      top: size.height * 0.68,
      height: 54,
      color: const Color(0xFF24113C).withValues(alpha: 0.72),
      phase: -34,
    );
    _drawWave(
      canvas,
      size,
      top: size.height * 0.79,
      height: 42,
      color: const Color(0xFF160C2D).withValues(alpha: 0.86),
      phase: 18,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double top,
    required double height,
    required Color color,
    required double phase,
  }) {
    final path = Path()..moveTo(0, top + height * 0.35);
    path.cubicTo(
      size.width * 0.18,
      top - height * 0.2 + phase,
      size.width * 0.32,
      top + height * 0.9,
      size.width * 0.5,
      top + height * 0.4,
    );
    path.cubicTo(
      size.width * 0.66,
      top - height * 0.02,
      size.width * 0.78,
      top + height * 0.85,
      size.width,
      top + height * 0.22,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
