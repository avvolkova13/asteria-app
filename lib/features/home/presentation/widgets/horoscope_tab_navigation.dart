import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

/// Навигация по табам гороскопа (SegmentedPicker)
class HoroscopeTabNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final List<String> titles;

  const HoroscopeTabNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.titles,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedPicker.indexed(
      titles: titles,
      selectedIndex: selectedIndex,
      onTabSelected: onTabSelected,
    );
  }
}
