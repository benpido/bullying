/// Pantalla de login principal.
///
/// Autentica con Firebase, sincroniza contactos y navega según la
/// configuración del usuario.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/routes/app_routes.dart';
import '../../shared/models/contact_model.dart';
import '../../shared/services/contact_service.dart';
import '../../shared/services/background_monitor_service.dart';
import '../../shared/services/permission_service.dart';

/// Widget que muestra el formulario de autenticación y maneja el proceso de
/// inicio de sesión.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _contactService = ContactService();

  String? _errorMessage;

  /// Intenta cargar el documento de usuario del servidor con reintentos
  /// exponenciales y finalmente recurre al caché local si falla la conexión.
  Future<DocumentSnapshot<Map<String, dynamic>>?> _loadUserDocument(
    String uid,
  ) async {
    const maxRetries = 3;
    var delay = const Duration(seconds: 1);

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await _firestore
            .collection('users')
            .doc(uid)
            .get(const GetOptions(source: Source.server));
      } on FirebaseException catch (e) {
        if (e.code != 'unavailable') rethrow;
      }
      await Future.delayed(delay);
      delay *= 2;
    }

    try {
      return await _firestore
          .collection('users')
          .doc(uid)
          .get(const GetOptions(source: Source.cache));
    } on FirebaseException {
      return null;
    }
  }

  /// Sincroniza el contacto del admin localmente (actualiza o agrega).
  Future<void> _syncAdminContact(Map<String, dynamic> data) async {
    final name = data['adminName'] as String?;
    final phone = data['adminPhone'] as String?;
    if (name == null || phone == null) return;

    final contacts = await _contactService.getContacts();
    final admin = ContactModel(name: name, phoneNumber: phone);
    final index = contacts.indexWhere((c) => c.phoneNumber == phone);
    if (index >= 0) {
      contacts[index] = admin;
    } else {
      contacts.add(admin);
    }
    await _contactService.setContacts(contacts);
  }

  /// Maneja el proceso de login y navegación según estado de configuración.
  Future<void> _login() async {
    setState(() => _errorMessage = null);

    try {
      // 1. Autenticación con email y contraseña
      final cred = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final uid = cred.user!.uid;

      // 2. Obtener datos de usuario con reintentos y fallback al caché
      final doc = await _loadUserDocument(uid);
      if (doc == null) {
        await _auth.signOut();
        setState(
          () => _errorMessage = 'Sin conexión y sin datos locales.',
        );
        return;
      }
      final data = doc.data();

      // Validar existencia, admin asignado y cuenta habilitada
      if (!doc.exists ||
          data?['adminId'] == null ||
          data?['disabled'] == true) {
        await _auth.signOut();
        setState(() => _errorMessage = 'Cuenta deshabilitada o sin admin.');
        return;
      }

      // 3. Sincronizar contactos y servicios de fondo
      await _contactService.syncFromBackend(uid);
      await _syncAdminContact(data!);
      await initializeBackgroundService();
      await PermissionService().requestIfNeeded();

      // 4. Decidir ruta según configuración local (contactos y PIN)
      final contacts = await _contactService.getContacts();
      final prefs = await SharedPreferences.getInstance();
      final pin = prefs.getString('configPin') ?? '';

      if (!mounted) return;
      if (pin.isEmpty) {
        Navigator.pushReplacementNamed(context, AppRoutes.pinSetup);
        return;
      }

      final nextRoute = contacts.isEmpty
          ? AppRoutes.config
          : AppRoutes.currentFacade;
      Navigator.pushReplacementNamed(context, nextRoute);
    } on FirebaseException catch (e) {
      await _auth.signOut();
      // Manejo de errores específicos de Firebase
      if (e.code == 'unavailable') {
        setState(
          () => _errorMessage = 'Sin conexión al servidor. Intenta luego.',
        );
      } else {
        setState(() => _errorMessage = e.message ?? 'Error al iniciar sesión.');
      }
    } catch (e) {
      await _auth.signOut();
      // Errores genéricos
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
