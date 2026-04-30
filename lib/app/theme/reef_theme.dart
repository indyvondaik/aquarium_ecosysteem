import 'package:flutter/material.dart';

class ReefColors {
  const ReefColors._();

  static const paper = Color(0xFFFFFEFA);
  static const ink = Color(0xFF11284C);
  static const navy = Color(0xFF1F3E68);
  static const deepSea = Color(0xFF0E3557);
  static const lagoon = Color(0xFF287C8E);
  static const water = Color(0xFF67C7D2);
  static const purple = Color(0xFF67507F);
  static const coral = Color(0xFFC75142);
  static const softCoral = Color(0xFFFF8C73);
  static const reefGold = Color(0xFFF6D44A);
  static const sand = Color(0xFFF2D69B);
  static const algae = Color(0xFF88A64D);
  static const brightAlgae = Color(0xFFB8D85B);
  static const seaFoam = Color(0xFFDDEBE6);
  static const line = Color(0xFF111111);
}

class ReefTypography {
  const ReefTypography._();

  static const displayFamily = 'Impact';
  static const labelFamily = 'Arial Black';

  static TextStyle display({double size = 64, Color color = ReefColors.ink}) {
    return TextStyle(
      color: color,
      fontFamily: displayFamily,
      fontFamilyFallback: const ['Arial Black', 'Roboto'],
      fontSize: size,
      fontWeight: FontWeight.w900,
      height: 0.9,
      letterSpacing: 0,
    );
  }

  static TextStyle condensed({double size = 22, Color color = ReefColors.ink}) {
    return TextStyle(
      color: color,
      fontFamily: labelFamily,
      fontFamilyFallback: const ['Roboto Condensed', 'Roboto'],
      fontSize: size,
      fontWeight: FontWeight.w900,
      height: 1,
      letterSpacing: 0,
    );
  }
}

class ReefTheme {
  const ReefTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ReefColors.navy,
      brightness: Brightness.light,
      surface: ReefColors.paper,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: ReefColors.navy,
        secondary: ReefColors.purple,
        tertiary: ReefColors.reefGold,
        surface: ReefColors.paper,
      ),
      scaffoldBackgroundColor: ReefColors.paper,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: ReefColors.ink,
          fontSize: 16,
          height: 1.35,
          letterSpacing: 0,
        ),
      ),
      iconTheme: const IconThemeData(color: ReefColors.ink),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: ReefTypography.condensed(size: 16),
          minimumSize: const Size(64, 52),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: ReefTypography.condensed(size: 16),
          minimumSize: const Size(64, 52),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          minimumSize: const Size(48, 48),
        ),
      ),
    );
  }
}
