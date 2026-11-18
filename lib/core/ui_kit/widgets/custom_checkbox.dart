import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:flutter/material.dart';

class CheckboxMark extends StatelessWidget {
  const CheckboxMark({
    super.key,
    required this.value,
    this.enabled = true,
    this.surfaceBrightness,
  });
  final bool value;
  final bool enabled;
  final Brightness? surfaceBrightness;

  @override
  Widget build(BuildContext context) {
    final dark =
        (surfaceBrightness ?? Theme.of(context).brightness) == Brightness.dark;
    return Container(
      width: 23,
      height: 23,
      alignment: Alignment.center,
      decoration: CardLensDecoration.button(
        enabled: enabled,
        borderRadius: BorderRadius.circular(6),
        color: dark
            ? AppColorsDark.secondary
            : context.colors.customButtonDisabledBackground,
        gradient: value && enabled
            ? CardLensDecoration.buttonFill(
                dark
                    ? AppColors.deepPurple
                    : context.colors.customButtonPrimaryBackground,
              )
            : null,
      ),
      child: value
          ? ClayIcon(
              Icons.check,
              size: 16,
              color: enabled
                  ? AppColors.white
                  : (dark
                        ? AppColorsDark.textTertiary
                        : context.colors.textTertiary),
            )
          : null,
    );
  }
}

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) => LotusFeedback(
    onActivate: onChanged == null ? null : () => onChanged!(!value),
    keyboard: true,
    builder: (activate) => Semantics(
      checked: value,
      enabled: onChanged != null,
      label: label,
      onTap: activate,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: activate,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: Row(
              mainAxisSize: label == null ? MainAxisSize.min : MainAxisSize.max,
              children: [
                CheckboxMark(value: value, enabled: onChanged != null),
                if (label != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label!,
                      style: AppTypography.text1.copyWith(
                        color: onChanged != null
                            ? context.colors.textPrimary
                            : context.colors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
