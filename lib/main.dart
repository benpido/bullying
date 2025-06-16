// ---------------------------------------------------------------------------
// Punto de entrada de la aplicación móvil. Inicializa Firebase y determina
// si se debe mostrar la pantalla de login o continuar a la app dependiendo del
// usuario autenticado.
// ---------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'shared/services/facade_service.dart';

/// Entry point of the mobile app.
///
/// Initializes Firebase with offline persistence, loads the saved facade and
/// launches the application with the appropriate initial route depending on the
/// current authentication state.
Future<void> main() async {
  // Required to use platform channels before `runApp`.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  await FacadeService().loadSavedFacade();
  final initialRoute = FirebaseAuth.instance.currentUser == null
      ? AppRoutes.login
      : AppRoutes.currentFacade;
  runApp(MyApp(initialRoute: initialRoute));
}
