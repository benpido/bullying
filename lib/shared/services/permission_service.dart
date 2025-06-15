import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static const _key = 'permissions_requested';

  Future<void> requestIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_key) == true) return;

    await [
      Permission.notification,
      Permission.microphone,
      Permission.location,
    ].request();

    await prefs.setBool(_key, true);
  }
}