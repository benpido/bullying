import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import 'widgets/lock_input.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  void _onUnlockSuccess(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removemos o AppBar aqui
      body: LockInput(onUnlock: () => _onUnlockSuccess(context)),
    );
  }
}
