import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:flutter/material.dart';

class RequestsLeftBadge extends StatelessWidget {
  final int? requestsLeft;
  final String? _label;

  const RequestsLeftBadge({super.key, required int this.requestsLeft})
    : _label = null;
  const RequestsLeftBadge.label(String label, {super.key})
    : _label = label,
      requestsLeft = null;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: CardLensDecoration.button(
        color: AppColorsDark.modal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          _label ?? context.l10n.requestsLeftCount(requestsLeft!),
          style: context.textTheme.urbanistRegular12.copyWith(
            color: AppColorsDark.linkGold,
          ),
        ),
      ),
    );
  }
}
