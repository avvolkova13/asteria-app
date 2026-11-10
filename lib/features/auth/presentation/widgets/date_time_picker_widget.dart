import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class DateTimePickerWidget extends StatelessWidget {
  final String? text;
  final String hintText;
  const DateTimePickerWidget({Key? key, this.text, required this.hintText})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
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
