import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool? isExit;
  final String icon;
  const SettingsListTile({Key? key, required this.title, required this.onTap, this.isExit = false, required this.icon})
    : super(key: key);

  Widget _buildIcon(BuildContext context) {
    if (isExit != null && isExit!) {
      return Container(
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(8),
        child: ClayAssetIcon(
          'assets/icons/exit_icon.svg',
          height: 20,
          tint: AppColors.white,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(8),
      child: ClayAssetIcon('assets/icons/${icon}.svg', height: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LotusTap(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildIcon(context),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(title, style: context.textTheme.urbanistRegular17),
                      Spacer(),
                      isExit != null && isExit!
                          ? ClayAssetIcon('assets/icons/exit_icon.svg', height: 24)
                          : ClayAssetIcon('assets/icons/right_arrow_icon.svg', height: 24),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, thickness: 1, color: AppColors.surface),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
