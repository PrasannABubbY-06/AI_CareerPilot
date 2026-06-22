import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Futuristic Primary / Accent Gradients
  static const Color primary = Color(0xFF5D8CFF); // Electric Blue
  static const Color secondary = Color(0xFF7B61FF); // Cyber Purple
  static const Color accentCyan = Color(0xFF06B6D4); // Cyber Cyan
  static const Color accentPink = Color(0xFFEC4899); // Neon Pink

  // Backgrounds (Deep Space Palette)
  static const Color scaffoldBg = Color(0xFF070B19);
  static const Color cardBg = Color(0xFF0F162A);
  static const Color glassBg = Color(0x0CFFFFFF); // Translucent glass fill

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textLight = Color(0xFF64748B); // Slate 500

  // Status (Vibrant Glowing states)
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber Warning
  static const Color error = Color(0xFFEF4444); // Rose Red

  // Borders & Dividers
  static const Color border = Color(0x1AFFFFFF); // Translucent border
  static const Color borderLight = Color(0x0DFFFFFF); // Extremely thin border

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentCyan, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF131B31), Color(0xFF090E1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}