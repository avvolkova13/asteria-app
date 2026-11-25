import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/cupertino.dart';

class DreamJournalScaffold extends StatelessWidget {
  const DreamJournalScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.footer,
  });
  final String title;
  final Widget child, footer;
  @override
  Widget build(BuildContext context) => SonnikPageScaffold(
    title: title,
    resizeToAvoidBottomInset: true,
    child: Column(
      children: [
        Expanded(child: child),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: footer,
        ),
      ],
    ),
  );
}

Widget dreamJournalDialog(Widget child) => CupertinoTheme(
  data: const CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColorsDark.linkGold,
  ),
  child: child,
);
