import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  // Headings
  static TextStyle h1 = GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.softWhiteText,
    letterSpacing: 0.5,
  );

  static TextStyle h2 = GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.softWhiteText,
    letterSpacing: 0.3,
  );

  static TextStyle h3 = GoogleFonts.orbitron(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.softWhiteText,
  );

  // Body
  static TextStyle body1 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.softWhiteText,
    height: 1.5,
  );

  static TextStyle body2 = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedGrayText,
    height: 1.5,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedGrayText,
  );

  static TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
}
