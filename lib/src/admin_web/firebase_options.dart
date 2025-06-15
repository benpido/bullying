import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'SENDER_ID',
      projectId: 'YOUR_PROJECT_ID',
      authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
      storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    );
  }
}