// lib/core/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../../modules/splash/splash_screen.dart';
import '../../modules/emergency/emergency_screen.dart';
import '../../modules/auth/lock_screen.dart';
import '../../modules/auth/login_screen.dart';
import '../../modules/auth/pin_setup_screen.dart';
import '../../modules/facades/calendar_screen.dart';
import '../../modules/facades/calculator_screen.dart';
import '../../modules/facades/notes_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String login = '/login';
  static const String emergency = '/emergency';
  static const String config = '/config';
  static const String lock = '/lock';
  static const String pinSetup = '/setup-pin';

  // Fachadas
  static const String calendar = '/facade/calendar';
  static const String calculator = '/facade/calculator';
  static const String notes = '/facade/notes';

  static String currentFacade = home;

  static final Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    pinSetup: (_) => const PinSetupScreen(),
    
    emergency: (_) => const EmergencyScreen(),
    //config: (_) => ConfigScreen(),
    lock: (context) {
      final next =
          ModalRoute.of(context)?.settings.arguments as String? ?? home;
      return LockScreen(nextRoute: next);
    },

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
        return const SizedBox.shrink(); // Placeholder when no facade selected
    }
  }
}
