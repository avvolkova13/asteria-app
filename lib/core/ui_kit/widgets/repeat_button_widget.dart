import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RepeatButtonWidget extends StatelessWidget {
  const RepeatButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 6.0),
      child: SvgPicture.asset(
        'assets/icons/repeat_icon.svg',
        width: 24,
        height: 24,
      ),
    );
  }
}
