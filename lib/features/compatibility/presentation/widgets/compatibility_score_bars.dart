import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class CompatibilityScoreBars extends StatelessWidget {
  final double love;
  final double conflicts;
  final double family;

  final String? loveLabel;
  final String? conflictsLabel;
  final String? familyLabel;

  const CompatibilityScoreBars({
    super.key,
    required this.love,
    required this.conflicts,
    required this.family,
    this.loveLabel,
    this.conflictsLabel,
    this.familyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        _ScoreBarRow(label: loveLabel ?? context.l10n.compatibilityLove, percent: love.clamp(0, 100), color: secondary, backgroundColor: AppColors.uiDisabled),
        const SizedBox(height: 12),
        _ScoreBarRow(
          label: conflictsLabel ?? context.l10n.compatibilityConflicts,
          percent: conflicts.clamp(0, 100),
          color: secondary,
          backgroundColor: AppColors.uiDisabled,
        ),
        const SizedBox(height: 12),
        _ScoreBarRow(
          label: familyLabel ?? context.l10n.compatibilityFamily,
          percent: family.clamp(0, 100),
          color: secondary,
          backgroundColor: AppColors.uiDisabled,
        ),
      ]),
    );
  }
}

class _ScoreBarRow extends StatelessWidget {
  final String label;
  final double percent; // 0..100
  final Color color;
  final Color backgroundColor;

  const _ScoreBarRow({required this.label, required this.percent, required this.color, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final value = (percent / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: context.textTheme.urbanistSemiBold16)),
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: context.textTheme.urbanistSemiBold16.copyWith(color: AppColors.secondary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ),
      ],
    );
  }
}
