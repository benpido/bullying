import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/services/contact_service.dart';
import '../../shared/models/contact_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/services/background_monitor_service.dart';
import '../../shared/services/permission_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _error;
  final ContactService _contactService = ContactService();

  Future<void> _updateAdminContact(Map<String, dynamic>? data) async {
    final adminName = data?['adminName'];
    final adminPhone = data?['adminPhone'];
    if (adminName is String && adminPhone is String) {
      final contacts = await _contactService.getContacts();
      final adminContact = ContactModel(
        name: adminName,
        phoneNumber: adminPhone,
      );
      final index = contacts.indexWhere((c) => c.phoneNumber == adminPhone);
      if (index >= 0) {
        contacts[index] = adminContact;
      } else {
        contacts.add(adminContact);
      }
      await _contactService.setContacts(contacts);
    }
  }

  Future<void> _login() async {
    setState(() => _error = null);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );

      final uid = cred.user!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data();
      final hasAdmin = data?['adminId'] != null;
      final disabled = data?['disabled'] == true;
      if (!doc.exists || !hasAdmin || disabled) {
        await FirebaseAuth.instance.signOut();
        setState(() => _error = 'Cuenta deshabilitada');
        return;
      }
      await _updateAdminContact(data);
      await initializeBackgroundService();
      await PermissionService().requestIfNeeded();
      final contacts = await _contactService.getContacts();
      final prefs = await SharedPreferences.getInstance();
      final pin = prefs.getString('configPin');
      if (!mounted) return;
      if (contacts.isEmpty || pin == null || pin.isEmpty) {
        Navigator.pushReplacementNamed(context, AppRoutes.config);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.splash);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}