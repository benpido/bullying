import 'package:flutter/material.dart';
import 'src/admin_web/app_admin.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAdmin();
  runApp(const AdminApp());
}