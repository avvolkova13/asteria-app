import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/extensions/build_context_extensions.dart';
import 'package:asteria_app/core/localization/locale_formatters.dart';
import 'package:asteria_app/features/auth/localization/auth_localization_contract.dart';
import 'package:asteria_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:asteria_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:asteria_app/features/auth/domain/models/auth_identity.dart';
import 'package:asteria_app/features/auth/presentation/widgets/bottom_button_widget.dart';
import 'package:asteria_app/features/auth/presentation/widgets/data_entry_section_widget.dart';
import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
import 'package:asteria_app/features/auth/presentation/widgets/date_picker_bottom_sheet.dart';
import 'package:asteria_app/features/auth/presentation/widgets/title_section_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalInfoInputScreen extends StatefulWidget {
  final AuthIdentity identity;
  final AuthLocalizationContract authLocalization;

  const PersonalInfoInputScreen({
    super.key,
    required this.identity,
    required this.authLocalization,
  });

  @override
  State<PersonalInfoInputScreen> createState() =>
      _PersonalInfoInputScreenState();
}

class _PersonalInfoInputScreenState extends State<PersonalInfoInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().initializeUser(widget.identity);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xCC0F0A1A),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DateTimePickerBottomSheet(
          key: ObjectKey('date_picker'),
          mode: CupertinoDatePickerMode.date,
          initialDate: DateTime(2000, 1, 1),
          minimumDate: DateTime(1900, 1, 1),
          maximumDate: DateTime.now(),
          title: widget.authLocalization.birthDatePickerTitle(context),
          useAuthStyle: true,
          onDateChanged: (DateTime newDate) {
            context.read<AuthCubit>().updateUserBirthDate(newDate);
          },
        );
      },
    );
  }

  void _showTimePicker() {
    showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xCC0F0A1A),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DateTimePickerBottomSheet(
          key: ObjectKey('time_picker'),
          mode: CupertinoDatePickerMode.time,
          initialDate: DateTime(0, 0, 0, 12, 0),
          title: widget.authLocalization.birthTimePickerTitle(context),
          use24hFormat: LocaleFormatters.uses24HourFormat(context),
          useAuthStyle: true,
          onDateChanged: (DateTime newDate) {},
          onTimeChanged: (TimeOfDay newTime) {
            context.read<AuthCubit>().updateUserBirthTime(
              birthTime: DateTime(0, 0, 0, newTime.hour, newTime.minute),
              isTimeUnknown: false,
            );
          },
        );
      },
    );
  }

  void _onTimeOptionChanged(TimeOfDayEnum option) {
    DateTime birthTime;

    if (option == TimeOfDayEnum.morning) {
      birthTime = DateTime(0, 0, 0, 12, 0);
    } else {
      birthTime = DateTime(0, 0, 0, 0, 0);
    }

    context.read<AuthCubit>().updateUserBirthTime(
      birthTime: birthTime,
      isTimeUnknown: true,
      timeOption: option,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is UserSaved) {
          HomeRoute.go(context);
        } else if (state is UserSaveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_authErrorMessage(context, state.code))),
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          UserModel? currentUser;
          bool isFormValid = false;
          bool isLoading = false;
          bool isTimeUnknown = false;

          if (state is UserInitialized) {
            currentUser = state.user;
            isFormValid = state.isFormValid;
            isTimeUnknown = state.isTimeUnknown;
          } else if (state is UserUpdated) {
            currentUser = state.user;
            isFormValid = state.isFormValid;
            isTimeUnknown = state.isTimeUnknown;
          }

          if (currentUser != null) {
            if (_nameController.text != (currentUser.name ?? '')) {
              _nameController.text = currentUser.name ?? '';
            }
            if (_placeController.text !=
                (currentUser.personalInfo?.birthPlace?.location ?? '')) {
              _placeController.text =
                  currentUser.personalInfo?.birthPlace?.location ?? '';
            }
          }

          return AuthFlowScaffold(
            backgroundAsset: 'assets/images/auth/personal_info_background.webp',
            backgroundOpacity: 1,
            backgroundHeightFactor: 1,
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const TitleSectionWidget(),
                            const SizedBox(height: 24),
                            DataEntrySectionWidget(
                              currentUser: currentUser,
                              isTimeUnknown: isTimeUnknown,
                              nameController: _nameController,
                              placeController: _placeController,
                              onShowDatePicker: _showDatePicker,
                              onShowTimePicker: _showTimePicker,
                              onTimeOptionChanged: _onTimeOptionChanged,
                              authLocalization: widget.authLocalization,
                            ),
                            const SizedBox(height: 24),
                            BottomButtonWidget(
                              isFormValid: isFormValid,
                              isLoading: isLoading,
                              text: widget.authLocalization.saveButtonText(
                                context,
                              ),
                              loadingText: widget.authLocalization
                                  .saveButtonLoadingText(context),
                              onPressed: () =>
                                  context.read<AuthCubit>().saveUser(),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

String _authErrorMessage(BuildContext context, AuthErrorCode code) {
  return switch (code) {
    AuthErrorCode.userNotInitialized => context.l10n.authUserNotInitialized,
    AuthErrorCode.saveUser => context.l10n.authSaveUserError,
  };
}
