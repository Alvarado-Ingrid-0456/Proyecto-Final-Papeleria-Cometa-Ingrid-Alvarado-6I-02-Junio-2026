import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  // Toggles the theme between light and dark
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify listeners of the change
  }

  // Sets the theme to system default
  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}
