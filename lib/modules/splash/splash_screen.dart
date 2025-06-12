// lib/modules/splash/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import './widgets/splash_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      // Verifica se o widget ainda está montado antes de chamar o Navigator
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    });

    return const Scaffold(body: Center(child: SplashLogo()));
  }
}
