import 'package:flutter/material.dart';

/// Keeps a short reading together on iPad while longer readings scroll naturally.
class ReadingContentSliver extends StatelessWidget {
  const ReadingContentSliver({
    super.key,
    required this.maxWidth,
    required this.child,
  });

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    return SliverLayoutBuilder(
      builder: (context, viewport) {
        final availableHeight =
            viewport.viewportMainAxisExtent - viewport.precedingScrollExtent;
        return SliverToBoxAdapter(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: tablet && availableHeight > 0 ? availableHeight : 0,
            ),
            child: Align(
              alignment: tablet ? const Alignment(0, -.3) : Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
