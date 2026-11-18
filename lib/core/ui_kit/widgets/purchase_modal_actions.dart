import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:flutter/material.dart';

/// Keeps purchase actions readable when Dynamic Type needs the full width.
class PurchaseModalActions extends StatelessWidget {
  const PurchaseModalActions({
    super.key,
    required this.primary,
    required this.cancelLabel,
    required this.onCancel,
  });
  final Widget primary;
  final String cancelLabel;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final cancel = LotusButtons.text(
      onPressed: onCancel,
      style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
      child: Text(
        cancelLabel,
        textAlign: TextAlign.center,
        style: context.textTheme.inverseUrbanistSemiBold16,
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 320 ||
            MediaQuery.textScalerOf(context).scale(16) > 22;
        if (stacked) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [primary, const SizedBox(height: 8), cancel],
          );
        }
        return Row(
          children: [
            Expanded(child: cancel),
            const SizedBox(width: 12),
            Expanded(child: primary),
          ],
        );
      },
    );
  }
}
