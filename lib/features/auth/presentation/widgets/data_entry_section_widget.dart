import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/auth/localization/auth_localization_contract.dart';
import 'package:asteria_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
import 'package:asteria_app/features/auth/presentation/widgets/inputs_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataEntrySectionWidget extends StatelessWidget {
  final UserModel? currentUser;
  final bool isTimeUnknown;
  final TextEditingController nameController;
  final TextEditingController placeController;
  final VoidCallback onShowDatePicker;
  final VoidCallback onShowTimePicker;
  final ValueChanged<TimeOfDayEnum> onTimeOptionChanged;
  final AuthLocalizationContract authLocalization;

  const DataEntrySectionWidget({
    super.key,
    required this.currentUser,
    required this.isTimeUnknown,
    required this.nameController,
    required this.placeController,
    required this.onShowDatePicker,
    required this.onShowTimePicker,
    required this.onTimeOptionChanged,
    required this.authLocalization,
  });

  TimeOfDayEnum _getSelectedTimeOption(
    UserModel? user,
    bool isTimeUnknown,
    BuildContext context,
  ) {
    if (!isTimeUnknown) {
      return TimeOfDayEnum.unknown;
    }

    final cubit = context.read<AuthCubit>();
    final lastOption = cubit.lastSelectedTimeOption;

    if (lastOption != null) {
      return lastOption;
    }

    final birthTime = user?.personalInfo?.birthDate?.birthTime;
    if (birthTime == null) {
      return TimeOfDayEnum.unknown;
    }

    if (birthTime.hour == 12 && birthTime.minute == 0) {
      return TimeOfDayEnum.morning;
    } else if (birthTime.hour == 0 && birthTime.minute == 0) {
      return TimeOfDayEnum.unknown;
    }

    return TimeOfDayEnum.unknown;
  }

  @override
  Widget build(BuildContext context) {
    final selectedGender = currentUser?.personalInfo?.gender ?? Gender.female;
    final selectedDate = currentUser?.personalInfo?.birthDate?.birthDate;
    final selectedTime = currentUser?.personalInfo?.birthDate?.birthTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AuthGenderSegmentedPicker(
          options: Gender.values,
          selectedValue: selectedGender,
          onChanged: (gender) {
            context.read<AuthCubit>().updateUserGender(gender);
          },
          labelBuilder: (gender) =>
              authLocalization.genderLabel(context, gender),
        ),
        const SizedBox(height: 12),
        InputsSectionWidget(
          currentUser: currentUser,
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          isTimeUnknown: isTimeUnknown,
          selectedTimeOption: _getSelectedTimeOption(
            currentUser,
            isTimeUnknown,
            context,
          ),
          nameController: nameController,
          placeController: placeController,
          onShowDatePicker: onShowDatePicker,
          onShowTimePicker: onShowTimePicker,
          onTimeOptionChanged: onTimeOptionChanged,
          birthDateLabel: authLocalization.birthDateLabel(context),
          birthTimeLabel: authLocalization.birthTimeLabel(context),
          nameLabel: authLocalization.nameLabel(context),
          placeLabel: authLocalization.placeLabel(context),
          exactTimeUnknown: authLocalization.exactTimeUnknown(context),
          exactTimeUnknownDescription: authLocalization
              .exactTimeUnknownDescription(context),
        ),
      ],
    );
  }
}

class _AuthGenderSegmentedPicker extends StatelessWidget {
  final List<Gender> options;
  final Gender selectedValue;
  final ValueChanged<Gender> onChanged;
  final String Function(Gender) labelBuilder;

  const _AuthGenderSegmentedPicker({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 32,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1433),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                for (final option in options)
                  Expanded(
                    child: _AuthGenderSegment(
                      label: labelBuilder(option),
                      isSelected: option == selectedValue,
                    ),
                  ),
              ],
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                for (final option in options)
                  Expanded(
                    child: _AuthGenderHitTarget(
                      label: labelBuilder(option),
                      isSelected: option == selectedValue,
                      onTap: () => onChanged(option),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthGenderHitTarget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AuthGenderHitTarget({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: LotusTap(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _AuthGenderSegment extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _AuthGenderSegment({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: context.textTheme.inverseUrbanistRegular12.copyWith(
        color: isSelected ? AppColors.white : const Color(0xFFB5AAB8),
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        height: 1.2,
        letterSpacing: -0.08,
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF151028) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: const Color(0xFF31296D)) : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: isSelected
          ? ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => authGoldGradient.createShader(bounds),
              child: text,
            )
          : text,
    );
  }
}
