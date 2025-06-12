// lib/core/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../../modules/splash/splash_screen.dart';
import '../../modules/home/home_screen.dart';
import '../../modules/emergency/emergency_screen.dart';
import '../../modules/auth/lock_screen.dart';

// Fachadas (máscaras)
import '../../modules/facades/calendar_screen.dart';
import '../../modules/facades/calculator_screen.dart';
import '../../modules/facades/notes_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String emergency = '/emergency';
  static const String config = '/config';
  static const String lock = '/lock';

  // Fachadas
  static const String calendar = '/facade/calendar';
  static const String calculator = '/facade/calculator';
  static const String notes = '/facade/notes';

  static String currentFacade = home;

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    home: (_) => const HomeScreen(),
    emergency: (_) => const EmergencyScreen(),
    //config: (_) => ConfigScreen(),
    lock: (_) => const LockScreen(),

    // Rutas de fachadas
    calendar: (_) => const CalendarScreen(),
    calculator: (_) => const CalculatorScreen(),
    notes: (_) => const NotesScreen(),
  };
  // Cuando se carga la app, usa la fachada actual
  static Widget getCurrentFacade() {
    switch (currentFacade) {
      case calendar:
        return const CalendarScreen();
      case calculator:
        return const CalculatorScreen();
      case notes:
        return const NotesScreen();
      default:
        return const HomeScreen(); // O cualquier pantalla predeterminada
    }
  }
}
