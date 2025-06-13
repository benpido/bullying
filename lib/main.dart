import 'package:flutter/material.dart';
import 'app.dart';
import 'shared/services/background_monitor_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeBackgroundService();
  runApp(const MyApp());
}
