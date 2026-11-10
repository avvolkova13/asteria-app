import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

/// Виджет для отображения текста с иконкой монетки.
///
/// Два режима использования:
/// 1. [text] — простой режим: текст + иконка (для баланса и т.п.)
/// 2. [textBeforePrice] + [price] — режим с ценой: текст до цены + (цена + иконка).
///    Цена и иконка остаются вместе при переносе строки.
class TextWithCoin extends StatelessWidget {
  final String? text;
  final String? textBeforePrice;
  final String? price;
  final TextStyle? textStyle;
  final double iconSize;
  final TextAlign? textAlign;

  const TextWithCoin({
    super.key,
    this.text,
    this.textBeforePrice,
    this.price,
    this.textStyle,
    this.iconSize = 20,
    this.textAlign,
  }) : assert((text != null) != (textBeforePrice != null && price != null), 'Укажите либо text, либо textBeforePrice и price');

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? context.textTheme.urbanistRegular16;

    if (textBeforePrice != null && price != null) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: textBeforePrice, style: style),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(price!, style: style),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, top: 8),
                    child: Image.asset('assets/icons/star_coin_icon.png', height: iconSize),
                  ),
                ],
              ),
            ),
          ],
        ),
        textAlign: textAlign,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text!, style: style),
        Image.asset('assets/icons/star_coin_icon.png', height: iconSize),
      ],
    );
  }
}
