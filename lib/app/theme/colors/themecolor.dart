import 'package:flutter/material.dart';

class Themecolor {
  // Light theme colors
  static const Color purple = Color(0xFF37225C);
  static const Color lavender = Color(0xFFB8A6E6);
  static const Color white = Color(0xFFFFFFFF);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2D2D2D);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkSecondaryText = Color(0xFFB0B0B0);
  static const Color darkPurple = Color(0xFF6B46C1);
  static const Color darkLavender = Color(0xFF9F7AEA);

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

  MaterialColor darkCustomSwatch = const MaterialColor(
    0xFF6B46C1, // Dark Primary color
    <int, Color>{
      50: Color(0xFF1A1625),
      100: Color(0xFF2D2438),
      200: Color(0xFF40324B),
      300: Color(0xFF53405E),
      400: Color(0xFF664E71),
      500: Color(0xFF795C84),
      600: Color(0xFF8C6A97),
      700: Color(0xFF9F7AEA),
      800: Color(0xFFB288BD),
      900: Color(0xFFC596D0),
    },
  );
}
