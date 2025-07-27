import 'package:flutter/material.dart';
import 'package:softconnect/app/theme/colors/themecolor.dart';

ThemeData getApplicationTheme({bool isDarkMode = false}) {
  final themecolor = Themecolor();
  
  if (isDarkMode) {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      primarySwatch: themecolor.darkCustomSwatch,
      primaryColor: Themecolor.darkPurple,
      scaffoldBackgroundColor: Themecolor.darkBackground,
      cardColor: Themecolor.darkCard,
      fontFamily: 'Opensans Regular',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Themecolor.darkPurple,
          foregroundColor: Themecolor.white,
          textStyle: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Themecolor.darkSurface,
        foregroundColor: Themecolor.darkText,
        elevation: 4,
        shadowColor: Colors.black,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Themecolor.darkSurface,
        selectedItemColor: Themecolor.darkPurple,
        unselectedItemColor: Themecolor.darkSecondaryText,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Themecolor.darkText),
        bodyMedium: TextStyle(color: Themecolor.darkText),
        bodySmall: TextStyle(color: Themecolor.darkSecondaryText),
        headlineLarge: TextStyle(color: Themecolor.darkText),
        headlineMedium: TextStyle(color: Themecolor.darkText),
        headlineSmall: TextStyle(color: Themecolor.darkText),
        titleLarge: TextStyle(color: Themecolor.darkText),
        titleMedium: TextStyle(color: Themecolor.darkText),
        titleSmall: TextStyle(color: Themecolor.darkText),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Themecolor.darkCard,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Themecolor.darkSecondaryText),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Themecolor.darkSecondaryText),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Themecolor.darkPurple),
        ),
        labelStyle: TextStyle(color: Themecolor.darkSecondaryText),
        hintStyle: TextStyle(color: Themecolor.darkSecondaryText),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Themecolor.darkSurface,
        titleTextStyle: TextStyle(color: Themecolor.darkText, fontSize: 20, fontWeight: FontWeight.bold),
        contentTextStyle: TextStyle(color: Themecolor.darkText, fontSize: 16),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Themecolor.darkSurface,
        modalBackgroundColor: Themecolor.darkSurface,
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: themecolor.darkCustomSwatch,
        brightness: Brightness.dark,
      ).copyWith(
        primary: Themecolor.darkPurple,
        secondary: Themecolor.darkLavender,
        surface: Themecolor.darkSurface,
        background: Themecolor.darkBackground,
        onPrimary: Themecolor.white,
        onSecondary: Themecolor.white,
        onSurface: Themecolor.darkText,
        onBackground: Themecolor.darkText,
      ),
    );
  }
  
  // Light theme (existing)
  return ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    primarySwatch: themecolor.customSwatch,
    primaryColor: Themecolor.purple,
    scaffoldBackgroundColor: Themecolor.white,
    fontFamily: 'Opensans Regular',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Themecolor.purple,
        foregroundColor: Themecolor.white,
        textStyle: const TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: Themecolor.purple,
      foregroundColor: Themecolor.white,
      elevation: 4,
      shadowColor: Colors.black,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Themecolor.white,
      selectedItemColor: Themecolor.purple,
      unselectedItemColor: Themecolor.lavender,
      type: BottomNavigationBarType.fixed,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Themecolor.purple),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: themecolor.customSwatch,
      brightness: Brightness.light,
    ).copyWith(
      primary: Themecolor.purple,
      secondary: Themecolor.lavender,
      surface: Themecolor.white,
      background: Themecolor.white,
    ),
  );
}
