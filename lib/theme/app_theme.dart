import 'package:flutter/material.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0A0A23),
  primaryColor: const Color(0xFF7A5CFF),
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF7A5CFF),
    secondary: const Color(0xFF00E7FF),
    surface: const Color(0xFF1A1A40),
    error: const Color(0xFFFF5A6A),
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFEAEAEA),
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFEAEAEA),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: const Color(0xFFEAEAEA),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: const Color(0xFFEAEAEA),
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      color: const Color(0xFFA0A0B3),
    ),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF00E7FF),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF0E0E2C).withOpacity(0.6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: const Color(0xFF7A5CFF).withOpacity(0.3),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: const Color(0xFF7A5CFF).withOpacity(0.2),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFF7A5CFF),
        width: 2,
      ),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF7A5CFF),
      foregroundColor: const Color(0xFFEAEAEA),
      elevation: 8,
      shadowColor: const Color(0xFF7A5CFF).withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF00E7FF),
      side: BorderSide(
        color: const Color(0xFF00E7FF).withOpacity(0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);
