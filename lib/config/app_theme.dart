import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'app_theme_extension.dart';

class AppTheme {
  // ================= DARK THEME (Current Premium AI_CareerPilot Look) =================
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.scaffoldBg,
    primaryColor: AppColors.primary,
    cardColor: AppColors.cardBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.cardBg,
      error: AppColors.error,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    dividerColor: Colors.white12,
    fontFamily: GoogleFonts.poppins().fontFamily,
    extensions: <ThemeExtension<dynamic>>[
      const AppThemeExtension(
        primaryGradient: AppColors.primaryGradient,
        accentGradient: AppColors.accentGradient,
        cardGradient: AppColors.darkCardGradient,
        glassGradient: AppColors.glassGradient,
        success: AppColors.success,
        warning: AppColors.warning,
        error: AppColors.error,
        glassBg: AppColors.glassBg,
        textLight: AppColors.textLight,
        border: AppColors.border,
        borderLight: AppColors.borderLight,
      ),
    ],
  );

  // ================= LIGHT THEME =================
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
    primaryColor: AppColors.primary,
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF0F172A)),
      titleTextStyle: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 20),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF0F172A)), // Slate 900
      bodyMedium: TextStyle(color: Color(0xFF475569)), // Slate 600
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Colors.white,
      error: AppColors.error,
    ),
    iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
    dividerColor: Colors.black12,
    fontFamily: GoogleFonts.poppins().fontFamily,
    extensions: <ThemeExtension<dynamic>>[
      const AppThemeExtension(
        primaryGradient: AppColors.primaryGradient,
        accentGradient: AppColors.accentGradient,
        cardGradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF1F5F9)], // Slate 100
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        glassGradient: LinearGradient(
          colors: [Color(0xCCFFFFFF), Color(0x99FFFFFF)], // Whitish translucent
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        success: AppColors.success,
        warning: AppColors.warning,
        error: AppColors.error,
        glassBg: Color(0x66FFFFFF),
        textLight: Color(0xFF94A3B8),
        border: Colors.black12,
        borderLight: Colors.black12,
      ),
    ],
  );
}
