import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_activity_indicator.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:asteria_app/core/extensions/build_context_extensions.dart';

enum CustomButtonType { primary, secondary, outline, text, deepPurple }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final String? imageAsset;
  final double? imageWidth;
  final double? imageHeight;
  final double? width;
  final double? height;
  final FontWeight? fontWeight;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.imageAsset,
    this.imageWidth,
    this.imageHeight,
    this.width,
    this.height,
    this.fontWeight,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidget = _buildButtonWidget(context);

    if (isFullWidth || width != null || height != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: height ?? 50),
        child: SizedBox(
          width: isFullWidth ? double.infinity : width,
          child: buttonWidget,
        ),
      );
    }

    return buttonWidget;
  }

  Widget _buildButtonWidget(BuildContext context) {
    if (type == CustomButtonType.text) {
      return LotusButtons.text(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: context.colors.customButtonOutlineText,
          disabledForegroundColor: context.colors.customButtonDisabledText,
        ),
        child: _buildButtonContent(context),
      );
    }
    return AsteriaActionButton(
      onPressed: onPressed,
      isLoading: isLoading,
      height: height ?? 50,
      width: isFullWidth ? double.infinity : width,
      child: _buildButtonContent(context),
    );
  }

  TextStyle _getTextStyleForType(BuildContext context, CustomButtonType type) {
    switch (type) {
      case CustomButtonType.primary:
        return context.textTheme.button;
      case CustomButtonType.secondary:
        return context.textTheme.button.copyWith(fontSize: 16);
      case CustomButtonType.outline:
        return context.textTheme.buttonOutline;
      case CustomButtonType.text:
        return context.textTheme.button.copyWith(
          decoration: TextDecoration.underline,
        );
      case CustomButtonType.deepPurple:
        return context.textTheme.button.copyWith(color: AppColors.white);
    }
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return const AsteriaActivityIndicator(size: 20);
    }

    // Получаем стиль в зависимости от типа кнопки
    final buttonTextStyle = _getTextStyleForType(context, type);
    const double defaultIconSize = 20;

    final label = Builder(
      builder: (buttonContext) => Text(
        text,
        textAlign: TextAlign.center,
        style: buttonTextStyle.copyWith(
          fontWeight: fontWeight,
          color: onPressed == null
              ? DefaultTextStyle.of(buttonContext).style.color
              : (type == CustomButtonType.text ? textColor : null) ??
                    DefaultTextStyle.of(buttonContext).style.color,
        ),
      ),
    );

    if (imageAsset != null) {
      final width = imageWidth ?? defaultIconSize;
      final height = imageHeight ?? defaultIconSize;
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: label),
          const SizedBox(width: 10),
          LotusRasterIcon(
            imageAsset!,
            width: width,
            height: height,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClayIcon(icon, size: defaultIconSize),
          const SizedBox(width: 10),
          Flexible(child: label),
        ],
      );
    }

    return label;
  }
}
