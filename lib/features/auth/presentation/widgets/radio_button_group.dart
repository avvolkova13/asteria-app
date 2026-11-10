import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/extensions/enum_extensions.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
import 'package:flutter/material.dart';

class RadioButtonGroup extends StatelessWidget {
  final TimeOfDayEnum selectedValue;
  final ValueChanged<TimeOfDayEnum> onChanged;
  final bool isEnabled;

  const RadioButtonGroup({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 42,
        runSpacing: 10,
        children: [
          _AuthRadioButton(
            option: TimeOfDayEnum.morning,
            isSelected: selectedValue == TimeOfDayEnum.morning,
            isEnabled: isEnabled,
            onChanged: onChanged,
          ),
          _AuthRadioButton(
            option: TimeOfDayEnum.unknown,
            isSelected: selectedValue == TimeOfDayEnum.unknown,
            isEnabled: isEnabled,
            onChanged: onChanged,
          ),
          _AuthRadioButton(
            option: TimeOfDayEnum.night,
            isSelected: selectedValue == TimeOfDayEnum.night,
            isEnabled: isEnabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AuthRadioButton extends StatelessWidget {
  final TimeOfDayEnum option;
  final bool isSelected;
  final bool isEnabled;
  final ValueChanged<TimeOfDayEnum> onChanged;

  const _AuthRadioButton({
    required this.option,
    required this.isSelected,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final optionLabel = option.label(context);
    final label = Text(
      optionLabel,
      style: context.textTheme.inverseUrbanistRegular16.copyWith(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        height: 1.2,
        letterSpacing: -0.408,
      ),
    );

    return LotusFeedback(
      onActivate: isEnabled ? () => onChanged(option) : null,
      keyboard: true,
      builder: (activate) => Semantics(
        button: true,
        checked: isSelected,
        enabled: isEnabled,
        label: optionLabel,
        onTap: activate,
        child: Semantics(
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: activate,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RadioMark(isSelected: isSelected),
                    const SizedBox(width: 8),
                    label,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  final bool isSelected;

  const _RadioMark({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      padding: const EdgeInsets.all(1),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: authGoldGradient,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF0F0A1A),
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: authGoldGradient,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
