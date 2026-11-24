import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:flutter/material.dart';

class JournalAddButton extends StatelessWidget {
  const JournalAddButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: LotusButtons.text(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColorsDark.linkGold,
        minimumSize: const Size(44, 48),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(
            dimension: 28,
            child: LotusIconSurface(
              diameter: 28,
              child: Center(
                child: ClayIcon(
                  Icons.add,
                  size: 18,
                  color: AppColorsDark.linkGold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: context.textTheme.inverseUrbanistMedium16.copyWith(
                color: AppColorsDark.linkGold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class JournalEntryMenu extends StatelessWidget {
  const JournalEntryMenu({
    super.key,
    required this.label,
    required this.deleteLabel,
    required this.onDelete,
  });
  final String label, deleteLabel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: label,
    enabled: onDelete != null,
    constraints: const BoxConstraints(minWidth: 180),
    icon: const ClayIcon(
      Icons.more_horiz,
      size: 22,
      color: AppColors.cardTinted,
    ),
    padding: const EdgeInsets.all(12),
    onSelected: (_) => onDelete?.call(),
    itemBuilder: (_) => [
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
            const SizedBox(width: 10),
            Flexible(child: Text(deleteLabel)),
          ],
        ),
      ),
    ],
  );
}
