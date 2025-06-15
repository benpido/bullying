import 'package:flutter/material.dart';
import 'app.dart';
import 'shared/services/background_monitor_service.dart';
import 'shared/services/permission_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeBackgroundService();
  await PermissionService().requestIfNeeded();
  runApp(const MyApp());
}
