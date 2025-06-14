import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import 'widgets/lock_input.dart';

class LockScreen extends StatelessWidget {
  final String nextRoute;
  const LockScreen({super.key, this.nextRoute = AppRoutes.home});

  void _onUnlockSuccess(BuildContext context) {
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removemos o AppBar aqui
      body: LockInput(onUnlock: () => _onUnlockSuccess(context)),
    );
  }
}
