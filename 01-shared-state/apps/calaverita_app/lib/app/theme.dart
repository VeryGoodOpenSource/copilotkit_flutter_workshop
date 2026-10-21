import 'package:flutter/material.dart';

/// The Día de Muertos look: marigold, magenta and a deep purple night.
ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFFFF8F00),
    secondary: const Color(0xFFC2185B),
    tertiary: const Color(0xFF4A148C),
  );
  return ThemeData(
    colorScheme: scheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.tertiary,
      foregroundColor: Colors.white,
    ),
  );
}
