import 'package:asteria_app/features/taro_cards/widgets/tarot_sphere_chip.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/app/data/models/user/tarot_deck_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

enum TarotLayoutSphere {
  love('ic_heart'),
  selfRealization('ic_award'),
  spirituality('ic_education'),
  health('ic_cup_of_tea'),
  family('ic_map'),
  career('ic_education');

  const TarotLayoutSphere(this.iconPath);

  final String iconPath;

  String title(BuildContext context) => switch (this) {
    TarotLayoutSphere.love => context.l10n.tarotSphereLove,
    TarotLayoutSphere.selfRealization =>
      context.l10n.tarotSphereSelfRealization,
    TarotLayoutSphere.spirituality => context.l10n.tarotSphereSpirituality,
    TarotLayoutSphere.health => context.l10n.tarotSphereHealth,
    TarotLayoutSphere.family => context.l10n.tarotSphereFamily,
    TarotLayoutSphere.career => context.l10n.tarotSphereCareer,
  };
}

class InterpretationBlock extends StatefulWidget {
  final InterpretationModel interpretation;

  const InterpretationBlock({Key? key, required this.interpretation})
    : super(key: key);

  @override
  _InterpretationBlockState createState() => _InterpretationBlockState();
}

class _InterpretationBlockState extends State<InterpretationBlock> {
  TarotLayoutSphere _selectedSphere = TarotLayoutSphere.love;

  String _getTextForSphere(TarotLayoutSphere sphere) {
    switch (sphere) {
      case TarotLayoutSphere.love:
        return widget.interpretation.love;
      case TarotLayoutSphere.selfRealization:
        return widget.interpretation.selfRealization;
      case TarotLayoutSphere.spirituality:
        return widget.interpretation.spirituality;
      case TarotLayoutSphere.health:
        return widget.interpretation.health;
      case TarotLayoutSphere.family:
        return widget.interpretation.family;
      case TarotLayoutSphere.career:
        return widget.interpretation.career;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.tarotChooseSphere,
          style: context.textTheme.playfairMedium20.copyWith(
            color: AppColors.white,
            height: 1.1,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TarotLayoutSphere.values.map((sphere) {
            final isSelected = _selectedSphere == sphere;
            return TarotSphereChip(
              title: sphere.title(context),
              iconName: sphere.iconPath,
              selected: isSelected,
              onTap: () => setState(() => _selectedSphere = sphere),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          _getTextForSphere(_selectedSphere),
          style: context.textTheme.urbanistRegular16.copyWith(
            color: AppColors.white,
            height: 1.2,
            letterSpacing: -0.408,
          ),
        ),
      ]),
    );
  }
}
