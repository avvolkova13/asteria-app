import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/advice_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('animates the status title color instead of switching abruptly', (
    tester,
  ) async {
    await tester.pumpWidget(
      _adviceApp(status: DayStatus.favorable, title: 'Благоприятный день'),
    );

    expect(
      _animatedTitleStyle(tester, 'Благоприятный день')?.color,
      const Color(0xFF5FA88F),
    );

    final animatedTitle = _animatedTitle(tester, 'Благоприятный день');

    expect(animatedTitle?.duration, const Duration(milliseconds: 360));
    expect(animatedTitle?.curve, Curves.easeOutCubic);

    await tester.pumpWidget(
      _adviceApp(status: DayStatus.unfavorable, title: 'Неблагоприятный день'),
    );
    await tester.pumpAndSettle();

    expect(
      _animatedTitleStyle(tester, 'Неблагоприятный день')?.color,
      const Color(0xFFDB4C4C),
    );
  });
}

Widget _adviceApp({required DayStatus status, required String title}) {
  return MaterialApp(
    home: Builder(
      builder: (context) => Theme(
        data: AppThemeDark.instance.getThemeData(context),
        child: Scaffold(
          body: AdviceWidget(
            title: title,
            text: 'Описание статуса дня',
            status: status,
          ),
        ),
      ),
    ),
  );
}

TextStyle? _animatedTitleStyle(WidgetTester tester, String title) {
  return _animatedTitle(tester, title)?.style;
}

AnimatedDefaultTextStyle? _animatedTitle(WidgetTester tester, String title) {
  AnimatedDefaultTextStyle? animatedStyle;
  tester.element(find.text(title)).visitAncestorElements((ancestor) {
    final widget = ancestor.widget;
    if (widget is AnimatedDefaultTextStyle) {
      animatedStyle = widget;
      return false;
    }
    return true;
  });

  return animatedStyle;
}
