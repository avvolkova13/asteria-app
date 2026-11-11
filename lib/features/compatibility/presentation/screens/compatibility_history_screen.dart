import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compatibility_layout.dart';
import 'package:flutter/material.dart';

class CompatibilityHistoryScreen extends StatelessWidget {
  final UserModel? user;
  final void Function(SavedCompatibilityModel compatibility) onItemTap;
  final VoidCallback onNewPairPressed;

  const CompatibilityHistoryScreen({
    Key? key,
    this.user,
    required this.onItemTap,
    required this.onNewPairPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final history = user?.compatibilityHistory ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.compatibilityHistoryTitle,
          style: context.textTheme.inversePlayfairSemiBold32,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        if (history.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                context.l10n.compatibilityHistoryEmpty,
                style: context.textTheme.inverseUrbanistRegular16,
              ).withEntrance(),
            ),
          )
        else
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return Padding(
                key: ValueKey(item.id),
                padding: const EdgeInsets.only(bottom: 16),
                child: _CompatibilityHistoryItem(
                  compatibility: item,
                  onTap: () => onItemTap(item),
                ),
              );
            },
          ),
        const SizedBox(height: 8),
        CompatibilityGradientButton(
          text: context.l10n.compatibilityNewPair,
          onPressed: onNewPairPressed,
        ),
      ]),
    );
  }
}

class _CompatibilityHistoryItem extends StatelessWidget {
  final SavedCompatibilityModel compatibility;
  final VoidCallback onTap;
  const _CompatibilityHistoryItem({
    Key? key,
    required this.compatibility,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return LotusTap(
      onTap: onTap,
      child: CompatibilityGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    compatibility.createdAt.toLocalizedShortDate(locale),
                    style: context.textTheme.inverseUrbanistRegular16,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          compatibility.firstBirthdate.getZodiacSignName(
                            languageCode: locale.languageCode,
                          ),
                          style: context.textTheme.urbanistSemiBold14.copyWith(
                            color: AppColors.textInverse,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ClayAssetIcon(
                        'assets/icons/plus_icon.svg',
                        width: 12,
                        tint: AppColors.white,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          compatibility.secondBirthdate.getZodiacSignName(
                            languageCode: locale.languageCode,
                          ),
                          style: context.textTheme.urbanistSemiBold14.copyWith(
                            color: AppColors.textInverse,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              compatibility.generalPercentage,
              style: context.textTheme.playfairSemiBold20.copyWith(
                color: const Color(0xFFFFB45E),
              ),
            ),
            const SizedBox(width: 18),
            const LotusArrowBubble(),
          ],
        ),
      ),
    );
  }
}
