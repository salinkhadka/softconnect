import 'package:flutter/material.dart';

class Themecolor {
  // Define the new theme colors
  static const Color purple = Color(0xFF37225C);
  static const Color lavender = Color(0xFFB8A6E6);
  static const Color white = Color(0xFFFFFFFF);

  MaterialColor customSwatch = const MaterialColor(
    0xFF37225C, // Primary color (PURPLE)
    <int, Color>{
      50: Color(0xFFF3F0F7),
      100: Color(0xFFE1D9ED),
      200: Color(0xFFCDC0E1),
      300: Color(0xFFB8A6E6), // LAVENDER
      400: Color(0xFFA892E0),
      500: Color(0xFF977EDA),
      600: Color(0xFF7A63C4),
      700: Color(0xFF5D4A9E),
      800: Color(0xFF4A3B7F),
      900: Color(0xFF37225C), // PURPLE
    },
  );
}
