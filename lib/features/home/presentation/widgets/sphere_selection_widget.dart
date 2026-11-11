import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/extensions/build_context_extensions.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/closed_content_modal.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_state.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum Sphere {
  beauty('beauty', 'ic_beauty'),
  garden('garden', 'ic_picture'),
  health('health', 'ic_heart'),
  workAndRest('work_and_rest', 'ic_education'),
  relationships('relationships', 'ic_heart');

  const Sphere(this.localizationKey, this.iconPath);

  final String localizationKey;
  final String iconPath;

  String getLocalizedName(BuildContext context) {
    switch (this) {
      case Sphere.beauty:
        return context.l10n.sphereBeauty;
      case Sphere.garden:
        return context.l10n.sphereGarden;
      case Sphere.health:
        return context.l10n.sphereHealth;
      case Sphere.workAndRest:
        return context.l10n.sphereWorkRest;
      case Sphere.relationships:
        return context.l10n.sphereRelationships;
    }
  }

  String getDisabledIconPath() {
    return '${iconPath}_locked';
  }

  static List<Sphere> get allSpheres => Sphere.values;
}

class SphereSelectionWidget extends StatefulWidget {
  const SphereSelectionWidget({super.key});

  @override
  State<SphereSelectionWidget> createState() => _SphereSelectionWidgetState();
}

class _SphereSelectionWidgetState extends State<SphereSelectionWidget> {
  bool _isSphereAvailableWithoutSubscription(Sphere sphere) {
    return sphere == Sphere.beauty || sphere == Sphere.garden;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoonScreenCubit, MoonScreenState>(
      builder: (context, state) {
        final userProvider = context.watch<UserProvider>();
        final hasProSubscription =
            userProvider.currentUser != null &&
            (MonetizationProvider.maybeOf(context)?.effectivePro ?? false);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.sphereSelect,
              style: context.textTheme.playfairMedium20.copyWith(
                color: AppColors.textInverse,
                fontFamily: 'Lora',
                height: 1.1,
              ),
            ).withEntrance(),
            const SizedBox(height: 16),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: Sphere.allSpheres.map((sphere) {
                final isAvailable =
                    hasProSubscription ||
                    _isSphereAvailableWithoutSubscription(sphere);
                final isDisabled = !isAvailable;
                final isSelected =
                    isAvailable && state.selectedSphere == sphere;
                final label = sphere.getLocalizedName(context);

                void handleTap() {
                  if (isDisabled) {
                    ClosedContentModal.show(
                      context,
                      description: context.l10n.sphereSubscriptionRequired,
                    );
                  } else {
                    context.read<MoonScreenCubit>().selectSphere(
                      isSelected ? null : sphere,
                    );
                  }
                }

                return LotusFeedback(
                  onActivate: handleTap,
                  builder: (activate) => Semantics(
                    button: true,
                    selected: isSelected,
                    label: isDisabled
                        ? '$label, ${context.l10n.subscriptionOnlyTitle}'
                        : label,
                    onTap: activate,
                    child: ExcludeSemantics(
                      child: InkWell(
                        onTap: activate,
                        borderRadius: BorderRadius.circular(8),
                        child: _SphereSelectionItem(
                          sphere: sphere,
                          isSelected: isSelected,
                          isDisabled: isDisabled,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _SphereSelectionItem extends StatelessWidget {
  final Sphere sphere;
  final bool isSelected;
  final bool isDisabled;
  const _SphereSelectionItem({
    required this.sphere,
    required this.isSelected,
    required this.isDisabled,
  });

  Widget _buildIcon(Color foreground) {
    final (asset, left, top) = switch (sphere) {
      Sphere.beauty => ('beauty', 3.25, 2.25),
      Sphere.garden => ('garden', 2.25, 2.25),
      Sphere.health => ('health', 1.59, 3.25),
      Sphere.workAndRest => ('work', 2.25, 0.25),
      Sphere.relationships => ('relationships', 1.25, 2.25),
    };
    return SizedBox.square(
      dimension: 24,
      child: Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            child: ClayAssetIcon(
              'assets/icons/sphere_icon/calendar_$asset.svg',
              tint: foreground,
              excludeFromSemantics: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foreground = isDisabled
        ? AppColors.uiDisabledText
        : isSelected
        ? AppColors.textPrimary
        : MoonDesignTokens.chipOrange;
    final label = Text(
      sphere.getLocalizedName(context),
      style: context.textTheme.urbanistRegular16.copyWith(
        fontFamily: 'Onest',
        color: foreground,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        height: 1.2,
        letterSpacing: -0.408,
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isSelected ? MoonDesignTokens.orangeGradient : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? null
            : Border.all(
                color: isDisabled
                    ? AppColors.uiDisabledText.withValues(alpha: .48)
                    : MoonDesignTokens.chipOrange,
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(foreground),
            const SizedBox(width: 4),
            Flexible(
              child: isSelected || isDisabled
                  ? label
                  : ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback:
                          MoonDesignTokens.orangeGradient.createShader,
                      child: label,
                    ),
            ),
            if (isDisabled) ...[
              const SizedBox(width: 6),
              const ClayIcon(
                Icons.lock_rounded,
                size: 16,
                color: AppColors.uiDisabledText,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
