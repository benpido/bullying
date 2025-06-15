import 'package:flutter/material.dart';
import 'src/admin_web/app_admin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'src/admin_web/app_admin.dart' show initializeAdmin;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAdmin();
  runApp(const AdminApp());
}