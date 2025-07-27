import 'package:flutter/material.dart';
import 'package:softconnect/app/theme/colors/themecolor.dart';

ThemeData getApplicationTheme() {
  final themecolor = Themecolor();
  return ThemeData(
    useMaterial3: false,
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
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: themecolor.customSwatch,
    ).copyWith(
      primary: Themecolor.purple,
      secondary: Themecolor.lavender,
      surface: Themecolor.white,
    ),
  );
}
