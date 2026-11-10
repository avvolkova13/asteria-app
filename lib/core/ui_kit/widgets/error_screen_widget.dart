import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

import 'package:asteria_app/core/extensions/build_context_extensions.dart';

import 'custom_button.dart';

class ErrorScreenWidget extends StatelessWidget {
  final String error;
  final Function() onRetry;
  const ErrorScreenWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const ClayIcon(Icons.error_outline, color: Colors.red, size: 64),
        const SizedBox(height: 16),
        Text(
          context.l10n.errorWithDetails(error),
          style: const TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        CustomButton(
          type: CustomButtonType.primary,
          onPressed: onRetry,
          text: context.l10n.commonRetry,
        ),
      ],
    );
  }
}
