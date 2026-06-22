import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xff0B1020),

    primaryColor: const Color(0xff5D8CFF),

    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff0B1020),
      elevation: 0,
    ),

    cardColor: const Color(0xff151922),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xff5D8CFF),
    ),
  );
}