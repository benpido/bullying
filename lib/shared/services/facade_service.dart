// lib/shared/services/facade_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes/app_routes.dart';

class FacadeService {
  static const _key = 'selectedFacade';

  Future<void> setFacade(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, route);
    AppRoutes.currentFacade = route;
  }

  String getCurrentFacade() {
    return AppRoutes.currentFacade;
  }

  Future<void> loadSavedFacade() async {
    final prefs = await SharedPreferences.getInstance();
    AppRoutes.currentFacade = prefs.getString(_key) ?? AppRoutes.home;
  }
}
