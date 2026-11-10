import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/utils/utils.dart';
import 'package:asteria_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:asteria_app/features/auth/presentation/widgets/radio_button_group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';

const _authInputFill = Color(0x339A7DB8);
const _authInputDarkFill = Color(0x331E1640);
const _authPanelFill = Color(0xFF151028);
const _authMutedText = Color(0xFFB5AAB8);
const _authPurpleStart = Color(0xFF6E4BFF);
const _authPurpleEnd = Color(0xFF5A3FD1);

class InputsSectionWidget extends StatefulWidget {
  final UserModel? currentUser;
  final DateTime? selectedDate;
  final DateTime? selectedTime;
  final bool isTimeUnknown;
  final TimeOfDayEnum selectedTimeOption;
  final TextEditingController nameController;
  final TextEditingController placeController;
  final VoidCallback onShowDatePicker;
  final VoidCallback onShowTimePicker;
  final ValueChanged<TimeOfDayEnum> onTimeOptionChanged;
  final String birthDateLabel;
  final String birthTimeLabel;
  final String nameLabel;
  final String placeLabel;
  final String exactTimeUnknown;
  final String exactTimeUnknownDescription;

  const InputsSectionWidget({
    super.key,
    required this.currentUser,
    required this.selectedDate,
    required this.selectedTime,
    required this.isTimeUnknown,
    required this.selectedTimeOption,
    required this.nameController,
    required this.placeController,
    required this.onShowDatePicker,
    required this.onShowTimePicker,
    required this.onTimeOptionChanged,
    required this.birthDateLabel,
    required this.birthTimeLabel,
    required this.nameLabel,
    required this.placeLabel,
    required this.exactTimeUnknown,
    required this.exactTimeUnknownDescription,
  });

  @override
  State<InputsSectionWidget> createState() => _InputsSectionWidgetState();
}

class _InputsSectionWidgetState extends State<InputsSectionWidget> {
  late final FocusNode _nameFocusNode;
  late final FocusNode _placeFocusNode;

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();
    _placeFocusNode = FocusNode();
    widget.nameController.addListener(_handleControllerChanged);
    widget.placeController.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(InputsSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nameController != widget.nameController) {
      oldWidget.nameController.removeListener(_handleControllerChanged);
      widget.nameController.addListener(_handleControllerChanged);
    }
    if (oldWidget.placeController != widget.placeController) {
      oldWidget.placeController.removeListener(_handleControllerChanged);
      widget.placeController.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_handleControllerChanged);
    widget.placeController.removeListener(_handleControllerChanged);
    _nameFocusNode.dispose();
    _placeFocusNode.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AuthTextInput(
          hintText: widget.nameLabel,
          controller: widget.nameController,
          focusNode: _nameFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _placeFocusNode.requestFocus(),
          onChanged: (value) {
            context.read<AuthCubit>().updateUserName(value);
          },
        ),
        const SizedBox(height: 16),
        _buildPlaceInput(context),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _AuthDateTimeField(
                text: widget.selectedDate != null
                    ? formatDate(
                        context,
                        widget.selectedDate,
                        widget.birthDateLabel,
                      )
                    : null,
                hintText: widget.birthDateLabel,
                onTap: widget.onShowDatePicker,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AuthDateTimeField(
                text: widget.selectedTime != null
                    ? formatTime(
                        context,
                        TimeOfDay(
                          hour: widget.selectedTime!.hour,
                          minute: widget.selectedTime!.minute,
                        ),
                        widget.birthTimeLabel,
                      )
                    : null,
                hintText: widget.birthTimeLabel,
                onTap: widget.onShowTimePicker,
                isEnabled: !widget.isTimeUnknown,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _AuthCheckbox(
          value: widget.isTimeUnknown,
          label: widget.exactTimeUnknown,
          onChanged: (value) {
            if (value) {
              context.read<AuthCubit>().updateUserBirthTime(
                birthTime: DateTime(0, 0, 0, 12, 0),
                isTimeUnknown: value,
                timeOption: TimeOfDayEnum.morning,
              );
            } else {
              context.read<AuthCubit>().updateUserBirthTime(
                isTimeUnknown: value,
              );
            }
          },
        ),
        if (widget.isTimeUnknown) ...[
          const SizedBox(height: 16),
          Text(
            widget.exactTimeUnknownDescription,
            style: context.textTheme.inverseUrbanistRegular16.copyWith(
              height: 1.2,
              letterSpacing: -0.408,
            ),
          ),
          const SizedBox(height: 24),
          RadioButtonGroup(
            selectedValue: widget.selectedTimeOption,
            onChanged: widget.onTimeOptionChanged,
            isEnabled: true,
          ),
        ],
      ],
    );
  }

  Widget _buildPlaceInput(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.white,
        ),
      ),
      child: GooglePlaceAutoCompleteTextField(
        boxDecoration: BoxDecoration(
          gradient: _authInputGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        textEditingController: widget.placeController,
        focusNode: _placeFocusNode,
        googleAPIKey: di.get<Environment>().googleMapsApiKey,
        inputDecoration: InputDecoration(
          hintText: widget.placeLabel,
          hintStyle: _inputTextStyle(
            context,
          ).copyWith(color: AppColors.white.withValues(alpha: 0.5)),
          border: _transparentBorder,
          focusedBorder: _transparentBorder,
          enabledBorder: _transparentBorder,
          disabledBorder: _transparentBorder,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          filled: false,
          fillColor: Colors.transparent,
          suffixIcon: widget.placeController.text.isNotEmpty
              ? LotusButtons.icon(
                  onPressed: () {
                    widget.placeController.clear();
                    context.read<AuthCubit>().updateUserBirthPlace('');
                  },
                  icon: const ClayIcon(
                    CupertinoIcons.clear_circled_solid,
                    color: _authMutedText,
                    size: 20,
                  ),
                  padding: const EdgeInsets.only(right: 10),
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                )
              : null,
        ),
        textStyle: _inputTextStyle(context),
        debounceTime: 600,
        language: Localizations.localeOf(context).languageCode,
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          context.read<AuthCubit>().updateUserBirthPlace(
            prediction.description ?? '',
            latitude: double.tryParse(prediction.lat ?? '0'),
            longitude: double.tryParse(prediction.lng ?? '0'),
          );
        },
        itemClick: (Prediction prediction) {
          final description = prediction.description ?? '';
          widget.placeController.text = description;
          widget.placeController.selection = TextSelection.fromPosition(
            TextPosition(offset: description.length),
          );
        },
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            height: 36,
            color: _authPanelFill,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              prediction.description ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.inverseUrbanistRegular16.copyWith(
                height: 1.2,
                letterSpacing: -0.408,
              ),
            ),
          );
        },
        seperatedBuilder: const Divider(
          height: 1,
          thickness: 1,
          indent: 8,
          endIndent: 8,
          color: Color(0x1AEEEAFD),
        ),
        isCrossBtnShown: false,
        containerHorizontalPadding: 0,
        placeType: PlaceType.cities,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
      ),
    );
  }
}

class _AuthTextInput extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  const _AuthTextInput({
    required this.hintText,
    required this.controller,
    this.focusNode,
    this.textInputAction,
    required this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: _authInputGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.name,
              textInputAction: textInputAction ?? TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: _inputTextStyle(context),
              cursorColor: AppColors.white,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: _inputTextStyle(
                  context,
                ).copyWith(color: AppColors.white.withValues(alpha: 0.5)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            LotusButtons.icon(
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              icon: const ClayIcon(
                CupertinoIcons.clear_circled_solid,
                color: _authMutedText,
                size: 20,
              ),
              padding: const EdgeInsets.only(right: 10),
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
        ],
      ),
    );
  }
}

class _AuthDateTimeField extends StatelessWidget {
  final String? text;
  final String hintText;
  final VoidCallback onTap;
  final bool isEnabled;

  const _AuthDateTimeField({
    required this.text,
    required this.hintText,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = text != null;

    return LotusTap(
      behavior: HitTestBehavior.opaque,
      onTap: isEnabled ? onTap : null,
      child: Semantics(
        button: true,
        enabled: isEnabled,
        label: text ?? hintText,
        child: Container(
          height: 50,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: _authInputGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text ?? hintText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _inputTextStyle(context).copyWith(
              color: hasValue
                  ? AppColors.white.withValues(alpha: isEnabled ? 1 : 0.55)
                  : AppColors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthCheckbox extends StatelessWidget {
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  const _AuthCheckbox({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LotusFeedback(
      onActivate: () => onChanged(!value),
      keyboard: true,
      builder: (activate) => Semantics(
        button: true,
        checked: value,
        enabled: true,
        label: label,
        onTap: activate,
        child: Semantics(
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: activate,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                children: [
                  Container(
                    width: 23,
                    height: 23,
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_authPurpleStart, _authPurpleEnd],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0A1A),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: value
                          ? ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [_authPurpleStart, _authPurpleEnd],
                              ).createShader(bounds),
                              child: const ClayIcon(
                                Icons.check,
                                color: AppColors.white,
                                size: 18,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: context.textTheme.inverseUrbanistRegular16.copyWith(
                        height: 1.2,
                        letterSpacing: -0.408,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle _inputTextStyle(BuildContext context) {
  return context.textTheme.inverseUrbanistRegular17.copyWith(
    color: AppColors.white,
    height: 1.2,
    letterSpacing: -0.408,
  );
}

const _transparentBorder = OutlineInputBorder(
  borderSide: BorderSide.none,
  borderRadius: BorderRadius.all(Radius.circular(16)),
);

const _authInputGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [_authInputDarkFill, _authInputFill],
);
