import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

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
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      backgroundColor: AppColorsDark.homeCanvas,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: .16,
              child: Image.asset(SonnikAssets.clouds, fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SonnikTopNavBar(title: title),
                Expanded(child: child),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: footer,
                ),
              ],
            ),
          ),
        ],
      ),
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
