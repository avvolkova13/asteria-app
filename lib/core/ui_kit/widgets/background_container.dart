import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final bool expanded;

  const BackgroundContainer({
    super.key,
    required this.child,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );

    if (!expanded) {
      return container;
    }

    return Expanded(child: container);
  }
}
