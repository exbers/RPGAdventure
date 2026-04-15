import 'package:flutter/material.dart';

class GameTheme {
  const GameTheme._();

  static final ThemeData light = _build(
    brightness: Brightness.light,
    seedColor: const Color(0xFF1D7F4F),
    scaffoldBackground: const Color(0xFFF7F9F7),
    surfaceColor: Colors.white,
    outlineColor: const Color(0xFFCCD8D0),
  );

  static final ThemeData dark = _build(
    brightness: Brightness.dark,
    seedColor: const Color(0xFF5DE08A),
    scaffoldBackground: const Color(0xFF101413),
    surfaceColor: const Color(0xFF181D1B),
    outlineColor: const Color(0xFF34423B),
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color seedColor,
    required Color scaffoldBackground,
    required Color surfaceColor,
    required Color outlineColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: outlineColor),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.45),
      ),
    );
  }
}
