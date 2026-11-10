import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class RequestsLeftBadge extends StatelessWidget {
  final int requestsLeft;

  const RequestsLeftBadge({Key? key, required this.requestsLeft})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardTinted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        context.l10n.requestsLeftCount(requestsLeft),
        style: context.textTheme.urbanistRegular16,
      ),
    );
  }
}
