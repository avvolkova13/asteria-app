import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseScaffold extends StatelessWidget {
  final Widget child;
  final bool resizeToAvoidBottomInset;
  final bool showAppBar;
  const BaseScaffold({super.key, required this.child, this.resizeToAvoidBottomInset = false, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: showAppBar,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: LotusButtons.icon(
                onPressed: () => Navigator.pop(context),
                icon: const LotusArrowBubble(back: true),
              ),
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
            )
          : null,
      body: Container(
        // TODO: add bg image for dark and light theme
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/background/bg_light.webp'), fit: BoxFit.cover),
        ),
        child: child,
      ),
    );
  }
}
