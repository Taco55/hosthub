import 'package:flutter/material.dart';

const TextTheme organizeTextTheme = TextTheme(
  displayLarge: TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 36,
    height: 1,
    letterSpacing: -0.96, // = -2%
  ),
  titleMedium: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.2,
    letterSpacing: 0,
  ),
  labelSmall: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    letterSpacing: 0,
    height: 1,
  ),
  bodySmall: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    letterSpacing: 0,
    height: 1,
  ),
  bodyMedium: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0,
    height: 1.2,
  ),
  bodyLarge: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18,
    letterSpacing: 0,
    height: 1.2,
  ),
);

extension CustomTextTheme on TextTheme {
  TextStyle get linkMedium => const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    letterSpacing: 14 * -0.02,
    decoration: TextDecoration.underline,
  );

  TextStyle get buttonExtraSmall => const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
    letterSpacing: 0,
  );

  TextStyle get buttonSmall => const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 14,
    letterSpacing: 0,
  );

  TextStyle get buttonMedium => const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    letterSpacing: 0,
  );

  TextStyle get bodyExtraLarge => const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18,
    height: 1.2,
    letterSpacing: 0,
  );

  TextStyle get h0 => const TextStyle(
    // fontFamily: 'EBGaramond',
    fontWeight: FontWeight.w600,
    fontSize: 48,
    height: 1,
    letterSpacing: 48 * -0.02,
    fontStyle: FontStyle.italic,
  );

  TextStyle get h1 => const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 36,
    height: 1,
    letterSpacing: -0.96, // = -2%
  );

  TextStyle get h2 => const TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 1,
    letterSpacing: -0.96, // = -2%
  );

  TextStyle get h3 => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.24, // -1%
    height: 1,
  );

  TextStyle get h4 => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.18, // -1%
    height: 1.1,
  );

  TextStyle get h5 => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.1,
  );

  TextStyle get h6 => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.1,
  );
}
