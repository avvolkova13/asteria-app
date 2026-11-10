import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeSwitcherWidget extends StatefulWidget {
  const ThemeSwitcherWidget({required this.initialMode, required this.child, super.key});

  final ThemeMode initialMode;
  final Widget child;

  @override
  ThemeSwitcherWidgetState createState() => ThemeSwitcherWidgetState();
}

class ThemeSwitcherWidgetState extends State<ThemeSwitcherWidget> {
  late ThemeMode themeMode;

  @override
  void initState() {
    super.initState();
    themeMode = widget.initialMode;
  }

  void switchTheme(ThemeMode mode) {
    setState(() {
      themeMode = mode;
    });

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcher(data: this, child: widget.child);
  }
}

class ThemeSwitcher extends InheritedWidget {
  const ThemeSwitcher({required this.data, required super.child, super.key});

  final ThemeSwitcherWidgetState data;

  static ThemeSwitcherWidgetState of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<ThemeSwitcher>()!).data;
  }

  @override
  bool updateShouldNotify(ThemeSwitcher old) {
    return this != old;
  }
}
