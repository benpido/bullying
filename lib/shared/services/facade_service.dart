// lib/shared/services/facade_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes/app_routes.dart';

import 'package:flutter/services.dart';
class FacadeService {
  static const _key = 'selectedFacade';
  static const MethodChannel _channel = MethodChannel('bullying/icon');

  Future<void> setFacade(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, route);
    AppRoutes.currentFacade = route;
    await _updateIcon(route);
  }

  String getCurrentFacade() {
    return AppRoutes.currentFacade;
  }

  Future<void> loadSavedFacade() async {
    final prefs = await SharedPreferences.getInstance();
    AppRoutes.currentFacade = prefs.getString(_key) ?? AppRoutes.home;
     await _updateIcon(AppRoutes.currentFacade);
  }

  Future<void> _updateIcon(String route) async {
    String alias;
    switch (route) {
      case AppRoutes.calendar:
        alias = 'CalendarIcon';
        break;
      case AppRoutes.calculator:
        alias = 'CalculatorIcon';
        break;
      case AppRoutes.notes:
        alias = 'NotesIcon';
        break;
      default:
        alias = 'FinanceIcon';
    }
    try {
      await _channel.invokeMethod('changeIcon', {'alias': alias});
    } on PlatformException {
      // If the platform call fails, ignore for now
    }
  }
}
