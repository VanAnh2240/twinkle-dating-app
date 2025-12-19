import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // COLORS
  static const Color primaryColor = Colors.pinkAccent;
  static const Color secondaryColor = Color.fromARGB(255, 125, 166, 255);
  static const Color tertiaryColor = Color.fromARGB(255, 233, 167, 245);
  static const Color quaternaryColor = Color.fromARGB(255, 252, 114, 213);
  static const Color backgroundColor = Color.fromARGB(255, 8, 8, 8);
  static const Color textPrimaryColor = Colors.white;
  static const Color textSecondaryColor = Color.fromARGB(179, 214, 214, 214);
  static const Color textTeriaryColor = Color.fromARGB(255, 36, 36, 36);
  static const Color errorColor = Color.fromARGB(255, 235, 142, 142);
  static const Color successColor = Color.fromARGB(255, 125, 219, 172);
  static const Color borderColor = Colors.white38;

  // DARK MODE
  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      surface: backgroundColor,
      primary: primaryColor,
      secondary: const Color.fromARGB(255, 137, 174, 254),
      tertiary: tertiaryColor,
      inversePrimary: Colors.grey,
      error: const Color.fromARGB(255, 218, 52, 52),
    ),

    // TEXT THEME
    textTheme: GoogleFonts.latoTextTheme().copyWith(
      headlineLarge: GoogleFonts.lato(
          fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryColor),
      headlineMedium: GoogleFonts.lato(
          fontSize: 28, fontWeight: FontWeight.w600, color: textPrimaryColor),
      headlineSmall: GoogleFonts.lato(
          fontSize: 20, fontWeight: FontWeight.w500, color: textPrimaryColor),
      bodyLarge: GoogleFonts.lato(
          fontSize: 16, fontWeight: FontWeight.normal, color: textPrimaryColor),
      bodyMedium: GoogleFonts.lato(
          fontSize: 14, fontWeight: FontWeight.normal, color: textSecondaryColor),
      bodySmall: GoogleFonts.lato(
          fontSize: 12, fontWeight: FontWeight.normal, color: textSecondaryColor),
    ),

    // APP BAR THEME
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      iconTheme: IconThemeData(color: textPrimaryColor),
    ),

    // BUTTON THEME
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),

    // CARD THEME
    cardTheme: CardThemeData(
      surfaceTintColor: backgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: textSecondaryColor,
          width: 1,
        ),
      ),
    ),


    // INPUT THEME
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white10,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
    ),

    // FAB THEME
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: textPrimaryColor,
      elevation: 0,
    ),
  );
}
