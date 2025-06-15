import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/dashboard': (_) => const DashboardPage(),
      },
    );
  }
}

Future<void> initializeAdmin() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Keep admin sessions across browser reloads
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
}