import 'package:flutter/widgets.dart';

class ScenarioSky extends StatelessWidget {
  const ScenarioSky({super.key});

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/scenarios/scenario_sky.webp',
    fit: BoxFit.cover,
    excludeFromSemantics: true,
  );
}

/// Keeps scenario styling through pushes into features that also have standalone entries.
class ScenarioSkyScope extends InheritedWidget {
  const ScenarioSkyScope({super.key, required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ScenarioSkyScope>() != null;

  @override
  bool updateShouldNotify(ScenarioSkyScope oldWidget) => false;
}
