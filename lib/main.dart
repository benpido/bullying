// ---------------------------------------------------------------------------
// Punto de entrada de la aplicación móvil. Inicializa Firebase y determina
// si se debe mostrar la pantalla de login o continuar a la app dependiendo del
// usuario autenticado.
// ---------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/routes/app_routes.dart';

Future<void> main() async {
  // Required to use platform channels before `runApp`.
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final initialRoute =
      FirebaseAuth.instance.currentUser == null ? AppRoutes.login : AppRoutes.splash;
  runApp(MyApp(initialRoute: initialRoute));
}
