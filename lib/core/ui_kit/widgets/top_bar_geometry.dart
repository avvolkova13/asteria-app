import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared toolbar geometry. SafeArea belongs to the screen or sliver, once.
abstract final class AsteriaTopBarMetrics {
  static const double toolbarHeight = 52;
  static const double horizontalInset = 16;

  static double heightOf(BuildContext context) => math.max(
    toolbarHeight,
    MediaQuery.textScalerOf(context).scale(17) * 1.2 + 8,
  );
}

class AsteriaTopBarFrame extends StatelessWidget {
  const AsteriaTopBarFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AsteriaTopBarMetrics.horizontalInset,
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: AsteriaTopBarMetrics.heightOf(context),
    ),
    child: Center(
      heightFactor: 1,
      child: Padding(padding: padding, child: child),
    ),
  );
}

/// One title-fit decision shared by normal headers and their pinned slivers.
class AsteriaTopBarLayout {
  const AsteriaTopBarLayout._({
    required this.width,
    required this.separateTitle,
    required this.height,
    required this.actionRowHeight,
    required this.actionRunHeight,
    required this.actionInset,
  });
  final double width;
  final bool separateTitle;
  final double height;
  final double actionRowHeight;
  final double actionRunHeight;
  final double actionInset;

  static Size textSize(
    BuildContext context,
    String text,
    TextStyle style, {
    double maxWidth = double.infinity,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
    )..layout(maxWidth: maxWidth);
    final size = painter.size;
    painter.dispose();
    return size;
  }

  factory AsteriaTopBarLayout.resolve(
    BuildContext context, {
    required String title,
    required TextStyle titleStyle,
    required List<double> actionWidths,
    required double width,
    required double leadingWidth,
    double inlineGap = 8,
    double? baseHeight,
    double? stackedLeadingWidth,
    double expandedTitleLeadingWidth = 0,
    double expandedTitleMinHeight = 0,
  }) {
    final base = baseHeight ?? AsteriaTopBarMetrics.heightOf(context);
    final available = math.max(
      1.0,
      width - AsteriaTopBarMetrics.horizontalInset * 2,
    );
    final actionsWidth =
        actionWidths.fold(0.0, (sum, item) => sum + item) +
        math.max(0, actionWidths.length - 1) * 8;
    final remaining = available - leadingWidth - inlineGap - actionsWidth;
    final largeText = MediaQuery.textScalerOf(context).scale(17) > 17.01;
    final separate =
        remaining < 0 ||
        (largeText && textSize(context, title, titleStyle).width > remaining);
    final runHeight = math.max(
      44.0,
      MediaQuery.textScalerOf(context).scale(17) * 1.2,
    );
    final inset = math.max(0.0, (base - runHeight) / 2);
    var runs = 1;
    var used = 0.0;
    final actionSpace = math.max(
      1.0,
      available - (stackedLeadingWidth ?? (leadingWidth > 0 ? 52 : 0)),
    );
    for (final item in actionWidths) {
      final next = used == 0 ? item : used + 8 + item;
      if (used > 0 && next > actionSpace) {
        runs++;
        used = item;
      } else {
        used = next;
      }
    }
    final rowHeight = math.max(
      base,
      runs * runHeight + (runs - 1) * 8 + inset * 2,
    );
    final titleHeight = math.max(
      expandedTitleMinHeight,
      textSize(
        context,
        title,
        titleStyle,
        maxWidth: math.max(1.0, available - expandedTitleLeadingWidth),
      ).height,
    );
    return AsteriaTopBarLayout._(
      width: width,
      separateTitle: separate,
      height: separate ? rowHeight + 8 + titleHeight : base,
      actionRowHeight: rowHeight,
      actionRunHeight: runHeight,
      actionInset: inset,
    );
  }
}

/// Keeps the established row when it fits; otherwise actions precede the full title.
class AsteriaAdaptiveTopBar extends StatelessWidget {
  const AsteriaAdaptiveTopBar({
    super.key,
    required this.title,
    required this.titleStyle,
    required this.actions,
    required this.actionWidths,
    required this.inline,
    this.leading,
    this.leadingWidth = 0,
    this.inlineGap = 8,
    this.layout,
    this.expandedTitle,
    this.expandedTitleLeadingWidth = 0,
    this.expandedTitleMinHeight = 0,
  });
  final String title;
  final TextStyle titleStyle;
  final List<Widget> actions;
  final List<double> actionWidths;
  final Widget inline;
  final Widget? leading;
  final double leadingWidth;
  final double inlineGap;
  final AsteriaTopBarLayout? layout;
  final Widget? expandedTitle;
  final double expandedTitleLeadingWidth;
  final double expandedTitleMinHeight;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final geometry =
          layout ??
          AsteriaTopBarLayout.resolve(
            context,
            title: title,
            titleStyle: titleStyle,
            actionWidths: actionWidths,
            width: constraints.maxWidth,
            leadingWidth: leadingWidth,
            inlineGap: inlineGap,
            stackedLeadingWidth: leading == null ? 0 : 52,
            expandedTitleLeadingWidth: expandedTitleLeadingWidth,
            expandedTitleMinHeight: expandedTitleMinHeight,
          );
      if (!geometry.separateTitle) return AsteriaTopBarFrame(child: inline);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AsteriaTopBarFrame(
            child: SizedBox(
              height: geometry.actionRowHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (leading != null) ...[
                    Padding(
                      padding: EdgeInsets.only(top: geometry.actionInset),
                      child: leading!,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: geometry.actionInset,
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final action in actions)
                            SizedBox(
                              height: geometry.actionRunHeight,
                              child: Align(
                                widthFactor: 1,
                                heightFactor: 1,
                                child: action,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: expandedTitle ?? Text(title, style: titleStyle),
          ),
        ],
      );
    },
  );
}
