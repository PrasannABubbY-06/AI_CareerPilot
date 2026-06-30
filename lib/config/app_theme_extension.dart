import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final LinearGradient primaryGradient;
  final LinearGradient accentGradient;
  final LinearGradient cardGradient;
  final LinearGradient glassGradient;
  final Color success;
  final Color warning;
  final Color error;
  final Color glassBg;
  final Color textLight;
  final Color border;
  final Color borderLight;

  const AppThemeExtension({
    required this.primaryGradient,
    required this.accentGradient,
    required this.cardGradient,
    required this.glassGradient,
    required this.success,
    required this.warning,
    required this.error,
    required this.glassBg,
    required this.textLight,
    required this.border,
    required this.borderLight,
  });

  @override
  AppThemeExtension copyWith({
    LinearGradient? primaryGradient,
    LinearGradient? accentGradient,
    LinearGradient? cardGradient,
    LinearGradient? glassGradient,
    Color? success,
    Color? warning,
    Color? error,
    Color? glassBg,
    Color? textLight,
    Color? border,
    Color? borderLight,
  }) {
    return AppThemeExtension(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      accentGradient: accentGradient ?? this.accentGradient,
      cardGradient: cardGradient ?? this.cardGradient,
      glassGradient: glassGradient ?? this.glassGradient,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      glassBg: glassBg ?? this.glassBg,
      textLight: textLight ?? this.textLight,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      accentGradient: LinearGradient.lerp(accentGradient, other.accentGradient, t)!,
      cardGradient: LinearGradient.lerp(cardGradient, other.cardGradient, t)!,
      glassGradient: LinearGradient.lerp(glassGradient, other.glassGradient, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      glassBg: Color.lerp(glassBg, other.glassBg, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
    );
  }
}
