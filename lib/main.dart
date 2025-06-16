// Entry point for the mobile application.
// Sets up Firebase and required services before launching [MyApp].
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
