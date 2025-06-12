import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // Método para retornar o tema de acordo com a preferência do usuário
  static ThemeMode getThemeMode(bool isDarkModeEnabled) {
    return isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
  }
}
