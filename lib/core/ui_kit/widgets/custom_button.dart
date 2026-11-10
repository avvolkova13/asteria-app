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

    if (isFullWidth) {
      return SizedBox(width: double.infinity, height: height ?? 50, child: buttonWidget);
    }

    if (width != null || height != null) {
      return SizedBox(width: width, height: height ?? 50, child: buttonWidget);
    }

    return buttonWidget;
  }

  Widget _buildButtonWidget(BuildContext context) {
    switch (type) {
      case CustomButtonType.primary:
        return _buildPrimaryButton(context);
      case CustomButtonType.secondary:
        return _buildSecondaryButton(context);
      case CustomButtonType.outline:
        return _buildOutlineButton(context);
      case CustomButtonType.text:
        return _buildTextButton(context);
      case CustomButtonType.deepPurple:
        return _buildDeepPurpleButton(context);
    }
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.colors.customButtonPrimaryBackground,
        foregroundColor: context.colors.customButtonPrimaryText,
        disabledBackgroundColor: context.colors.customButtonDisabledBackground,
        disabledForegroundColor: context.colors.customButtonDisabledText,
      ),
      child: _buildButtonContent(context),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textPrimary,
        disabledBackgroundColor: context.colors.customButtonDisabledBackground,
        disabledForegroundColor: context.colors.customButtonDisabledText,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _buildButtonContent(context),
    );
  }

  Widget _buildOutlineButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colors.customButtonOutlineText,
        disabledForegroundColor: context.colors.customButtonDisabledText,
        side: BorderSide(
          color: (isLoading || onPressed == null)
              ? context.colors.customButtonDisabledBackground
              : context.colors.customButtonOutlineBorder,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _buildButtonContent(context),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: context.colors.customButtonOutlineText,
        disabledForegroundColor: context.colors.customButtonDisabledText,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _buildButtonContent(context),
    );
  }

  Widget _buildDeepPurpleButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.deepPurple,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: context.colors.customButtonDisabledBackground,
        disabledForegroundColor: context.colors.customButtonDisabledText,
      ),
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
        return context.textTheme.button.copyWith(decoration: TextDecoration.underline);
      case CustomButtonType.deepPurple:
        return context.textTheme.button.copyWith(color: AppColors.white);
    }
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
    }

    // Получаем стиль в зависимости от типа кнопки
    final buttonTextStyle = _getTextStyleForType(context, type);
    const double defaultIconSize = 20;

    if (imageAsset != null) {
      final width = imageWidth ?? defaultIconSize;
      final height = imageHeight ?? defaultIconSize;
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: buttonTextStyle.copyWith(fontWeight: fontWeight, color: textColor ?? buttonTextStyle.color),
          ),
          const SizedBox(width: 10),
          Image.asset(imageAsset!, width: width, height: height, fit: BoxFit.contain),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClayPressFeedback(
            enabled: onPressed != null && !isLoading,
            child: ClayIcon(icon, size: defaultIconSize),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: buttonTextStyle.copyWith(fontWeight: fontWeight, color: textColor ?? buttonTextStyle.color),
          ),
        ],
      );
    }

    return Text(
      text,
      textAlign: TextAlign.center,
      style: buttonTextStyle.copyWith(fontWeight: fontWeight, color: textColor ?? buttonTextStyle.color),
    );
  }
}
