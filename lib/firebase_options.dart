import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  // Evita instanciación
  DefaultFirebaseOptions._();

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCzpXEsuNxbNoywgoGfUOoYdWQbVp913t0',
    appId: '1:337818312485:web:4feb1446f3bd89241884cc',
    messagingSenderId: '337818312485',
    projectId: 'bullying-88362',
    authDomain: 'bullying-88362.firebaseapp.com',
    storageBucket: 'bullying-88362.firebasestorage.app',
    measurementId: 'G-K05WSRLXP3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAh6vfIDT06_H_b9WHUHWF1NhK2xxscQEI',
    appId: '1:337818312485:android:0073f50a1b6b23cd1884cc',
    messagingSenderId: '337818312485',
    projectId: 'bullying-88362',
    storageBucket: 'bullying-88362.firebasestorage.app',
  );

  /// Devuelve las opciones correctas para la plataforma actual.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }

    // Para cualquier otra plataforma unsupported:
    throw UnsupportedError(
      'DefaultFirebaseOptions no está configurado para '
      '$defaultTargetPlatform. Ejecuta FlutterFire CLI de nuevo.',
    );
  }
}
