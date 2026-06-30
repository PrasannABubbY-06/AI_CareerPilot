import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ValueNotifier<ThemeMode> {
  // Singleton Pattern
  static final ThemeService _instance = ThemeService._internal();

  factory ThemeService() {
    return _instance;
  }

  ThemeService._internal() : super(ThemeMode.dark);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode');
    
    if (savedTheme == 'light') {
      value = ThemeMode.light;
    } else {
      value = ThemeMode.dark;
    }
  }

  Future<void> toggleTheme() async {
    final newMode = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    value = newMode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', newMode == ThemeMode.light ? 'light' : 'dark');
  }

  bool get isDarkMode => value == ThemeMode.dark;
}
