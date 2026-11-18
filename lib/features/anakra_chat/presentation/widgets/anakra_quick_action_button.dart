import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:flutter/material.dart';
class AnakraQuickActionButton extends StatelessWidget {
  const AnakraQuickActionButton({
    super.key,
    required this.text,
    required this.onPressed,
  });
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AsteriaActionButton(text: text, onPressed: onPressed);
  }
}
