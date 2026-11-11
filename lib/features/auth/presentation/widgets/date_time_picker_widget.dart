import 'package:asteria_app/core/ui_kit/widgets/input_bubble_surface.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class DateTimePickerWidget extends StatelessWidget {
  final String? text;
  final String hintText;
  final bool enabled;
  final bool selected;
  const DateTimePickerWidget({
    super.key,
    this.text,
    required this.hintText,
    this.enabled = true,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InputBubbleSurface(
      enabled: enabled,
      focused: selected,
      child: Container(
        alignment: Alignment.centerLeft,
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          text ?? hintText,
          style: text != null
              ? context.textTheme.inputText
              : context.textTheme.inputHint,
        ),
      ),
    );
  }
}
