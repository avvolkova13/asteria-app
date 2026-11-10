import 'package:asteria_app/features/auth/presentation/widgets/auth_flow_widgets.dart';
import 'package:flutter/material.dart';

class BottomButtonWidget extends StatelessWidget {
  final bool isFormValid;
  final bool isLoading;
  final String text;
  final String loadingText;
  final VoidCallback onPressed;

  const BottomButtonWidget({
    super.key,
    required this.isFormValid,
    required this.isLoading,
    required this.text,
    required this.loadingText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AuthGradientButton(
      text: isLoading ? loadingText : text,
      onPressed: isFormValid && !isLoading ? onPressed : null,
      isLoading: isLoading,
    );
  }
}
