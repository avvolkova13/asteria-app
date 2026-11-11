import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String? error;
  const ErrorScreen({Key? key, this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: AsteriaEntrance.sections([
        Text(
          context.l10n.genericSomethingWrong,
          style: context.textTheme.playfairSemiBold24,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          error ?? context.l10n.genericCheckConnection,
          style: context.textTheme.urbanistRegular16,
          textAlign: TextAlign.center,
        ),
        Image.asset('assets/background/error_image.webp', height: 300),
        const SizedBox(height: 150),
      ]),
    );
  }
}
