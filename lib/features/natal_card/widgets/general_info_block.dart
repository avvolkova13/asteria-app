import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class GeneralInfoBlock extends StatelessWidget {
  final String birthDate;
  final String birthTime;
  final String birthPlace;
  const GeneralInfoBlock({
    Key? key,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.natalGeneralData,
          style: context.textTheme.playfairSemiBold24,
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _GeneralInfoItem(
                  title: context.l10n.commonBirthDate,
                  value: birthDate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GeneralInfoItem(
                  title: context.l10n.commonBirthTime,
                  value: birthTime,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GeneralInfoItem(
                  title: context.l10n.commonBirthPlace,
                  value: birthPlace.split(',').first.trim(),
                  valueMaxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _GeneralInfoItem extends StatelessWidget {
  final String title;
  final String value;
  final int valueMaxLines;
  const _GeneralInfoItem({
    required this.title,
    required this.value,
    this.valueMaxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: CardLensDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.cardTinted,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.playfairMedium16,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.urbanistRegular16.copyWith(
              color: AppColors.secondary,
            ),
            maxLines: valueMaxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
