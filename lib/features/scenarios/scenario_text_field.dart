import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/input_bubble_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScenarioTextField extends StatelessWidget {
  const ScenarioTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.controller,
    this.initialValue,
    this.hint,
    this.minLines = 1,
    this.maxLines,
    this.textInputAction,
    this.inputFormatters,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String? initialValue, hint;
  final int minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ExcludeSemantics(
        child: Text(label, style: context.textTheme.inverseUrbanistRegular16),
      ),
      const SizedBox(height: 8),
      DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColorsDark.modal,
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        child: InputBubbleSurface(
          surfaceBrightness: Brightness.dark,
          child: Semantics(
            label: label,
            child: TextFormField(
              controller: controller,
              initialValue: initialValue,
              onChanged: onChanged,
              minLines: minLines,
              maxLines: maxLines,
              textInputAction: textInputAction,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: inputFormatters,
              style: context.textTheme.inverseUrbanistRegular16.copyWith(
                color: AppColors.textInverse,
              ),
              cursorColor: AppColors.textInverse,
              decoration: InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintText: hint,
                hintStyle: AppTypography.text2.copyWith(
                  color: AppColors.cardTinted,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
