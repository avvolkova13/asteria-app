import 'package:flutter/material.dart';

final class TextThemeData extends ThemeExtension<TextThemeData> {
  const TextThemeData({
    // required this.headlineLarge,
    // required this.headlineLargeInverse,
    // required this.headlineMedium,
    // required this.headlineMediumInverse,
    // required this.headlineSmall,
    // required this.titleLarge,
    // required this.titleMedium,
    // required this.titleSmall,
    // required this.bodyLarge,
    // required this.bodyMedium,
    // required this.bodySmall,
    required this.button,
    required this.buttonOutline,
    required this.inputHint,
    required this.appBarTitle,
    required this.subtitle,
    required this.subtitleInverse,
    required this.inputText,
    required this.inputErrorText,
    required this.codeInput,
    required this.secondaryUrbanistRegular16,
    // PlayfairDisplay Regular (400)
    required this.playfairRegular12,
    required this.playfairRegular14,
    required this.playfairRegular16,
    required this.playfairRegular17,
    required this.playfairRegular18,
    required this.playfairRegular20,
    required this.playfairRegular24,
    required this.playfairRegular32,
    // PlayfairDisplay Medium (500)
    required this.playfairMedium12,
    required this.playfairMedium14,
    required this.playfairMedium16,
    required this.playfairMedium17,
    required this.playfairMedium18,
    required this.playfairMedium20,
    required this.playfairMedium24,
    required this.playfairMedium32,
    // PlayfairDisplay SemiBold (600)
    required this.playfairSemiBold12,
    required this.playfairSemiBold14,
    required this.playfairSemiBold16,
    required this.playfairSemiBold17,
    required this.playfairSemiBold18,
    required this.playfairSemiBold20,
    required this.playfairSemiBold24,
    required this.playfairSemiBold32,
    // PlayfairDisplay Bold (700)
    required this.playfairBold12,
    required this.playfairBold14,
    required this.playfairBold16,
    required this.playfairBold17,
    required this.playfairBold18,
    required this.playfairBold20,
    required this.playfairBold24,
    required this.playfairBold32,
    // Urbanist Regular (400)
    required this.urbanistRegular12,
    required this.urbanistRegular14,
    required this.urbanistRegular16,
    required this.urbanistRegular17,
    required this.urbanistRegular18,
    required this.urbanistRegular20,
    required this.urbanistRegular24,
    required this.urbanistRegular32,
    // Urbanist Medium (500)
    required this.urbanistMedium12,
    required this.urbanistMedium14,
    required this.urbanistMedium16,
    required this.urbanistMedium17,
    required this.urbanistMedium18,
    required this.urbanistMedium20,
    required this.urbanistMedium24,
    required this.urbanistMedium32,
    // Urbanist SemiBold (600)
    required this.urbanistSemiBold12,
    required this.urbanistSemiBold14,
    required this.urbanistSemiBold16,
    required this.urbanistSemiBold17,
    required this.urbanistSemiBold18,
    required this.urbanistSemiBold20,
    required this.urbanistSemiBold24,
    required this.urbanistSemiBold32,
    // Urbanist Bold (700)
    required this.urbanistBold12,
    required this.urbanistBold14,
    required this.urbanistBold16,
    required this.urbanistBold17,
    required this.urbanistBold18,
    required this.urbanistBold20,
    required this.urbanistBold24,
    required this.urbanistBold32,
    // PlayfairDisplay Inverse variants (textInverse color)
    required this.inversePlayfairRegular12,
    required this.inversePlayfairRegular14,
    required this.inversePlayfairRegular16,
    required this.inversePlayfairRegular17,
    required this.inversePlayfairRegular18,
    required this.inversePlayfairRegular20,
    required this.inversePlayfairRegular24,
    required this.inversePlayfairRegular32,
    required this.inversePlayfairMedium12,
    required this.inversePlayfairMedium14,
    required this.inversePlayfairMedium16,
    required this.inversePlayfairMedium17,
    required this.inversePlayfairMedium18,
    required this.inversePlayfairMedium20,
    required this.inversePlayfairMedium24,
    required this.inversePlayfairMedium32,
    required this.inversePlayfairSemiBold12,
    required this.inversePlayfairSemiBold14,
    required this.inversePlayfairSemiBold16,
    required this.inversePlayfairSemiBold17,
    required this.inversePlayfairSemiBold18,
    required this.inversePlayfairSemiBold20,
    required this.inversePlayfairSemiBold24,
    required this.inversePlayfairSemiBold32,
    required this.inversePlayfairBold12,
    required this.inversePlayfairBold14,
    required this.inversePlayfairBold16,
    required this.inversePlayfairBold17,
    required this.inversePlayfairBold18,
    required this.inversePlayfairBold20,
    required this.inversePlayfairBold24,
    required this.inversePlayfairBold32,
    // Urbanist Inverse variants (textInverse color)
    required this.inverseUrbanistRegular12,
    required this.inverseUrbanistRegular14,
    required this.inverseUrbanistRegular16,
    required this.inverseUrbanistRegular17,
    required this.inverseUrbanistRegular18,
    required this.inverseUrbanistRegular20,
    required this.inverseUrbanistRegular24,
    required this.inverseUrbanistRegular32,
    required this.inverseUrbanistMedium12,
    required this.inverseUrbanistMedium14,
    required this.inverseUrbanistMedium16,
    required this.inverseUrbanistMedium17,
    required this.inverseUrbanistMedium18,
    required this.inverseUrbanistMedium20,
    required this.inverseUrbanistMedium24,
    required this.inverseUrbanistMedium32,
    required this.inverseUrbanistSemiBold12,
    required this.inverseUrbanistSemiBold14,
    required this.inverseUrbanistSemiBold16,
    required this.inverseUrbanistSemiBold17,
    required this.inverseUrbanistSemiBold18,
    required this.inverseUrbanistSemiBold20,
    required this.inverseUrbanistSemiBold24,
    required this.inverseUrbanistSemiBold32,
    required this.inverseUrbanistBold12,
    required this.inverseUrbanistBold14,
    required this.inverseUrbanistBold16,
    required this.inverseUrbanistBold17,
    required this.inverseUrbanistBold18,
    required this.inverseUrbanistBold20,
    required this.inverseUrbanistBold24,
    required this.inverseUrbanistBold32,
    // PlayfairDisplay Tertiary variants (textTertiary color)
    required this.tertiaryPlayfairRegular12,
    required this.tertiaryPlayfairRegular14,
    required this.tertiaryPlayfairRegular16,
    required this.tertiaryPlayfairRegular17,
    required this.tertiaryPlayfairRegular18,
    required this.tertiaryPlayfairRegular20,
    required this.tertiaryPlayfairRegular24,
    required this.tertiaryPlayfairRegular32,
    required this.tertiaryPlayfairMedium12,
    required this.tertiaryPlayfairMedium14,
    required this.tertiaryPlayfairMedium16,
    required this.tertiaryPlayfairMedium17,
    required this.tertiaryPlayfairMedium18,
    required this.tertiaryPlayfairMedium20,
    required this.tertiaryPlayfairMedium24,
    required this.tertiaryPlayfairMedium32,
    required this.tertiaryPlayfairSemiBold12,
    required this.tertiaryPlayfairSemiBold14,
    required this.tertiaryPlayfairSemiBold16,
    required this.tertiaryPlayfairSemiBold17,
    required this.tertiaryPlayfairSemiBold18,
    required this.tertiaryPlayfairSemiBold20,
    required this.tertiaryPlayfairSemiBold24,
    required this.tertiaryPlayfairSemiBold32,
    required this.tertiaryPlayfairBold12,
    required this.tertiaryPlayfairBold14,
    required this.tertiaryPlayfairBold16,
    required this.tertiaryPlayfairBold17,
    required this.tertiaryPlayfairBold18,
    required this.tertiaryPlayfairBold20,
    required this.tertiaryPlayfairBold24,
    required this.tertiaryPlayfairBold32,
    // Urbanist Tertiary variants (textTertiary color)
    required this.tertiaryUrbanistRegular12,
    required this.tertiaryUrbanistRegular14,
    required this.tertiaryUrbanistRegular16,
    required this.tertiaryUrbanistRegular17,
    required this.tertiaryUrbanistRegular18,
    required this.tertiaryUrbanistRegular20,
    required this.tertiaryUrbanistRegular24,
    required this.tertiaryUrbanistRegular32,
    required this.tertiaryUrbanistMedium12,
    required this.tertiaryUrbanistMedium14,
    required this.tertiaryUrbanistMedium16,
    required this.tertiaryUrbanistMedium17,
    required this.tertiaryUrbanistMedium18,
    required this.tertiaryUrbanistMedium20,
    required this.tertiaryUrbanistMedium24,
    required this.tertiaryUrbanistMedium32,
    required this.tertiaryUrbanistSemiBold12,
    required this.tertiaryUrbanistSemiBold14,
    required this.tertiaryUrbanistSemiBold16,
    required this.tertiaryUrbanistSemiBold17,
    required this.tertiaryUrbanistSemiBold18,
    required this.tertiaryUrbanistSemiBold20,
    required this.tertiaryUrbanistSemiBold24,
    required this.tertiaryUrbanistSemiBold32,
    required this.tertiaryUrbanistBold12,
    required this.tertiaryUrbanistBold14,
    required this.tertiaryUrbanistBold16,
    required this.tertiaryUrbanistBold17,
    required this.tertiaryUrbanistBold18,
    required this.tertiaryUrbanistBold20,
    required this.tertiaryUrbanistBold24,
    required this.tertiaryUrbanistBold32,
  });

  // final TextStyle headlineLarge;
  // final TextStyle headlineLargeInverse;
  // final TextStyle headlineMedium;
  // final TextStyle headlineMediumInverse;
  // final TextStyle headlineSmall;
  // final TextStyle titleLarge;
  // final TextStyle titleMedium;
  // final TextStyle titleSmall;
  // final TextStyle bodyLarge;
  // final TextStyle bodyMedium;
  // final TextStyle bodySmall;
  final TextStyle button;
  final TextStyle buttonOutline;
  final TextStyle inputHint;
  final TextStyle appBarTitle;
  final TextStyle subtitle;
  final TextStyle subtitleInverse;
  final TextStyle inputText;
  final TextStyle inputErrorText;
  final TextStyle codeInput;

  // Secondary style
  final TextStyle secondaryUrbanistRegular16;

  // PlayfairDisplay Regular (400)
  final TextStyle playfairRegular12;
  final TextStyle playfairRegular14;
  final TextStyle playfairRegular16;
  final TextStyle playfairRegular17;
  final TextStyle playfairRegular18;
  final TextStyle playfairRegular20;
  final TextStyle playfairRegular24;
  final TextStyle playfairRegular32;

  // PlayfairDisplay Medium (500)
  final TextStyle playfairMedium12;
  final TextStyle playfairMedium14;
  final TextStyle playfairMedium16;
  final TextStyle playfairMedium17;
  final TextStyle playfairMedium18;
  final TextStyle playfairMedium20;
  final TextStyle playfairMedium24;
  final TextStyle playfairMedium32;

  // PlayfairDisplay SemiBold (600)
  final TextStyle playfairSemiBold12;
  final TextStyle playfairSemiBold14;
  final TextStyle playfairSemiBold16;
  final TextStyle playfairSemiBold17;
  final TextStyle playfairSemiBold18;
  final TextStyle playfairSemiBold20;
  final TextStyle playfairSemiBold24;
  final TextStyle playfairSemiBold32;

  // PlayfairDisplay Bold (700)
  final TextStyle playfairBold12;
  final TextStyle playfairBold14;
  final TextStyle playfairBold16;
  final TextStyle playfairBold17;
  final TextStyle playfairBold18;
  final TextStyle playfairBold20;
  final TextStyle playfairBold24;
  final TextStyle playfairBold32;

  // Urbanist Regular (400)
  final TextStyle urbanistRegular12;
  final TextStyle urbanistRegular14;
  final TextStyle urbanistRegular16;
  final TextStyle urbanistRegular17;
  final TextStyle urbanistRegular18;
  final TextStyle urbanistRegular20;
  final TextStyle urbanistRegular24;
  final TextStyle urbanistRegular32;

  // Urbanist Medium (500)
  final TextStyle urbanistMedium12;
  final TextStyle urbanistMedium14;
  final TextStyle urbanistMedium16;
  final TextStyle urbanistMedium17;
  final TextStyle urbanistMedium18;
  final TextStyle urbanistMedium20;
  final TextStyle urbanistMedium24;
  final TextStyle urbanistMedium32;

  // Urbanist SemiBold (600)
  final TextStyle urbanistSemiBold12;
  final TextStyle urbanistSemiBold14;
  final TextStyle urbanistSemiBold16;
  final TextStyle urbanistSemiBold17;
  final TextStyle urbanistSemiBold18;
  final TextStyle urbanistSemiBold20;
  final TextStyle urbanistSemiBold24;
  final TextStyle urbanistSemiBold32;

  // Urbanist Bold (700)
  final TextStyle urbanistBold12;
  final TextStyle urbanistBold14;
  final TextStyle urbanistBold16;
  final TextStyle urbanistBold17;
  final TextStyle urbanistBold18;
  final TextStyle urbanistBold20;
  final TextStyle urbanistBold24;
  final TextStyle urbanistBold32;

  // PlayfairDisplay Inverse variants (textInverse color)
  final TextStyle inversePlayfairRegular12;
  final TextStyle inversePlayfairRegular14;
  final TextStyle inversePlayfairRegular16;
  final TextStyle inversePlayfairRegular17;
  final TextStyle inversePlayfairRegular18;
  final TextStyle inversePlayfairRegular20;
  final TextStyle inversePlayfairRegular24;
  final TextStyle inversePlayfairRegular32;
  final TextStyle inversePlayfairMedium12;
  final TextStyle inversePlayfairMedium14;
  final TextStyle inversePlayfairMedium16;
  final TextStyle inversePlayfairMedium17;
  final TextStyle inversePlayfairMedium18;
  final TextStyle inversePlayfairMedium20;
  final TextStyle inversePlayfairMedium24;
  final TextStyle inversePlayfairMedium32;
  final TextStyle inversePlayfairSemiBold12;
  final TextStyle inversePlayfairSemiBold14;
  final TextStyle inversePlayfairSemiBold16;
  final TextStyle inversePlayfairSemiBold17;
  final TextStyle inversePlayfairSemiBold18;
  final TextStyle inversePlayfairSemiBold20;
  final TextStyle inversePlayfairSemiBold24;
  final TextStyle inversePlayfairSemiBold32;
  final TextStyle inversePlayfairBold12;
  final TextStyle inversePlayfairBold14;
  final TextStyle inversePlayfairBold16;
  final TextStyle inversePlayfairBold17;
  final TextStyle inversePlayfairBold18;
  final TextStyle inversePlayfairBold20;
  final TextStyle inversePlayfairBold24;
  final TextStyle inversePlayfairBold32;

  // Urbanist Inverse variants (textInverse color)
  final TextStyle inverseUrbanistRegular12;
  final TextStyle inverseUrbanistRegular14;
  final TextStyle inverseUrbanistRegular16;
  final TextStyle inverseUrbanistRegular17;
  final TextStyle inverseUrbanistRegular18;
  final TextStyle inverseUrbanistRegular20;
  final TextStyle inverseUrbanistRegular24;
  final TextStyle inverseUrbanistRegular32;
  final TextStyle inverseUrbanistMedium12;
  final TextStyle inverseUrbanistMedium14;
  final TextStyle inverseUrbanistMedium16;
  final TextStyle inverseUrbanistMedium17;
  final TextStyle inverseUrbanistMedium18;
  final TextStyle inverseUrbanistMedium20;
  final TextStyle inverseUrbanistMedium24;
  final TextStyle inverseUrbanistMedium32;
  final TextStyle inverseUrbanistSemiBold12;
  final TextStyle inverseUrbanistSemiBold14;
  final TextStyle inverseUrbanistSemiBold16;
  final TextStyle inverseUrbanistSemiBold17;
  final TextStyle inverseUrbanistSemiBold18;
  final TextStyle inverseUrbanistSemiBold20;
  final TextStyle inverseUrbanistSemiBold24;
  final TextStyle inverseUrbanistSemiBold32;
  final TextStyle inverseUrbanistBold12;
  final TextStyle inverseUrbanistBold14;
  final TextStyle inverseUrbanistBold16;
  final TextStyle inverseUrbanistBold17;
  final TextStyle inverseUrbanistBold18;
  final TextStyle inverseUrbanistBold20;
  final TextStyle inverseUrbanistBold24;
  final TextStyle inverseUrbanistBold32;

  // PlayfairDisplay Tertiary variants (textTertiary color)
  final TextStyle tertiaryPlayfairRegular12;
  final TextStyle tertiaryPlayfairRegular14;
  final TextStyle tertiaryPlayfairRegular16;
  final TextStyle tertiaryPlayfairRegular17;
  final TextStyle tertiaryPlayfairRegular18;
  final TextStyle tertiaryPlayfairRegular20;
  final TextStyle tertiaryPlayfairRegular24;
  final TextStyle tertiaryPlayfairRegular32;
  final TextStyle tertiaryPlayfairMedium12;
  final TextStyle tertiaryPlayfairMedium14;
  final TextStyle tertiaryPlayfairMedium16;
  final TextStyle tertiaryPlayfairMedium17;
  final TextStyle tertiaryPlayfairMedium18;
  final TextStyle tertiaryPlayfairMedium20;
  final TextStyle tertiaryPlayfairMedium24;
  final TextStyle tertiaryPlayfairMedium32;
  final TextStyle tertiaryPlayfairSemiBold12;
  final TextStyle tertiaryPlayfairSemiBold14;
  final TextStyle tertiaryPlayfairSemiBold16;
  final TextStyle tertiaryPlayfairSemiBold17;
  final TextStyle tertiaryPlayfairSemiBold18;
  final TextStyle tertiaryPlayfairSemiBold20;
  final TextStyle tertiaryPlayfairSemiBold24;
  final TextStyle tertiaryPlayfairSemiBold32;
  final TextStyle tertiaryPlayfairBold12;
  final TextStyle tertiaryPlayfairBold14;
  final TextStyle tertiaryPlayfairBold16;
  final TextStyle tertiaryPlayfairBold17;
  final TextStyle tertiaryPlayfairBold18;
  final TextStyle tertiaryPlayfairBold20;
  final TextStyle tertiaryPlayfairBold24;
  final TextStyle tertiaryPlayfairBold32;

  // Urbanist Tertiary variants (textTertiary color)
  final TextStyle tertiaryUrbanistRegular12;
  final TextStyle tertiaryUrbanistRegular14;
  final TextStyle tertiaryUrbanistRegular16;
  final TextStyle tertiaryUrbanistRegular17;
  final TextStyle tertiaryUrbanistRegular18;
  final TextStyle tertiaryUrbanistRegular20;
  final TextStyle tertiaryUrbanistRegular24;
  final TextStyle tertiaryUrbanistRegular32;
  final TextStyle tertiaryUrbanistMedium12;
  final TextStyle tertiaryUrbanistMedium14;
  final TextStyle tertiaryUrbanistMedium16;
  final TextStyle tertiaryUrbanistMedium17;
  final TextStyle tertiaryUrbanistMedium18;
  final TextStyle tertiaryUrbanistMedium20;
  final TextStyle tertiaryUrbanistMedium24;
  final TextStyle tertiaryUrbanistMedium32;
  final TextStyle tertiaryUrbanistSemiBold12;
  final TextStyle tertiaryUrbanistSemiBold14;
  final TextStyle tertiaryUrbanistSemiBold16;
  final TextStyle tertiaryUrbanistSemiBold17;
  final TextStyle tertiaryUrbanistSemiBold18;
  final TextStyle tertiaryUrbanistSemiBold20;
  final TextStyle tertiaryUrbanistSemiBold24;
  final TextStyle tertiaryUrbanistSemiBold32;
  final TextStyle tertiaryUrbanistBold12;
  final TextStyle tertiaryUrbanistBold14;
  final TextStyle tertiaryUrbanistBold16;
  final TextStyle tertiaryUrbanistBold17;
  final TextStyle tertiaryUrbanistBold18;
  final TextStyle tertiaryUrbanistBold20;
  final TextStyle tertiaryUrbanistBold24;
  final TextStyle tertiaryUrbanistBold32;

  @override
  ThemeExtension<TextThemeData> copyWith() {
    return TextThemeData(
      // headlineLarge: headlineLarge,
      // headlineLargeInverse: headlineLargeInverse,
      // headlineMedium: headlineMedium,
      // headlineMediumInverse: headlineMediumInverse,
      // headlineSmall: headlineSmall,
      // titleLarge: titleLarge,
      // titleMedium: titleMedium,
      // titleSmall: titleSmall,
      // bodyLarge: bodyLarge,
      // bodyMedium: bodyMedium,
      // bodySmall: bodySmall,
      button: button,
      buttonOutline: buttonOutline,
      inputHint: inputHint,
      appBarTitle: appBarTitle,
      subtitle: subtitle,
      subtitleInverse: subtitleInverse,
      inputText: inputText,
      inputErrorText: inputErrorText,
      codeInput: codeInput,
      // Secondary style
      secondaryUrbanistRegular16: secondaryUrbanistRegular16,
      // PlayfairDisplay Regular (400)
      playfairRegular12: playfairRegular12,
      playfairRegular14: playfairRegular14,
      playfairRegular16: playfairRegular16,
      playfairRegular17: playfairRegular17,
      playfairRegular18: playfairRegular18,
      playfairRegular20: playfairRegular20,
      playfairRegular24: playfairRegular24,
      playfairRegular32: playfairRegular32,
      // PlayfairDisplay Medium (500)
      playfairMedium12: playfairMedium12,
      playfairMedium14: playfairMedium14,
      playfairMedium16: playfairMedium16,
      playfairMedium17: playfairMedium17,
      playfairMedium18: playfairMedium18,
      playfairMedium20: playfairMedium20,
      playfairMedium24: playfairMedium24,
      playfairMedium32: playfairMedium32,
      // PlayfairDisplay SemiBold (600)
      playfairSemiBold12: playfairSemiBold12,
      playfairSemiBold14: playfairSemiBold14,
      playfairSemiBold16: playfairSemiBold16,
      playfairSemiBold17: playfairSemiBold17,
      playfairSemiBold18: playfairSemiBold18,
      playfairSemiBold20: playfairSemiBold20,
      playfairSemiBold24: playfairSemiBold24,
      playfairSemiBold32: playfairSemiBold32,
      // PlayfairDisplay Bold (700)
      playfairBold12: playfairBold12,
      playfairBold14: playfairBold14,
      playfairBold16: playfairBold16,
      playfairBold17: playfairBold17,
      playfairBold18: playfairBold18,
      playfairBold20: playfairBold20,
      playfairBold24: playfairBold24,
      playfairBold32: playfairBold32,
      // Urbanist Regular (400)
      urbanistRegular12: urbanistRegular12,
      urbanistRegular14: urbanistRegular14,
      urbanistRegular16: urbanistRegular16,
      urbanistRegular17: urbanistRegular17,
      urbanistRegular18: urbanistRegular18,
      urbanistRegular20: urbanistRegular20,
      urbanistRegular24: urbanistRegular24,
      urbanistRegular32: urbanistRegular32,
      // Urbanist Medium (500)
      urbanistMedium12: urbanistMedium12,
      urbanistMedium14: urbanistMedium14,
      urbanistMedium16: urbanistMedium16,
      urbanistMedium17: urbanistMedium17,
      urbanistMedium18: urbanistMedium18,
      urbanistMedium20: urbanistMedium20,
      urbanistMedium24: urbanistMedium24,
      urbanistMedium32: urbanistMedium32,
      // Urbanist SemiBold (600)
      urbanistSemiBold12: urbanistSemiBold12,
      urbanistSemiBold14: urbanistSemiBold14,
      urbanistSemiBold16: urbanistSemiBold16,
      urbanistSemiBold17: urbanistSemiBold17,
      urbanistSemiBold18: urbanistSemiBold18,
      urbanistSemiBold20: urbanistSemiBold20,
      urbanistSemiBold24: urbanistSemiBold24,
      urbanistSemiBold32: urbanistSemiBold32,
      // Urbanist Bold (700)
      urbanistBold12: urbanistBold12,
      urbanistBold14: urbanistBold14,
      urbanistBold16: urbanistBold16,
      urbanistBold17: urbanistBold17,
      urbanistBold18: urbanistBold18,
      urbanistBold20: urbanistBold20,
      urbanistBold24: urbanistBold24,
      urbanistBold32: urbanistBold32,
      // PlayfairDisplay Inverse variants (textInverse color)
      inversePlayfairRegular12: inversePlayfairRegular12,
      inversePlayfairRegular14: inversePlayfairRegular14,
      inversePlayfairRegular16: inversePlayfairRegular16,
      inversePlayfairRegular17: inversePlayfairRegular17,
      inversePlayfairRegular18: inversePlayfairRegular18,
      inversePlayfairRegular20: inversePlayfairRegular20,
      inversePlayfairRegular24: inversePlayfairRegular24,
      inversePlayfairRegular32: inversePlayfairRegular32,
      inversePlayfairMedium12: inversePlayfairMedium12,
      inversePlayfairMedium14: inversePlayfairMedium14,
      inversePlayfairMedium16: inversePlayfairMedium16,
      inversePlayfairMedium17: inversePlayfairMedium17,
      inversePlayfairMedium18: inversePlayfairMedium18,
      inversePlayfairMedium20: inversePlayfairMedium20,
      inversePlayfairMedium24: inversePlayfairMedium24,
      inversePlayfairMedium32: inversePlayfairMedium32,
      inversePlayfairSemiBold12: inversePlayfairSemiBold12,
      inversePlayfairSemiBold14: inversePlayfairSemiBold14,
      inversePlayfairSemiBold16: inversePlayfairSemiBold16,
      inversePlayfairSemiBold17: inversePlayfairSemiBold17,
      inversePlayfairSemiBold18: inversePlayfairSemiBold18,
      inversePlayfairSemiBold20: inversePlayfairSemiBold20,
      inversePlayfairSemiBold24: inversePlayfairSemiBold24,
      inversePlayfairSemiBold32: inversePlayfairSemiBold32,
      inversePlayfairBold12: inversePlayfairBold12,
      inversePlayfairBold14: inversePlayfairBold14,
      inversePlayfairBold16: inversePlayfairBold16,
      inversePlayfairBold17: inversePlayfairBold17,
      inversePlayfairBold18: inversePlayfairBold18,
      inversePlayfairBold20: inversePlayfairBold20,
      inversePlayfairBold24: inversePlayfairBold24,
      inversePlayfairBold32: inversePlayfairBold32,
      // Urbanist Inverse variants (textInverse color)
      inverseUrbanistRegular12: inverseUrbanistRegular12,
      inverseUrbanistRegular14: inverseUrbanistRegular14,
      inverseUrbanistRegular16: inverseUrbanistRegular16,
      inverseUrbanistRegular17: inverseUrbanistRegular17,
      inverseUrbanistRegular18: inverseUrbanistRegular18,
      inverseUrbanistRegular20: inverseUrbanistRegular20,
      inverseUrbanistRegular24: inverseUrbanistRegular24,
      inverseUrbanistRegular32: inverseUrbanistRegular32,
      inverseUrbanistMedium12: inverseUrbanistMedium12,
      inverseUrbanistMedium14: inverseUrbanistMedium14,
      inverseUrbanistMedium16: inverseUrbanistMedium16,
      inverseUrbanistMedium17: inverseUrbanistMedium17,
      inverseUrbanistMedium18: inverseUrbanistMedium18,
      inverseUrbanistMedium20: inverseUrbanistMedium20,
      inverseUrbanistMedium24: inverseUrbanistMedium24,
      inverseUrbanistMedium32: inverseUrbanistMedium32,
      inverseUrbanistSemiBold12: inverseUrbanistSemiBold12,
      inverseUrbanistSemiBold14: inverseUrbanistSemiBold14,
      inverseUrbanistSemiBold16: inverseUrbanistSemiBold16,
      inverseUrbanistSemiBold17: inverseUrbanistSemiBold17,
      inverseUrbanistSemiBold18: inverseUrbanistSemiBold18,
      inverseUrbanistSemiBold20: inverseUrbanistSemiBold20,
      inverseUrbanistSemiBold24: inverseUrbanistSemiBold24,
      inverseUrbanistSemiBold32: inverseUrbanistSemiBold32,
      inverseUrbanistBold12: inverseUrbanistBold12,
      inverseUrbanistBold14: inverseUrbanistBold14,
      inverseUrbanistBold16: inverseUrbanistBold16,
      inverseUrbanistBold17: inverseUrbanistBold17,
      inverseUrbanistBold18: inverseUrbanistBold18,
      inverseUrbanistBold20: inverseUrbanistBold20,
      inverseUrbanistBold24: inverseUrbanistBold24,
      inverseUrbanistBold32: inverseUrbanistBold32,
      // PlayfairDisplay Tertiary variants (textTertiary color)
      tertiaryPlayfairRegular12: tertiaryPlayfairRegular12,
      tertiaryPlayfairRegular14: tertiaryPlayfairRegular14,
      tertiaryPlayfairRegular16: tertiaryPlayfairRegular16,
      tertiaryPlayfairRegular17: tertiaryPlayfairRegular17,
      tertiaryPlayfairRegular18: tertiaryPlayfairRegular18,
      tertiaryPlayfairRegular20: tertiaryPlayfairRegular20,
      tertiaryPlayfairRegular24: tertiaryPlayfairRegular24,
      tertiaryPlayfairRegular32: tertiaryPlayfairRegular32,
      tertiaryPlayfairMedium12: tertiaryPlayfairMedium12,
      tertiaryPlayfairMedium14: tertiaryPlayfairMedium14,
      tertiaryPlayfairMedium16: tertiaryPlayfairMedium16,
      tertiaryPlayfairMedium17: tertiaryPlayfairMedium17,
      tertiaryPlayfairMedium18: tertiaryPlayfairMedium18,
      tertiaryPlayfairMedium20: tertiaryPlayfairMedium20,
      tertiaryPlayfairMedium24: tertiaryPlayfairMedium24,
      tertiaryPlayfairMedium32: tertiaryPlayfairMedium32,
      tertiaryPlayfairSemiBold12: tertiaryPlayfairSemiBold12,
      tertiaryPlayfairSemiBold14: tertiaryPlayfairSemiBold14,
      tertiaryPlayfairSemiBold16: tertiaryPlayfairSemiBold16,
      tertiaryPlayfairSemiBold17: tertiaryPlayfairSemiBold17,
      tertiaryPlayfairSemiBold18: tertiaryPlayfairSemiBold18,
      tertiaryPlayfairSemiBold20: tertiaryPlayfairSemiBold20,
      tertiaryPlayfairSemiBold24: tertiaryPlayfairSemiBold24,
      tertiaryPlayfairSemiBold32: tertiaryPlayfairSemiBold32,
      tertiaryPlayfairBold12: tertiaryPlayfairBold12,
      tertiaryPlayfairBold14: tertiaryPlayfairBold14,
      tertiaryPlayfairBold16: tertiaryPlayfairBold16,
      tertiaryPlayfairBold17: tertiaryPlayfairBold17,
      tertiaryPlayfairBold18: tertiaryPlayfairBold18,
      tertiaryPlayfairBold20: tertiaryPlayfairBold20,
      tertiaryPlayfairBold24: tertiaryPlayfairBold24,
      tertiaryPlayfairBold32: tertiaryPlayfairBold32,
      // Urbanist Tertiary variants (textTertiary color)
      tertiaryUrbanistRegular12: tertiaryUrbanistRegular12,
      tertiaryUrbanistRegular14: tertiaryUrbanistRegular14,
      tertiaryUrbanistRegular16: tertiaryUrbanistRegular16,
      tertiaryUrbanistRegular17: tertiaryUrbanistRegular17,
      tertiaryUrbanistRegular18: tertiaryUrbanistRegular18,
      tertiaryUrbanistRegular20: tertiaryUrbanistRegular20,
      tertiaryUrbanistRegular24: tertiaryUrbanistRegular24,
      tertiaryUrbanistRegular32: tertiaryUrbanistRegular32,
      tertiaryUrbanistMedium12: tertiaryUrbanistMedium12,
      tertiaryUrbanistMedium14: tertiaryUrbanistMedium14,
      tertiaryUrbanistMedium16: tertiaryUrbanistMedium16,
      tertiaryUrbanistMedium17: tertiaryUrbanistMedium17,
      tertiaryUrbanistMedium18: tertiaryUrbanistMedium18,
      tertiaryUrbanistMedium20: tertiaryUrbanistMedium20,
      tertiaryUrbanistMedium24: tertiaryUrbanistMedium24,
      tertiaryUrbanistMedium32: tertiaryUrbanistMedium32,
      tertiaryUrbanistSemiBold12: tertiaryUrbanistSemiBold12,
      tertiaryUrbanistSemiBold14: tertiaryUrbanistSemiBold14,
      tertiaryUrbanistSemiBold16: tertiaryUrbanistSemiBold16,
      tertiaryUrbanistSemiBold17: tertiaryUrbanistSemiBold17,
      tertiaryUrbanistSemiBold18: tertiaryUrbanistSemiBold18,
      tertiaryUrbanistSemiBold20: tertiaryUrbanistSemiBold20,
      tertiaryUrbanistSemiBold24: tertiaryUrbanistSemiBold24,
      tertiaryUrbanistSemiBold32: tertiaryUrbanistSemiBold32,
      tertiaryUrbanistBold12: tertiaryUrbanistBold12,
      tertiaryUrbanistBold14: tertiaryUrbanistBold14,
      tertiaryUrbanistBold16: tertiaryUrbanistBold16,
      tertiaryUrbanistBold17: tertiaryUrbanistBold17,
      tertiaryUrbanistBold18: tertiaryUrbanistBold18,
      tertiaryUrbanistBold20: tertiaryUrbanistBold20,
      tertiaryUrbanistBold24: tertiaryUrbanistBold24,
      tertiaryUrbanistBold32: tertiaryUrbanistBold32,
    );
  }

  @override
  ThemeExtension<TextThemeData> lerp(covariant ThemeExtension<TextThemeData>? other, double t) {
    if (other is! TextThemeData) {
      return this;
    }

    return TextThemeData(
      // headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      // headlineLargeInverse: TextStyle.lerp(headlineLargeInverse, other.headlineLargeInverse, t)!,
      // headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      // headlineMediumInverse: TextStyle.lerp(headlineMediumInverse, other.headlineMediumInverse, t)!,
      // headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      // titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      // titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      // titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      // bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      // bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      // bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      // Secondary style
      secondaryUrbanistRegular16: TextStyle.lerp(secondaryUrbanistRegular16, other.secondaryUrbanistRegular16, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      buttonOutline: TextStyle.lerp(buttonOutline, other.buttonOutline, t)!,
      inputHint: TextStyle.lerp(inputHint, other.inputHint, t)!,
      appBarTitle: TextStyle.lerp(appBarTitle, other.appBarTitle, t)!,
      subtitle: TextStyle.lerp(subtitle, other.subtitle, t)!,
      subtitleInverse: TextStyle.lerp(subtitleInverse, other.subtitleInverse, t)!,
      inputText: TextStyle.lerp(inputText, other.inputText, t)!,
      inputErrorText: TextStyle.lerp(inputErrorText, other.inputErrorText, t)!,
      codeInput: TextStyle.lerp(codeInput, other.codeInput, t)!,
      // PlayfairDisplay Regular (400)
      playfairRegular12: TextStyle.lerp(playfairRegular12, other.playfairRegular12, t)!,
      playfairRegular14: TextStyle.lerp(playfairRegular14, other.playfairRegular14, t)!,
      playfairRegular16: TextStyle.lerp(playfairRegular16, other.playfairRegular16, t)!,
      playfairRegular17: TextStyle.lerp(playfairRegular17, other.playfairRegular17, t)!,
      playfairRegular18: TextStyle.lerp(playfairRegular18, other.playfairRegular18, t)!,
      playfairRegular20: TextStyle.lerp(playfairRegular20, other.playfairRegular20, t)!,
      playfairRegular24: TextStyle.lerp(playfairRegular24, other.playfairRegular24, t)!,
      playfairRegular32: TextStyle.lerp(playfairRegular32, other.playfairRegular32, t)!,
      // PlayfairDisplay Medium (500)
      playfairMedium12: TextStyle.lerp(playfairMedium12, other.playfairMedium12, t)!,
      playfairMedium14: TextStyle.lerp(playfairMedium14, other.playfairMedium14, t)!,
      playfairMedium16: TextStyle.lerp(playfairMedium16, other.playfairMedium16, t)!,
      playfairMedium17: TextStyle.lerp(playfairMedium17, other.playfairMedium17, t)!,
      playfairMedium18: TextStyle.lerp(playfairMedium18, other.playfairMedium18, t)!,
      playfairMedium20: TextStyle.lerp(playfairMedium20, other.playfairMedium20, t)!,
      playfairMedium24: TextStyle.lerp(playfairMedium24, other.playfairMedium24, t)!,
      playfairMedium32: TextStyle.lerp(playfairMedium32, other.playfairMedium32, t)!,
      // PlayfairDisplay SemiBold (600)
      playfairSemiBold12: TextStyle.lerp(playfairSemiBold12, other.playfairSemiBold12, t)!,
      playfairSemiBold14: TextStyle.lerp(playfairSemiBold14, other.playfairSemiBold14, t)!,
      playfairSemiBold16: TextStyle.lerp(playfairSemiBold16, other.playfairSemiBold16, t)!,
      playfairSemiBold17: TextStyle.lerp(playfairSemiBold17, other.playfairSemiBold17, t)!,
      playfairSemiBold18: TextStyle.lerp(playfairSemiBold18, other.playfairSemiBold18, t)!,
      playfairSemiBold20: TextStyle.lerp(playfairSemiBold20, other.playfairSemiBold20, t)!,
      playfairSemiBold24: TextStyle.lerp(playfairSemiBold24, other.playfairSemiBold24, t)!,
      playfairSemiBold32: TextStyle.lerp(playfairSemiBold32, other.playfairSemiBold32, t)!,
      // PlayfairDisplay Bold (700)
      playfairBold12: TextStyle.lerp(playfairBold12, other.playfairBold12, t)!,
      playfairBold14: TextStyle.lerp(playfairBold14, other.playfairBold14, t)!,
      playfairBold16: TextStyle.lerp(playfairBold16, other.playfairBold16, t)!,
      playfairBold17: TextStyle.lerp(playfairBold17, other.playfairBold17, t)!,
      playfairBold18: TextStyle.lerp(playfairBold18, other.playfairBold18, t)!,
      playfairBold20: TextStyle.lerp(playfairBold20, other.playfairBold20, t)!,
      playfairBold24: TextStyle.lerp(playfairBold24, other.playfairBold24, t)!,
      playfairBold32: TextStyle.lerp(playfairBold32, other.playfairBold32, t)!,
      // Urbanist Regular (400)
      urbanistRegular12: TextStyle.lerp(urbanistRegular12, other.urbanistRegular12, t)!,
      urbanistRegular14: TextStyle.lerp(urbanistRegular14, other.urbanistRegular14, t)!,
      urbanistRegular16: TextStyle.lerp(urbanistRegular16, other.urbanistRegular16, t)!,
      urbanistRegular17: TextStyle.lerp(urbanistRegular17, other.urbanistRegular17, t)!,
      urbanistRegular18: TextStyle.lerp(urbanistRegular18, other.urbanistRegular18, t)!,
      urbanistRegular20: TextStyle.lerp(urbanistRegular20, other.urbanistRegular20, t)!,
      urbanistRegular24: TextStyle.lerp(urbanistRegular24, other.urbanistRegular24, t)!,
      urbanistRegular32: TextStyle.lerp(urbanistRegular32, other.urbanistRegular32, t)!,
      // Urbanist Medium (500)
      urbanistMedium12: TextStyle.lerp(urbanistMedium12, other.urbanistMedium12, t)!,
      urbanistMedium14: TextStyle.lerp(urbanistMedium14, other.urbanistMedium14, t)!,
      urbanistMedium16: TextStyle.lerp(urbanistMedium16, other.urbanistMedium16, t)!,
      urbanistMedium17: TextStyle.lerp(urbanistMedium17, other.urbanistMedium17, t)!,
      urbanistMedium18: TextStyle.lerp(urbanistMedium18, other.urbanistMedium18, t)!,
      urbanistMedium20: TextStyle.lerp(urbanistMedium20, other.urbanistMedium20, t)!,
      urbanistMedium24: TextStyle.lerp(urbanistMedium24, other.urbanistMedium24, t)!,
      urbanistMedium32: TextStyle.lerp(urbanistMedium32, other.urbanistMedium32, t)!,
      // Urbanist SemiBold (600)
      urbanistSemiBold12: TextStyle.lerp(urbanistSemiBold12, other.urbanistSemiBold12, t)!,
      urbanistSemiBold14: TextStyle.lerp(urbanistSemiBold14, other.urbanistSemiBold14, t)!,
      urbanistSemiBold16: TextStyle.lerp(urbanistSemiBold16, other.urbanistSemiBold16, t)!,
      urbanistSemiBold17: TextStyle.lerp(urbanistSemiBold17, other.urbanistSemiBold17, t)!,
      urbanistSemiBold18: TextStyle.lerp(urbanistSemiBold18, other.urbanistSemiBold18, t)!,
      urbanistSemiBold20: TextStyle.lerp(urbanistSemiBold20, other.urbanistSemiBold20, t)!,
      urbanistSemiBold24: TextStyle.lerp(urbanistSemiBold24, other.urbanistSemiBold24, t)!,
      urbanistSemiBold32: TextStyle.lerp(urbanistSemiBold32, other.urbanistSemiBold32, t)!,
      // Urbanist Bold (700)
      urbanistBold12: TextStyle.lerp(urbanistBold12, other.urbanistBold12, t)!,
      urbanistBold14: TextStyle.lerp(urbanistBold14, other.urbanistBold14, t)!,
      urbanistBold16: TextStyle.lerp(urbanistBold16, other.urbanistBold16, t)!,
      urbanistBold17: TextStyle.lerp(urbanistBold17, other.urbanistBold17, t)!,
      urbanistBold18: TextStyle.lerp(urbanistBold18, other.urbanistBold18, t)!,
      urbanistBold20: TextStyle.lerp(urbanistBold20, other.urbanistBold20, t)!,
      urbanistBold24: TextStyle.lerp(urbanistBold24, other.urbanistBold24, t)!,
      urbanistBold32: TextStyle.lerp(urbanistBold32, other.urbanistBold32, t)!,
      // PlayfairDisplay Inverse variants (textInverse color)
      inversePlayfairRegular12: TextStyle.lerp(inversePlayfairRegular12, other.inversePlayfairRegular12, t)!,
      inversePlayfairRegular14: TextStyle.lerp(inversePlayfairRegular14, other.inversePlayfairRegular14, t)!,
      inversePlayfairRegular16: TextStyle.lerp(inversePlayfairRegular16, other.inversePlayfairRegular16, t)!,
      inversePlayfairRegular17: TextStyle.lerp(inversePlayfairRegular17, other.inversePlayfairRegular17, t)!,
      inversePlayfairRegular18: TextStyle.lerp(inversePlayfairRegular18, other.inversePlayfairRegular18, t)!,
      inversePlayfairRegular20: TextStyle.lerp(inversePlayfairRegular20, other.inversePlayfairRegular20, t)!,
      inversePlayfairRegular24: TextStyle.lerp(inversePlayfairRegular24, other.inversePlayfairRegular24, t)!,
      inversePlayfairRegular32: TextStyle.lerp(inversePlayfairRegular32, other.inversePlayfairRegular32, t)!,
      inversePlayfairMedium12: TextStyle.lerp(inversePlayfairMedium12, other.inversePlayfairMedium12, t)!,
      inversePlayfairMedium14: TextStyle.lerp(inversePlayfairMedium14, other.inversePlayfairMedium14, t)!,
      inversePlayfairMedium16: TextStyle.lerp(inversePlayfairMedium16, other.inversePlayfairMedium16, t)!,
      inversePlayfairMedium17: TextStyle.lerp(inversePlayfairMedium17, other.inversePlayfairMedium17, t)!,
      inversePlayfairMedium18: TextStyle.lerp(inversePlayfairMedium18, other.inversePlayfairMedium18, t)!,
      inversePlayfairMedium20: TextStyle.lerp(inversePlayfairMedium20, other.inversePlayfairMedium20, t)!,
      inversePlayfairMedium24: TextStyle.lerp(inversePlayfairMedium24, other.inversePlayfairMedium24, t)!,
      inversePlayfairMedium32: TextStyle.lerp(inversePlayfairMedium32, other.inversePlayfairMedium32, t)!,
      inversePlayfairSemiBold12: TextStyle.lerp(inversePlayfairSemiBold12, other.inversePlayfairSemiBold12, t)!,
      inversePlayfairSemiBold14: TextStyle.lerp(inversePlayfairSemiBold14, other.inversePlayfairSemiBold14, t)!,
      inversePlayfairSemiBold16: TextStyle.lerp(inversePlayfairSemiBold16, other.inversePlayfairSemiBold16, t)!,
      inversePlayfairSemiBold17: TextStyle.lerp(inversePlayfairSemiBold17, other.inversePlayfairSemiBold17, t)!,
      inversePlayfairSemiBold18: TextStyle.lerp(inversePlayfairSemiBold18, other.inversePlayfairSemiBold18, t)!,
      inversePlayfairSemiBold20: TextStyle.lerp(inversePlayfairSemiBold20, other.inversePlayfairSemiBold20, t)!,
      inversePlayfairSemiBold24: TextStyle.lerp(inversePlayfairSemiBold24, other.inversePlayfairSemiBold24, t)!,
      inversePlayfairSemiBold32: TextStyle.lerp(inversePlayfairSemiBold32, other.inversePlayfairSemiBold32, t)!,
      inversePlayfairBold12: TextStyle.lerp(inversePlayfairBold12, other.inversePlayfairBold12, t)!,
      inversePlayfairBold14: TextStyle.lerp(inversePlayfairBold14, other.inversePlayfairBold14, t)!,
      inversePlayfairBold16: TextStyle.lerp(inversePlayfairBold16, other.inversePlayfairBold16, t)!,
      inversePlayfairBold17: TextStyle.lerp(inversePlayfairBold17, other.inversePlayfairBold17, t)!,
      inversePlayfairBold18: TextStyle.lerp(inversePlayfairBold18, other.inversePlayfairBold18, t)!,
      inversePlayfairBold20: TextStyle.lerp(inversePlayfairBold20, other.inversePlayfairBold20, t)!,
      inversePlayfairBold24: TextStyle.lerp(inversePlayfairBold24, other.inversePlayfairBold24, t)!,
      inversePlayfairBold32: TextStyle.lerp(inversePlayfairBold32, other.inversePlayfairBold32, t)!,
      // Urbanist Inverse variants (textInverse color)
      inverseUrbanistRegular12: TextStyle.lerp(inverseUrbanistRegular12, other.inverseUrbanistRegular12, t)!,
      inverseUrbanistRegular14: TextStyle.lerp(inverseUrbanistRegular14, other.inverseUrbanistRegular14, t)!,
      inverseUrbanistRegular16: TextStyle.lerp(inverseUrbanistRegular16, other.inverseUrbanistRegular16, t)!,
      inverseUrbanistRegular17: TextStyle.lerp(inverseUrbanistRegular17, other.inverseUrbanistRegular17, t)!,
      inverseUrbanistRegular18: TextStyle.lerp(inverseUrbanistRegular18, other.inverseUrbanistRegular18, t)!,
      inverseUrbanistRegular20: TextStyle.lerp(inverseUrbanistRegular20, other.inverseUrbanistRegular20, t)!,
      inverseUrbanistRegular24: TextStyle.lerp(inverseUrbanistRegular24, other.inverseUrbanistRegular24, t)!,
      inverseUrbanistRegular32: TextStyle.lerp(inverseUrbanistRegular32, other.inverseUrbanistRegular32, t)!,
      inverseUrbanistMedium12: TextStyle.lerp(inverseUrbanistMedium12, other.inverseUrbanistMedium12, t)!,
      inverseUrbanistMedium14: TextStyle.lerp(inverseUrbanistMedium14, other.inverseUrbanistMedium14, t)!,
      inverseUrbanistMedium16: TextStyle.lerp(inverseUrbanistMedium16, other.inverseUrbanistMedium16, t)!,
      inverseUrbanistMedium17: TextStyle.lerp(inverseUrbanistMedium17, other.inverseUrbanistMedium17, t)!,
      inverseUrbanistMedium18: TextStyle.lerp(inverseUrbanistMedium18, other.inverseUrbanistMedium18, t)!,
      inverseUrbanistMedium20: TextStyle.lerp(inverseUrbanistMedium20, other.inverseUrbanistMedium20, t)!,
      inverseUrbanistMedium24: TextStyle.lerp(inverseUrbanistMedium24, other.inverseUrbanistMedium24, t)!,
      inverseUrbanistMedium32: TextStyle.lerp(inverseUrbanistMedium32, other.inverseUrbanistMedium32, t)!,
      inverseUrbanistSemiBold12: TextStyle.lerp(inverseUrbanistSemiBold12, other.inverseUrbanistSemiBold12, t)!,
      inverseUrbanistSemiBold14: TextStyle.lerp(inverseUrbanistSemiBold14, other.inverseUrbanistSemiBold14, t)!,
      inverseUrbanistSemiBold16: TextStyle.lerp(inverseUrbanistSemiBold16, other.inverseUrbanistSemiBold16, t)!,
      inverseUrbanistSemiBold17: TextStyle.lerp(inverseUrbanistSemiBold17, other.inverseUrbanistSemiBold17, t)!,
      inverseUrbanistSemiBold18: TextStyle.lerp(inverseUrbanistSemiBold18, other.inverseUrbanistSemiBold18, t)!,
      inverseUrbanistSemiBold20: TextStyle.lerp(inverseUrbanistSemiBold20, other.inverseUrbanistSemiBold20, t)!,
      inverseUrbanistSemiBold24: TextStyle.lerp(inverseUrbanistSemiBold24, other.inverseUrbanistSemiBold24, t)!,
      inverseUrbanistSemiBold32: TextStyle.lerp(inverseUrbanistSemiBold32, other.inverseUrbanistSemiBold32, t)!,
      inverseUrbanistBold12: TextStyle.lerp(inverseUrbanistBold12, other.inverseUrbanistBold12, t)!,
      inverseUrbanistBold14: TextStyle.lerp(inverseUrbanistBold14, other.inverseUrbanistBold14, t)!,
      inverseUrbanistBold16: TextStyle.lerp(inverseUrbanistBold16, other.inverseUrbanistBold16, t)!,
      inverseUrbanistBold17: TextStyle.lerp(inverseUrbanistBold17, other.inverseUrbanistBold17, t)!,
      inverseUrbanistBold18: TextStyle.lerp(inverseUrbanistBold18, other.inverseUrbanistBold18, t)!,
      inverseUrbanistBold20: TextStyle.lerp(inverseUrbanistBold20, other.inverseUrbanistBold20, t)!,
      inverseUrbanistBold24: TextStyle.lerp(inverseUrbanistBold24, other.inverseUrbanistBold24, t)!,
      inverseUrbanistBold32: TextStyle.lerp(inverseUrbanistBold32, other.inverseUrbanistBold32, t)!,
      // PlayfairDisplay Tertiary variants (textTertiary color)
      tertiaryPlayfairRegular12: TextStyle.lerp(tertiaryPlayfairRegular12, other.tertiaryPlayfairRegular12, t)!,
      tertiaryPlayfairRegular14: TextStyle.lerp(tertiaryPlayfairRegular14, other.tertiaryPlayfairRegular14, t)!,
      tertiaryPlayfairRegular16: TextStyle.lerp(tertiaryPlayfairRegular16, other.tertiaryPlayfairRegular16, t)!,
      tertiaryPlayfairRegular17: TextStyle.lerp(tertiaryPlayfairRegular17, other.tertiaryPlayfairRegular17, t)!,
      tertiaryPlayfairRegular18: TextStyle.lerp(tertiaryPlayfairRegular18, other.tertiaryPlayfairRegular18, t)!,
      tertiaryPlayfairRegular20: TextStyle.lerp(tertiaryPlayfairRegular20, other.tertiaryPlayfairRegular20, t)!,
      tertiaryPlayfairRegular24: TextStyle.lerp(tertiaryPlayfairRegular24, other.tertiaryPlayfairRegular24, t)!,
      tertiaryPlayfairRegular32: TextStyle.lerp(tertiaryPlayfairRegular32, other.tertiaryPlayfairRegular32, t)!,
      tertiaryPlayfairMedium12: TextStyle.lerp(tertiaryPlayfairMedium12, other.tertiaryPlayfairMedium12, t)!,
      tertiaryPlayfairMedium14: TextStyle.lerp(tertiaryPlayfairMedium14, other.tertiaryPlayfairMedium14, t)!,
      tertiaryPlayfairMedium16: TextStyle.lerp(tertiaryPlayfairMedium16, other.tertiaryPlayfairMedium16, t)!,
      tertiaryPlayfairMedium17: TextStyle.lerp(tertiaryPlayfairMedium17, other.tertiaryPlayfairMedium17, t)!,
      tertiaryPlayfairMedium18: TextStyle.lerp(tertiaryPlayfairMedium18, other.tertiaryPlayfairMedium18, t)!,
      tertiaryPlayfairMedium20: TextStyle.lerp(tertiaryPlayfairMedium20, other.tertiaryPlayfairMedium20, t)!,
      tertiaryPlayfairMedium24: TextStyle.lerp(tertiaryPlayfairMedium24, other.tertiaryPlayfairMedium24, t)!,
      tertiaryPlayfairMedium32: TextStyle.lerp(tertiaryPlayfairMedium32, other.tertiaryPlayfairMedium32, t)!,
      tertiaryPlayfairSemiBold12: TextStyle.lerp(tertiaryPlayfairSemiBold12, other.tertiaryPlayfairSemiBold12, t)!,
      tertiaryPlayfairSemiBold14: TextStyle.lerp(tertiaryPlayfairSemiBold14, other.tertiaryPlayfairSemiBold14, t)!,
      tertiaryPlayfairSemiBold16: TextStyle.lerp(tertiaryPlayfairSemiBold16, other.tertiaryPlayfairSemiBold16, t)!,
      tertiaryPlayfairSemiBold17: TextStyle.lerp(tertiaryPlayfairSemiBold17, other.tertiaryPlayfairSemiBold17, t)!,
      tertiaryPlayfairSemiBold18: TextStyle.lerp(tertiaryPlayfairSemiBold18, other.tertiaryPlayfairSemiBold18, t)!,
      tertiaryPlayfairSemiBold20: TextStyle.lerp(tertiaryPlayfairSemiBold20, other.tertiaryPlayfairSemiBold20, t)!,
      tertiaryPlayfairSemiBold24: TextStyle.lerp(tertiaryPlayfairSemiBold24, other.tertiaryPlayfairSemiBold24, t)!,
      tertiaryPlayfairSemiBold32: TextStyle.lerp(tertiaryPlayfairSemiBold32, other.tertiaryPlayfairSemiBold32, t)!,
      tertiaryPlayfairBold12: TextStyle.lerp(tertiaryPlayfairBold12, other.tertiaryPlayfairBold12, t)!,
      tertiaryPlayfairBold14: TextStyle.lerp(tertiaryPlayfairBold14, other.tertiaryPlayfairBold14, t)!,
      tertiaryPlayfairBold16: TextStyle.lerp(tertiaryPlayfairBold16, other.tertiaryPlayfairBold16, t)!,
      tertiaryPlayfairBold17: TextStyle.lerp(tertiaryPlayfairBold17, other.tertiaryPlayfairBold17, t)!,
      tertiaryPlayfairBold18: TextStyle.lerp(tertiaryPlayfairBold18, other.tertiaryPlayfairBold18, t)!,
      tertiaryPlayfairBold20: TextStyle.lerp(tertiaryPlayfairBold20, other.tertiaryPlayfairBold20, t)!,
      tertiaryPlayfairBold24: TextStyle.lerp(tertiaryPlayfairBold24, other.tertiaryPlayfairBold24, t)!,
      tertiaryPlayfairBold32: TextStyle.lerp(tertiaryPlayfairBold32, other.tertiaryPlayfairBold32, t)!,
      // Urbanist Tertiary variants (textTertiary color)
      tertiaryUrbanistRegular12: TextStyle.lerp(tertiaryUrbanistRegular12, other.tertiaryUrbanistRegular12, t)!,
      tertiaryUrbanistRegular14: TextStyle.lerp(tertiaryUrbanistRegular14, other.tertiaryUrbanistRegular14, t)!,
      tertiaryUrbanistRegular16: TextStyle.lerp(tertiaryUrbanistRegular16, other.tertiaryUrbanistRegular16, t)!,
      tertiaryUrbanistRegular17: TextStyle.lerp(tertiaryUrbanistRegular17, other.tertiaryUrbanistRegular17, t)!,
      tertiaryUrbanistRegular18: TextStyle.lerp(tertiaryUrbanistRegular18, other.tertiaryUrbanistRegular18, t)!,
      tertiaryUrbanistRegular20: TextStyle.lerp(tertiaryUrbanistRegular20, other.tertiaryUrbanistRegular20, t)!,
      tertiaryUrbanistRegular24: TextStyle.lerp(tertiaryUrbanistRegular24, other.tertiaryUrbanistRegular24, t)!,
      tertiaryUrbanistRegular32: TextStyle.lerp(tertiaryUrbanistRegular32, other.tertiaryUrbanistRegular32, t)!,
      tertiaryUrbanistMedium12: TextStyle.lerp(tertiaryUrbanistMedium12, other.tertiaryUrbanistMedium12, t)!,
      tertiaryUrbanistMedium14: TextStyle.lerp(tertiaryUrbanistMedium14, other.tertiaryUrbanistMedium14, t)!,
      tertiaryUrbanistMedium16: TextStyle.lerp(tertiaryUrbanistMedium16, other.tertiaryUrbanistMedium16, t)!,
      tertiaryUrbanistMedium17: TextStyle.lerp(tertiaryUrbanistMedium17, other.tertiaryUrbanistMedium17, t)!,
      tertiaryUrbanistMedium18: TextStyle.lerp(tertiaryUrbanistMedium18, other.tertiaryUrbanistMedium18, t)!,
      tertiaryUrbanistMedium20: TextStyle.lerp(tertiaryUrbanistMedium20, other.tertiaryUrbanistMedium20, t)!,
      tertiaryUrbanistMedium24: TextStyle.lerp(tertiaryUrbanistMedium24, other.tertiaryUrbanistMedium24, t)!,
      tertiaryUrbanistMedium32: TextStyle.lerp(tertiaryUrbanistMedium32, other.tertiaryUrbanistMedium32, t)!,
      tertiaryUrbanistSemiBold12: TextStyle.lerp(tertiaryUrbanistSemiBold12, other.tertiaryUrbanistSemiBold12, t)!,
      tertiaryUrbanistSemiBold14: TextStyle.lerp(tertiaryUrbanistSemiBold14, other.tertiaryUrbanistSemiBold14, t)!,
      tertiaryUrbanistSemiBold16: TextStyle.lerp(tertiaryUrbanistSemiBold16, other.tertiaryUrbanistSemiBold16, t)!,
      tertiaryUrbanistSemiBold17: TextStyle.lerp(tertiaryUrbanistSemiBold17, other.tertiaryUrbanistSemiBold17, t)!,
      tertiaryUrbanistSemiBold18: TextStyle.lerp(tertiaryUrbanistSemiBold18, other.tertiaryUrbanistSemiBold18, t)!,
      tertiaryUrbanistSemiBold20: TextStyle.lerp(tertiaryUrbanistSemiBold20, other.tertiaryUrbanistSemiBold20, t)!,
      tertiaryUrbanistSemiBold24: TextStyle.lerp(tertiaryUrbanistSemiBold24, other.tertiaryUrbanistSemiBold24, t)!,
      tertiaryUrbanistSemiBold32: TextStyle.lerp(tertiaryUrbanistSemiBold32, other.tertiaryUrbanistSemiBold32, t)!,
      tertiaryUrbanistBold12: TextStyle.lerp(tertiaryUrbanistBold12, other.tertiaryUrbanistBold12, t)!,
      tertiaryUrbanistBold14: TextStyle.lerp(tertiaryUrbanistBold14, other.tertiaryUrbanistBold14, t)!,
      tertiaryUrbanistBold16: TextStyle.lerp(tertiaryUrbanistBold16, other.tertiaryUrbanistBold16, t)!,
      tertiaryUrbanistBold17: TextStyle.lerp(tertiaryUrbanistBold17, other.tertiaryUrbanistBold17, t)!,
      tertiaryUrbanistBold18: TextStyle.lerp(tertiaryUrbanistBold18, other.tertiaryUrbanistBold18, t)!,
      tertiaryUrbanistBold20: TextStyle.lerp(tertiaryUrbanistBold20, other.tertiaryUrbanistBold20, t)!,
      tertiaryUrbanistBold24: TextStyle.lerp(tertiaryUrbanistBold24, other.tertiaryUrbanistBold24, t)!,
      tertiaryUrbanistBold32: TextStyle.lerp(tertiaryUrbanistBold32, other.tertiaryUrbanistBold32, t)!,
    );
  }
}
