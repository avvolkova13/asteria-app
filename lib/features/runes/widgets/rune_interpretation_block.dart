import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class _RuneInterpretationColors {
  static const text = Color(0xFFEEEAFD);
}

class RuneInterpretationBlock extends StatelessWidget {
  final String interpretation;

  const RuneInterpretationBlock({Key? key, required this.interpretation})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      interpretation,
      style: context.textTheme.urbanistRegular16.copyWith(
        color: _RuneInterpretationColors.text,
        height: 1.2,
        letterSpacing: -0.408,
      ),
    );
  }
}
