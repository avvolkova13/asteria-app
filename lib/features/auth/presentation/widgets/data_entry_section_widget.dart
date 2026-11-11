import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/auth/localization/auth_localization_contract.dart';
import 'package:asteria_app/features/auth/presentation/cubit/auth_cubit.dart';
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
        SegmentedPicker<Gender>(
          surfaceBrightness: Brightness.dark,
          options: Gender.values,
          selectedValue: selectedGender,
          onChanged: (gender) {
            context.read<AuthCubit>().updateUserGender(gender);
          },
          labelBuilder: (gender) =>
              authLocalization.genderLabel(context, gender),
        ).withEntrance(),
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
