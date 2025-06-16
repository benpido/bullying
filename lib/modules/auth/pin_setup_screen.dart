import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes/app_routes.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _pinController = TextEditingController();
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El PIN debe tener 4 d\u00edgitos')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('configPin', pin);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'PIN de 4 d\u00edgitos',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _savePin,
              child: const Text('Guardar PIN'),
            ),
          ],
        ),
      ),
    );
  }
}