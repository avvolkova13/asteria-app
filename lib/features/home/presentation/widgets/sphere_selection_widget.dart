import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/extensions/build_context_extensions.dart';
import 'package:asteria_app/core/ui_kit/widgets/closed_content_modal.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_state.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: Sphere.allSpheres.map((sphere) {
                final isSelected = state.selectedSphere == sphere;
                final isAvailable =
                    hasProSubscription ||
                    _isSphereAvailableWithoutSubscription(sphere);
                final isDisabled = !isAvailable;
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

                return Semantics(
                  button: true,
                  selected: isSelected,
                  label: isDisabled
                      ? '$label, ${context.l10n.subscriptionOnlyTitle}'
                      : label,
                  onTap: handleTap,
                  child: ExcludeSemantics(
                    child: GestureDetector(
                      onTap: handleTap,
                      child: _SphereSelectionItem(
                        sphere: sphere,
                        isSelected: isSelected,
                        isDisabled: isDisabled,
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

  Widget _buildIcon(BuildContext context) {
    final icon = SvgPicture.asset(
      isDisabled
          ? 'assets/icons/sphere_icon/${sphere.getDisabledIconPath()}.svg'
          : 'assets/icons/sphere_icon/${sphere.iconPath}.svg',
      colorFilter: ColorFilter.mode(
        isSelected ? AppColors.textInverse : MoonDesignTokens.chipOrange,
        BlendMode.srcIn,
      ),
      width: 24,
      height: 24,
    );

    if (!isDisabled) return icon;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(opacity: 0.52, child: icon),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: MoonDesignTokens.pageBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 8,
              color: MoonDesignTokens.chipOrange,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: isSelected ? MoonDesignTokens.orangeGradient : null,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? null
            : Border.all(color: MoonDesignTokens.chipOrange, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sphere.iconPath.isNotEmpty)
            _buildIcon(context)
          else
            const SizedBox(width: 24, height: 24),
          const SizedBox(width: 4),
          Text(
            sphere.getLocalizedName(context),
            style: context.textTheme.urbanistRegular16.copyWith(
              color: isSelected
                  ? AppColors.textInverse
                  : MoonDesignTokens.chipOrange,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              height: 1.2,
            ),
          ),
        ],
      ),
    );

    if (!isDisabled) return chip;

    return Opacity(opacity: 0.8, child: chip);
  }
}
