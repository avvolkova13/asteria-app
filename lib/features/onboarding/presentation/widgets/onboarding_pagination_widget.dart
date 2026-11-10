import 'package:flutter/material.dart';

class OnboardingPaginationWidget extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final Color activeColor;
  final Color inactiveColor;

  const OnboardingPaginationWidget({
    super.key,
    required this.totalPages,
    required this.currentPage,
    this.activeColor = const Color(0xFFEEEAFD),
    this.inactiveColor = const Color(0xFFEEEAFD),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        totalPages,
        (index) => Expanded(
          child: Container(
            height: 2,
            margin: EdgeInsets.only(right: index < totalPages - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: index == currentPage
                  ? activeColor
                  : inactiveColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}
