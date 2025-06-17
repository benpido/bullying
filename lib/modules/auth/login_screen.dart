/// Pantalla de login principal.
///
/// Autentica con Firebase, sincroniza contactos y navega según la
/// configuración del usuario.
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/user_service.dart';
import '../../shared/services/admin_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/routes/app_routes.dart';
import '../../shared/services/contact_service.dart';
import '../../shared/models/contact_model.dart';
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
  final _authService = AuthService();
  final _userService = UserService();
  final _contactService = ContactService();
  final _adminService = AdminService();

  String? _errorMessage;


  /// Maneja el proceso de login y navegación según estado de configuración.
  Future<void> _login() async {
    setState(() => _errorMessage = null);

    try {
      // 1. Autenticación con email y contraseña
      final cred = await _authService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      final uid = cred.user!.uid;

      // 2. Obtener datos de usuario con reintentos y fallback al caché
      final doc = await _userService.loadUserDocument(uid);
      if (doc == null) {
        await _authService.signOut();
        setState(
          () => _errorMessage = 'Sin conexión y sin datos locales.',
        );
        return;
      }

      final data = doc.data();

      // Sincronizar solo el contacto del administrador cuando los datos
      // del usuario estén disponibles.
      if (data != null) {
        await _userService.syncAdminContact(data);
      }

      // 2b. Cargar la información de contacto del administrador
      final adminInfo = await _adminService.loadContactInfo(uid);
      if (adminInfo != null) {
        await _adminService.saveContactInfo(adminInfo);

        final name = adminInfo['name'] as String?;
        final phone = adminInfo['phone'] as String?;
        if (name != null && phone != null) {
          final contacts = await _contactService.getContacts();
          final admin = ContactModel(name: name, phoneNumber: phone);
          final index =
              contacts.indexWhere((c) => c.phoneNumber == admin.phoneNumber);
          if (index >= 0) {
            contacts[index] = admin;
          } else {
            contacts.add(admin);
          }
          await _contactService.setContacts(contacts);
        }
      }

      // 3. Iniciar servicios de fondo
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
      await _authService.signOut();
      // Manejo de errores específicos de Firebase
      if (e.code == 'unavailable') {
        setState(
          () => _errorMessage = 'Sin conexión al servidor. Intenta luego.',
        );
      } else {
        setState(() => _errorMessage = e.message ?? 'Error al iniciar sesión.');
      }
    } catch (e) {
      await _authService.signOut();
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
